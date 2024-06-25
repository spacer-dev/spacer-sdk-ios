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
    
    private let sprLockerService = SPR.sprLockerService()
    private let httpLockerService = HttpLockerService()
    private var centralService: CBLockerCentralService?
    private var locationManager = CLLocationManager()
    private var isHttpSupported = false
    private var isCanceled = false
    private var isRequestingLocation = false
    private var hasBLERetried = false
    private let httpFallbackErrors = [
        SPRError.CBServiceNotFound,
        SPRError.CBCharacteristicNotFound,
        SPRError.CBReadingCharacteristicFailed,
        SPRError.CBConnectStartTimeout,
        SPRError.CBConnectDiscoverTimeout,
        SPRError.CBConnectReadTimeoutBeforeWrite
    ]
    
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
        print("connectWithRetry：\(retryNum + 1)回目")
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
                    let status = CLLocationManager.authorizationStatus()
                    let isPermitted = status == .authorizedAlways || status == .authorizedWhenInUse
                    if self.isHttpSupported, !self.hasBLERetried, self.httpFallbackErrors.contains(error), isPermitted {
                        self.requestLocation()
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
        
    private func checkHttpAvailable(locker: CBLockerModel? = nil) {
        print("readAPI開始")
        sprLockerService.getLocker(
            token: token,
            spacerId: spacerId,
            success: { spacer in
                if spacer.isHttpSupported {
                    self.isHttpSupported = true
                    if let locker = locker {
                        self.connectable(locker)
                    } else {
                        self.requestLocation()
                    }
                } else {
                    if let locker = locker {
                        self.connectable(locker)
                    }
                }
            },
            failure: { error in self.failure(error) }
        )
    }
    
    func requestLocation() {
        if !isRequestingLocation {
            isRequestingLocation = true
            locationManager.requestLocation()
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
            var locker = locker
            locker.isScanned = true
            if type == .read {
                connectable(locker)
            } else {
                checkHttpAvailable(locker: locker)
            }
        }
    }

    func failureIfNotCanceled(_ error: SPRError) {
        centralService?.stopScan()
        
        if !isCanceled {
            isCanceled = true
            if type == .read {
                failure(error)
            } else {
                checkHttpAvailable()
                sprError = error
            }
        }
    }
    
    func httpLockerServices(lat: Double?, lng: Double?) {
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

extension CBLockerCentralConnectService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            httpLockerServices(lat: lat, lng: lng)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isRequestingLocation = false
        print("現在地取得失敗: \(error)")
        httpLockerServices(lat: nil, lng: nil)
    }
}
