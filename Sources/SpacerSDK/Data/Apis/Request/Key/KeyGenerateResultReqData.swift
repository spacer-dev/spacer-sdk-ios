//
//  KeyGenerateResultReqData.swift
//
//
//  Created by Takehito Soi on 2021/06/24.
//

import Foundation

struct KeyGenerateResultReqData: IReqData {
    var spacerId: String

    func toParams() -> [String: Any] {
        [
            "spacerId": spacerId
        ]
    }
}
