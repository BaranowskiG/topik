//
//  DiaryView.swift
//  topik
//
//  Created by Grzegorz Baranowski on 16/02/2025.
//

import SwiftUI
import SwiftData
import PhotosUI

struct DiaryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Note.title) var notes: [Note]

    @State private var isNewDiaryViewVisible = false
    @State private var title = ""
    @State private var thumbnail = "figure.climbing"

    let availableThumbnails: [String] = ["figure.climbing", "building.2", "mountain.2", "book.closed", "folder", "mappin.and.ellipse"]

    var body: some View {
        NavigationStack {
            List {
                if !notes.filter(\.isFavorite).isEmpty {
                    Section("Favorites") {
                        favouriteList
                    }
                }

                Section("All") {
                    list
                }
            }
            .navigationDestination(for: Note.self) { note in
                NoteView(note: note)
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
                List {
                    TextField("title", text: $title)
                    Picker("picker_new_thumbnail", selection: $thumbnail) {
                        ForEach(availableThumbnails, id: \.self) { image in
                            Image(systemName: image)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowSeparator(.hidden)
                    Button {
                        isNewDiaryViewVisible = false
                        context.insert(Note(
                            id: UUID().uuidString,
                            title: title,
                            value: "",
                            thumbnail: thumbnail,
                            images: []
                        ))
                    } label: {
                        Label("add_new_note", systemImage: "note.text.badge.plus")
                    }

                }
                .presentationDetents([.height(180)])
            }
        }
    }

    var list: some View {
        ForEach(notes.filter { $0.isFavorite == false }) { note in
            NavigationLink(value: note) {
                Label(note.title, systemImage: note.thumbnail)
                    .swipeActions(edge: .leading) {
                        Button {
                            note.isFavorite = true
                        } label: {
                            Text("add to favorite")
                        }
                        .tint(.accent)
                    }
            }
        }
        .onDelete { offsets in
            for offset in offsets {
                let note = notes.filter { $0.isFavorite == false }[offset]
                context.delete(note)
            }
        }
    }

    var favouriteList: some View {
        ForEach(notes.filter(\.isFavorite)) { note in
            NavigationLink(value: note) {
                Label(note.title, systemImage: note.thumbnail)
                    .swipeActions(edge: .leading) {
                        Button {
                            note.isFavorite = false
                        } label: {
                            Text("remove favorite")
                        }
                        .tint(.accent)
                    }
            }
        }
        .onDelete { offsets in
            for offset in offsets {
                let note = notes.filter(\.isFavorite)[offset]
                context.delete(note)
            }
        }
    }
}

struct NoteView: View {
    var note: Note

    @State private var text: String = ""
    let columns = [
        GridItem(.flexible(minimum: 40, maximum: .infinity)),
        GridItem(.flexible(minimum: 40, maximum: .infinity)),
        GridItem(.flexible(minimum: 40, maximum: .infinity))
    ]

    @State private var photoItem: PhotosPickerItem?
    @State private var photoImage: Image?


    var body: some View {
        VStack {
            Text("Note")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("test", text: $text, axis: .vertical)
                .lineLimit(10)
                .padding()
                .background(.background)
                .clipShape(.rect(cornerRadius: 15))
                .onChange(of: text) { _, newValue in
                    note.value = newValue
                }
                .onAppear {
                    text = note.value
                }
            HStack {
                Text("Photos")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                PhotosPicker(selection: $photoItem,
                             matching: .images,
                             photoLibrary: .shared()) {
                    Image(systemName: "plus")
                }
            }
            .padding(.top)
            .onChange(of: photoItem) {
                Task {
                    if let loaded = try? await photoItem?.loadTransferable(type: Data.self) {
                        if !note.images.contains(loaded) {
                            note.images.append(loaded)
                        }
                    } else {
                        print("Failed")
                    }
                }
            }
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(note.images, id: \.self) { image in
                        image.asImage()
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: UIColor.secondarySystemBackground))
        .navigationTitle(note.title)
        .navigationBarTitleDisplayMode(.inline)
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
