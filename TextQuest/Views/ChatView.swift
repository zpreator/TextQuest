//
//  ChatView.swift
//  TextQuest
//
//  Created by Zachary Preator on 6/20/25.
//

import SwiftUI

struct ChatView: View {
    let chat: AdventureChat
    let goBack: () -> Void

    @State private var userInput: String = ""
    @State private var messages: [StoryEntry] = []
    @State private var currentOptions: [AdventureAction] = []
    @State private var isLoading: Bool = false

    private let llmService = LLMService()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Chat history
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(messages) { message in
                                HStack {
                                    if message.sender == "Player" {
                                        Spacer()
                                        Text(message.message)
                                            .padding(10)
                                            .background(Color.accentColor)
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                            .id(message.id)
                                    } else {
                                        Text(message.message)
                                            .padding(10)
                                            .background(Color(.systemGray5))
                                            .foregroundColor(.primary)
                                            .cornerRadius(12)
                                            .id(message.id)
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal)
                            }
                            if isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView() // default spinner
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .padding()
                                    Spacer()
                                }
                                .id(UUID()) // ensure it appears as a new item
                            }
                        }
                        .padding(.vertical)
                    }
                }

                // Suggested options from LLM
                if !currentOptions.isEmpty && !isLoading {
                    VStack(spacing: 8) {
                        ForEach(currentOptions) { option in
                            Button(action: {
                                handlePlayerChoice(option.content)
                            }) {
                                Text(option.content)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }

                // Input bar
                HStack(spacing: 8) {
                    TextField("Message...", text: $userInput, axis: .vertical)
                        .padding(10)
                        .cornerRadius(25)
                        .glassEffect()
                        .lineLimit(1...4)
                        .disabled(isLoading) // disable during LLM response

                    if !userInput.trimmingCharacters(in: .whitespaces).isEmpty && !isLoading {
                        Button(action: {
                            let choice = userInput.trimmingCharacters(in: .whitespaces)
                            userInput = "" // clear text
                            handlePlayerChoice(choice)
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.accentColor)
                        }
                        .transition(.scale)
                        .glassEffect()
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: goBack) {
                        Image(systemName: "chevron.left")
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text(chat.title)
                        .font(.headline)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Future menu
                    }) {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .task {
                // Kick off the first narrator message when the chat starts
                await fetchNextTurn()
            }
        }
    }

    // MARK: - Logic

    private func handlePlayerChoice(_ choice: String) {
        guard !isLoading else { return }
        messages.append(StoryEntry(sender: "Player", message: choice))
        currentOptions = [] // hide options while waiting
        userInput = ""      // clear input if typed
        Task {
            await fetchNextTurn()
        }
    }

    private func fetchNextTurn() async {
        guard !isLoading else { return }
        isLoading = true

        do {
            let history = messages.map { "\($0.sender): \($0.message)" }
            let turn = try await llmService.generateNextTurn(
                theme: chat.title,
                goal: nil,
                history: history
            )

            messages.append(StoryEntry(sender: "Narrator", message: turn.description))
            currentOptions = turn.actions // show new options
        } catch {
            messages.append(StoryEntry(sender: "Narrator", message: "⚠️ Error: \(error.localizedDescription)"))
            currentOptions = []
        }

        isLoading = false
    }

}
