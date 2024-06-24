//
//  File.swift
//  
//
//  Created by ASW on 2024/06/24.
//

import Foundation

struct SPRLockerListGetResData: IResData {
    var spacers: [SPRLockerResData]?
    var result: Bool
    var error: ErrorResData?
}
