//
//  MyLockerSharedReqData.swift
//
//
//  Created by Takehito Soi on 2021/07/09.
//

import Foundation

struct MyLockerSharedReqData: IReqData {
    var urlKey: String

    func toParams() -> [String: Any] {
        [
            "urlKey": urlKey
        ]
    }
}
