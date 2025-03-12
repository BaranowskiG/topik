//
//  Event.swift
//  topik
//
//  Created by Grzegorz Baranowski on 16/02/2025.
//

import FirebaseFirestore

struct Event: Decodable, Identifiable, Hashable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var price: Double
    var place: String
    var level: String
    var date: Date
}
