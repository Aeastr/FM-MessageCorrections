//
//  AnimatedBubbleView.swift
//  FM-MessageCorrections
//
//  View for animating message bubbles from input field to their final position
//

import SwiftUI

// MARK: - Animation Constants

/// Duration of the main animation from input field to message position
let animationDuration: TimeInterval = 0.4

/// Duration of the bounce effect at the end of the animation
let bounceDuration: TimeInterval = 0.1

/// Main animation curve for the bubble movement
let animationExample: Animation = Animation.smooth(duration: animationDuration)

/// Animation curve for the extra bounce effect
let animationExampleExtraBounce: Animation = Animation.smooth(duration: animationDuration + bounceDuration)

// MARK: - Animated Bubble View

/// A view that animates a message bubble from the text input field to its final position in the chat
struct AnimatedBubbleView: View {
    /// The animating bubble data containing the message and ID
    let anim: AnimatingBubble
    /// Combined anchor preferences containing source and destination positions
    let combined: CombinedAnchorKey.Value
    /// Callback executed when the animation completes
    let onComplete: (AnimatingBubble) -> Void
    
    // MARK: - Animation State
    
    /// Whether the bubble has reached its destination position
    @State private var isAtDestination = false
    /// Current offset from the calculated position
    @State private var offset: CGSize = .zero
    /// Current scale of the bubble during animation
    @State private var scale: CGSize = CGSize(width: 0.5, height: 0.5)
    /// Current blur radius for the fade-in effect
    @State private var blur: CGFloat = 5
    
    var body: some View {
        GeometryReader { proxy in
            // Ensure we have both source (text field) and destination (message position) anchors
            if let srcAnchor = combined.source,
               let dstAnchor = combined.dest[anim.id]
            {
                // Resolve the current source & destination rects on every update
                let sourceRect = proxy[srcAnchor]
                let destRect   = proxy[dstAnchor]
                // Pick which rect to use based on animation state
                let currentRect = isAtDestination ? destRect : sourceRect
                
                BubbleView(message: Binding(get: {
                    anim.message
                }, set: { Value in
                    // Read-only binding since this is just for animation
                }), messages: .constant([]))
                .scaleEffect(scale)
                .blur(radius: blur)
                .frame(width: destRect.width, height: destRect.height)
                .offset(
                    x: currentRect.minX + offset.width,
                    y: currentRect.minY + offset.height
                )
                .onAppear {
                    // Start the animation sequence
                    performAnimationSequence()
                }
                .transition(.asymmetric(insertion: .scale, removal: .opacity))
                .onDisappear{
                    print("gone")
                }
            }
        }
    }
    
    /// Performs the complete animation sequence for the bubble
    private func performAnimationSequence() {
        // Initial scale and offset animation
        withAnimation(.snappy(duration: animationDuration / 1.3)) {
            scale = CGSizeMake(0.5, 1)
            offset = CGSizeMake(100, 80)
        }
        
        // Main movement and blur fade-in animation
        withAnimation(animationExample) {
            blur = 0
            isAtDestination = true
        }
        
        // Small bounce effect at the destination
        DispatchQueue.main.asyncAfter(deadline: .now() + (animationDuration / 2) - 0.1) {
            withAnimation(animationExampleExtraBounce) {
                offset = .zero
                scale = CGSizeMake(1, 1)
            }
        }
        
        // Cleanup: remove the animated bubble after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + bounceDuration + 0.35) {
            onComplete(anim)
        }
    }
} 