//
//  CBLockerEnums.swift
//
//
//  Created by Takehito Soi on 2021/07/13.
//

import Foundation

enum CBLockerActionType {
    case put
    case take
    case openForMaintenance
    case checkDoorStatusAvailable
}

enum CBLockerStatus {
    case none
    case read
    case write
}
