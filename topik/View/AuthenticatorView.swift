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

    @Binding var requiresAuthorization: Bool

    @State private var authenticationType: AuthenticationType = .login
    @State private var isLoading: Bool = false

    @ObservedObject var model: Authenticator

    @FocusState private var focusedField: Bool

    @State private var email: String = "User@wp.pl"
    @State private var password: String = "Test123456"
    @State private var passwordRepeat: String = ""

    public var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Picker("test", selection: $authenticationType) {
                        Text("login").tag(AuthenticationType.login)
                        Text("register").tag(AuthenticationType.register)
                    }
                    .padding()
                    .pickerStyle(.segmented)
                    .onChange(of: authenticationType) {
                        isLoading = false
                    }
                    Form {
                        TextField("email", text: $email)
                            .focused($focusedField)
                        TextField("password", text: $password)
                        if authenticationType == .register {
                            TextField("password_repeat", text: $passwordRepeat)
                        }
                        Button {
                            isLoading = true
                            switch authenticationType {
                                case .login: model.login(email: email, password: password)
                                case .register: model.register(email: email, password: password)
                            }
                        } label: {
                            switch authenticationType {
                                case .login: Label(
                                    "login_form_button_label",
                                    systemImage: "person.crop.circle"
                                )
                                case .register: Label(
                                    "register_form_button_label",
                                    systemImage: "person.crop.circle.badge.plus"
                                )
                            }
                        }
                    }
                    .onAppear {
                        focusedField = true
                    }
                    .onReceive(model.$currentUser) { user in
                        if user != nil {
                            print("logged in")
                            requiresAuthorization = false
                        }
                    }
                    .navigationTitle("auth_view_title")
                }
                VStack {
                    Spacer()
                    ProgressView()
                        .controlSize(.regular)
                        .opacity(isLoading ? 1 : 0)
                        .padding(.bottom, 40)
                }
            }
        }
    }
}

#Preview {
    AuthenticatorView(requiresAuthorization: .constant(false), model: .mock)
}

// MARK: - model

class Authenticator: ObservableObject {

    @Published var currentUser: User? = nil

    var isNotAuthenticated: Bool {
        get { currentUser == nil }
        set {}
    }

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
