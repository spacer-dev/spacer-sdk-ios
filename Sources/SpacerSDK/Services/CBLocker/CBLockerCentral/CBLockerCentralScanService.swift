//
//  CBLockerCentralScanService.swift
//
//
//  Created by Takehito Soi on 2021/06/23.
//

import CoreBluetooth
import Foundation

class CBLockerCentralScanService: NSObject {
    private var token: String!
    private var success: ([SPRLockerModel]) -> Void = { _ in }
    private var failure: (SPRError) -> Void = { _ in }

    private var centralService: CBLockerCentralService?
    private var sprLockerService = SPRLockerService()
    private var isCanceled = false
    private var scannedLockers: [CBLockerModel] = []

    override init() {
        super.init()
        self.centralService = CBLockerCentralService(delegate: self)
    }

    func scan(token: String, success: @escaping ([SPRLockerModel]) -> Void, failure: @escaping (SPRError) -> Void) {
        self.token = token
        self.success = success
        self.failure = failure
        
        centralService?.startScan()
    }

    private func convertSprLockers(lockers: [CBLockerModel]) {
        scannedLockers = lockers
        let spacerIds = lockers.map { $0.id }
        sprLockerService.getLockers(
            token: token,
            spacerIds: spacerIds,
            success: successIfNotCanceled,
            failure: failureIfNotCanceled)
    }
}

extension CBLockerCentralScanService: CBLockerCentralDelegate {
    func execAfterDiscovered(locker: CBLockerModel) {}

    func execAfterScanning(lockers: [CBLockerModel]) -> Bool {
        if !lockers.isEmpty {
            convertSprLockers(lockers: lockers)
        }
        return !lockers.isEmpty
    }

    func successIfNotCanceled(sprLockers: [SPRLockerModel]) {
        print("スキャンに成功しました")
        centralService?.stopScan()

        var sprLockers = sprLockers
        if !isCanceled {
            scannedLockers.forEach { scannedlocker in
                sprLockers.enumerated().forEach { index, sprLocker in
                    if sprLocker.id == scannedlocker.id {
                        sprLockers[index].isScanned = true
                        print("\(scannedlocker.id)のisScannedをtrueにしました")
                    }
                }
            }
            isCanceled = true
            print("スキャンに成功したロッカー一覧\(sprLockers)")
            success(sprLockers)
        }
    }

    func failureIfNotCanceled(_ error: SPRError) {
        print("スキャンに失敗しました")
        centralService?.stopScan()

        if !isCanceled {
            isCanceled = true
            print("error:\(error)")
            failure(error)
        }
    }
}
