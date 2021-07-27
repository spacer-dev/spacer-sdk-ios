//
//  MyLockerGetResData.swift
//
//
//  Created by Takehito Soi on 2021/07/14.
//

import Foundation

struct MyLockerGetResData: IResData {
    var myLockers: [MyLockerResData]?
    var result: Bool
    var error: ErrorResData?
}
