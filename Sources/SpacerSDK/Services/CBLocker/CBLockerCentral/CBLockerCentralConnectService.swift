//
//  CBLockerCentralConnectService.swift
//
//
//  Created by Takehito Soi on 2021/06/23.
//

import CoreBluetooth
import CoreLocation
import Foundation
import UIKit

class CBLockerCentralConnectService: NSObject {
    private var token: String!
    private var spacerId: String!
    private var type: CBLockerActionType!
    private var connectable: (CBLockerModel) -> Void = { _ in }
    private var success: () -> Void = {}
    private var readSuccess: (String) -> Void = { _ in }
    private var failure: (SPRError) -> Void = { _ in }
    private var sprError: SPRError?
    private var checkHttpAvailableCallBack: () -> Void = {}
    
    private let sprLockerService = SPR.sprLockerService()
    private let httpLockerService = HttpLockerService()
    private var centralService: CBLockerCentralService?
    private var locationManager = CLLocationManager()
    private var isHttpSupported = false
    private var isCanceled = false
    private var isRequestingLocation = false
    
    override init() {
        super.init()
        self.centralService = CBLockerCentralService(delegate: self)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
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

        checkHttpAvailable { self.scan() }
    }
    
    func take(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.token = token
        self.spacerId = spacerId
        self.type = .take
        self.connectable = { locker in self.connectWithRetry(locker: locker) }
        self.success = success
        self.failure = failure

        checkHttpAvailable { self.scan() }
    }
    
    func openForMaintenance(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.token = token
        self.spacerId = spacerId
        self.type = .openForMaintenance
        self.connectable = { locker in self.connectWithRetry(locker: locker) }
        self.success = success
        self.failure = failure

        checkHttpAvailable { self.scan() }
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
        print("connectWithRetry：\(retryNum + 1)回目")
        if retryNum == 1, isHttpSupported {
            sprError = SPRError.CBConnectingFailed
            requestLocation()
            return
        }
        print("connectWithRetry：BLE通信開始")
        guard let peripheral = locker.peripheral else { return failure(SPRError.CBPeripheralNotFound) }
        let peripheralDelegate =
            CBLockerPeripheralService.Factory.create(
                type: type, token: token, locker: locker, isRetry: retryNum > 0,
                success: {
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
        print("connectを行わない。これによってconnectのタイムアウトが発生する。")
//        centralService?.connect(peripheral: peripheral)
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
    
    private func checkHttpAvailable(callBack: @escaping () -> Void) {
        print("readAPI開始")
        sprLockerService.getLocker(
            token: token,
            spacerId: spacerId,
            success: { spacer in
                if spacer.isHttpSupported {
                    self.isHttpSupported = true
                    let status = CLLocationManager.authorizationStatus()
                    self.checkHttpAvailableCallBack = callBack
                    
                    switch status {
                    case .notDetermined:
                        self.locationManager.requestWhenInUseAuthorization()
                    case .denied, .restricted:
                        self.showLocationPermissionAlert()
                    case .authorizedWhenInUse, .authorizedAlways:
                        callBack()
                    @unknown default:
                        break
                    }
                }
            },
            failure: { _ in callBack() }
        )
    }
    
    func requestLocation() {
        if !isRequestingLocation {
            isRequestingLocation = true
            locationManager.requestLocation()
        }
    }
    
    func showLocationPermissionAlert() {
        guard let window = UIApplication.shared.windows.first,
              let rootViewController = window.rootViewController
        else {
            return
        }
        let alertController = UIAlertController(
            title: "位置情報の利用許可が必要です",
            message: "設定アプリで位置情報の利用を許可してください。",
            preferredStyle: .alert
        )
        let settingsAction = UIAlertAction(title: "設定へ移動", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: {_ in self.checkHttpAvailableCallBack()})
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        rootViewController.present(alertController, animated: true, completion: nil)
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
        var locker = locker
        locker.isScanned = true

        if !isCanceled {
            isCanceled = true
            connectable(locker)
        }
    }

    func failureIfNotCanceled(_ error: SPRError) {
        centralService?.stopScan()
        if isHttpSupported {
            sprError = error
            requestLocation()
        } else if !isCanceled {
            isCanceled = true
            failure(error)
        }
    }
}

extension CBLockerCentralConnectService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            
            if type == .put {
                print("HTTP:預入API")
                httpLockerService.put(
                    token: token,
                    spacerId: spacerId,
                    lat: lat,
                    lng: lng,
                    success: success,
                    failure: { error in self.failure(error) }
                )
            } else if type == .take {
                print("HTTP:取出API")
                httpLockerService.take(
                    token: token,
                    spacerId: spacerId,
                    lat: lat,
                    lng: lng,
                    success: success,
                    failure: { error in self.failure(error) }
                )
            } else if type == .openForMaintenance {
                print("HTTP:メンテナンス取出API")
                httpLockerService.openForMaintenance(
                    token: token,
                    spacerId: spacerId,
                    lat: lat,
                    lng: lng,
                    success: success,
                    failure: { error in self.failure(error) }
                )
            }
            isRequestingLocation = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isRequestingLocation = false
        print("現在地取得失敗: \(error)")
        if let sprError = sprError {
            failure(sprError)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkHttpAvailableCallBack()
    }
}
