//
//  Emoji.swift
//  EmojiUtilities
//

/// A wrapper for a string that is guaranteed to contain exactly one emoji.
public struct Emoji: RawRepresentable, Hashable {
    public let rawValue: String

    public init?(rawValue: String) {
        guard rawValue.isEmoji else { return nil }
        self.rawValue = rawValue
    }
}

extension Emoji: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension Emoji: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        guard let emoji = Emoji(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: """
            Did not find an emoji, found "\(rawValue)" instead.
            """)
        }
        self = emoji
    }
}

extension Emoji: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}
