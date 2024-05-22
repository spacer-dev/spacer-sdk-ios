//
//  MaintenanceKeyGetResultReqData.swift
//  
//
//  Created by s.norimatsu on 2022/10/24.
//

import Foundation

struct MaintenanceKeyGetResultReqData: IReqData {
    var spacerId: String

    func toParams() -> [String: Any] {
        [
            "spacerId": spacerId
        ]
    }
}
