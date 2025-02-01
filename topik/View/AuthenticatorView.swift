//
//  AuthenticatorView.swift
//  topik
//
//  Created by Grzegorz Baranowski on 26/01/2025.
//

import SwiftUI
import FirebaseAuth

struct AuthenticatorView: View {

    private enum AuthenticationType {
        case login
        case register
    }
    @State private var authenticationType: AuthenticationType = .login

    @ObservedObject var model: Authenticator

    @FocusState private var focusedField: Bool
    @Environment(\.dismiss) var dismiss

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordRepeat: String = ""

    public var body: some View {
        VStack {
            Picker("test", selection: $authenticationType) {
                Text("login").tag(AuthenticationType.login)
                Text("register").tag(AuthenticationType.register)
            }
            .padding()
            .pickerStyle(.segmented)
            Form {
                TextField("email", text: $email)
                    .focused($focusedField)
                TextField("password", text: $password)
                if authenticationType == .register {
                    TextField("password_repeat", text: $passwordRepeat)
                }
                Button {
                    switch authenticationType {
                    case .login: model.login(email: email, password: password)
                    case .register: model.register(email: email, password: password)
                    }
                } label: {
                    switch authenticationType {
                    case .login: Label("login_form_button_label", systemImage: "trash")
                    case .register: Label("register_form_button_label", systemImage: "cross")
                    }
                }
            }
            .onAppear {
                focusedField = true
            }
            .onReceive(model.$currentUser) { user in
                if user != nil {
                    dismiss()
                }
            }
            .navigationTitle("register_title")
        }
    }
}

#Preview {
    AuthenticatorView(model: .mock)
}

// MARK: - model

class Authenticator: ObservableObject {

    @Published var currentUser: User? = nil

    required init() {}

    func register(
        email: String,
        password: String
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard error == nil else {
                print("Firebase error: \(String(describing: error))")
                return
            }
            if let user = result?.user {
                self?.currentUser = user
            }
        }
    }

    func login(
        email: String,
        password: String
    ) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard error == nil else {
                print("Firebase error: \(String(describing: error))")
                return
            }
            if let user = result?.user {
                self?.currentUser = user
            }
        }
    }
}

#if DEBUG
extension Authenticator {
    static var mock: Self {
        .init()
    }
}
#endif
