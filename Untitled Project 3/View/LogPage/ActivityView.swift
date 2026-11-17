

import SwiftUI

struct ActivityDisplayState {
    var date: Date
    var week: [WeekDay]
    var streak: Int
    var freezed: Int
    var usedFreezes: Int
    var totalFreezes: Int
    var loggedToday: Bool
    var freezedToday: Bool
    var outcome: GoalOutcome = .active
    var freezeActive: Bool = false
}


struct ActivityView: View {
    let state: ActivityDisplayState
    var onLog: () -> Void = {}
    var onFreeze: () -> Void = {}
    var onUndoFreeze: () -> Void = {}
    var onCalendar: () -> Void = {}
    var onEditGoal: () -> Void = {}
    var onSetGoal: () -> Void = {}

    @State private var showUndoFreeze = false

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: state.date)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                header

                Text(dateText)
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.top, 2)

                WeekStripView(days: state.week)
                    .padding(.top, 22)

                HStack(spacing: 14) {
                    StatCardView(
                        systemImage: "flame.fill",
                        tint: .appOrange,
                        value: state.streak,
                        title: "Learned"
                    )
                    StatCardView(
                        systemImage: "snowflake",
                        tint: .freezeBlue,
                        value: state.freezed,
                        title: "Freezed"
                    )
                }
                .padding(.top, 18)

                if state.outcome == .active {
                    Spacer()

                    LogButton(
                        isLogged: state.loggedToday,
                        isBlocked: state.freezeActive,
                        action: onLog
                    )
                    .frame(maxWidth: .infinity)

                    Spacer()

                    FreezeButton(
                        isFreezeActive: state.freezeActive,
                        isLoggedToday: state.loggedToday,
                        usedFreezes: state.usedFreezes,
                        totalFreezes: state.totalFreezes,
                        onFreeze: onFreeze,
                        onUndo: { showUndoFreeze = true }
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                } else {
                    Spacer()

                    GoalResultView(outcome: state.outcome, onSetGoal: onSetGoal)

                    Spacer()
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
        }
        .preferredColorScheme(.dark)
        .overlay {
            if showUndoFreeze {
                ConfirmPopup(
                    title: "Undo Freeze",
                    message: "Do you want to undo today's Freeze? You'll get it back.",
                    cancelTitle: "Dismiss",
                    confirmTitle: "Undo",
                    confirmTint: .appOrange,
                    onCancel: { showUndoFreeze = false },
                    onConfirm: {
                        showUndoFreeze = false
                        onUndoFreeze()
                    }
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showUndoFreeze)
    }

    private var header: some View {
        HStack {
            Text("Activity")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            HStack(spacing: 12) {
                circleIconButton("calendar", action: onCalendar)
                circleIconButton("pencil.and.outline", action: onEditGoal)
            }
        }
        .padding(.top, 12)
    }

    private func circleIconButton(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .glassBackground(in: Circle())
        }
        .buttonStyle(.plain)
    }
}


struct ActivityScreen: View {
    @StateObject private var vm: ActivityViewModel
    @State private var showGoalEditor = false
    @State private var showCalendar = false

    init(goal: Goal, onEditGoal: @escaping () -> Void = {}) {
        _vm = StateObject(wrappedValue: ActivityViewModel(goal: goal))
    }

    var body: some View {
        let state = vm.displayState

        NavigationStack {
            ActivityView(
                state: state,
                onLog: vm.logAsLearned,
                onFreeze: vm.freezeToday,
                onUndoFreeze: vm.undoFreeze,
                onCalendar: { showCalendar = true },
                onEditGoal: { showGoalEditor = true },
                onSetGoal: { showGoalEditor = true }
            )
            .toolbar(.hidden, for: .navigationBar)
            // Calendar: pushed with navigation (not a sheet).
            .navigationDestination(isPresented: $showCalendar) {
                LearningCalendarView(
                    goalStart: vm.historyStart,
                    states: vm.dayStates,
                    today: state.date
                )
            }
        }
        // Goal editor: slides up as a sheet.
        .sheet(isPresented: $showGoalEditor) {
            LearningGoalView(
                currentGoal: vm.goal,
                isNewGoal: state.outcome != .active,
                onBack: { showGoalEditor = false },
                onUpdate: { subject, duration in
                    vm.updateGoal(subject: subject, duration: duration)
                    showGoalEditor = false
                }
            )
            .presentationDragIndicator(.hidden)
        }

    }
}


private func previewState(
    streak: Int,
    freezed: Int,
    used: Int,
    loggedToday: Bool,
    freezedToday: Bool,
    pastStates: [Int: DayCellState],
    outcome: GoalOutcome = .active
) -> ActivityDisplayState {
    let cal = Calendar.current
    let today = Date()
    let startOfToday = cal.startOfDay(for: today)

    var states: [Date: DayCellState] = [:]
    for (offset, s) in pastStates {
        if let d = cal.date(byAdding: .day, value: offset, to: startOfToday) { states[d] = s }
    }
    if loggedToday { states[startOfToday] = .learned }
    if freezedToday { states[startOfToday] = .freezed }

    return ActivityDisplayState(
        date: today,
        week: WeekDay.week(containing: today, states: states),
        streak: streak,
        freezed: freezed,
        usedFreezes: used,
        totalFreezes: 2,
        loggedToday: loggedToday,
        freezedToday: freezedToday,
        outcome: outcome,
        freezeActive: freezedToday
    )
}

#Preview("Current day - Default") {
    ActivityView(state: previewState(
        streak: 4, freezed: 0, used: 0,
        loggedToday: false, freezedToday: false,
        pastStates: [-1: .learned, -2: .learned, -3: .learned, -4: .learned]
    ))
}

#Preview("Learned today") {
    ActivityView(state: previewState(
        streak: 5, freezed: 0, used: 0,
        loggedToday: true, freezedToday: false,
        pastStates: [-1: .learned, -2: .learned, -3: .learned, -4: .learned]
    ))
}

#Preview("Freezed today (Undo + Log disabled)") {
    ActivityView(state: previewState(
        streak: 4, freezed: 1, used: 1,
        loggedToday: false, freezedToday: true,
        pastStates: [-1: .learned, -2: .learned, -3: .learned, -4: .learned]
    ))
}

#Preview("No Freezes available") {
    ActivityView(state: previewState(
        streak: 3, freezed: 2, used: 2,
        loggedToday: false, freezedToday: false,
        pastStates: [-1: .freezed, -2: .learned, -3: .learned, -4: .learned]
    ))
}

#Preview("Goal completed") {
    ActivityView(state: previewState(
        streak: 3, freezed: 2, used: 2,
        loggedToday: false, freezedToday: false,
        pastStates: [-1: .freezed, -2: .learned, -3: .learned, -4: .learned],
        outcome: .completed
    ))
}

#Preview("Goal failed") {
    ActivityView(state: previewState(
        streak: 2, freezed: 2, used: 2,
        loggedToday: false, freezedToday: false,
        pastStates: [-1: .freezed, -2: .freezed, -4: .learned, -5: .learned],
        outcome: .failed
    ))
}
