//
//  BubbleView.swift
//  FM-MessageCorrections
//
//  Created by Aether on 17/06/2025.
//

import SwiftUI

struct BubbleView: View {
    @Binding var message: Message
    @Binding var messages: [Message]
    @Environment(\.colorScheme) var colorScheme
    @State private var isPulsing = false
    
    @ViewBuilder
    func UserBubble() -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(message.text)
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
                .id(message.text) // Unique ID for text transitions
                .transition(.blur.animation(.smooth(duration: 0.4)))
            
            HStack(spacing: 4) {
                Text(timeString)
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
                
                // Delivered indicator
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            // Modern gradient bubble
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.9),
                    Color.blue.mix(with: .purple, by: 0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(
                .rect(
                    topLeadingRadius: 20,
                    bottomLeadingRadius: 20,
                    bottomTrailingRadius: 6,
                    topTrailingRadius: 20
                )
            )
            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .frame(maxWidth: 280, alignment: .trailing)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .animation(.smooth(duration: 0.4), value: message.text)
    }
    
    @ViewBuilder
    func RecipientBubble() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.text)
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundStyle(recipientTextColor)
                .multilineTextAlignment(.leading)
                .id(message.text) // Unique ID for text transitions
                .transition(.blur.animation(.smooth(duration: 0.4)))
            
            HStack(spacing: 4) {
                Text(timeString)
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(.secondary)
                
                // Read indicator
                Image(systemName: "eye.fill")
                    .font(.caption2)
                    .foregroundStyle(.secondary.opacity(0.7))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(recipientBackgroundColor)
                .stroke(recipientBorderColor, lineWidth: 1)
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 1)
        }
        .frame(maxWidth: 280, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.smooth(duration: 0.4), value: message.text)
    }
    
    /// Formatted time string for the message
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.timestamp)
    }
    
    /// Dynamic recipient text color based on color scheme
    private var recipientTextColor: Color {
        switch colorScheme {
        case .dark:
            Color.white
        case .light:
            Color.black
        @unknown default:
            Color.primary
        }
    }
    
    /// Dynamic recipient background color based on color scheme
    private var recipientBackgroundColor: Color {
        switch colorScheme {
        case .dark:
            Color(.systemGray5)
        case .light:
            Color(.systemGray6)
        @unknown default:
            Color(.systemGray6)
        }
    }
    
    /// Dynamic recipient border color based on color scheme
    private var recipientBorderColor: Color {
        switch colorScheme {
        case .dark:
            Color(.systemGray4)
        case .light:
            Color(.systemGray5)
        @unknown default:
            Color(.systemGray5)
        }
    }
    
    var body: some View {
        if message.type == .user {
            UserBubble()
        } else if message.type == .recipient {
            RecipientBubble()
        }
    }
}
