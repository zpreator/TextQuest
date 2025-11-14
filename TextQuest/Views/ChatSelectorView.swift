//
//  ChatSelectorView.swift
//  TextQuest
//
//  Created by Zachary Preator on 6/20/25.
//

import SwiftUI

struct ChatSelectorView: View {
    let chats: [AdventureChat]
    let onSelect: (AdventureChat) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Your Adventures")
                .font(.largeTitle.bold())
                .padding(.top)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(chats) { chat in
                        Button(action: {
                            onSelect(chat)
                        }) {
                            VStack {
                                Image(systemName: "book.circle.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.accentColor)
                                Text(chat.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                            .shadow(radius: 4)
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.bottom)
    }
}
