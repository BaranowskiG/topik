//
//  RegisterView.swift
//  topik
//
//  Created by Grzegorz Baranowski on 26/01/2025.
//

import SwiftUI
import FirebaseAuth

struct RegisterView: View {

    @ObservedObject var model: Register

    @FocusState private var focusedField: Bool
    @Environment(\.dismiss) var dismiss

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordRepeat: String = ""

    public var body: some View {
        Form {
            TextField("email", text: $email)
                .focused($focusedField)
            TextField("password", text: $password)
            TextField("password_repeat", text: $passwordRepeat)
            Button {
                model.register(email: email, password: password)
            } label: {
                Label("register_form_button_label", systemImage: "cross")
            }
        }
        .onAppear {
            focusedField = true
        }
        .onReceive(model.$isOperationSuccessful) { isSuccessful in
            if isSuccessful {
                dismiss()
            }
        }
        .navigationTitle("register_title")
    }
}

#Preview {
    RegisterView(model: .mock)
}


class Register: ObservableObject {

    @Published var isOperationSuccessful: Bool = false

    required init() {}

    func register(
        email: String,
        password: String
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard error == nil else {
                print("Firebase error: \(String(describing: error))")
                self?.isOperationSuccessful = false
                return
            }
            if let _ = result?.user {
                self?.isOperationSuccessful = true
            }
        }
    }
}

#if DEBUG
extension Register {
    static var mock: Self {
        .init()
    }
}
#endif
