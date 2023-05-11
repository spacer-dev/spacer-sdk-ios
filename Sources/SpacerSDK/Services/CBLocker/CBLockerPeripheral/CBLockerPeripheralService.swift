//
//  CBLockerPeripheralService.swift
//
//
//  Created by Takehito Soi on 2021/06/23.
//

import CoreBluetooth
import Foundation

protocol CBLockerPeripheralDelegate {
    func getKey(locker: CBLockerModel, success: @escaping (Data) -> Void, failure: @escaping (SPRError) -> Void)
    func saveKey(locker: CBLockerModel, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void)
}

class CBLockerPeripheralService: NSObject {
    private var type: CBLockerActionType
    private var locker: CBLockerModel
    private let delegate: CBLockerPeripheralDelegate
    private let isRetry: Bool
    private var success: () -> Void = {}
    private var failure: (SPRError) -> Void = { _ in }
    private var isCanceled = false
    private var timeouts: CBLockerConnectTimeouts!

    init(type: CBLockerActionType, locker: CBLockerModel, delegate: CBLockerPeripheralDelegate, isRetry: Bool, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.type = type
        self.locker = locker
        self.delegate = delegate
        self.isRetry = isRetry
        self.success = success
        self.failure = failure

        super.init()

        self.locker.resetToConnect()
        self.timeouts = CBLockerConnectTimeouts(executable: execTimeoutProcessing)
    }

    enum Factory {
        static func create(type: CBLockerActionType,
                           token: String,
                           locker: CBLockerModel,
                           isRetry: Bool,
                           success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) -> CBLockerPeripheralService?
        {
            if type == .put {
                return CBLockerPeripheralPutService(type: type, token: token, locker: locker, isRetry: isRetry, success: success, failure: failure).peripheralDelegate
            } else if type == .take {
                return CBLockerPeripheralTakeService(type: type, token: token, locker: locker, isRetry: isRetry, success: success, failure: failure).peripheralDelegate
            } else if type == .openForMaintenance {
                return CBLockerPeripheralMaintenanceService(type: type, token: token, locker: locker, isRetry: isRetry, success: success, failure: failure).peripheralDelegate
            }
            return nil
        }
    }

    private func alreadyWrittenToCharacteristic(locker: CBLockerModel) -> Bool {
        if type == .put {
            return CBLockerConst.UsingOrWriteReadData.contains(locker.readData)
        } else if type == .take {
            return !CBLockerConst.UsingReadData.contains(locker.readData)
        } else if type == .openForMaintenance {
            return locker.status == .write
        }
        return false
    }

    func startConnectingAndDiscoveringServices() {
        timeouts.during.set()
        timeouts.start.set()
    }

    private func finishConnectingAndDiscoveringServices() {
        timeouts.start.clear()
    }

    private func startDiscoveringCharacteristics(peripheral: CBPeripheral, services: [CBService]) {
        timeouts.discover.set()

        for service in services {
            print(service)
            peripheral.discoverCharacteristics([CBLockerConst.CharacteristicUUID], for: service)
        }
    }

    private func finishDiscoveringCharacteristics() {
        timeouts.discover.clear()
    }

    private func startReadingValueFromCharacteristic(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        if locker.status == .none {
            timeouts.readBeforeWrite.set()
        } else if locker.status == .write {
            timeouts.readAfterWrite.set()
        }
        
        peripheral.readValue(for: characteristic)
    }

    private func finishReadingValueFromCharacteristic() {
        if locker.status == .none {
            timeouts.readBeforeWrite.clear()
        } else if locker.status == .write {
            timeouts.readAfterWrite.clear()
        }
    }

    private func startGettingKey(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        delegate.getKey(
            locker: locker,
            success: { data in self.startWritingValueToCharacteristic(peripheral: peripheral, characteristic: characteristic, data: data) },
            failure: failureIfNotCanceled)
    }

    private func startWritingValueToCharacteristic(peripheral: CBPeripheral, characteristic: CBCharacteristic, data: Data) {
        timeouts.write.set()

        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }

    private func finishWritingValueToCharacteristic() {
        timeouts.write.clear()
    }

    private func startSavingKey() {
        delegate.saveKey(locker: locker,
                         success: successIfNotCanceled,
                         failure: failureIfNotCanceled)
    }

    private func execTimeoutProcessing(error: SPRError) {
        failureIfNotCanceled(error)
    }

    private func successIfNotCanceled() {
        if !isCanceled {
            isCanceled = true
            clearConnecting()
            success()
        }
    }

    private func failureIfNotCanceled(_ error: SPRError) {
        if !isCanceled {
            isCanceled = true
            clearConnecting()
            failure(error)
        }
    }

    private func clearConnecting() {
        timeouts.clearAll()
    }
}

extension CBLockerPeripheralService: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("peripheral didDiscoverServices")

        finishConnectingAndDiscoveringServices()

        guard error == nil else {
            print("peripheral didDiscoverServices failed with error: \(String(describing: error))")
            return failureIfNotCanceled(SPRError.CBServiceNotFound)
        }

        guard let services = peripheral.services else {
            print("peripheral didDiscoverServices, services is nil")
            return failureIfNotCanceled(SPRError.CBServiceNotFound)
        }

        if services.isEmpty {
            print("peripheral didDiscoverServices, services is empty")
            return failureIfNotCanceled(SPRError.CBServiceNotFound)
        }

        startDiscoveringCharacteristics(peripheral: peripheral, services: services)
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
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

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("peripheral didUpdateValueFor")

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

        if isRetry, alreadyWrittenToCharacteristic(locker: locker) {
            startSavingKey()
        } else {
            if locker.status == .none {
                startGettingKey(peripheral: peripheral, characteristic: characteristic)
            } else if locker.status == .write {
                startSavingKey()
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("peripheral didWriteValueFor")

        finishWritingValueToCharacteristic()

        guard error == nil else {
            print("peripheral didWriteValueFor failed with error: \(String(describing: error))")
            if let characteristicValue = characteristic.value {
                let readData = String(bytes: characteristicValue, encoding: String.Encoding.ascii) ?? ""
                print("readData: \(readData)")
            }
            return failureIfNotCanceled(SPRError.CBWritingCharacteristicFailed)
        }
        
        guard let characteristicValue = characteristic.value else {
            print("peripheral didUpdateValueFor, characteristic value is nil")
            return failureIfNotCanceled(SPRError.CBReadingCharacteristicFailed)
        }
        
        let readData = String(bytes: characteristicValue, encoding: String.Encoding.ascii) ?? ""
        print("readData: \(readData)")

        locker.updateStatus(.write)
        startReadingValueFromCharacteristic(peripheral: peripheral, characteristic: characteristic)
    }
}
