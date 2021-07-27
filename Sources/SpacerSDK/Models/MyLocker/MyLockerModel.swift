//
//  MyLockerModel.swift
//
//
//  Created by Takehito Soi on 2021/06/23.
//

import CoreBluetooth
import Foundation

public struct MyLockerModel: Identifiable {
    public var id: String
    public var isReserved: Bool
    public var reservedAt: String?
    public var expiredAt: String?
    public var lockedAt: String?
    public var urlKey: String

    public var description: String {
        "id:\(id),isReserved:\(isReserved),reservedAt:\(reservedAt ?? ""),expiredAt:\(expiredAt ?? ""),lockedAt:\(lockedAt ?? ""),urlKey:\(urlKey)"
    }
}

extension MyLockerResData {
    func toModel() -> MyLockerModel {
        return MyLockerModel(id: id, isReserved: isReserved, reservedAt: reservedAt, expiredAt: expiredAt, lockedAt: lockedAt, urlKey: urlKey)
    }
}
