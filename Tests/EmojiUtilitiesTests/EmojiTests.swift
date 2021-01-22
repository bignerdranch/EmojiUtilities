import XCTest
@testable import EmojiUtilities

final class EmojiTests: XCTestCase {
    func testInit() {
        XCTAssertNotNil(Emoji(rawValue: "🏴‍☠️"))
        XCTAssertNil(Emoji(rawValue: "9"))
    }

    func testDescription() throws {
        let emoji = try XCTUnwrap(Emoji(rawValue: "🐻‍❄️"))
        XCTAssertEqual("\(emoji)", "🐻‍❄️")
    }

    struct Container: Codable {
        var emoji: Emoji
    }

    func testEncoding() throws {
        let emoji = try XCTUnwrap(Emoji(rawValue: "9️⃣"))
        let encoder = JSONEncoder()
        let data = try encoder.encode(Container(emoji: emoji))
        let json = String(decoding: data, as: UTF8.self)
        XCTAssertEqual(json, #"""
        {"emoji":"9️⃣"}
        """#)
    }

    func testDecoding() throws {
        let json = #"""
        {"emoji":"9️⃣"}
        """#
        let decoder = JSONDecoder()
        let container = try decoder.decode(Container.self, from: Data(json.utf8))
        XCTAssertEqual(container.emoji.rawValue, "9️⃣")
    }

    func testMaliciousDecoding() throws {
        let json = #"""
        {"emoji":"hello world"}
        """#
        let decoder = JSONDecoder()
        XCTAssertThrowsError(try decoder.decode(Container.self, from: Data(json.utf8)))
    }
}
