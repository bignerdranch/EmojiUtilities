//
//  String+Additions.swift
//  EmojiUtilities
//

extension String {
    /// A Boolean value indicating whether the string is exactly one character with an emoji presentation.
    ///
    /// This property is `true` for strings that are rendered as emoji by default and also for scalars that
    /// have a non-default emoji rendering.
    var isEmoji: Bool {
        // Must contain exactly one character.
        guard count == 1 else { return false }

        // Bytes must indicate there's an emoji.
        guard let firstScalar = unicodeScalars.first, firstScalar.properties.isEmoji else { return false }

        // "4" counts as an emoji because "4️⃣" is just "4" with a modifier.
        // Accept emoji that naturally present as emoji (like "🙂"), non-emoji
        // using a modifier (like "4️⃣" for "4"), but not ones with a plain-text
        // modifier (like "☢︎" for "☢️").
        if firstScalar.properties.isEmojiPresentation || firstScalar.value > 0x238C {
            // Manual indicator of text presentation.
            return unicodeScalars.dropFirst().first != "\u{fe0e}"
        } else {
            // Manual indicator of emoji presentation.
            return unicodeScalars.dropFirst().first == "\u{fe0f}"
        }
    }
}
