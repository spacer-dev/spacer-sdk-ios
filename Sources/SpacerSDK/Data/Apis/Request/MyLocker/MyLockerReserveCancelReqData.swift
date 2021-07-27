//
//  MyLockerReserveCancelReqData.swift
//  
//
//  Created by Takehito Soi on 2021/07/14.
//

import Foundation

struct MyLockerReserveCancelReqData: IReqData {
    var spacerId: String

    func toParams() -> [String: Any] {
        [
            "spacerId": spacerId
        ]
    }
}
