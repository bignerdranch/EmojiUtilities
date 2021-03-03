//
//  Emoji+BuiltIn.swift
//  EmojiUtilities
//

public extension Emoji {
    /// The "grinning face" emoji.
    ///
    /// This can be useful for showing a placeholder to the user.
    static let `default` = Emoji(rawValue: "😀")!

    /// Returns a random emoji from a built-in selection.
    ///
    /// The list of random emoji is curated and does not include all emoji.
    ///
    /// This can be useful for picking an emoji during development, such as
    /// in Interface Builder or a SwiftUI preview.
    static func random() -> Emoji {
        let someEmoji = ["😀", "🏖", "⚽️", "🌶", "🍩", "🥾", "🌭", "🚀", "🍣", "🏆", "😍", "🐬", "⛵️", "🦄", "🏄‍♂️", "🛵", "🎁", "🤩", "👘", "🤙", "🏕", "🎩", "🧸", "🍀", "🧊", "🥞", "🌮", "👻", "🥑", "🌹", "🍜", "🎉", "🚗", "🦋", "🔥", "🍄", "⛰", "🌴", "😱", "🍕", "🥶", "🎸", "🦾", "🌈", "💡", "👑", "☠️"]
        let rawValue = someEmoji.randomElement()!
        return Emoji(rawValue: rawValue)!
    }
}
