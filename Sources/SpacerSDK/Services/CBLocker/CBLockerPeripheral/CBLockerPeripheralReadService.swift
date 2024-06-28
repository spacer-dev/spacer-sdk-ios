//
//  CBLockerPeripheralReadService.swift
//
//
//  Created by s.norimatsu on 2023/05/26.
//

import CoreBluetooth
import Foundation

class CBLockerPeripheralReadService: NSObject {
    private var locker: CBLockerModel
    private var success: (Bool) -> Void = { _ in }
    private var isCanceled = false
    private var timeouts: CBLockerConnectTimeouts!
    private var notAvailableReadData = ["openedExpired", "openedNotExpired", "closedExpired", "false"]

    init(locker: CBLockerModel, success: @escaping (Bool) -> Void) {
        self.locker = locker
        self.success = success

        super.init()

        self.locker.resetToConnect()
        self.timeouts = CBLockerConnectTimeouts(executable: execTimeoutProcessing)
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
        timeouts.readBeforeWrite.set()

        peripheral.readValue(for: characteristic)
    }

    private func finishReadingValueFromCharacteristic() {
        timeouts.readBeforeWrite.clear()
    }

    private func execTimeoutProcessing(error: SPRError) {
        checkIsHttpSupportedIfNotCanceled()
    }

    private func successIfNotCanceled(lockerAvailable: Bool) {
        if !isCanceled {
            isCanceled = true
            clearConnecting()
            success(lockerAvailable)
        }
    }

    private func checkIsHttpSupportedIfNotCanceled() {
        if !isCanceled {
            isCanceled = true
            clearConnecting()
            success(locker.isHttpSupported)
        }
    }

    private func clearConnecting() {
        timeouts.clearAll()
    }
}

extension CBLockerPeripheralReadService: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("peripheral didDiscoverServices")

        finishConnectingAndDiscoveringServices()

        guard error == nil else {
            print("peripheral didDiscoverServices failed with error: \(String(describing: error))")
            return checkIsHttpSupportedIfNotCanceled()
        }

        guard let services = peripheral.services else {
            print("peripheral didDiscoverServices, services is nil")
            return checkIsHttpSupportedIfNotCanceled()
        }

        if services.isEmpty {
            print("peripheral didDiscoverServices, services is empty")
            return checkIsHttpSupportedIfNotCanceled()
        }

        startDiscoveringCharacteristics(peripheral: peripheral, services: services)
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("peripheral didDiscoverCharacteristicsFor")

        finishDiscoveringCharacteristics()

        guard error == nil else {
            print("peripheral didDiscoverCharacteristicsFor failed with error: \(String(describing: error))")
            return checkIsHttpSupportedIfNotCanceled()
        }

        let characteristic = service.characteristics?.first
        guard let characteristic = characteristic else {
            return checkIsHttpSupportedIfNotCanceled()
        }

        startReadingValueFromCharacteristic(peripheral: peripheral, characteristic: characteristic)
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("peripheral didUpdateValueFor")

        finishReadingValueFromCharacteristic()

        guard error == nil else {
            print("peripheral didUpdateValueFor failed with error: \(String(describing: error))")
            return checkIsHttpSupportedIfNotCanceled()
        }

        guard let characteristicValue = characteristic.value else {
            print("peripheral didUpdateValueFor, characteristic value is nil")
            return checkIsHttpSupportedIfNotCanceled()
        }

        let readData = String(bytes: characteristicValue, encoding: String.Encoding.ascii) ?? ""

        let lockerAvailable = !notAvailableReadData.contains(readData)
        successIfNotCanceled(lockerAvailable: lockerAvailable)
    }
}
