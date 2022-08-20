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
    private var connectable: (CBLockerModel) -> Void = { _ in }
    private var success: () -> Void = {}
    private var failure: (SPRError) -> Void = { _ in }
    
    override init() {
        super.init()
        self.centralService = CBLockerCentralService(delegate: self)
    }
    
    func scan(spacerId: String, connectable: @escaping (CBLockerModel) -> Void) {
        self.spacerId = spacerId
        self.connectable = connectable
        self.centralService?.scan()
    }
    
    func put(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.success = success
        self.failure = failure
        
        self.scan(
            spacerId: spacerId,
            connectable: { locker in self.execWithRetry(action: .put, token: token, locker: locker) }
        )
    }
    
    func take(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.success = success
        self.failure = failure
        
        self.scan(
            spacerId: spacerId,
            connectable: { locker in self.execWithRetry(action: .take, token: token, locker: locker) }
        )
    }
    
    private func execWithRetry(
        action: CBLockerActionType, token: String, locker: CBLockerModel, execMode: CBLockerExecMode = .normal, retryNum: Int = 0
    ) {
        guard let peripheral = locker.peripheral else { return self.failure(SPRError.CBPeripheralNotFound) }
        
        let peripheralDelegate =
            CBLockerPeripheralService.Factory.create(
                type: action, token: token, locker: locker, execMode: execMode, retryNum: retryNum, success: {
                    self.success()
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
        print("##### retryNum:\(retryNum)")
              
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
            self.connectable(locker)
        }
    }
    
    func onPostDelayed() {
        if self.centralService?.isScanning() == true {
            self.centralService?.stopScan()
            self.failure(SPRError.CBCentralTimeout)
        }
    }
    
    func onFailure(_ error: SPRError) {
        self.failure(error)
    }
}
