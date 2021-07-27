//
//  ErrorResData.swift
//
//
//  Created by Takehito Soi on 2021/06/24.
//

import Foundation

struct ErrorResData: Codable {
    var code: String
    var message: String

    func toSPRError() -> SPRError {
        SPRError(code: code, message: message)
    }
}
