//
//  CBLockerCentralService.swift
//
//
//  Created by Takehito Soi on 2021/06/23.
//

import CoreBluetooth
import Foundation

protocol CBLockerCentralDelegate {
    func execAfterDiscovered(locker: CBLockerModel)
    func execAfterScanning(lockers: [CBLockerModel])
    func failureIfNotCanceled(_ error: SPRError)
}

class CBLockerCentralService: NSObject {
    private var scanSeconds = CBLockerConst.ScanSeconds
    private var delegate: CBLockerCentralDelegate
    
    private var centralManager: CBCentralManager?
    var lockers = [CBLockerModel]()

    init(delegate: CBLockerCentralDelegate) {
        self.delegate = delegate
    }

    var isScanning: Bool {
        return centralManager?.isScanning == true
    }

    func startScan() {
        NSLog("CBLockerCentralService startScan")
        centralManager = CBCentralManager(delegate: self, queue: nil)
        postDelayed()
    }
    
    private func postDelayed() {
        NSLog("CBLockerCentralService postDelayed \(scanSeconds)s")
        DispatchQueue.main.asyncAfter(deadline: .now() + scanSeconds) {
            self.delegate.execAfterScanning(lockers: self.lockers)
        }
    }

    private func collectLocker(locker: CBLockerModel) {
        NSLog("CBLockerCentralService collectLocker \(locker.id)")
        delegate.execAfterDiscovered(locker: locker)

        let index = lockers.firstIndex(where: { $0.peripheral?.identifier == locker.peripheral?.identifier })
        if let index = index {
            lockers[index] = locker
        } else {
            lockers.append(locker)
        }
    }

    func stopScan() {
        if isScanning == true {
            NSLog("CBLockerCentralService stopScan")
            centralManager?.stopScan()
        }
    }

    func connect(peripheral: CBPeripheral) {
        NSLog("CBLockerCentralService connect")
        centralManager?.connect(peripheral, options: nil)
    }

    func discoverServices(peripheral: CBPeripheral) {
        NSLog("CBLockerCentralService discoverServices")
        peripheral.discoverServices([CBLockerConst.ServiceUUID])
    }

    func disconnect(peripheral: CBPeripheral) {
        NSLog("CBLockerCentralService disconnect")
        DispatchQueue.main.asyncAfter(deadline: .now() + CBLockerConst.DelayDisconnectSeconds) {
            NSLog("CBLockerCentralService disconnected")
            self.centralManager?.cancelPeripheralConnection(peripheral)
        }
    }
}

extension CBLockerCentralService: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let readyScan = central.state == .poweredOn && centralManager?.isScanning == false
        if readyScan {
            centralManager?.scanForPeripherals(withServices: [CBLockerConst.ServiceUUID], options: nil)
        } else {
            if let error = central.state.toSPRError() {
                delegate.failureIfNotCanceled(error)
            }
        }
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let id = advertisementData[CBLockerConst.AdvertisementName] as? String ?? ""
        let locker = CBLockerModel(id: id, peripheral: peripheral)
        
        NSLog("CBLockerCentralService didDiscover \(id)")

        collectLocker(locker: locker)
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NSLog("CBLockerCentralService didFailToConnect")
        delegate.failureIfNotCanceled(SPRError.CBConnectingFailed)
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        NSLog("CBLockerCentralService didConnect")
        peripheral.discoverServices([CBLockerConst.ServiceUUID])
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
