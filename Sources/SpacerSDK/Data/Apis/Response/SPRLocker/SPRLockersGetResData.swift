//
//  SPRLockerGetResData.swift
//
//
//  Created by Takehito Soi on 2021/07/13.
//

import Foundation

struct SPRLockersGetResData: IResData {
    var spacers: [SPRLockerResData]?
    var result: Bool
    var error: ErrorResData?
}
