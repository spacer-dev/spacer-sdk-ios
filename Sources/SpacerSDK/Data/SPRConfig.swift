//
//  SPRConfig.swift
//
//
//  Created by Takehito Soi on 2021/07/20.
//

import Foundation

public struct SPRConfig {
    var baseURL: String
    var scanSeconds: Double

    public init(
        baseURL: String = SPRConst.BaseURL,
        scanSeconds: Double = SPRConst.ScanSeconds) {
        self.baseURL = baseURL
        self.scanSeconds = scanSeconds
    }

    static let Default = SPRConfig()
}
