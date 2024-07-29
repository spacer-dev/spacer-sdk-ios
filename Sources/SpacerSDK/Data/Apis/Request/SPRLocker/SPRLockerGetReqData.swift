//
//  SPRLockerGetReqData.swift
//  
//
//  Created by Takehito Soi on 2021/07/13.
//

import Foundation

struct SPRLockerGetReqData: IReqData {
//  [変更前]
    var spacerIds: [String]
//  [変更後]
//  var spacerId: String

    func toParams() -> [String: Any] {
        [
//          [変更前]
            "spacerIds": spacerIds
//          [変更後]
//          "spacerId": spacerId
        ]
    }
}
