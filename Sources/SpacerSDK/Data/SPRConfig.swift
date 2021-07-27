//
//  SPRConfig.swift
//
//
//  Created by Takehito Soi on 2021/07/20.
//

import Foundation

public struct SPRConfig {
    var baseURL: String
    public init(baseURL: String) {
        self.baseURL = baseURL
    }

    static let Default = SPRConfig(baseURL: "https://ex-app.spacer.co.jp")
}
