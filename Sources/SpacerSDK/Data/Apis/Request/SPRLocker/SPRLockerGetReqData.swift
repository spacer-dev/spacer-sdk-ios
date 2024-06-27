//
//  SPRLockerGetReqData.swift
//
//
//  Created by ASW on 2024/06/19.
//

import Foundation

struct SPRLockerGetReqData: IReqData {
    var spacerId: String

    func toParams() -> [String: Any] {
        [
            "spacerId": spacerId
        ]
    }
}
