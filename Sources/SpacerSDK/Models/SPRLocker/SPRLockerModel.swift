//
//  SPRLockerModel.swift
//
//
//  Created by Takehito Soi on 2021/07/13.
//

import Foundation

public struct SPRLockerModel: Identifiable {
    public var id: String
    public var status: SPRLockerStatus
    public var size: String
    public var closedWait: String
    public var version: String
    public var doorStatus: String
    public var doorStatusExpiredAt: String?

    public var description: String {
        return "id:\(id),status:\(status),size:\(size),closedWait:\(closedWait),version:\(version),doorStatus:\(doorStatus),doorStatusExpiredAt:\(doorStatusExpiredAt ?? "")"
    }
}

extension SPRLockerResData {
    func toModel() -> SPRLockerModel {
        let status = SPRLockerStatus(rawValue: self.status) ?? .unknown
        return SPRLockerModel(id: id, status: status, size: size ?? "unknown", closedWait: closedWait, version: version, doorStatus: doorStatus, doorStatusExpiredAt: doorStatusExpiredAt)
    }
}
