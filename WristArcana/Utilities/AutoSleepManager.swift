import Foundation
import SwiftUI

protocol AutoSleepManaging {
    func registerInteraction()
}

protocol FrontmostTimeoutExtending {
    @discardableResult
    func extendFrontmostTimeout(_ timeout: TimeInterval) -> Bool
}

protocol DateProviding {
    func now() -> Date
}

struct SystemDateProvider: DateProviding {
    func now() -> Date { Date() }
}

#if os(watchOS)
import WatchKit

extension WKExtension: FrontmostTimeoutExtending {}

private enum DefaultExtensionProvider {
    static func make() -> FrontmostTimeoutExtending {
        WKExtension.shared()
    }
}
#else
private struct NoopExtensionProvider: FrontmostTimeoutExtending {
    func extendFrontmostTimeout(_ timeout: TimeInterval) -> Bool { true }
}

private enum DefaultExtensionProvider {
    static func make() -> FrontmostTimeoutExtending {
        NoopExtensionProvider()
    }
}
#endif

final class AutoSleepManager: AutoSleepManaging {
    private let extensionProvider: FrontmostTimeoutExtending
    private let timeout: TimeInterval
    private let throttle: TimeInterval
    private let dateProvider: DateProviding
    private var lastExtensionDate: Date?

    init(
        timeout: TimeInterval = 60,
        throttle: TimeInterval = 5,
        extensionProvider: FrontmostTimeoutExtending? = nil,
        dateProvider: DateProviding = SystemDateProvider()
    ) {
        self.timeout = timeout
        self.throttle = throttle
        self.extensionProvider = extensionProvider ?? DefaultExtensionProvider.make()
        self.dateProvider = dateProvider
    }

    func registerInteraction() {
        let now = self.dateProvider.now()

        if let last = self.lastExtensionDate,
           now.timeIntervalSince(last) < self.throttle
        {
            return
        }

        guard self.extensionProvider.extendFrontmostTimeout(self.timeout) else {
            return
        }

        self.lastExtensionDate = now
    }
}

private struct AutoSleepManagerKey: EnvironmentKey {
    static let defaultValue: AutoSleepManaging = AutoSleepManager()
}

extension EnvironmentValues {
    var autoSleepManager: AutoSleepManaging {
        get { self[AutoSleepManagerKey.self] }
        set { self[AutoSleepManagerKey.self] = newValue }
    }
}

extension View {
    func reportUserInteractions(using manager: AutoSleepManaging) -> some View {
        self.modifier(UserInteractionReporter(autoSleepManager: manager))
    }
}

private struct UserInteractionReporter: ViewModifier {
    let autoSleepManager: AutoSleepManaging

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        self.autoSleepManager.registerInteraction()
                    }
            )
            .onTapGesture {
                self.autoSleepManager.registerInteraction()
            }
    }
}
