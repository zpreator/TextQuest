//
//  LLMService.swift
//  TextQuest
//
//  Created by Zachary Preator on 6/13/25.
//

import Foundation
import FoundationModels

// MARK: - Generable Models

@Generable
struct AdventureTurn: Equatable {
    @Guide(description: "A vivid, immersive scene description")
    var description: String

    @Guide(description: "Three creative next steps the player could take", .count(3))
    var actions: [AdventureAction]
}

@Generable
struct AdventureAction: Identifiable, Equatable {
    @Guide(description: "A unique ID for this action", .pattern(/action-\d+/))
    var id: String

    @Guide(description: "A short phrase for the action, like 'Open the glowing chest'")
    var content: String
}

// MARK: - Service Class

class LLMService {
    private let session: LanguageModelSession

    init() {
        self.session = LanguageModelSession()
    }

    /// Fetches the next turn of the story using the LLM
    func generateNextTurn(theme: String, goal: String?, history: [String]) async throws -> AdventureTurn {
        let prompt = buildPrompt(theme: theme, goal: goal, history: history)
        let response = try await session.respond(to: prompt, generating: AdventureTurn.self)
        return response.content
    }

    /// Builds the prompt string based on theme, goal, and story so far
    private func buildPrompt(theme: String, goal: String?, history: [String]) -> String {
        var prompt = """
        You are a text adventure engine that responds with structured JSON.

        Generate a vivid scene description and five possible actions the player could take.

        THEME: \(theme)
        """

        if let goal = goal {
            prompt += "\nGOAL: \(goal)"
        }

        prompt += "\nHISTORY:"
        for line in history {
            prompt += "\n- \(line)"
        }

        prompt += "\n\nRespond only with structured JSON that fits the Swift struct definition of AdventureTurn."

        return prompt
    }
}

