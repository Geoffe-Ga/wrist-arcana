import Foundation

extension Notification.Name {
    /// Posted whenever a `CardPull` is persisted so list views can refresh their data.
    static let cardPullHistoryDidChange = Notification.Name("cardPullHistoryDidChange")
}
