//
//  LoginView.swift
//  topik
//
//  Created by Grzegorz Baranowski on 26/01/2025.
//

import SwiftUI

struct LoginView: View {

    @FocusState private var focusedField: Bool

    @State private var login: String = ""
    @State private var password: String = ""

    public var body: some View {
        Form {
            TextField("email", text: $login)
                .focused($focusedField)
            TextField("password", text: $password)
            Button {

            } label: {
                Label("login_form_button_label", systemImage: "cross")
            }
        }
        .onAppear {
            focusedField = true
        }
        .navigationTitle("login_title")
    }
}

#Preview {
    LoginView()
}
