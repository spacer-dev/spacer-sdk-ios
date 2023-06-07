//
//  CBLockerReadService.swift
//  
//
//  Created by s.norimatsu on 2023/05/26.
//

import CoreBluetooth
import Foundation

class CBLockerReadService: NSObject {
    private var locker: CBLockerModel!
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var isCanceled = false
    private var success: (String) -> Void = { _ in }
    private var failure: (SPRError) -> Void = { _ in }
    private var timeouts: CBLockerConnectTimeouts!
    
    func connect(locker: CBLockerModel, success: @escaping (String) -> Void, failure: @escaping (SPRError) -> Void) {
        print("connect: \(locker.id)")
        
        self.locker = locker
        self.success = success
        self.failure = failure
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    private func reset() {
        centralManager.cancelPeripheralConnection(peripheral!)
        peripheral = nil
    }
    
    private func successIfNotCanceled(readData: String) {
        reset()
        if (!isCanceled) {
            isCanceled = true
            success(readData)
        }
    }
    
    func startConnectingAndDiscoveringServices() {
        timeouts.during.set()
        timeouts.start.set()
    }
    
    private func startDiscoveringCharacteristics(peripheral: CBPeripheral, services: [CBService]) {
        timeouts.discover.set()
        
        for service in services {
            print(service)
            peripheral.discoverCharacteristics([CBLockerConst.CharacteristicUUID], for: service)
        }
    }
    
    private func startReadingValueFromCharacteristic(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        timeouts.readBeforeWrite.set()
        
        peripheral.readValue(for: characteristic)
    }
    
    private func failureIfNotCanceled(_ error: SPRError) {
        if !isCanceled {
            isCanceled = true
            clearConnecting()
            failure(error)
        }
    }
    
    private func finishReadingValueFromCharacteristic() {
        timeouts.readBeforeWrite.clear()
    }
    
    private func finishDiscoveringCharacteristics() {
        timeouts.discover.clear()
    }
    
    private func clearConnecting() {
        timeouts.clearAll()
    }
    
    private func finishConnectingAndDiscoveringServices() {
        timeouts.start.clear()
    }
    
    private func execTimeoutProcessing(error: SPRError) {
        failureIfNotCanceled(error)
    }
}

// MARK: - CBCentralManagerDelegate

extension CBLockerReadService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let readyScan = central.state == .poweredOn && centralManager?.isScanning == false
        if readyScan {
            centralManager?.scanForPeripherals(withServices: [CBLockerConst.ServiceUUID], options: nil)
        } else {
            if let error = central.state.toSPRError() {
                failureIfNotCanceled(error)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.centralManager.stopScan()
        self.peripheral = peripheral
        self.peripheral?.delegate = self
        self.centralManager.connect(self.peripheral!, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.peripheral?.discoverServices(nil)
    }
}

// MARK: - CBPeripheralDelegate

extension CBLockerReadService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        finishConnectingAndDiscoveringServices()
        
        guard error == nil else {
            print("peripheral didDiscoverServices failed with error: \(String(describing: error))")
            return failureIfNotCanceled(SPRError.CBServiceNotFound)
        }
        
        guard let services = peripheral.services else {
            return failureIfNotCanceled(SPRError.CBServiceNotFound)
        }
        
        if services.isEmpty {
            print("peripheral didDiscoverServices, services is empty")
            return failureIfNotCanceled(SPRError.CBServiceNotFound)
        }
        
        startDiscoveringCharacteristics(peripheral: peripheral, services: services)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("peripheral didDiscoverCharacteristicsFor")
        
        finishDiscoveringCharacteristics()
        
        guard error == nil else {
            print("peripheral didDiscoverCharacteristicsFor failed with error: \(String(describing: error))")
            return failureIfNotCanceled(SPRError.CBCharacteristicNotFound)
        }
        
        let characteristic = service.characteristics?.first
        guard let characteristic = characteristic else {
            return failureIfNotCanceled(SPRError.CBCharacteristicNotFound)
        }
        
        startReadingValueFromCharacteristic(peripheral: peripheral, characteristic: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        finishReadingValueFromCharacteristic()
        
        guard error == nil else {
            print("peripheral didUpdateValueFor failed with error: \(String(describing: error))")
            return failureIfNotCanceled(SPRError.CBReadingCharacteristicFailed)
        }
        
        guard let characteristicValue = characteristic.value else {
            print("peripheral didUpdateValueFor, characteristic value is nil")
            return failureIfNotCanceled(SPRError.CBReadingCharacteristicFailed)
        }
        
        locker.setReadData(String(bytes: characteristicValue, encoding: String.Encoding.ascii) ?? "")
        print("peripheral didUpdateValueFor, read data: \(locker.readData), status: \(locker.status)")
        
        
        successIfNotCanceled(readData: locker.readData)
    }
    
    
    
}
