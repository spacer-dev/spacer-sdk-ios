//
//  ErrorResData.swift
//
//
//  Created by Takehito Soi on 2021/07/20.
//

import Foundation

struct ErrorResData: Codable {
    var code: String
    var message: String
}

extension ErrorResData {
    func toExampleError() -> ExampleError {
        ExampleError(code: code, message: message)
    }
}
