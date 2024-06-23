//
//  CBLockerCentralConnectService.swift
//
//
//  Created by Takehito Soi on 2021/06/23.
//

import CoreBluetooth
import Foundation
import CoreLocation


class CBLockerCentralConnectService: NSObject {
    private var token: String!
    private var spacerId: String!
    private var type: CBLockerActionType!
    private var connectable: (CBLockerModel) -> Void = { _ in }
    private var success: () -> Void = {}
    private var readSuccess: (String) -> Void = { _ in }
    private var failure: (SPRError) -> Void = { _ in }
    
    private let sprLockerService = SPR.sprLockerService()
    private let httpLockerService = HttpLockerService()
    private var isHttpSupported = false
    private var centralService: CBLockerCentralService?
    private var isCanceled = false
    private var locationManager = CLLocationManager()
    var sprError: SPRError?
    
    override init() {
        super.init()
        self.centralService = CBLockerCentralService(delegate: self)
        locationManager.delegate = self
        // アプリの使用中に位置情報サービスを使用する許可をリクエストする
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func scan() {
        centralService?.startScan()
    }
    
    func put(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.token = token
        self.spacerId = spacerId
        self.type = .put
        self.connectable = { locker in self.connectWithRetry(locker: locker) }
        self.success = success
        self.failure = failure

        scan()
    }
    
    func take(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.token = token
        self.spacerId = spacerId
        self.type = .take
        self.connectable = { locker in self.connectWithRetry(locker: locker) }
        self.success = success
        self.failure = failure

        scan()
    }
    
    func openForMaintenance(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.token = token
        self.spacerId = spacerId
        self.type = .openForMaintenance
        self.connectable = { locker in self.connectWithRetry(locker: locker) }
        self.success = success
        self.failure = failure

        scan()
    }
    
    func read(spacerId: String, success: @escaping (String) -> Void, failure: @escaping (SPRError) -> Void) {
        self.spacerId = spacerId
        self.type = .read
        self.connectable = { locker in self.connectWithRetryByRead(locker: locker) }
        self.readSuccess = success
        self.failure = failure

        scan()
    }

    private func connectWithRetry(locker: CBLockerModel, retryNum: Int = 0) {
        // １回目のリトライ時のみHTTP接続を試みる　// connectWithRetryに進んでいる = scanが成功している　→そのためisScannedは不要なのでは？
        if retryNum == 1 {
            getLocker()
            // HTTP通信対応ロッカーの場合、下のBLE通信の処理に行かせない
            if isHttpSupported {
                return
            }
        }
        
        guard let peripheral = locker.peripheral else { return failure(SPRError.CBPeripheralNotFound) }
        let peripheralDelegate =
            CBLockerPeripheralService.Factory.create(
                type: type, token: token, locker: locker, isRetry: retryNum > 0, success: {
                    self.success()
                    self.disconnect(locker: locker)
                },
                failure: { error in
                    self.retryOrFailure(
                        error: error,
                        locker: locker,
                        retryNum: retryNum + 1,
                        executable: { self.connectWithRetry(locker: locker, retryNum: retryNum + 1) }
                    )
                }
            )

        guard let delegate = peripheralDelegate else { return failure(SPRError.CBConnectingFailed) }

        locker.peripheral?.delegate = delegate
        delegate.startConnectingAndDiscoveringServices()
        centralService?.connect(peripheral: peripheral)
    }
    
    private func connectWithRetryByRead(locker: CBLockerModel, retryNum: Int = 0) {
        guard let peripheral = locker.peripheral else { return failure(SPRError.CBPeripheralNotFound) }
        let peripheralDelegate =
            CBLockerPeripheralReadService(
                locker: locker, success: { readData in
                    self.readSuccess(readData)
                    self.disconnect(locker: locker)
                },
                failure: { error in
                    self.retryOrFailure(
                        error: error,
                        locker: locker,
                        retryNum: retryNum + 1,
                        executable: { self.connectWithRetryByRead(locker: locker, retryNum: retryNum + 1) }
                    )
                }
            )

        let delegate = peripheralDelegate

        locker.peripheral?.delegate = delegate
        delegate.startConnectingAndDiscoveringServices()
        centralService?.connect(peripheral: peripheral)
    }
    
    private func getLocker(error: SPRError? = nil, isDiscoverFailed: Bool = false) {
        sprLockerService.getLocker(
            token: token,
            spacerId: spacerId,
            success: { spacer in
                if spacer.isHttpSupported {
                    // 位置情報の使用許可を要求
                    self.locationManager.requestWhenInUseAuthorization()
                    // アプリの使用中に位置情報サービスを使用する許可をリクエストする
                    self.locationManager.requestLocation()
                } else if isDiscoverFailed,!self.isCanceled {
                    if let error = error {
                        self.isCanceled = true
                        self.failure(error)
                    }
                }
            },
            failure: { error in self.failure(error) }
        )
    }
    
    private func retryOrFailure(error: SPRError, locker: CBLockerModel, retryNum: Int, executable: @escaping () -> Void) {
        if retryNum < CBLockerConst.MaxRetryNum {
            executable()
        } else {
            failure(error)
            disconnect(locker: locker)
        }
    }
    
    private func disconnect(locker: CBLockerModel) {
        guard let peripheral = locker.peripheral else { return failure(SPRError.CBPeripheralNotFound) }
        centralService?.disconnect(peripheral: peripheral)
    }
}

extension CBLockerCentralConnectService: CBLockerCentralDelegate {
    func execAfterDiscovered(locker: CBLockerModel) {
        if locker.id == spacerId {
            centralService?.stopScan()
            successIfNotCanceled(locker: locker)
        }
    }
    
    func execAfterScanning(lockers: [CBLockerModel]) -> Bool {
        return centralService?.isScanning == false
    }
    
    func successIfNotCanceled(locker: CBLockerModel) {
        centralService?.stopScan()

        if !isCanceled {
            isCanceled = true
            connectable(locker)
        }
    }

    // 最終的にコネクトできなかった場合
    func failureIfNotCanceled(_ error: SPRError) {
        centralService?.stopScan()
        sprError = error
        getLocker(error: error, isDiscoverFailed: true)
    }
}

extension CBLockerCentralConnectService: CLLocationManagerDelegate {
    // 位置情報が更新されたとき
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
                
            // 位置情報の更新を停止
            locationManager.stopUpdatingLocation()
            
            if type == .put {
                httpLockerService.put(
                    token: token,
                    spacerId: spacerId,
                    lat: lat,
                    lng: lng,
                    success: success,
                    failure: { error in self.failure(error) }
                )
            } else if type == .take {
                httpLockerService.take(
                    token: token,
                    spacerId: spacerId,
                    lat: lat,
                    lng: lng,
                    success: success,
                    failure: { error in self.failure(error) }
                )
            } else if type == .openForMaintenance {
                httpLockerService.openForMaintenance(
                    token: token,
                    spacerId: spacerId,
                    lat: lat,
                    lng: lng,
                    success: success,
                    failure: { error in self.failure(error) }
                )
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError: \(error)")
        if let sprError = sprError {
            failure(sprError)
        }
    }
}
