//
//  Note.swift
//  topik
//
//  Created by Grzegorz Baranowski on 04/03/2025.
//

import SwiftData
import SwiftUI

@Model
final class Note {
    @Attribute(.unique) var id: String
    var title: String
    var value: String
    var thumbnail: String
    var images: [Data]
    var isFavorite: Bool = false

    init(
        id: String,
        title: String,
        value: String,
        thumbnail: String,
        images: [Data]
    ) {
        self.id = id
        self.title = title
        self.value = value
        self.thumbnail = thumbnail
        self.images = images
    }
}
