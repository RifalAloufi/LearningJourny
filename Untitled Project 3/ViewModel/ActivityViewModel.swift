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


    var progress: GoalProgress {
        GoalProgress.make(goal: goal, logs: logs, now: now, calendar: calendar)
    }

    var dayStates: [Date: DayCellState] {
        var states: [Date: DayCellState] = [:]
        for log in logs where log.loggedAt >= goal.createdAt {   // <- الشرط الجديد
            let day = calendar.startOfDay(for: log.loggedAt)
            if log.status == .freezed {
                states[day] = .freezed
            } else if states[day] == nil {
                states[day] = .learned
            }
        }
        return states
    }

    var historyStart: Date {
        goal.createdAt
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

    func undoFreeze() {
        refresh()
        guard progress.freezeActive,
              let index = logs.lastIndex(where: { $0.status == .freezed }) else { return }
        logs.remove(at: index)
        save(logs, forKey: Key.logs)
    }

    func updateGoal(subject: String, duration: LearningDuration) {
        refresh()
        goal = Goal(subject: subject, duration: duration, createdAt: now)
        save(goal, forKey: Key.goal)
    }

    func refresh() {
        now = Date()
    }

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
