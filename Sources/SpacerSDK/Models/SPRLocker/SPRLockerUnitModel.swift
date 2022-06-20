//
//  SPRLockerUnitModel.swift
//
//
//  Created by Takehito Soi on 2021/07/13.
//

import Foundation

public struct SPRLockerUnitModel: Identifiable {
    public var id: String
    public var dispOrder: Int?
    public var lockerType: Int?
    public var spacers: [SPRLockerModel]?

    public var description: String {
        let spacersText = spacers?.map { $0.description }.joined(separator: "\n") ?? ""
        return "id:\(id),spacers:\n\(spacersText)"
    }
}

extension SPRLockerUnitResData {
    func toModel() -> SPRLockerUnitModel {
        let spacers = spacers?.map { $0.toModel() }
        return SPRLockerUnitModel(id: id, spacers: spacers)
    }
}
