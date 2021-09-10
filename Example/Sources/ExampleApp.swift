//
//  ExampleApp.swift
//  Example
//
//  Created by Takehito Soi on 2021/07/19.
//

import SpacerSDK
import SwiftUI

@main
struct ExampleApp: App {
    @StateObject private var appControl = AppControl.shared
    var body: some Scene {
        WindowGroup {
            ZStack {
                LoadingView().zIndex(appControl.zIndex)
                ContentView()
                    .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
            }
        }
    }

    init() {
        if let baseURL = ProcessInfo.processInfo.environment["SDK_BASE_URL"] {
            let config = SPRConfig(baseURL: baseURL)
            SPR.configure(config: config)
        }
    }
}
