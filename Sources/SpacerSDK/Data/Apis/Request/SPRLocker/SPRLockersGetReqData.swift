//
//  SPRLockerGetReqData.swift
//  
//
//  Created by Takehito Soi on 2021/07/13.
//

import Foundation

struct SPRLockersGetReqData: IReqData {
    var spacerIds: [String]

    func toParams() -> [String: Any] {
        [
            "spacerIds": spacerIds
        ]
    }
}
