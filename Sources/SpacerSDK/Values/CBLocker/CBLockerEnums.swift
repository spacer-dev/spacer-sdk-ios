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
//  [変更前]
    case read
//  [変更後]
//  case checkDoorStatusAvailable
}

enum CBLockerStatus {
    case none
    case read
    case write
}
