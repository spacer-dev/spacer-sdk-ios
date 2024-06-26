//
//  ApiConst.swift
//
//
//  Created by Takehito Soi on 2021/06/29.
//

import Foundation

class ApiConst {
    static let TimeoutSec = 10.0
    static var BaseURL = SPR.config.baseURL
    static let ApiType = SPR.config.apiType
}

enum ApiPaths {
    static let KeyGenerate = "key/generate"
    static let KeyGenerateResult = "key/generateResult"
    static let KeyGet = "key/get"
    static let KeyGetResult = "key/getResult"
    static let userToken = "user/token"
    static let myLockerGet = "myLocker/get"
    static let myLockerReserve = "myLocker/reserve"
    static let myLockerReserveCancel = "myLocker/reserveCancel"
    static let myLockerShareUrlKey = "myLocker/shared"
    static let myMaintenanceLockerGet = "myLocker/maintenance/get"
    static let lockerSpacerList = "locker/spacer/list"
    static let lockerSpacer = "locker/spacer/"
    static let lockerUnitGet = "locker/unit/get"
    static let LocationGet = "location/get"
    static let LocationRPiBoxPut = "locationRPi/box/put"
    static let LocationRPiBoxTake = "locationRPi/box/take"
    static let LocationRPiBoxOpenForMaintenance = "locationRPi/box/openForMaintenance"
    static let MaintenanceKeyGet = "key/maintenance/get"
    static let MaintenanceKeyGetResult = "key/maintenance/getResult"
}
