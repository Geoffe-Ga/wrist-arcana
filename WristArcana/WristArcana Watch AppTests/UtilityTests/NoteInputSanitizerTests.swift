import XCTest
@testable import WristArcana

final class NoteInputSanitizerTests: XCTestCase {
    func test_sanitize_trimsWhitespace() {
        let input = "  Hello World  "
        let result = NoteInputSanitizer.sanitize(input)
        XCTAssertEqual(result, "Hello World")
    }

    func test_sanitize_removesControlCharacters() {
        let input = "Hello\u{0000}World\u{0001}"
        let result = NoteInputSanitizer.sanitize(input)
        XCTAssertEqual(result, "HelloWorld")
    }

    func test_sanitize_preservesNewlines() {
        let input = "Line1\nLine2\nLine3"
        let result = NoteInputSanitizer.sanitize(input)
        XCTAssertEqual(result, "Line1\nLine2\nLine3")
    }

    func test_sanitize_collapsesMultipleNewlines() {
        let input = "Line1\n\n\n\nLine2"
        let result = NoteInputSanitizer.sanitize(input)
        XCTAssertEqual(result, "Line1\n\nLine2")
    }

    func test_sanitize_enforcesCharacterLimit() {
        let input = String(repeating: "a", count: 600)
        let result = NoteInputSanitizer.sanitize(input)
        XCTAssertEqual(result.count, 500)
    }

    func test_isValid_returnsTrueForValidInput() {
        XCTAssertTrue(NoteInputSanitizer.isValid("Valid note"))
    }

    func test_isValid_returnsFalseForEmptyInput() {
        XCTAssertFalse(NoteInputSanitizer.isValid(""))
        XCTAssertFalse(NoteInputSanitizer.isValid("   "))
    }

    func test_isValid_returnsFalseForTooLong() {
        let input = String(repeating: "a", count: 501)
        XCTAssertFalse(NoteInputSanitizer.isValid(input))
    }

    func test_remainingCharacters_calculatesCorrectly() {
        let input = String(repeating: "a", count: 100)
        XCTAssertEqual(NoteInputSanitizer.remainingCharacters(input), 400)
    }

    func test_remainingCharacters_returnsZeroWhenAtLimit() {
        let input = String(repeating: "a", count: 500)
        XCTAssertEqual(NoteInputSanitizer.remainingCharacters(input), 0)
    }
}
