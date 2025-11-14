//
//  AppView.swift
//  TextQuest
//
//  Created by Zachary Preator on 6/20/25.
//

import SwiftUI

struct AppView: View {
    @State private var chats: [AdventureChat] = [
        AdventureChat(title: "Crystal Quest", messages: []),
        AdventureChat(title: "Robot Uprising", messages: []),
        AdventureChat(title: "Haunted Lighthouse", messages: [])
    ]

    @State private var selectedChat: AdventureChat? = nil

    var body: some View {
        NavigationStack {
            if let selectedChat {
                ChatView(chat: selectedChat, goBack: {
                    self.selectedChat = nil
                })
            } else {
                ChatSelectorView(chats: chats, onSelect: { chat in
                    self.selectedChat = chat
                })
            }
        }
    }
}
