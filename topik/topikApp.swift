//
//  topikApp.swift
//  topik
//
//  Created by Grzegorz Baranowski on 26/01/2025.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("failed to signOut user")
        }
    }
}


@main
struct topikApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}


struct MainTabView: View {

    @State private var requiresAuthorization: Bool = {
        Auth.auth().currentUser == nil
    }()

    var body: some View {
        TabView {
            EventListView(model: .init())
                .tabItem {
                    Label("tab_list", systemImage: "list.bullet.circle.fill")
                }
            DiaryView()
                .tabItem {
                    Label("tab_diary", systemImage: "book.closed.circle.fill")
                }
            AccountView(user: Auth.auth().currentUser!)
                .tabItem {
                    Label("tab_account", systemImage: "person.crop.circle.fill")
                }
        }
        .sheet(isPresented: $requiresAuthorization) {
            AuthenticatorView(requiresAuthorization: $requiresAuthorization, model: .init())
                .interactiveDismissDisabled()
        }
    }
}

#Preview {
    EventListView(model: .init())
}
