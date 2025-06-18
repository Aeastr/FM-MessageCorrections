//
//  ContentView.swift
//  FM-MessageCorrections
//
//  Main chat interface with animated message bubbles
//  Created by Aether on 17/06/2025.
//

import SwiftUI
import FoundationModels

/// Main content view for the message correction chat interface
struct ContentView: View {
    // MARK: - State Properties
    
    /// Array of all messages in the chat conversation
    @State private var messages: [Message] = [
        //
    ]
    /// Current text being typed in the input field
    @State private var inputText: String = ""
    /// Array of bubbles currently being animated from input to final position
    @State private var animatingBubbles: [AnimatingBubble] = []
    
    // MARK: - AI Correction State
    
    /// Current correction suggestion from AI, if any
    @State private var currentCorrection: MessageCorrection?
    /// Whether AI is currently analyzing the input for corrections
    @State private var isCheckingCorrection = false
    /// Task for debounced correction checking
    @State private var correctionTask: Task<Void, Never>?
    
    var body: some View {
        ScrollViewReader{ proxy in
            ScrollView {
                BubblesList()
                    .padding()
                    .rotationEffect(.degrees(180))
                    .animation(.smooth, value: messages.count)
            }
            .rotationEffect(.degrees(180))
            .onChange(of: messages) {
                // Auto-scroll to the newest message when messages array changes
                if let lastId = messages.last?.id {
                    withAnimation {
                        proxy.scrollTo(lastId, anchor: .center)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom, content: {
            UserMessageField()
        })
        .coordinateSpace(name: "chat")
        .overlayPreferenceValue(CombinedAnchorKey.self) { combined in
            // Overlay animated bubbles on top of the chat interface
            ForEach(animatingBubbles) { anim in
                AnimatedBubbleView(
                    anim: anim, 
                    combined: combined,
                    onComplete: { finished in
                        // Remove the bubble that just finished animating
                        animatingBubbles.removeAll { $0 == finished }
                    }
                )
            }
        }
        .background(backgroundColor)
    }
    
    // MARK: - View Components
    
    /// Builds the list of message bubbles in the chat
    @ViewBuilder
    func BubblesList() -> some View{
        LazyVStack(spacing: 16) {
            ForEach(messages) { msg in
                HStack {
                    BubbleView(message: Binding(get: {
                        msg
                    }, set: { Value in
                        // Update the message in the array when BubbleView modifies it
                        if let index = messages.firstIndex(of: msg){
                            messages[index] = Value
                        }
                    }), messages: $messages)
                    // Hide the bubble if it's currently being animated
                    .opacity(animatingBubbles.contains(where: { $0.id == msg.id }) ? 0 : 1)
                    // Store the bubble's position for animation targeting
                    .anchorPreference(
                        key: CombinedAnchorKey.self,
                        value: .bounds
                    ) { CombinedAnchorKey.Value(source: nil, dest: [msg.id: $0]) }
                }
                .frame(maxWidth: .infinity)
                .id(msg.id)
                // Apply blur transition for non-user messages
                .transition(msg.type != .user ? .blur.animation(.smooth) : .identity)
            }
        }
        .padding(.top, 20)
    }
    
    /// Builds the modern user input field at the bottom of the screen
    @ViewBuilder
    func UserMessageField() -> some View{
        VStack(spacing: 0) {
            // Show correction preview if available
            if let correction = currentCorrection, correction.isCorrection {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "wand.and.stars")
                        
                        Text("Correction:")
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundStyle(.secondary)
                        
                        Text(correction.message)
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.9))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        colors: [.red, .orange, .yellow, .purple, .pink, .red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                                .opacity(0.4)
                        }
                        .shadow(
                            color: .purple.opacity(0.3),
                            radius: 2,
                            x: 0,
                            y: 2
                        )
                        .shadow(
                            color: .blue.opacity(0.2),
                            radius: 3,
                            x: 0,
                            y: 2
                        )
                        .shadow(
                            color: .pink.opacity(0.15),
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .transition(.move(edge: .bottom).combined(with: .blur).animation(.smooth(duration: 0.3)))
            }
            
            // Main input area
            HStack(spacing: 12) {
                // Modern text input field
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $inputText, axis: .vertical)
                        .font(.system(.body, design: .rounded))
                        .lineLimit(1...4)
                        // Record the text field's bounds as the animation source point
                        .anchorPreference(
                            key: CombinedAnchorKey.self,
                            value: .bounds
                        ) { CombinedAnchorKey.Value(source: $0, dest: [:]) }
                        // Check for corrections when text changes
                        .onChange(of: inputText) {
                            checkForCorrection()
                        }
                    
                    // Show loading indicator when checking for corrections
                    if isCheckingCorrection {
                        ProgressView()
                            .scaleEffect(0.7)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(inputFieldBackgroundColor)
                        .stroke(inputFieldBorderColor, lineWidth: 1)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
                
                // Action buttons
                HStack(spacing: 8) {
                    // Show correction button if AI detected a correction
                    if let correction = currentCorrection, correction.isCorrection {
                        Button {
                            applyCorrection(correction)
                        } label: {
                            Image(systemName: "wand.and.stars")
                                .font(.system(.body, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background {
                                    LinearGradient(
                                        colors: [.red, .orange, .yellow, .purple, .pink, .red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                        .blur(radius: 10, opaque: true)
                                        .clipShape(Circle())
                                        .overlay {
                                            Circle()
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [.white.opacity(0.8), .white.opacity(0.3)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        }
                                      
                                }
                        }
                        .transition(.blur.animation(.smooth(duration: 0.3)))
                        .animation(.smooth(duration: 0.3), value: currentCorrection?.isCorrection)
                    }
                    
                    // Send button
                    Button {
                        send()
                    } label: {
                        Image(systemName: inputText.isEmpty ? "arrow.up" : "arrow.up.circle.fill")
                            .font(.system(.body, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background {
                                Circle()
                                    .fill(
                                        inputText.isEmpty ? 
                                        LinearGradient(
                                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        LinearGradient(
                                            colors: [.blue, .blue.mix(with: .purple, by: 0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(
                                        color: inputText.isEmpty ? .clear : .blue.opacity(0.4), 
                                        radius: inputText.isEmpty ? 0 : 6, 
                                        x: 0, 
                                        y: inputText.isEmpty ? 0 : 3
                                    )
                            }
                    }
                    .disabled(inputText.isEmpty)
                    .animation(.easeInOut(duration: 0.2), value: inputText.isEmpty)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background {
            Rectangle()
                .fill(messageFieldBackgroundColor)
                .background(.ultraThinMaterial, in: Rectangle())
                .ignoresSafeArea(edges: .bottom)
        }
    }
    
    // MARK: - Actions
    
    /// Handles sending a new message
    private func send() {
        guard !inputText.isEmpty else { return }
        let newMsg = Message(text: inputText, type: .user)
        messages.append(newMsg)
        
        print("📤 Sent message: '\(newMsg.text)'")
        print("📝 Total messages: \(messages.count)")
        print("🔗 Last message: '\(messages.last?.text ?? "none")'")
        
        // Enqueue a separate animation for this new message
        animatingBubbles.append(.init(id: newMsg.id, message: newMsg))
        
        // Clear input and correction state
        inputText = ""
        currentCorrection = nil
        correctionTask?.cancel()
    }
    
    /// Applies the AI-suggested correction to the last message
    private func applyCorrection(_ correction: MessageCorrection) {
        guard let lastMessage = messages.last else { return }
        
        // Update the last message with the corrected text
        if let index = messages.firstIndex(of: lastMessage) {
            messages[index].text = correction.message
        }
        
        // Clear input and correction state
        inputText = ""
        currentCorrection = nil
        correctionTask?.cancel()
    }
    
    /// Debounced function to check for AI corrections
    private func checkForCorrection() {
        // Cancel any existing correction task
        correctionTask?.cancel()
        
        // Clear correction if input is empty
        guard !inputText.isEmpty else {
            currentCorrection = nil
            isCheckingCorrection = false
            return
        }
        
        // Need at least one previous message to check for corrections
        guard let lastMessage = messages.last else {
            currentCorrection = nil
            isCheckingCorrection = false
            return
        }
        
        // Capture the current state to avoid race conditions
        let currentInput = inputText
        let previousMessageText = lastMessage.text
        
        // Start new debounced task
        correctionTask = Task {
            // Wait for debounce period
            try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
            
            // Check if task was cancelled
            guard !Task.isCancelled else { return }
            
            // Update UI to show checking state
            await MainActor.run {
                isCheckingCorrection = true
            }
            
            do {
                print("🔍 Checking correction for:")
                print("   Previous: '\(previousMessageText)'")
                print("   Current: '\(currentInput)'")
                
                // Call AI correction service with captured values
                let correction = try await getCorrectionResponse(
                    previousMessage: previousMessageText,
                    newMessage: currentInput
                )
                
                print("✅ AI Response:")
                print("   Message: '\(correction.message)'")
                print("   Is Correction: \(correction.isCorrection)")
                
                // Check if task was cancelled during AI call
                guard !Task.isCancelled else { return }
                
                // Update UI with results
                await MainActor.run {
                    currentCorrection = correction
                    isCheckingCorrection = false
                }
            } catch {
                print("❌ Error checking correction: \(error)")
                // Handle error - just clear the checking state
                await MainActor.run {
                    isCheckingCorrection = false
                    currentCorrection = nil
                }
            }
        }
    }
    
    // MARK: - Styling & Colors
    
    /// Current color scheme from the environment
    @Environment(\.colorScheme) var colorScheme
    
    /// Accent color for UI elements
    let accent = Color.white.mix(with: Color.orange, by: 0.8)
    
    /// Dynamic background color based on color scheme
    var backgroundColor: Color {
        switch colorScheme{
        case .dark:
            Color(.systemBackground)
        case .light:
            Color(.systemGroupedBackground)
        @unknown default:
            Color(.systemBackground)
        }
    }
    
    /// Dynamic tile background color based on color scheme
    var tile_backgroundColor: Color {
        switch colorScheme{
        case .dark:
            Color.black.mix(with: Color.blue, by: 0.1)
        case .light:
            Color.white
        @unknown default:
            Color.white
        }
    }
    
    /// Modern input field background color
    var inputFieldBackgroundColor: Color {
        switch colorScheme {
        case .dark:
            Color(.systemGray6)
        case .light:
            Color.white
        @unknown default:
            Color.white
        }
    }
    
    /// Modern input field border color
    var inputFieldBorderColor: Color {
        switch colorScheme {
        case .dark:
            Color(.systemGray4)
        case .light:
            Color(.systemGray5)
        @unknown default:
            Color(.systemGray5)
        }
    }
    
    /// Modern message field background color
    var messageFieldBackgroundColor: Color {
        switch colorScheme {
        case .dark:
            Color(.systemBackground).opacity(0.8)
        case .light:
            Color(.systemBackground).opacity(0.9)
        @unknown default:
            Color(.systemBackground)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
