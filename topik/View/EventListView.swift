//
//  EventListView.swift
//  topik
//
//  Created by Grzegorz Baranowski on 26/01/2025.
//

import SwiftUI

struct EventListView: View {
    var model: EventList
    @State private var isNewEventViewVisible: Bool = false
    @AppStorage("canOrganizeEvents") var canOrganizeEvents: Bool = false

    var body: some View {
        NavigationStack {
            List(model.events) { event in
                NavigationLink(value: event) {
                    EventCell(event: event)
                }
            }
            .listStyle(.insetGrouped)
            .navigationDestination(for: Event.self) { event in
                EventDetailView(
                    event: event,
                    eventList: model,
                    hasJoinedEvent: event.participants.contains(model.currentUser)
                )
            }
            .navigationTitle("event_list_title")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                model.setupListenerForEvents()
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
            .sheet(isPresented: $isNewEventViewVisible) {
                newEventFormView(model: model)
            }
        }
    }
}

struct newEventFormView: View {

    var model: EventList
    @Environment(\.dismiss) var dismiss

    @State private var description: String = ""
    @State private var title: String = ""
    @State private var place: String = ""
    @State private var price: String = ""
    @State private var level: String = ""
    @State private var date: Date = Date()

    var body: some View {
        Form {
            Section(header: Text("Enter new event details")) {
                TextField("Event Title", text: $title)
                DatePicker("Event Date", selection: $date, displayedComponents: [.date])
                TextField("Event Place", text: $place)
                TextField("Event price", text: $price)
                    .keyboardType(.numberPad)
                TextField("Event Difficulty", text: $level)
                TextField("Event description", text: $description, axis: .vertical)
                    .lineLimit(10)
                Button {
                    model.create(Event(
                        title: title,
                        description: description,
                        price: Double(price) ?? 0.0,
                        place: place,
                        level: level,
                        date: date,
                        ownerId: model.currentUser,
                        participants: []
                    ))
                    dismiss()
                } label: {
                    Label("Create", systemImage: "calendar.badge.plus")
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

struct EventDetailView: View {
    var event: Event
    var eventList: EventList

    @Environment(\.dismiss) var dismiss
    @State private var hasJoinedEvent: Bool

    init(event: Event, eventList: EventList, hasJoinedEvent: Bool) {
        self.event = event
        self.eventList = eventList
        self.hasJoinedEvent = hasJoinedEvent
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    Text(event.title)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                    HStack {
                        VStack(alignment: .leading, spacing: 15) {
                            Label(event.place, systemImage: "location.fill")
                            Label("\(event.date.formatted(date: .numeric, time: .omitted))", systemImage: "calendar")
                        }
                        .font(.system(.body, design: .rounded, weight: .regular))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        VStack(alignment: .leading, spacing: 15) {
                            Label(String(format: "%.2f", event.price) + " zł", systemImage: "creditcard.fill")
                            Label(event.level, systemImage: "figure.climbing")
                        }
                        .font(.system(.body, design: .rounded, weight: .regular))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(.subheadline, design: .rounded, weight: .light))
                    Divider()
                    Text("Description")
                        .padding(.vertical, 5)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(event.description)
                        .font(.system(.body, design: .rounded, weight: .regular))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(nil)
                    if eventList.currentUser == event.ownerId {
                        Divider()
                        Text("Participants")
                            .padding(.vertical, 5)
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(event.participants, id: \.self) { item in
                            Label(item, systemImage: "backpack")
                                .font(.system(.body, design: .rounded, weight: .regular))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 3)
                        }
                    }
                }
                .padding()
                .navigationBarTitleDisplayMode(.inline)
            }
            VStack {
                Spacer()
                if eventList.currentUser == event.ownerId {
                    Button {
                        eventList.delete(event)
                        dismiss()
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.bordered)
                    .padding(.bottom)
                } else {
                    if !hasJoinedEvent {
                        Button {
                            var event = self.event
                            event.participants.append(eventList.currentUser)
                            eventList.update(event)
                            hasJoinedEvent = true
                        } label: {
                            Label("Join", systemImage: "door.left.hand.open")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.bottom, eventList.currentUser == event.ownerId ? 0 : 15)
                    } else {
                        Button {
                            if let offset = event.participants.firstIndex(of: eventList.currentUser) {
                                var event = self.event
                                event.participants.remove(at: offset)
                                eventList.update(event)
                                hasJoinedEvent = false
                            }
                        } label: {
                            Label("Quit", systemImage: "door.right.hand.open")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.borderless)
                        .padding(.bottom, eventList.currentUser == event.ownerId ? 0 : 15)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - model

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@MainActor
@Observable
class EventList {

    var events: [Event] = []
    let firestore: Firestore

    var currentUser = Auth.auth().currentUser?.email ?? ""

    func setupListenerForEvents() {
        firestore.collection("event")
          .addSnapshotListener { [weak self] document, error in
              guard let data = document?.documents else {
              print("Document data was empty.")
              return
            }
              do {
                  self?.events = try data.compactMap { try $0.data(as: Event.self) }
              } catch { }
            print("Current data: \(data)")
          }
    }

    func create(_ event: Event) {
        do {
            try firestore
                .collection("event")
                .addDocument(from: event)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func delete(_ event: Event) {
        guard let id = event.id else { return }
        firestore
            .collection("event")
            .document(id)
            .delete()
    }

    func update(_ event: Event) {
        guard let id = event.id else { return }
        do {
            try firestore
                .collection("event")
                .document(id)
                .setData(from: event)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    init() {
        self.firestore = Firestore.firestore()
    }
}
