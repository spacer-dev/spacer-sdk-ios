//
//  SPRLockerUnitGetReqData.swift
//  
//
//  Created by Takehito Soi on 2021/07/14.
//

import Foundation

struct SPRLockerUnitGetReqData: IReqData {
    var unitIds: [String]

    func toParams() -> [String: Any] {
        [
            "unitIds": unitIds
        ]
    }
}
