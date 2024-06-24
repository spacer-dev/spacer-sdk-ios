//
//  File.swift
//
//
//  Created by ASW on 2024/06/24.
//

import Foundation

struct SPRLockerListGetReqData: IReqData {
    var spacerIds: [String]

    func toParams() -> [String: Any] {
        [
            "spacerIds": spacerIds
        ]
    }
}
