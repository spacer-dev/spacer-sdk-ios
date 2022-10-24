//
//  MyMaintenanceLockerGetResData.swift
//  
//
//  Created by s.norimatsu on 2022/10/24.
//

import Foundation

struct MyMaintenanceLockerGetResData: IResData {
    var myMaintenanceLockers: [MyMaintenanceLockerResData]?
    var result: Bool
    var error: ErrorResData?
}
