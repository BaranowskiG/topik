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

    @State private var copyText = "Kopiuj"

    public var body: some View {
        NavigationStack {
            List {
                Section("User data") {
                    DetailedRow(title: "Email", detail: user.email)
                    DetailedRow(title: "Numer telefonu", detail: user.phoneNumber)
                    DetailedRow(title: "Ostatnie logowanie", detail: user.metadata.lastSignInDate?.formatted(date: .numeric, time: .shortened))
                    DetailedRow(title: "Konto utworzona", detail: user.metadata.creationDate?.formatted(date: .numeric, time: .shortened))
                }
                Section("developer data") {
                    DetailedRow(title: "Id", detail: user.uid)
                    DetailedRow(title: "Dostawca", detail: user.providerID)
                    NavigationLink {
                        VStack {
                            Text(user.refreshToken ?? "Error: refresh token not found")
                                .multilineTextAlignment(.leading)
                            Button(copyText) {
                                UIPasteboard.general.string = user.refreshToken ?? "Error: refresh token not found"
                                copyText = "Skopiowano"
                            }
                            .onAppear {
                                copyText = "Kopiuj"
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
