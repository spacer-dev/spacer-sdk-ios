//
//  LoadingView.swift
//  Example
//
//  Created by Takehito Soi on 2021/06/22.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.gray)
                .opacity(0.6)
            ProgressView("loading")
        }
    }
}
