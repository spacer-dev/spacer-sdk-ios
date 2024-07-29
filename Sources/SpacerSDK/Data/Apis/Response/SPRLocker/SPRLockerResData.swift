//
//  SpacerResData.swift
//
//
//  Created by Takehito Soi on 2021/07/13.
//

import Foundation

struct SPRLockerResData: Codable {
    public var id: String
    public var status: String
    public var size: String?
    public var closedWait: String
    public var version: String
    public var doorStatus: String
    public var doorStatusExpiredAt: String?
    public var isHttpSupported: Bool
}
