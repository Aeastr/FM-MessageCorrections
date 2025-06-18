//
//  Models.swift
//  FM-MessageCorrections
//
//  Data models for the message correction system
//

import Foundation
import SwiftUI

/// Represents a bubble that is currently animating from the input field to its final position
struct AnimatingBubble: Identifiable, Equatable {
    let id: UUID
    let message: Message
}

/// Defines the type of message in the chat
enum MessageType {
    case user
    case recipient
}

/// Represents a single message in the chat conversation
struct Message: Identifiable, Equatable {
    var id = UUID()
    var text: String
    var type: MessageType
    var timestamp: Date = Date()
    var completedLoading: Bool = false
}
