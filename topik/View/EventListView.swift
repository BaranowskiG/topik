//
//  EventListView.swift
//  topik
//
//  Created by Grzegorz Baranowski on 26/01/2025.
//

import SwiftUI

struct EventListView: View {
    @ObservedObject var model: EventList
    @State private var isNewEventViewVisible: Bool = false
    @AppStorage("canOrganizeEvents") var canOrganizeEvents: Bool = false

    var body: some View {
        NavigationStack {
            List(model.events) { event in
                NavigationLink(value: event) {
                    EventCell(event: event)
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
                UserDefaults.standard.synchronize()
            }
            .toolbar {
                if canOrganizeEvents {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isNewEventViewVisible = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
    }
}

struct EventCell: View {
    var event: Event

    var body: some View {
        VStack(spacing: 4) {
            Text(event.title)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                .padding(.bottom, 5)
            HStack {
                VStack(alignment: .leading, spacing: 9) {
                    Label(event.place, systemImage: "location.fill")
                    Label("\(event.date.formatted(date: .numeric, time: .omitted))", systemImage: "calendar")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading, spacing: 9) {
                    Label(String(format: "%.2f", event.price) + " zł", systemImage: "creditcard.fill")
                    Label(event.level, systemImage: "figure.climbing")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.system(.caption, design: .rounded, weight: .light))
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
