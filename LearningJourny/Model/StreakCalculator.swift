import Foundation

enum StreakCalculator {
    /// More than 32 hours without a Learned log or a Freeze resets the streak.
    static let resetInterval: TimeInterval = 32 * 60 * 60

    /// - Learned days increase the streak (one per calendar day).
    /// - Freezed days keep it alive but do not increase it.
    /// - A gap longer than 32 hours between two logs, or between the last log and `now`, resets it.
    static func streak(logs: [DayLog], now: Date, calendar: Calendar = .current) -> Int {
        let sorted = logs.sorted { $0.loggedAt < $1.loggedAt }
        guard let last = sorted.last else { return 0 }

        // Already broken: too long since the last activity.
        if now.timeIntervalSince(last.loggedAt) > resetInterval { return 0 }

        var streak = 0
        var previous: Date?
        var lastCountedDay: Date?

        for log in sorted {
            if let previous, log.loggedAt.timeIntervalSince(previous) > resetInterval {
                streak = 0
                lastCountedDay = nil
            }
            previous = log.loggedAt

            if log.status == .learned {
                let day = calendar.startOfDay(for: log.loggedAt)
                if day != lastCountedDay {
                    streak += 1
                    lastCountedDay = day
                }
            }
        }
        return streak
    }
}
