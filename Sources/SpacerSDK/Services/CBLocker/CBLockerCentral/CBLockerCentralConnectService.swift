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
    private var isPermitted = false
    private var cachedHttpSupported: Bool?
    
    private var notAvailableReadData = ["openedExpired", "openedNotExpired", "closedExpired", "false"]
    
    override init() {
        super.init()
        centralService = CBLockerCentralService(delegate: self)
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
        self.success = success
        self.failure = failure
        
        prepareAndScan(isScan: true, success: success, failure: failure)
    }

    func take(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.token = token
        self.spacerId = spacerId
        type = .take
        self.success = success
        self.failure = failure
        
        prepareAndScan(isScan: true, success: success, failure: failure)
    }
    
    func reservedOpen(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.token = token
        self.spacerId = spacerId
        type = .reservedOpen
        self.success = success
        self.failure = failure
        
        prepareAndScan(isScan: false, success: success, failure: failure)
    }

    func openForMaintenance(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.token = token
        self.spacerId = spacerId
        type = .openForMaintenance
        self.success = success
        self.failure = failure
        
        prepareAndScan(isScan: true, success: success, failure: failure)
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
        if let isHttpSupported = cachedHttpSupported {
            var locker = locker
            locker.isHttpSupported = isHttpSupported
            connectable(locker)
        } else {
            sprLockerService.getLocker(
                token: token,
                spacerId: spacerId,
                success: { spacer in
                    var locker = locker
                    locker.isHttpSupported = spacer.isHttpSupported
                    self.cachedHttpSupported = spacer.isHttpSupported
                    success(locker)
                },
                failure: failure
            )
        }
    }
    
    private func connectWithRetry(locker: CBLockerModel, retryNum: Int = 0) {
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
    
    private func httpLockerServices() {
        if type == .put {
            httpLockerService.put(
                token: token,
                spacerId: spacerId,
                success: success,
                failure: { error in self.failure(error) }
            )
        } else if type == .take {
            httpLockerService.take(
                token: token,
                spacerId: spacerId,
                success: success,
                failure: { error in self.failure(error) }
            )
        } else if type == .reservedOpen {
            httpLockerService.reservedOpen(
                token: token,
                spacerId: spacerId,
                success: success,
                failure: { error in self.failure(error) }
            )
        } else if type == .openForMaintenance {
            httpLockerService.openForMaintenance(
                token: token,
                spacerId: spacerId,
                success: success,
                failure: { error in self.failure(error) }
            )
        }
    }
    
    private func prepareAndScan(
        isScan: Bool,
        success: @escaping () -> Void,
        failure: @escaping (SPRError) -> Void
    ) {
        updateHttpSupportStatus(
            locker: CBLockerModel(id: spacerId),
            success: {
                [weak self] locker in
                guard let self = self else { return }
                
                self.cachedHttpSupported = locker.isHttpSupported
            
                if locker.isHttpSupported {
                    self.httpLockerServices()
                } else if isScan {
                    self.connectable = { [weak self] scanLocker in self?.connectWithRetry(locker: scanLocker) }
                    self.scan()
                } else {
                    failure(SPRError.CBServiceNotSupported)
                }
            }, failure: { error in
                failure(error)
            }
        )
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
            updateHttpSupportStatus(locker: locker, success: connectable, failure: failure)
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
                    } else {
                        self.failure(error)
                    }
                },
                failure: failure
            )
        }
    }
}
