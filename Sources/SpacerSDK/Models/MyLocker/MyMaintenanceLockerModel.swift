//
//  MyMaintenanceLockerModel.swift
//  
//
//  Created by s.norimatsu on 2022/10/24.
//

import CoreBluetooth
import Foundation

public struct MyMaintenanceLockerModel: Identifiable {
    public var id: String
    public var lockedAt: String
    public var expiredAt: String?

    public var description: String {
        "id:\(id),lockedAt:\(lockedAt),expiredAt:\(expiredAt ?? "")"
    }
}

extension MyMaintenanceLockerResData {
    func toModel() -> MyMaintenanceLockerModel {
        return MyMaintenanceLockerModel(id: id, lockedAt: lockedAt, expiredAt: expiredAt)
    }
}
