//
//  MyLockerReserveReqData.swift
//
//
//  Created by Takehito Soi on 2021/07/14.
//

import Foundation

struct MyLockerReserveReqData: IReqData {
    var spacerId: String

    func toParams() -> [String: Any] {
        [
            "spacerId": spacerId
        ]
    }
}
