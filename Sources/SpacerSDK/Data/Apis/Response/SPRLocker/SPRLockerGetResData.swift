//
//  SPRLockerGetResData.swift
//
//
//  Created by Takehito Soi on 2021/07/13.
//

import Foundation

struct SPRLockerGetResData: IResData {
//  [変更前]
    var spacers: [SPRLockerResData]?
//  [変更後]
//  var spacer: SPRLockerResData?
    var result: Bool
    var error: ErrorResData?
}
