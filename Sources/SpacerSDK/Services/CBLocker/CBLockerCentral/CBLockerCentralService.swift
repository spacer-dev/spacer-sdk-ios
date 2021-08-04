//
//  CBLockerCentralService.swift
//
//
//  Created by Takehito Soi on 2021/06/23.
//

import CoreBluetooth
import Foundation

protocol CBLockerCentralDelegate {
    func onDiscovered(locker: CBLockerModel)
    func onDelayed()
    func onFailure(_ error: SPRError)
}

class CBLockerCentralService: NSObject {
    private var scanSeconds = CBLockerConst.ScanSeconds
    private var delegate: CBLockerCentralDelegate
    private var centralManager: CBCentralManager?

    init(delegate: CBLockerCentralDelegate) {
        self.delegate = delegate
    }

    func isScanning() -> Bool {
        return centralManager?.isScanning == true
    }

    func scan() {
        centralManager = CBCentralManager(delegate: self, queue: nil)

        postDelayed()
    }

    func stopScan() {
        centralManager?.stopScan()
    }

    func connect(peripheral: CBPeripheral) {
        centralManager?.connect(peripheral, options: nil)
    }

    func disconnect(peripheral: CBPeripheral) {
        centralManager?.cancelPeripheralConnection(peripheral)
    }

    private func postDelayed() {
        DispatchQueue.main.asyncAfter(deadline: .now() + scanSeconds) {
            self.delegate.onDelayed()
        }
    }
}

extension CBLockerCentralService: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let canScan = central.state == .poweredOn && centralManager?.isScanning == false
        if canScan {
            centralManager?.scanForPeripherals(withServices: [CBLockerConst.ServiceUUID], options: nil)
        } else {
            if let error = central.state.toSPRError() {
                delegate.onFailure(error)
            }
        }
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let id = advertisementData[CBLockerConst.AdvertisementName] as? String ?? ""
        let locker = CBLockerModel(id: id, peripheral: peripheral)
        delegate.onDiscovered(locker: locker)
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("centralManager didFailToConnect")
        delegate.onFailure(SPRError.CBConnectingFailed)
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("centralManager didConnect")
        peripheral.discoverServices(nil)
    }
}

extension CBManagerState {
    func toSPRError() -> SPRError? {
        switch self {
        case .poweredOff:
            return SPRError.CBPoweredOff
        case .resetting:
            return SPRError.CBResetting
        case .unauthorized:
            return SPRError.CBUnauthorized
        case .unknown:
            return SPRError.CBUnknown
        case .unsupported:
            return SPRError.CBUnsupported
        default:
            break
        }
        return nil
    }
}
