//
//  CBLockerPeripheralService.swift
//
//
//  Created by Takehito Soi on 2021/06/23.
//

import CoreBluetooth
import Foundation

protocol CBLockerPeripheralDelegate {
    func onGetKey(locker: CBLockerModel, success: @escaping (Data) -> Void, failure: @escaping (SPRError) -> Void)
    func onSuccess(locker: CBLockerModel)
    func onFailure(_ error: SPRError)
}

class CBLockerPeripheralService: NSObject {
    var skipFirstRead: Bool
    var delegate: CBLockerPeripheralDelegate

    var locker: CBLockerModel!

    init(locker: CBLockerModel, delegate: CBLockerPeripheralDelegate, skipFirstRead: Bool = false) {
        self.locker = locker
        self.delegate = delegate
        self.skipFirstRead = skipFirstRead
    }
}

extension CBLockerPeripheralService: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("peripheral didDiscoverServices")

        guard error == nil else {
            print("peripheral didDiscoverServices failed with error: \(String(describing: error))")
            return delegate.onFailure(SPRError.CBDiscoveringServicesFailed)
        }

        guard let services = peripheral.services else {
            print("peripheral didDiscoverServices, services is nil")
            return delegate.onFailure(SPRError.CBDiscoveringServicesFailed)
        }

        if services.isEmpty {
            print("peripheral didDiscoverServices, services is empty")
            return delegate.onFailure(SPRError.CBDiscoveringServicesFailed)
        }

        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("peripheral didDiscoverCharacteristicsFor")

        guard error == nil else {
            print("peripheral didDiscoverCharacteristicsFor failed with error: \(String(describing: error))")
            return delegate.onFailure(SPRError.CBDiscoveringCharacteristicsFailed)
        }

        let characteristic = service.characteristics?.first(where: { $0.uuid.isEqual(CBLockerConst.CharacteristicUUID) })
        if let characteristic = characteristic {
            locker?.characteristic = characteristic

            if skipFirstRead {
                self.peripheral(peripheral, willWriteValueFor: characteristic)
            } else {
                peripheral.readValue(for: characteristic)
            }
        } else {
            return delegate.onFailure(SPRError.CBDiscoveringCharacteristicsFailed)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("peripheral didUpdateValueFor")

        guard error == nil else {
            print("peripheral didUpdateValueFor failed with error: \(String(describing: error))")
            return delegate.onFailure(SPRError.CBReadingCharacteristicFailed)
        }

        guard let characteristicValue = characteristic.value else {
            print("peripheral didUpdateValueFor, characteristic value is nil")
            return delegate.onFailure(SPRError.CBReadingCharacteristicFailed)
        }

        locker.readData = String(bytes: characteristicValue, encoding: String.Encoding.ascii) ?? ""

        print("peripheral didUpdateValueFor, read data: \(locker.readData), operation: \(locker.operation)")

        if locker.operation == .none {
            self.peripheral(peripheral, willWriteValueFor: characteristic)
        } else if locker.operation == .write {
            delegate.onSuccess(locker: locker)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("peripheral didWriteValueFor")

        guard error == nil else {
            print("peripheral didWriteValueFor failed with error: \(String(describing: error))")
            return delegate.onFailure(SPRError.CBWritingCharacteristicFailed)
        }

        locker.update(.write)
        peripheral.readValue(for: characteristic)
    }

    public func peripheral(_ peripheral: CBPeripheral, willWriteValueFor characteristic: CBCharacteristic) {
        delegate.onGetKey(
            locker: locker,
            success: { data in peripheral.writeValue(data, for: characteristic, type: .withResponse) },
            failure: delegate.onFailure)
    }
}
