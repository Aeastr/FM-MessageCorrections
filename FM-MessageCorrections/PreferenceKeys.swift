//
//  PreferenceKeys.swift
//  FM-MessageCorrections
//
//  Preference keys for coordinate space and anchor management
//

import SwiftUI

/// A preference key that combines source and destination anchor points for animation
/// Used to track the position of the text field (source) and message bubbles (destinations)
struct CombinedAnchorKey: PreferenceKey {
    /// Value structure containing source anchor and destination anchors mapped by message ID
    struct Value {
        /// The anchor point of the text input field (source of animation)
        var source: Anchor<CGRect>? = nil
        /// Dictionary mapping message IDs to their anchor points (destinations for animation)
        var dest: [UUID: Anchor<CGRect>] = [:]
    }
    
    /// Default empty value
    static var defaultValue = Value()
    
    /// Combines multiple preference values, preserving the first source and merging all destinations
    static func reduce(value: inout Value, nextValue: () -> Value) {
        let next = nextValue()
        if value.source == nil { value.source = next.source }
        value.dest.merge(next.dest) { $1 }
    }
}