//
//  CBLockerCentralScanService.swift
//
//
//  Created by Takehito Soi on 2021/06/23.
//

import CoreBluetooth
import Foundation

class CBLockerCentralScanService: NSObject {
    private var sprLockerService = SPRLockerService()
    private var centralService: CBLockerCentralService?

    private var token = String()
    private var success: ([SPRLockerModel]) -> Void = { _ in }
    private var failure: (SPRError) -> Void = { _ in }

    private var lockers = [CBLockerModel]()

    override init() {
        super.init()
        self.centralService = CBLockerCentralService(delegate: self)
    }

    func scan(token: String, success: @escaping ([SPRLockerModel]) -> Void, failure: @escaping (SPRError) -> Void) {
        self.token = token
        self.success = success
        self.failure = failure

        centralService?.scan()
    }
}

extension CBLockerCentralScanService: CBLockerCentralDelegate {
    func onDiscovered(locker: CBLockerModel) {
        let index = lockers.firstIndex(where: { $0.peripheral?.identifier == locker.peripheral?.identifier })

        if let index = index {
            lockers[index] = locker
        } else {
            lockers.append(locker)
        }
    }

    func onDelayed() {
        centralService?.stopScan()

        let spacerIds = lockers.map { $0.id }
        sprLockerService.get(
            token: token,
            spacerIds: spacerIds,
            success: success,
            failure: failure)
    }

    func onFailure(_ error: SPRError) {
        failure(error)
    }
}
