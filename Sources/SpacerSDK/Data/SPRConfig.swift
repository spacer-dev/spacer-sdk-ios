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
    var maxRetryNum: Int

    public init(
        baseURL: String = SPRConst.BaseURL,
        scanSeconds: Double = SPRConst.ScanSeconds,
        maxRetryNum: Int = SPRConst.MaxRetryNum)
    {
        self.baseURL = baseURL
        self.scanSeconds = scanSeconds
        self.maxRetryNum = maxRetryNum
    }

    static let Default = SPRConfig()
}
