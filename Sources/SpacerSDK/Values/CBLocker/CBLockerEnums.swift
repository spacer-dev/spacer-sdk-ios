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
}

enum CBLockerStatus {
    case none
    case read
    case write
}

enum CBLockerExecMode {
    case normal
    case retryFromConnBeginning
    case retryFromConnSaveDB
}
