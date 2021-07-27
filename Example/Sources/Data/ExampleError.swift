//
//  ExampleError.swift
//
//  Created by Takehito Soi on 2021/07/20.
//

import Foundation
import SpacerSDK

class ExampleError {
    public var code: String
    public var message: String

    public init(code: String, message: String) {
        self.code = code
        self.message = message
    }

    static let TestError = ExampleError(code: "E00000000", message: "example error")
}
