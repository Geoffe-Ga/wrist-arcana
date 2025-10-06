import XCTest
@testable import WristArcana_Watch_App

final class AutoSleepManagerTests: XCTestCase {
    func testRegisterInteractionThrottlesRepeatedRequests() {
        let extensionProvider = MockExtensionProvider()
        let dateProvider = MockDateProvider(current: Date())
        let manager = AutoSleepManager(
            timeout: 60,
            throttle: 10,
            extensionProvider: extensionProvider,
            dateProvider: dateProvider
        )

        manager.registerInteraction()
        manager.registerInteraction()

        XCTAssertEqual(extensionProvider.recordedTimeouts.count, 1)

        dateProvider.current = dateProvider.current.addingTimeInterval(11)
        manager.registerInteraction()

        XCTAssertEqual(extensionProvider.recordedTimeouts.count, 2)
    }

    func testFailedExtensionDoesNotUpdateThrottle() {
        let extensionProvider = MockExtensionProvider(shouldSucceed: false)
        let dateProvider = MockDateProvider(current: Date())
        let manager = AutoSleepManager(
            timeout: 60,
            throttle: 10,
            extensionProvider: extensionProvider,
            dateProvider: dateProvider
        )

        manager.registerInteraction()
        XCTAssertEqual(extensionProvider.recordedTimeouts.count, 1)

        extensionProvider.shouldSucceed = true
        manager.registerInteraction()

        XCTAssertEqual(extensionProvider.recordedTimeouts.count, 2)
    }
}

private final class MockExtensionProvider: FrontmostTimeoutExtending {
    var recordedTimeouts: [TimeInterval] = []
    var shouldSucceed: Bool

    init(shouldSucceed: Bool = true) {
        self.shouldSucceed = shouldSucceed
    }

    func extendFrontmostTimeout(_ timeout: TimeInterval) -> Bool {
        self.recordedTimeouts.append(timeout)
        return self.shouldSucceed
    }
}

private final class MockDateProvider: DateProviding {
    var current: Date

    init(current: Date) {
        self.current = current
    }

    func now() -> Date {
        self.current
    }
}
