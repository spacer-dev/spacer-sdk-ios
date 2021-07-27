//
//  ExampleErrorExtensions.swift
//  Example
//
//  Created by Takehito Soi on 2021/07/19.
//

import Foundation
import SwiftUI

extension ExampleError {
    func toAlertItem() -> AlertItem {
        return AlertItem(title: "\(message)(\(code))")
    }
}
