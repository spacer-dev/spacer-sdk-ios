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
    var status: CBLockerStatus = .none
    var readData: String = ""
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?

    mutating func update(status: CBLockerStatus) {
        self.status = status
    }
}
