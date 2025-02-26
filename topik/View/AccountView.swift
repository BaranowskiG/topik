//
//  AccountView.swift
//  topik
//
//  Created by Grzegorz Baranowski on 16/02/2025.
//

import SwiftUI
import FirebaseAuth

public struct AccountView: View {

    let user: User

    public var body: some View {
        NavigationStack {
            List {
                Section("User data") {
                    DetailedRow(title: "Email", detail: user.email)
                    DetailedRow(title: "Phone number", detail: user.phoneNumber)
                    DetailedRow(title: "Last sign in at:", detail: user.metadata.lastSignInDate?.formatted(date: .numeric, time: .shortened))
                    DetailedRow(title: "Created at:", detail: user.metadata.creationDate?.formatted(date: .numeric, time: .shortened))
                }
                Section("developer data") {
                    DetailedRow(title: "Id", detail: user.uid)
                    DetailedRow(title: "Provider", detail: user.providerID)
                    NavigationLink {
                        VStack {
                            Text(user.refreshToken ?? "Error: refresh token not found")
                                .multilineTextAlignment(.leading)
                            Button("Copy") {
                                UIPasteboard.general.string = user.refreshToken ?? "Error: refresh token not found"
                            }
                            .padding()
                        }
                        .padding(.horizontal, 50)
                    } label: {
                        Text("Refresh token")
                    }

                }
                Section("Manage") {
                    Button("log out", role: .cancel) {

                    }
                    Button("delete account", role: .destructive) {

                    }
                }
            }
            .navigationTitle("account_view_title")
        }
    }
}

fileprivate struct DetailedRow: View {
    let title: String
    var detail: String? = nil

    var body: some View {
        HStack() {
            Text(title)
            if let detail {
                Spacer()
                Text(detail).foregroundColor(Color(.secondaryLabel))
            }
        }
    }
}

fileprivate extension Date? {
    func displaySimpleFormat() -> String {
        guard let self else {
            return ""
        }

        return self.formatted(date: .complete, time: .shortened)
    }
}

// MARK: - model


class Account: ObservableObject {

}
