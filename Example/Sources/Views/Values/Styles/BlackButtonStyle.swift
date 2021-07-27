//
//  BlackButtonStyle.swift
//  Example
//
//  Created by Takehito Soi on 2021/06/22.
//

import SwiftUI

struct BlackButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        BlackButton(configuration: configuration)
    }

    struct BlackButton: View {
        @Environment(\.isEnabled) var isEnabled
        let configuration: BlackButtonStyle.Configuration
        var body: some View {
            configuration.label
                .foregroundColor(.white)
                .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
                .opacity(configuration.isPressed ? 0.2 : 1.0)
                .padding(10)
                .background(isEnabled ? Color.black.opacity(0.8) : .gray)
                .cornerRadius(8)
        }
    }
}
