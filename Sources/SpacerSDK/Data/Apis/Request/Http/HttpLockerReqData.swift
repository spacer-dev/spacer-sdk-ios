//
//  HttpLockerReqData.swift
//
//
//  Created by ASW on 2024/06/20.
//

import Foundation

struct HttpLockerReqData: IReqData {
    var spacerId: String

    func toParams() -> [String: Any] {
        let params: [String: Any] = ["spacerId": spacerId]
        return params
    }
}
