import Foundation
import Combine
import UIKit

final class ActivityViewModel: ObservableObject {
    @Published private(set) var goal: Goal
    @Published private(set) var logs: [DayLog]
    @Published private(set) var now: Date

    private let defaults: UserDefaults
    private let calendar = Calendar.current
    private var cancellables = Set<AnyCancellable>()

    private enum Key {
        static let goal = "activity.goal"
        static let logs = "activity.logs"
    }

    /// The saved goal, if onboarding was already completed.
    static func storedGoal(defaults: UserDefaults = .standard) -> Goal? {
        guard let data = defaults.data(forKey: Key.goal) else { return nil }
        return try? JSONDecoder().decode(Goal.self, from: data)
    }

    init(goal: Goal, defaults: UserDefaults = .standard) {
        self.goal = goal
        self.defaults = defaults
        self.now = Date()

        if let data = defaults.data(forKey: Key.logs),
           let saved = try? JSONDecoder().decode([DayLog].self, from: data) {
            self.logs = saved
        } else {
            self.logs = []
        }

        save(goal, forKey: Key.goal)
        observeTimeChanges()
    }

    // MARK: - Derived state

    var progress: GoalProgress {
        GoalProgress.make(goal: goal, logs: logs, now: now, calendar: calendar)
    }

    /// Learned / Freezed state per calendar day (Freezed wins over Learned).
    var dayStates: [Date: DayCellState] {
        var states: [Date: DayCellState] = [:]
        for log in logs {
            let day = calendar.startOfDay(for: log.loggedAt)
            if log.status == .freezed {
                states[day] = .freezed
            } else if states[day] == nil {
                states[day] = .learned
            }
        }
        return states
    }
    /// Start of the calendar: the oldest logged day or the current goal's start.
    var historyStart: Date {
        guard let oldest = logs.map(\.loggedAt).min() else { return goal.createdAt }
        return min(oldest, goal.createdAt)
    }
    
    var displayState: ActivityDisplayState {
        let p = progress

        return ActivityDisplayState(
            date: now,
            week: WeekDay.week(containing: now, states: dayStates, calendar: calendar),
            streak: p.streak,
            freezed: p.usedFreezes,
            usedFreezes: p.usedFreezes,
            totalFreezes: p.totalFreezes,
            loggedToday: p.loggedToday,
            freezedToday: p.freezedToday,
            outcome: p.outcome,
            freezeActive: p.freezeActive
        )
    }

    // MARK: - Actions
    /// A new goal restarts the streak and the Freezes (they only count logs since the goal
    /// started), but past days stay in the calendar.
    
    
    func logAsLearned() {
        refresh()
        guard progress.canLog else { return }
        logs.append(DayLog(status: .learned, loggedAt: now))
        save(logs, forKey: Key.logs)
    }

    func freezeToday() {
        refresh()
        guard progress.canFreeze else { return }
        logs.append(DayLog(status: .freezed, loggedAt: now))
        save(logs, forKey: Key.logs)
    }

    /// Undo: removes the active Freeze (only possible within 24h of pressing it).
    func undoFreeze() {
        refresh()
        guard progress.freezeActive,
              let index = logs.lastIndex(where: { $0.status == .freezed }) else { return }
        logs.remove(at: index)
        save(logs, forKey: Key.logs)
    }

    /// Updating the learning goal resets the streak and the Freezes.
    /// A new goal restarts the streak and the Freezes (they only count logs since the goal
    /// started), but past days stay in the calendar.
    func updateGoal(subject: String, duration: LearningDuration) {
        refresh()
        goal = Goal(subject: subject, duration: duration, createdAt: now)
        save(goal, forKey: Key.goal)
    }

    /// Re-reads the clock so buttons re-enable at 12AM, Freezes expire after 24h
    /// and the 32-hour rule is re-checked.
    func refresh() {
        now = Date()
    }

    // MARK: - Private

    private func observeTimeChanges() {
        let names: [Notification.Name] = [
            .NSCalendarDayChanged,
            UIApplication.significantTimeChangeNotification,
            UIApplication.willEnterForegroundNotification
        ]
        for name in names {
            NotificationCenter.default.publisher(for: name)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in self?.refresh() }
                .store(in: &cancellables)
        }

        // While the app is open: catch the 24h Freeze expiry and the 32h rule.
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
    }

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }


}
