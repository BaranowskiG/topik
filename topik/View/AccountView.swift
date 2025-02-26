//
//  AccountView.swift
//  topik
//
//  Created by Grzegorz Baranowski on 16/02/2025.
//

import SwiftUI
import FirebaseAuth

public struct AccountView: View {

    var account: Account

    @State private var copyText = "Kopiuj"
    @Binding var requiresAuthentication: Bool

    public var body: some View {
        NavigationStack {
            List {
                Section("account.user data") {
                    DetailedRow(title: "Email", detail: account.user?.email)
                    DetailedRow(title: "Numer telefonu", detail: account.user?.phoneNumber)
                    DetailedRow(title: "Ostatnie logowanie", detail: account.user?.metadata.lastSignInDate?.formatted(date: .numeric, time: .shortened))
                    DetailedRow(title: "Konto utworzona", detail: account.user?.metadata.creationDate?.formatted(date: .numeric, time: .shortened))
                }
                Section("developer data") {
                    DetailedRow(title: "Id", detail: account.user?.uid)
                    DetailedRow(title: "Dostawca", detail: account.user?.providerID)
                    NavigationLink {
                        VStack {
                            Text(account.user?.refreshToken ?? "Error: refresh token not found")
                                .multilineTextAlignment(.leading)
                            Button(copyText) {
                                UIPasteboard.general.string = account.user?.refreshToken ?? "Error: refresh token not found"
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
                        Task {
                            await account.signOut()

                        }
                        requiresAuthentication = true
                    }
                    Button("delete account", role: .destructive) {
                        Task {
                            await account.deleteAccount()
                        }
                        requiresAuthentication = true
                    }
                }
            }
            .navigationTitle("account_view_title")
            .onAppear {
                account.user = Auth.auth().currentUser
            }
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

// MARK: - model

@Observable
class Account {

    var user: User?

    init() {
        self.user = Auth.auth().currentUser
    }

    func signOut() async {
        do {
            try Auth.auth().signOut()
        } catch {
            print("failed to signOut user")
        }
    }

    func deleteAccount() async {
        user?.delete { error in
          if let error = error {
            // An error happened.
              print("account not deleted. Error \(error.localizedDescription)")
          } else {
            // Account deleted.
              print("account deleted")
          }
        }
    }

}
