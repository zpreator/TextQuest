//
//  ContentView.swift
//  TextQuest
//
//  Created by Zachary Preator on 6/13/25.
//

import SwiftUI

//struct StoryEntry: Identifiable {
//    let id = UUID()
//    let sender: String // "Narrator" or "Player"
//    let message: String
//}

struct ContentView: View {
    @State private var story: [StoryEntry] = []
    @State private var turn: AdventureTurn?
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let llm = LLMService()

    var body: some View {
        VStack(spacing: 0) {
            // Scrollable story history
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(story) { entry in
                            HStack {
                                if entry.sender == "Narrator" {
                                    Image(systemName: "wand.and.stars")
                                        .foregroundColor(.purple)
                                    VStack(alignment: .leading) {
                                        Text("Narrator")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Text(entry.message)
                                            .padding(12)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(16)
                                            .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                                    }
                                    Spacer()
                                } else {
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text("You")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Text(entry.message)
                                            .padding(12)
                                            .background(Color.indigo)
                                            .foregroundColor(.white)
                                            .cornerRadius(16)
                                    }
                                }
                            }
                            .padding(.horizontal)

                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: story.count) { _ in
                    // Scroll to the bottom
                    if let last = story.last {
                        withAnimation {
                            scrollView.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            if isLoading {
                ProgressView()
                    .padding()
            } else if let turn = turn {
                VStack(spacing: 12) {
                    ForEach(turn.actions) { action in
                        Button(action.content) {
                            handleAction(action)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            } else {
                Button("🧙‍♂️ Begin Your Adventure") {
                    startNewAdventure()
                }
                .padding()
            }

            Divider()

            // Bottom Menu Bar
            HStack {
                Button(action: {
                    startNewAdventure()
                }) {
                    Label("New", systemImage: "sparkles")
                }
                .buttonStyle(.bordered)

                Spacer()

                Button(action: {
                    // Future feature
                    print("History tapped")
                }) {
                    Label("History", systemImage: "scroll")
                }
                .buttonStyle(.bordered)
            }
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(radius: 4)
            .padding([.horizontal, .bottom])
        }
    }

    // MARK: - Game Logic

    func startNewAdventure() {
        story.removeAll()
        turn = nil
        Task {
            await fetchNext(theme: "Fantasy", goal: "Recover the lost crystal", starting: true)
        }
    }

    func handleAction(_ action: AdventureAction) {
        story.append(.init(sender: "Player", message: action.content))
        Task {
            await fetchNext(theme: "Fantasy", goal: "Recover the lost crystal", starting: false)
        }
    }

    func fetchNext(theme: String, goal: String?, starting: Bool) async {
        isLoading = true
        errorMessage = nil
        do {
            let storyStrings = story.map { "[\($0.sender)]: \($0.message)" }
            let next = try await llm.generateNextTurn(theme: theme, goal: goal, history: storyStrings)
            story.append(.init(sender: "Narrator", message: next.description))
            turn = next
        } catch {
            errorMessage = error.localizedDescription
            turn = nil
        }
        isLoading = false
    }
}
