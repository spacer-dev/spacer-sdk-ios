//
//  MaintenanceKeyGetResData.swift
//  
//
//  Created by s.norimatsu on 2022/10/24.
//

import Foundation

struct MaintenanceKeyGetResData: IResData {
    var encryptedData: String?
    var result: Bool
    var error: ErrorResData?
}
