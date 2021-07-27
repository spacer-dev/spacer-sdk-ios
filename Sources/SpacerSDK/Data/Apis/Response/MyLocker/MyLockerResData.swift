//
//  MyLockerResData.swift
//
//
//  Created by Takehito Soi on 2021/06/24.
//

import Foundation

struct MyLockerResData: Codable {
    var id: String
    var isReserved: Bool
    var reservedAt: String?
    var expiredAt: String?
    var lockedAt: String?
    var urlKey: String
}
