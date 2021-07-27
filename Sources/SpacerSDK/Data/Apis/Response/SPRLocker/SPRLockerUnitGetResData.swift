//
//  SPRLockerUnitGetResData.swift
//  
//
//  Created by Takehito Soi on 2021/07/14.
//

import Foundation

struct SPRLockerUnitGetResData: IResData {
    var units: [SPRLockerUnitResData]?
    var result: Bool
    var error: ErrorResData?
}
