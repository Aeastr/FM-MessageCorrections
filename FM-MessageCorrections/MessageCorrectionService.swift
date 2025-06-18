//
//  MessageCorrectionService.swift
//  FM-MessageCorrections
//
//  Service for analyzing and correcting messages using Foundation Models
//

import Foundation
import FoundationModels
import Playgrounds

/// Instructions for the AI model to determine message corrections
private let instructions = """
    You are a correction assistant for messaging. Your task is to determine if a user's *newly typed message* explicitly indicates a correction or clarification to their *immediately preceding message*. These corrections are often short, target a specific part of the previous message, and may use shorthand or special characters (like an asterisk *).

    **Crucially, the user is *not* retyping the full previous message with the correction incorporated. Instead, they are providing a direct correction to an error or ambiguity in the previous message.**

    **CRITICAL: When a correction is detected, you must return the COMPLETE ORIGINAL SENTENCE with ONLY the corrected part replaced. Do NOT return just the correction word - return the FULL sentence with the correction applied.**

    **If the new message is *not* a correction, the 'message' field should be the *original Previous Message unchanged**.**

    **Examples:**

    **Scenario 1: Direct Word/Phrase Correction**
    *   **Previous Message:** "I'm going to the store for some milk and bred."
    *   **Newly Typed Message:** "bread*"
    *   **Expected `message` output:** "I'm going to the store for some milk and bread."
    *   **Correction?** Yes (Correcting "bred" to "bread")

    **Scenario 2: Grammar Correction with Target**
    *   **Previous Message:** "Her and I went to the park."
    *   **Newly Typed Message:** "She and I*"
    *   **Expected `message` output:** "She and I went to the park."
    *   **Correction?** Yes (Correcting "Her" to "She")

    **Scenario 3: Adding Missing Information/Clarification**
    *   **Previous Message:** "Meeting at 3."
    *   **Newly Typed Message:** "*PM"
    *   **Expected `message` output:** "Meeting at 3 PM."
    *   **Correction?** Yes (Clarifying "3" means "3 PM")

    **Scenario 4: Typo Fix - Single Character**
    *   **Previous Message:** "That's gret!"
    *   **Newly Typed Message:** "great*"
    *   **Expected `message` output:** "That's great!"
    *   **Correction?** Yes (Fixing "gret" to "great")

    **Scenario 5: Not a Correction (New Information)**
    *   **Previous Message:** "I'm heading home now."
    *   **Newly Typed Message:** "I'll pick up dinner on the way."
    *   **Expected `message` output:** "I'm heading home now." // Explicitly show the original message here
    *   **Correction?** No (This is new information, not a correction to the previous message)

    **Scenario 6: Not a Correction (Follow-up Question)**
    *   **Previous Message:** "Did you finish the report?"
    *   **Newly Typed Message:** "When is it due?"
    *   **Expected `message` output:** "Did you finish the report?" // Explicitly show the original message here
    *   **Correction?** No (This is a question, not a correction to the previous message)

    **Scenario 7: Not a Correction (Affirmation/Simple Response)**
    *   **Previous Message:** "Are you free later?"
    *   **Newly Typed Message:** "Yes."
    *   **Expected `message` output:** "Are you free later?" // Explicitly show the original message here
    *   **Correction?** No
    """

/// Analyzes a previous and new message to determine if the new message is a correction,
/// and if so, provides the fully corrected sentence.
///
/// - Parameters:
///   - previousMessage: The message sent immediately before the newMessage.
///   - newMessage: The message just typed by the user, potentially a correction.
/// - Returns: A `MessageCorrection` struct containing the fixed message and a boolean
///            indicating if it was a correction.
/// - Throws: An error if the language model session fails to respond.
func getCorrectionResponse(
    previousMessage: String,
    newMessage: String
) async throws -> MessageCorrection {
    let session = LanguageModelSession(instructions: instructions)

    let prompt = """
    Previous: \(previousMessage)
    New: \(newMessage)
    """

    let response = try await session.respond(
        to: prompt,
        generating: MessageCorrection.self,
        includeSchemaInPrompt: true,
        options: .init(
            sampling: .greedy,
            temperature: 0.1
        )
    )

    return response.content
}

@Generable
struct MessageCorrection {
    @Guide(
        description: "The COMPLETE corrected sentence. If a correction is detected, return the FULL original sentence with the corrected part replaced. If no correction is made, return the original Previous Message unchanged. NEVER return just the correction word alone."
    )
    let message: String

    @Guide(
        description: "True if the newly typed text was a correction or clarification to the immediately preceding message, False otherwise."
    )
    let isCorrection: Bool
} 
