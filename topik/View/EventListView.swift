//
//  EventListView.swift
//  topik
//
//  Created by Grzegorz Baranowski on 26/01/2025.
//

import SwiftUI

struct EventListView: View {

    var body: some View {
        NavigationStack {
            List {
                item()
                Button {

                } label: {
                    Text("next")
                        .frame(width: 289, height: 32)
                        .bold()
                        .textCase(.uppercase)
                }
            }
            .navigationTitle("event_list_title")
        }
    }

    func item() -> some View {
        HStack(alignment: .top) {
            Image(systemName: "star")
            VStack(alignment: .leading, spacing: 10) {
                Text("event_name")
                    .font(.headline)
                Text("hello world")
                    .font(.subheadline)
            }
            .bold()
        }
    }
}

#Preview {
    EventListView()
}

// MARK: - model

class EventList: ObservableObject {

}
