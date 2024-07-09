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
    private var readSuccess: (Bool) -> Void = { _ in }
    private var failure: (SPRError) -> Void = { _ in }

    private let sprLockerService = SPR.sprLockerService()
    private let httpLockerService = HttpLockerService()
    private var centralService: CBLockerCentralService?
    private var locationManager = CLLocationManager()
    private var isCanceled = false
    private var isExecutingHttpService = false
    private var hasBLERetried = false
    private var isPermitted = false
    private let httpFallbackErrors = [
        SPRError.CBServiceNotFound,
        SPRError.CBCharacteristicNotFound,
        SPRError.CBReadingCharacteristicFailed,
        SPRError.CBConnectStartTimeout,
        SPRError.CBConnectDiscoverTimeout,
        SPRError.CBConnectReadTimeoutBeforeWrite
    ]
    
    // MEMO:テスト用コード
    private var connectWithRetryStart : Date? = nil
    private var locationInfoGetStart : Date? = nil
    private var coneectableStartTime : Date? = nil

    private var notAvailableReadData = ["openedExpired", "openedNotExpired", "closedExpired", "false"]

    override init() {
        super.init()
        centralService = CBLockerCentralService(delegate: self)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        let status = CLLocationManager.authorizationStatus()
        isPermitted = status == .authorizedAlways || status == .authorizedWhenInUse
    }

    private func scan() {
        centralService?.startScan()
    }

    func put(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.token = token
        self.spacerId = spacerId
        type = .put
        connectable = { locker in self.connectWithRetry(locker: locker) }
        self.success = success
        self.failure = failure

        scan()
    }

    func take(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.token = token
        self.spacerId = spacerId
        type = .take
        connectable = { locker in self.connectWithRetry(locker: locker) }
        self.success = success
        self.failure = failure

        scan()
    }

    func openForMaintenance(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.token = token
        self.spacerId = spacerId
        type = .openForMaintenance
        connectable = { locker in self.connectWithRetry(locker: locker) }
        self.success = success
        self.failure = failure

        scan()
    }

    func checkDoorStatusAvailable(token: String, spacerId: String, success: @escaping (Bool) -> Void, failure: @escaping (SPRError) -> Void) {
        self.token = token
        self.spacerId = spacerId
        type = .checkDoorStatusAvailable
        connectable = { locker in self.checkDoorStatusAvailable(locker: locker) }
        readSuccess = success
        self.failure = failure

        scan()
    }

    private func updateHttpSupportStatus(locker: CBLockerModel, success: @escaping (CBLockerModel) -> Void, failure: @escaping (SPRError) -> Void) {
        sprLockerService.getLocker(
            token: token,
            spacerId: spacerId,
            success: { spacer in
                print("６、readAPI成功")
                var locker = locker
                locker.isHttpSupported = spacer.isHttpSupported
                success(locker)
            },
            failure: failure
        )
    }

    private func connectWithRetry(locker: CBLockerModel, retryNum: Int = 0) {
        if locker.isHttpSupported, !locker.isScanned, isPermitted {
            locationManager.requestLocation()
        } else {
            guard let peripheral = locker.peripheral else { return failure(SPRError.CBPeripheralNotFound) }
            let peripheralDelegate =
                CBLockerPeripheralService.Factory.create(
                    type: type, token: token, locker: locker, isRetry: retryNum > 0,
                    success: {
                        self.success()
                        self.disconnect(locker: locker)
                    },
                    failure: { error in
                        if locker.isHttpSupported, !self.hasBLERetried, self.httpFallbackErrors.contains(error), self.isPermitted {
                            let now = Date()
                            let currentMillisecond = Calendar.current.component(.nanosecond, from: now) / 1_000_000
                            print("拠点取得開始時のミリ秒: \(currentMillisecond)")
                            self.connectWithRetryStart = Date()
                            self.locationManager.requestLocation()
                        } else {
                            self.retryOrFailure(
                                error: error,
                                locker: locker,
                                retryNum: retryNum + 1,
                                executable: { self.connectWithRetry(locker: locker, retryNum: retryNum + 1) }
                            )
                        }
                    }
                )

            guard let delegate = peripheralDelegate else { return failure(SPRError.CBConnectingFailed) }

            locker.peripheral?.delegate = delegate
            delegate.startConnectingAndDiscoveringServices()
            centralService?.connect(peripheral: peripheral)
        }
    }

    private func retryOrFailure(error: SPRError, locker: CBLockerModel, retryNum: Int, executable: @escaping () -> Void) {
        if retryNum < CBLockerConst.MaxRetryNum {
            hasBLERetried = true
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

    private func checkDoorStatusAvailable(locker: CBLockerModel) {
        if locker.isScanned {
            guard let peripheral = locker.peripheral else { return failure(SPRError.CBPeripheralNotFound) }
            let peripheralDelegate =
                CBLockerPeripheralReadService(
                    locker: locker,
                    success: { readData in
                        self.readSuccess(!self.notAvailableReadData.contains(readData))
                        self.disconnect(locker: locker)
                    },
                    failure: { _ in
                        self.readSuccess(locker.isHttpSupported)
                    }
                )

            let delegate = peripheralDelegate

            locker.peripheral?.delegate = delegate
            delegate.startConnectingAndDiscoveringServices()
            centralService?.connect(peripheral: peripheral)
        } else {
            readSuccess(locker.isHttpSupported)
        }
    }

    func httpLockerServices(lat: Double?, lng: Double?) {
        let start = Date()
        if type == .put {
            httpLockerService.put(
                token: token,
                spacerId: spacerId,
                lat: lat,
                lng: lng,
                success: {
                    self.success()
                    let elapsed = Date().timeIntervalSince(start)
                    print("HTTPのput処理時間",elapsed)
                    if let coneectableStartTime = self.coneectableStartTime {
                        let elapsed = Date().timeIntervalSince(coneectableStartTime)
                        print("connectable開始からHTTPのput処理開始まで", elapsed)
                    }
                    let now = Date()
                    let currentMillisecond = Calendar.current.component(.nanosecond, from: now) / 1_000_000
                    print("HTTPのput完了時のミリ秒: \(currentMillisecond)")
                },
                failure: { error in self.failure(error) }
            )
        } else if type == .take {
            httpLockerService.take(
                token: token,
                spacerId: spacerId,
                lat: lat,
                lng: lng,
                success: {
                    self.success()
                    if let coneectableStartTime = self.coneectableStartTime {
                        let elapsed = Date().timeIntervalSince(coneectableStartTime)
                        print("connectable開始からHTTPのtake処理開始まで", elapsed)
                    }
                    let elapsed = Date().timeIntervalSince(start)
                    print("HTTPのtake処理時間", elapsed)
                    let now = Date()
                    let currentMillisecond = Calendar.current.component(.nanosecond, from: now) / 1_000_000
                    print("HTTPのtake完了時のミリ秒: \(currentMillisecond)")
                },
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

extension CBLockerCentralConnectService: CBLockerCentralDelegate {
    func execAfterDiscovered(locker: CBLockerModel) {
        if locker.id == spacerId {
            centralService?.stopScan()
            print("４、スキャンストップ")
            print("５、スキャンしたIDと施錠/開錠するロッカ-のIDが一緒なので、successIfNotCanceledへ")
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
            var locker = locker
            locker.isScanned = true
            updateHttpSupportStatus(
                locker: locker,
                success: { locker in
                    self.connectable(locker)
                    print("connectable開始")
                    self.coneectableStartTime = Date()
                },
                failure: failure
            )
        }
    }

    func failureIfNotCanceled(_ error: SPRError) {
        centralService?.stopScan()

        if !isCanceled {
            isCanceled = true
            let locker = CBLockerModel(id: spacerId)
            updateHttpSupportStatus(
                locker: locker,
                success: { locker in
                    if locker.isHttpSupported, self.isPermitted {
                        self.connectable(locker)
                        print("connectable開始")
                        self.coneectableStartTime = Date()
                    } else {
                        self.failure(error)
                    }
                },
                failure: failure
            )
        }
    }
}

extension CBLockerCentralConnectService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            if !isExecutingHttpService {
                isExecutingHttpService = true
                httpLockerServices(lat: lat, lng: lng)
                if let locationInfoGetStart = locationInfoGetStart{
                    let elapsed = Date().timeIntervalSince(locationInfoGetStart)
                    print("位置情報取得処理時間",elapsed)
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if !isExecutingHttpService {
            isExecutingHttpService = true
            httpLockerServices(lat: nil, lng: nil)
        }
    }
}
