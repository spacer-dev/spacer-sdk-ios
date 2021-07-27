//
//  ApiConst.swift
//
//
//  Created by Takehito Soi on 2021/07/20.
//

import Foundation

class ApiConst {
    static let TimeoutInterval = 10.0

    static let ApiBaseURL = ProcessInfo.processInfo.environment["SPR_API_BASE_URL"] ?? ""
    static let ApiKey = ProcessInfo.processInfo.environment["SPR_API_KEY"] ?? ""
    static let ApiUserId = ProcessInfo.processInfo.environment["SPR_API_USER_ID"] ?? ""
}

enum ApiPaths {
    static let userToken = "user/token"
}
