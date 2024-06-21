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
    private var lat = Double()
    private var Ing = Double()
    var pendingError: SPRError?
    
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
        guard let peripheral = locker.peripheral else { return failure(SPRError.CBPeripheralNotFound) }
        
        // １回目のリトライはHTTPに行く
        if retryNum == 1 {
//            pendingError = error
            // connectWithRetryに進んでいる = scanが成功している　→そのためisScannedは不要なのでは？
            sprLockerService.getLocker(
                token: token,
                spacerId: spacerId,
                success: { spacer in
                    if spacer.isHttpSupported {
                        // 位置情報の使用許可を要求
                        self.locationManager.requestWhenInUseAuthorization()
                        // アプリの使用中に位置情報サービスを使用する許可をリクエストする
                        self.locationManager.requestLocation()
                    }
                },
                failure: { error in self.failure(error) }
            )
            
            if isHttpSupported {
                // 位置情報の使用許可を要求
                locationManager.requestWhenInUseAuthorization()
                // アプリの使用中に位置情報サービスを使用する許可をリクエストする
                locationManager.requestLocation()
                
//                httpLockerService.put(
//                    token: token,
//                    spacerId: spacerId,
//                    lat: lat,
//                    Ing: Ing,
//                    success: success,
//                    failure: { error in self.failure(error) }
//                )
            }
        }
        
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

    // 検出失敗時の処理？
    func failureIfNotCanceled(_ error: SPRError) {
        centralService?.stopScan()
        pendingError = error
        // readAPI
        sprLockerService.getLocker(
            token: token,
            spacerId: spacerId,
            success: { spacer in
                if spacer.isHttpSupported {
                    // 位置情報の使用許可を要求
                    self.locationManager.requestWhenInUseAuthorization()
                    // アプリの使用中に位置情報サービスを使用する許可をリクエストする
                    self.locationManager.requestLocation()
                }
            },
            failure: { error in self.failure(error) }
        )

//        if !isCanceled {
//            isCanceled = true
//            failure(error)
//        }
    }
}

extension CBLockerCentralConnectService: CLLocationManagerDelegate {
    // 位置情報が更新されたときに呼ばれるデリゲートメソッド
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            print("Latitude: \(latitude), Longitude: \(longitude)")
                
            // 必要に応じて、位置情報の更新を停止
            locationManager.stopUpdatingLocation()
                
            // HTTPでの施錠
            httpLockerService.put(
                token: token,
                spacerId: spacerId,
                lat: lat,
                Ing: Ing,
                success: success,
                failure: { error in self.failure(error) }
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
        if let pendingError = pendingError{
            failure(pendingError)
        }
    }
}
