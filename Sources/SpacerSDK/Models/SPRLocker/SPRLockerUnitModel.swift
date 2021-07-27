//
//  SPRLockerUnitModel.swift
//
//
//  Created by Takehito Soi on 2021/07/13.
//

import Foundation

public struct SPRLockerUnitModel: Identifiable {
    public var id: String
    public var open: String?
    public var close: String?
    public var address: String?
    public var spacers: [SPRLockerModel]?

    public var description: String {
        let spacersText = spacers?.map { $0.description }.joined(separator: "\n") ?? ""
        return "id:\(id),open:\(open ?? ""),close:\(close ?? ""),address:\(address ?? ""),spacers:\n\(spacersText)"
    }
}

extension SPRLockerUnitResData {
    func toModel() -> SPRLockerUnitModel {
        let spacers = spacers?.map { $0.toModel() }
        return SPRLockerUnitModel(id: id, open: open, close: close, address: address, spacers: spacers)
    }
}
