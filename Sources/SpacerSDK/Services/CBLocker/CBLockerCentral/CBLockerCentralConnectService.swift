//
//  CBLockerCentralConnectService.swift
//
//
//  Created by Takehito Soi on 2021/06/23.
//

import CoreBluetooth
import Foundation

class CBLockerCentralConnectService: NSObject {
    private var centralService: CBLockerCentralService?
    
    private var spacerId: String!
    private var success: (CBLockerModel) -> Void = { _ in }
    private var failure: (SPRError) -> Void = { _ in }
    
    override init() {
        super.init()
        
        self.centralService = CBLockerCentralService(delegate: self)
    }
    
    func scan(spacerId: String, success: @escaping (CBLockerModel) -> Void, failure: @escaping (SPRError) -> Void) {
        self.spacerId = spacerId
        self.success = success
        self.failure = failure
        
        self.centralService?.scan()
    }
    
    func put(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.scan(
            spacerId: spacerId,
            success: { locker in
                self.put(token: token, locker: locker, success: success, failure: failure)
            },
            failure: failure
        )
    }
    
    func take(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.scan(
            spacerId: spacerId,
            success: { locker in
                self.take(token: token, locker: locker, success: success, failure: failure)
            },
            failure: failure
        )
    }
    
    private func put(token: String, locker: CBLockerModel, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        guard let peripheral = locker.peripheral else { return failure(SPRError.CBPeripheralNotFound) }
        
        let putService = CBLockerPeripheralPutService(
            token: token,
            locker: locker,
            success: {
                success()
                self.disconnect(locker: locker)
            },
            failure: { error in
                failure(error)
                self.disconnect(locker: locker)
            }
        )
        
        locker.peripheral?.delegate = putService.connectService
        self.centralService?.connect(peripheral: peripheral)
    }
    
    private func take(token: String, locker: CBLockerModel, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        guard let peripheral = locker.peripheral else { return failure(SPRError.CBPeripheralNotFound) }
        
        let takeService = CBLockerPeripheralTakeService(
            token: token,
            locker: locker,
            success: {
                success()
                self.disconnect(locker: locker)
            },
            failure: { error in
                failure(error)
                self.disconnect(locker: locker)
            }
        )
        locker.peripheral?.delegate = takeService.connectService
        self.centralService?.connect(peripheral: peripheral)
    }
    
    private func disconnect(locker: CBLockerModel) {
        guard let peripheral = locker.peripheral else { return self.failure(SPRError.CBPeripheralNotFound) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + CBLockerConst.DelayDisconnectSeconds) {
            self.centralService?.disconnect(peripheral: peripheral)
        }
    }
}

extension CBLockerCentralConnectService: CBLockerCentralDelegate {
    func onDiscovered(locker: CBLockerModel) {
        if locker.id == self.spacerId {
            self.centralService?.stopScan()
            self.success(locker)
        }
    }
    
    func onDelayed() {
        if self.centralService?.isScanning() == true {
            self.centralService?.stopScan()
            self.failure(SPRError.CBCentralTimeout)
        }
    }
    
    func onFailure(_ error: SPRError) {
        self.failure(error)
    }
}
