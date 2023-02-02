//
//  CBLockerModel.swift
//
//
//  Created by Takehito Soi on 2021/06/23.
//

import CoreBluetooth
import Foundation

public struct CBLockerModel: Identifiable {
    public var id: String
    private(set) var status: CBLockerStatus = .none
    private(set) var readData: String = ""
    private(set) var peripheral: CBPeripheral?

    mutating func setPeripheral(_ peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }

    mutating func setReadData(_ readData: String) {
        self.readData = readData
    }

    mutating func updateStatus(_ status: CBLockerStatus) {
        self.status = status
    }

    mutating func resetToConnect() {
        self.readData = ""
        self.status = .none
    }
}
