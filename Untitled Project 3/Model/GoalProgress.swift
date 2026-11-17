import Foundation

/// Where the current goal stands.
enum GoalOutcome: Equatable {
    case active
    case completed   // "Well done!"
    case failed      // 32h without a log or a Freeze
}

/// Everything derived from the goal + logs at a given moment.
struct GoalProgress: Equatable {
    /// A Freeze stays active for 24 hours after it is pressed.
    static let freezeDuration: TimeInterval = 24 * 60 * 60

    let streak: Int
    let usedFreezes: Int
    let totalFreezes: Int
    let loggedToday: Bool
    let freezedToday: Bool
    /// A Freeze was pressed less than 24 hours ago (Undo is available, Log is blocked).
    let freezeActive: Bool
    /// More than 32 hours without a Learned log or a Freeze.
    let isFailed: Bool
    /// Days covered so far (Learned or Freezed) and the days the goal needs.
    let coveredDays: Int
    let targetDays: Int

    var isCompleted: Bool { coveredDays >= targetDays }

    /// Completed wins over failed (a finished goal can't fail afterwards).
    var outcome: GoalOutcome {
        if isCompleted { return .completed }
        if isFailed { return .failed }
        return .active
    }

    var canFreeze: Bool {
        outcome == .active && !freezeActive && !loggedToday && usedFreezes < totalFreezes
    }

    var canLog: Bool { outcome == .active && !loggedToday && !freezeActive }

    static func make(
        goal: Goal,
        logs: [DayLog],
        now: Date,
        calendar: Calendar = .current
    ) -> GoalProgress {
        // Only logs since the goal started count.
        let valid = logs.filter { $0.loggedAt >= goal.createdAt }
        let today = calendar.startOfDay(for: now)

        func hasLog(_ status: DayStatus) -> Bool {
            valid.contains { $0.status == status && calendar.startOfDay(for: $0.loggedAt) == today }
        }

        let reference = valid.map(\.loggedAt).max() ?? goal.createdAt
        let isFailed = now.timeIntervalSince(reference) > StreakCalculator.resetInterval

        let freezes = valid.filter { $0.status == .freezed }
        let freezeActive = freezes.map(\.loggedAt).max()
            .map { now.timeIntervalSince($0) < freezeDuration } ?? false

        let covered = Set(valid.map { calendar.startOfDay(for: $0.loggedAt) }).count

        return GoalProgress(
            streak: StreakCalculator.streak(logs: valid, now: now, calendar: calendar),
            usedFreezes: freezes.count,
            totalFreezes: goal.duration.freezeLimit,
            loggedToday: hasLog(.learned),
            freezedToday: hasLog(.freezed),
            freezeActive: freezeActive,
            isFailed: isFailed,
            coveredDays: covered,
            targetDays: goal.duration.targetDays
        )
    }
}
