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

    public var description: String {
        return "id:\(id),status:\(status),size:\(size)"
    }
}

extension SPRLockerResData {
    func toModel() -> SPRLockerModel {
        let status = SPRLockerStatus(rawValue: self.status) ?? .unknown
        return SPRLockerModel(id: id, status: status, size: size ?? "unknown")
    }
}
