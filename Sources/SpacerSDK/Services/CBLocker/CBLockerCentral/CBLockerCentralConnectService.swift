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
            success: { locker in self.execWithRetry(action: .put, token: token, locker: locker) },
            failure: failure
        )
    }
    
    func take(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.scan(
            spacerId: spacerId,
            success: { locker in self.execWithRetry(action: .take, token: token, locker: locker) },
            failure: failure
        )
    }
    
    private func execWithRetry(
        action: CBLockerActionType, token: String, locker: CBLockerModel, execMode: CBLockerExecMode = .normal, retryNum: Int = 0
    ) {
        guard let peripheral = locker.peripheral else { return self.failure(SPRError.CBPeripheralNotFound) }
        
        let peripheralDelegate =
            CBLockerPeripheralService.Factory.create(
                type: action, token: token, locker: locker, execMode: execMode, retryNum: retryNum, success: {
                    self.success(locker)
                    self.disconnect(locker: locker)
                },
                failure: { error in
                    self.retryOrFailure(
                        error: error,
                        locker: locker,
                        retryNum: retryNum,
                        executable: { execMode, retryNum in
                            self.execWithRetry(action: action, token: token, locker: locker, execMode: execMode, retryNum: retryNum)
                        }
                    )
                }
            )
        
        guard let delegate = peripheralDelegate else { return self.failure(SPRError.CBConnectingFailed) }
        
        locker.peripheral?.delegate = delegate
        self.centralService?.connect(peripheral: peripheral)
    }
    
    private func retryOrFailure(error: SPRError, locker: CBLockerModel, retryNum: Int, executable: @escaping (CBLockerExecMode, Int) -> Void) {
        if retryNum < CBLockerConst.MaxRetryNum {
            executable(.normal, retryNum + 1)
        } else {
            self.failure(error)
            self.disconnect(locker: locker)
        }
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
