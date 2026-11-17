import Foundation

enum StreakCalculator {
    static let resetInterval: TimeInterval = 32 * 60 * 60

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
