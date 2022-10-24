//
//  MyMaintenanceLockerResData.swift
//  
//
//  Created by s.norimatsu on 2022/10/24.
//

import Foundation

struct MyMaintenanceLockerResData: Codable {
    var id: String
    var lockedAt: String
    var expiredAt: String?
}
