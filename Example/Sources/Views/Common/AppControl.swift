//
//  AppControl.swift
//  Example
//
//  Created by Takehito Soi on 2021/06/22.
//

import Foundation

class AppControl: ObservableObject {
    static let shared = AppControl()

    @Published var zIndex: Double = 0.0

    func showLoading() {
        zIndex = 1.0
    }

    func hideLoading() {
        zIndex = 0.0
    }
}
