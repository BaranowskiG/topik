//
//  ContentView.swift
//  topik
//
//  Created by Grzegorz Baranowski on 26/01/2025.
//

import SwiftUI

struct WelcomeView: View {

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("welcome_title")
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .fontDesign(.rounded)
                .font(.largeTitle)
                .bold()
                .padding(.vertical)
            item
            Spacer()
            Button {
                dismiss()
            } label: {
                Text("OK")
                    .frame(width: 289, height: 32)
                    .bold()
                    .textCase(.uppercase)
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .padding(.vertical)

        }
        .padding(.horizontal, 32)
        .padding(.top, 32)
    }

    var item: some View {
        VStack(spacing: 64) {
            Label("welcome_point_1", systemImage: "star")
            Label("welcome_point_2", systemImage: "star")
            Label("welcome_point_3", systemImage: "star")
        }
    }
}

#Preview {
    WelcomeView()
}
