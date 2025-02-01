//
//  AuthenticatorView.swift
//  topik
//
//  Created by Grzegorz Baranowski on 26/01/2025.
//

import SwiftUI
import FirebaseAuth

struct AuthenticatorView: View {

    private enum AuthenticateViewType {
        case login
        case register
    }
    @State private var authenticateViewType: AuthenticateViewType = .login

    @ObservedObject var model: Authenticator

    @FocusState private var focusedField: Bool
    @Environment(\.dismiss) var dismiss

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordRepeat: String = ""

    public var body: some View {
        VStack {
            Picker("test", selection: $authenticateViewType) {
                Text("login").tag(AuthenticateViewType.login)
                Text("register").tag(AuthenticateViewType.register)
            }
            .padding()
            .pickerStyle(.segmented)
            Form {
                TextField("email", text: $email)
                    .focused($focusedField)
                TextField("password", text: $password)
                if authenticateViewType == .register {
                    TextField("password_repeat", text: $passwordRepeat)
                }
                Button {
                    switch authenticateViewType {
                    case .login: model.login(email: email, password: password)
                    case .register: model.register(email: email, password: password)
                    }
                } label: {
                    switch authenticateViewType {
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
