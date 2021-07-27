//
//  KeyGenerateReqData.swift
//
//
//  Created by Takehito Soi on 2021/06/24.
//

import Foundation

struct KeyGenerateReqData: IReqData {
    var spacerId: String
    var readData: String

    func toParams() -> [String: Any] {
        [
            "spacerId": spacerId,
            "readData": readData
        ]
    }
}
