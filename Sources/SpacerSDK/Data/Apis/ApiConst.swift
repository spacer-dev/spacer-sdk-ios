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
    static let myLockerShared = "myLocker/shared"
    static let lockerSpacerGet = "locker/spacer/get"
    static let lockerUnitGet = "locker/unit/get"
}
