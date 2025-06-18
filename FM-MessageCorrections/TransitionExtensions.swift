//
//  TransitionExtensions.swift
//  FM-MessageCorrections
//
//  Custom transitions and view modifiers for smooth animations
//

import SwiftUI

/// A view modifier that applies blur effect for transitions
private struct BlurModifier: ViewModifier {
    /// Whether this is the identity state (no blur) or active state (with blur)
    public let isIdentity: Bool
    /// The intensity of the blur effect
    public var intensity: CGFloat

    public func body(content: Content) -> some View {
        content
            .blur(radius: isIdentity ? intensity : 0)
            .opacity(isIdentity ? 0 : 1)
    }
}

/// Extensions to AnyTransition for custom blur-based transitions
public extension AnyTransition {
    /// Simple blur transition with default settings
    static var blur: AnyTransition {
        .blur()
    }
    
    /// Blur transition without scaling effect
    static var blurWithoutScale: AnyTransition {
        .modifier(
            active: BlurModifier(isIdentity: true, intensity: 20),
            identity: BlurModifier(isIdentity: false, intensity: 20)
        )
    }
    
    /// Customizable blur transition with scale effect
    /// - Parameters:
    ///   - intensity: The blur radius intensity (default: 5)
    ///   - scale: The scale factor during transition (default: 0.8)
    /// - Returns: A combined transition with blur and scale effects
    static func blur(
        intensity: CGFloat = 5,
        scale: CGFloat = 0.8
    ) -> AnyTransition {
        .scale(scale: scale)
        .combined(
            with: .modifier(
                active: BlurModifier(isIdentity: true, intensity: intensity),
                identity: BlurModifier(isIdentity: false, intensity: intensity)
            )
        )
    }
} 