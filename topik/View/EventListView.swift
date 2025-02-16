//
//  EventListView.swift
//  topik
//
//  Created by Grzegorz Baranowski on 26/01/2025.
//

import SwiftUI

struct EventListView: View {

    @ObservedObject var model: EventList

    var body: some View {
        NavigationStack {
            List(model.events) { event in
                NavigationLink(value: event) {
                    item(event)
                }
            }
            .navigationDestination(for: Event.self) { event in
                Text(event.title)
            }
            .navigationTitle("event_list_title")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                Task {
                    await model.fetch()
                }
            }
        }
    }

    func item(_ event: Event) -> some View {
        HStack(alignment: .top) {
            Image(systemName: "star")
            VStack(alignment: .leading, spacing: 10) {
                Text(event.title)
                    .font(.headline)
                Text("\(event.price)")
                    .font(.subheadline)
            }
            .bold()
        }
    }
}

#Preview {
    EventListView(model: .init())
}

// MARK: - model

import FirebaseCore
import FirebaseFirestore

class EventList: ObservableObject {

    @Published var events: [Event] = []
    let firestore: Firestore

    @MainActor
    func fetch() async {
        guard events.isEmpty else { return }
        do {
            events = try await firestore
                .collection("event")
                .getDocuments()
                .documents
                .compactMap { try $0.data(as: Event.self) }
            print("Events: \(events)")
        } catch let error {
            print(error.localizedDescription)
        }
    }

    init() {
        self.firestore = Firestore.firestore()
    }

}
