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
    func execAfterScanning(lockers: [CBLockerModel]) -> Bool
    func failureIfNotCanceled(_ error: SPRError)
}

class CBLockerCentralService: NSObject {
    static let MaxScanningCnt = 3
    private var scanSeconds = CBLockerConst.ScanSeconds
    private var delegate: CBLockerCentralDelegate
    private var scanningCnt = 0
    
    private var centralManager: CBCentralManager?
    var lockers = [CBLockerModel]()

    init(delegate: CBLockerCentralDelegate) {
        self.delegate = delegate
    }

    var isScanning: Bool {
        return centralManager?.isScanning == true
    }

    func startScan() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        postDelayed()
    }
    
    private func postDelayed() {
        DispatchQueue.main.asyncAfter(deadline: .now() + scanSeconds) { [self] in
            scanningCnt += 1
            let isScanned = self.delegate.execAfterScanning(lockers: self.lockers)
            if isScanned {
                return self.stopScan()
            }

            if self.scanningCnt > CBLockerCentralService.MaxScanningCnt {
                print("9秒間スキャンを行ったため、スキャンを中止します")
                self.stopScan()
                delegate.failureIfNotCanceled(SPRError.CBCentralTimeout)
            } else {
                self.postDelayed()
            }
        }
    }

    private func collectLocker(locker: CBLockerModel) {
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
            centralManager?.stopScan()
        }
    }

    func connect(peripheral: CBPeripheral) {
        print("コネクト開始")
        centralManager?.connect(peripheral, options: nil)
    }

    func discoverServices(peripheral: CBPeripheral) {
        print("サービス検出開始")
        peripheral.discoverServices([CBLockerConst.ServiceUUID])
    }

    func disconnect(peripheral: CBPeripheral) {
        print("disconnect開始")
        DispatchQueue.main.asyncAfter(deadline: .now() + CBLockerConst.DelayDisconnectSeconds) {
            self.centralManager?.cancelPeripheralConnection(peripheral)
        }
    }
}

extension CBLockerCentralService: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let readyScan = central.state == .poweredOn && centralManager?.isScanning == false
        if readyScan {
            print("スキャン開始")
            centralManager?.scanForPeripherals(withServices: [CBLockerConst.ServiceUUID], options: nil)
        } else {
            if let error = central.state.toSPRError() {
                print("スキャンできる状態ではありません")
                delegate.failureIfNotCanceled(error)
            }
        }
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("ペリフェラルを検出しました")
        let id = advertisementData[CBLockerConst.AdvertisementName] as? String ?? ""
        let locker = CBLockerModel(id: id, peripheral: peripheral)
        collectLocker(locker: locker)
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("コネクトに失敗しました")
        delegate.failureIfNotCanceled(SPRError.CBConnectingFailed)
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("コネクトに成功しました")
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
