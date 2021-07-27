//
//  UserTokenReqData.swift
//
//
//  Created by Takehito Soi on 2021/07/20.
//

import Foundation

struct UserTokenReqData: IReqData {
    var apiKey: String
    var userId: String

    func toParams() -> [String: Any] {
        [
            "apiKey": apiKey,
            "userId": userId,
        ]
    }
}
