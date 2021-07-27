//
//  SPRLockerGetReqData.swift
//  
//
//  Created by Takehito Soi on 2021/07/13.
//

import Foundation

struct SPRLockerGetReqData: IReqData {
    var spacerIds: [String]

    func toParams() -> [String: Any] {
        [
            "spacerIds": spacerIds
        ]
    }
}
