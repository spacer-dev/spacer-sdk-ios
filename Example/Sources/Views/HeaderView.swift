//
//  HeaderView.swift
//  Example
//
//  Created by Takehito Soi on 2021/07/21.
//

import Foundation

import SwiftUI

struct HeaderView: View {
    private let title: String

    init(title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.headline)
            .padding()
    }
}
