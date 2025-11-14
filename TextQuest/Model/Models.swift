//
//  Models.swift
//  TextQuest
//
//  Created by Zachary Preator on 6/20/25.
//

import Foundation

struct AdventureChat: Identifiable, Equatable {
    var id = UUID()
    var title: String
    var messages: [StoryEntry]
}

struct StoryEntry: Identifiable, Equatable {
    let id = UUID()
    let sender: String  // "Narrator" or "Player"
    let message: String
    var options: [String]? = nil // only for narrator entries
}
