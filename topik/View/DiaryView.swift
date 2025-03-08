//
//  DiaryView.swift
//  topik
//
//  Created by Grzegorz Baranowski on 16/02/2025.
//

import SwiftUI
import SwiftData

struct DiaryView: View {
    @Environment(\.modelContext) private var context
    @Query var notes: [Note]

    @State private var isNewDiaryViewVisible = false
    @State private var title = ""
    @State private var value = ""
    @State private var thumbnail = "photo"

    let availableThumbnails: [String] = ["photo", "music.note", "book.closed", "folder", "film"]

    var body: some View {
        NavigationStack {
            List {
                ForEach(notes) { note in
                    NavigationLink(value: note) {
                        Label(note.title, systemImage: note.thumbnail)
                    }
                }
                .onDelete { offsets in
                    for offset in offsets {
                        let note = notes[offset]
                        context.delete(note)
                    }
                }
            }
            .navigationDestination(for: Note.self) { note in
                Text("detail view: \(note.title)")
            }
            .navigationTitle("diary_view_title")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isNewDiaryViewVisible = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isNewDiaryViewVisible) {
                Form {
                    TextField("title", text: $title)
                    TextField("value", text: $value)
                    Picker("picker_new_thumbnail", selection: $thumbnail) {
                        ForEach(availableThumbnails, id: \.self) { image in
                            Image(systemName: image)
                        }
                    }
                    .pickerStyle(.segmented)
                    Button {
                        context.insert(Note(
                            id: "\(Int.random(in: 0..<1000))",
                            title: title,
                            value: value,
                            thumbnail: thumbnail,
                            images: []
                        ))
                    } label: {
                        Label("add_new_note", systemImage: "note.text.badge.plus")
                    }

                }
                .presentationDetents([.fraction(0.3)])
            }
        }
    }
}

// MARK: - Model

@Observable
class Diary {
    var notes: [Note]

    init(notes: [Note] = []) {
        self.notes = notes
    }
}
