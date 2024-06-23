//
//  CBLockerCentralConnectService.swift
//
//
//  Created by Takehito Soi on 2021/06/23.
//

import CoreBluetooth
import Foundation
import CoreLocation
import UIKit


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
    // 位置情報が複数回更新されることを防ぐためのフラグ
    private var isRequestingLocation = false
    private var sprError: SPRError?
    
    override init() {
        super.init()
        self.centralService = CBLockerCentralService(delegate: self)
        locationManager.delegate = self
        // 位置データの精度を最大にする（NOTE:最大にするデメリットとして利用できるまでの時間が長くなる）
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
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
        // １回目のリトライ時のみHTTP接続を試みる　// connectWithRetryに進んでいる = scanが成功している　→そのためisScannedは不要なのでは？
        if retryNum == 1 {
            requestLocation()
            print("connectWithRetry時点のisHttpSupported:\(isHttpSupported)")
            if isHttpSupported {
                // HTTP通信対応ロッカーの場合、下のBLE通信の処理に行かせない
                return
            }
        }
        print("connectWithRetry：BLE通信開始")
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
    
    private func checkHttpAvailable(error: SPRError? = nil, callBack: @escaping () -> Void) {
        print("HTTP:readAPI開始")
        sprLockerService.getLocker(
            token: token,
            spacerId: spacerId,
            success: { spacer in
                if spacer.isHttpSupported {
                    self.isHttpSupported = true
                    // 位置情報サービスのステータスを確認
                    let status = CLLocationManager.authorizationStatus()
                    
                    switch status {
                    case .notDetermined:
                        // 未確定の場合 → ユーザーにアプリの使用中に位置情報サービスを使用する許可をリクエスト
                        self.locationManager.requestWhenInUseAuthorization()
                    case .denied, .restricted:
                        // 拒否されている場合 → ダイアログ表示
                        self.showLocationPermissionAlert()
                    case .authorizedWhenInUse, .authorizedAlways:
                        // 許可されている場合 → 何もしない
                        break
                    @unknown default:
                        break
                    }
                }
                callBack()
            },
            failure: { _ in callBack() }
        )
    }
    
    func requestLocation() {
        // 位置情報が複数回更新されるのを防ぐ仕様
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
            // 設定アプリを開く
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
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

        if !isCanceled {
            isCanceled = true
            connectable(locker)
        }
    }

    // スキャンができる状態でない場合、検出失敗した場合、接続失敗した場合
    func failureIfNotCanceled(_ error: SPRError) {
        centralService?.stopScan()
        if isHttpSupported {
            sprError = error
            requestLocation()
        } else {
            isCanceled = true
            failure(error)
        }
    }
}

extension CBLockerCentralConnectService: CLLocationManagerDelegate {
    // 現在地取得成功
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
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
    
    // 現在地取得失敗
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isRequestingLocation = false
        print("現在地取得失敗: \(error)")
        if let sprError = sprError {
            failure(sprError)
        }
    }
}
