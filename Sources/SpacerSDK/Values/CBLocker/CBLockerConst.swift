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
    public static let MaxRetryNum = SPR.config.maxRetryNum
    public static let ApiType = SPR.config.apiType
    static let DelayDisconnectSeconds: Double = 3.0
    static let ServiceUUID = CBUUID(string: "FF10")
    static let CharacteristicUUID = CBUUID(string: "FF11")
    static let AdvertisementName = "kCBAdvDataLocalName"
    static let PutKeyPrefix = "543214723567xxxrw"
    static let TakeKeyPrefix = "543214723567xxxw"
    static let UsingReadData = ["using"]
    static let WriteReadData = ["rwsuccess", "wsuccess"]
    static let UsingOrWriteReadData = UsingReadData + WriteReadData

    static let StartTimeoutSeconds = 5.0
    static let DiscoverTimeoutSeconds = 5.0
    static let ReadTimeoutSeconds = 5.0
    static let WriteTimeoutSeconds = 5.0
    static let DuringTimeoutSeconds = 60.0
}
