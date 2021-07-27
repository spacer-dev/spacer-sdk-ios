//
//  ItemView.swift
//  Example
//
//  Created by Takehito Soi on 2021/07/20.
//

import Foundation
import SwiftUI

struct SimpleItemView: View {
    private let title: String
    private let desc: String
    private var runnable: () -> Void

    init(title: String, desc: String, runnable: @escaping () -> Void) {
        self.title = title
        self.desc = desc
        self.runnable = runnable
    }

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(desc)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 3)

            Button(action: {
                runnable()
            }) {
                Text(Strings.DefaultBtnText)
                    .font(.body)
            }
            .buttonStyle(BlackButtonStyle())
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 5)
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 1)
        )
    }
}

struct InputItemView: View {
    private let title: String
    private let desc: String
    private let textHint: String
    private var runnable: (String) -> Void

    @State private var text = ""

    init(title: String, desc: String, textHint: String, runnable: @escaping (String) -> Void) {
        self.title = title
        self.desc = desc
        self.textHint = textHint
        self.runnable = runnable
    }

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(desc)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 3)

            TextField(textHint, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: {
                runnable(text.trimmingCharacters(in: .whitespaces))
            }) {
                Text(Strings.DefaultBtnText)
                    .font(.body)
            }
            .buttonStyle(BlackButtonStyle())
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 3)
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 1)
        )
    }
}
