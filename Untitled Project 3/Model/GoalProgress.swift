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

    /// Can't freeze when: the goal is over, a Freeze is already active,
    /// today is learned, or all Freezes are used.
    var canFreeze: Bool {
        outcome == .active && !freezeActive && !loggedToday && usedFreezes < totalFreezes
    }

    /// Can't log when: the goal is over, today is already logged, or a Freeze is active.
    var canLog: Bool { outcome == .active && !loggedToday && !freezeActive }

    /// Days needed to complete the goal. Change here if your rule is different.
    static func targetDays(for duration: LearningDuration) -> Int {
        switch duration {
        case .week:  return 7
        case .month: return 30
        case .year:  return 365
        }
    }

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

        // Last activity, or the goal start if the user never logged anything.
        let reference = valid.map(\.loggedAt).max() ?? goal.createdAt
        let isFailed = now.timeIntervalSince(reference) > StreakCalculator.resetInterval

        let lastFreeze = valid.filter { $0.status == .freezed }.map(\.loggedAt).max()
        let freezeActive = lastFreeze.map { now.timeIntervalSince($0) < freezeDuration } ?? false

        let covered = Set(valid.map { calendar.startOfDay(for: $0.loggedAt) }).count

        return GoalProgress(
            streak: StreakCalculator.streak(logs: valid, now: now, calendar: calendar),
            usedFreezes: valid.filter { $0.status == .freezed }.count,
            totalFreezes: FreezePolicy.limit(for: goal.duration),
            loggedToday: hasLog(.learned),
            freezedToday: hasLog(.freezed),
            freezeActive: freezeActive,
            isFailed: isFailed,
            coveredDays: covered,
            targetDays: targetDays(for: goal.duration)
        )
    }
}
 
enum FreezePolicy {
    static func limit(for duration: LearningDuration) -> Int {
        switch duration {
        case .week:  return 2
        case .month: return 8
        case .year:  return 96
        }
    }
}

