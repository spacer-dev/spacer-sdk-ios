//
//  CBLockerConst.swift
//
//
//  Created by Takehito Soi on 2021/06/23.
//

import CoreBluetooth
import Foundation

public enum CBLockerConst {
    public static let ScanSeconds = SPR.config.scanSeconds
    static let DelayDisconnectSeconds: Double = 2.5
    static let ServiceUUID = CBUUID(string: "FF10")
    static let CharacteristicUUID = CBUUID(string: "FF11")
    static let AdvertisementName = "kCBAdvDataLocalName"
    static let PutKeyPrefix = "543214723567xxxrw"
    static let TakeKeyPrefix = "543214723567xxxw"
}
