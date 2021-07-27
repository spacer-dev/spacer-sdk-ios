//
//  SPRLockerUnitResData.swift
//
//
//  Created by Takehito Soi on 2021/07/13.
//

import Foundation

struct SPRLockerUnitResData: Codable {
    public var id: String
    public var open: String?
    public var close: String?
    public var address: String?
    public var spacers: [SPRLockerResData]?
}
