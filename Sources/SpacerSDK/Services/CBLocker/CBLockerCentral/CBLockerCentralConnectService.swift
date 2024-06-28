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
    private var execAfterScanAndCheckHttpAvailable: (CBLockerModel) -> Void = { _ in }
    private var success: () -> Void = {}
    private var readSuccess: (Bool) -> Void = { _ in }
    private var failure: (SPRError) -> Void = { _ in }
    private var errorBeforeConnect: SPRError?
    
    private let sprLockerService = SPR.sprLockerService()
    private let httpLockerService = HttpLockerService()
    private var centralService: CBLockerCentralService?
    private var locationManager = CLLocationManager()
    private var isHttpSupported = false
    private var isCanceled = false
    private var isExecutingHttpService = false
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
        type = .put
        execAfterScanAndCheckHttpAvailable = { locker in self.connectWithRetry(locker: locker) }
        self.success = success
        self.failure = failure

        scan()
    }
    
    func take(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.token = token
        self.spacerId = spacerId
        type = .take
        execAfterScanAndCheckHttpAvailable = { locker in self.connectWithRetry(locker: locker) }
        self.success = success
        self.failure = failure

        scan()
    }
    
    func openForMaintenance(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.token = token
        self.spacerId = spacerId
        type = .openForMaintenance
        execAfterScanAndCheckHttpAvailable = { locker in self.connectWithRetry(locker: locker) }
        self.success = success
        self.failure = failure

        scan()
    }
    
    func checkDoorStatusAvailable(token: String, spacerId: String, success: @escaping (Bool) -> Void, failure: @escaping (SPRError) -> Void) {
        self.token = token
        self.spacerId = spacerId
        type = .checkDoorStatusAvailable
        execAfterScanAndCheckHttpAvailable = { locker in self.checkDoorStatusAvailable(locker: locker) }
        readSuccess = success
        self.failure = failure

        scan()
    }

    private func checkHttpAvailable(locker: CBLockerModel) {
        sprLockerService.getLocker(
            token: token,
            spacerId: spacerId,
            success: { spacer in
                var locker = locker
                locker.isHttpSupported = spacer.isHttpSupported
                self.execAfterScanAndCheckHttpAvailable(locker)
            },
            failure: { error in
                self.failure(error)
            }
        )
    }
    
    private func connectWithRetry(locker: CBLockerModel, retryNum: Int = 0) {
        if !hasBLERetried {
            if !locker.isScanned, locker.isHttpSupported {
                locationManager.requestLocation()
                return
            } else if !locker.isScanned, !locker.isHttpSupported, let error = errorBeforeConnect {
                failure(error)
                return
            }
        }
       
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
                    success: { lockerAvailable in
                        self.readSuccess(lockerAvailable)
                        self.disconnect(locker: locker)
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
            checkHttpAvailable(locker: locker)
        }
    }

    func failureIfNotCanceled(_ error: SPRError) {
        centralService?.stopScan()
        
        if !isCanceled {
            isCanceled = true
            errorBeforeConnect = error
            let locker = CBLockerModel(id: spacerId)
            checkHttpAvailable(locker: locker)
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
