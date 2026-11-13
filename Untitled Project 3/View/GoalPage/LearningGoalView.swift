import SwiftUI

/// "Learning Goal" sheet: opened from the pencil icon or "Set a goal".
/// Editing a running goal asks for confirmation (the streak restarts).
/// With `isNewGoal` (goal completed or failed) there is nothing to lose,
/// so it saves directly and allows keeping the same subject and duration.
struct LearningGoalView: View {
    let currentGoal: Goal
    var isNewGoal: Bool = false
    var onBack: () -> Void
    var onUpdate: (String, LearningDuration) -> Void

    @State private var subject: String
    @State private var duration: LearningDuration
    @State private var showConfirm = false

    init(
        currentGoal: Goal,
        isNewGoal: Bool = false,
        onBack: @escaping () -> Void,
        onUpdate: @escaping (String, LearningDuration) -> Void
    ) {
        self.currentGoal = currentGoal
        self.isNewGoal = isNewGoal
        self.onBack = onBack
        self.onUpdate = onUpdate
        _subject = State(initialValue: currentGoal.subject)
        _duration = State(initialValue: currentGoal.duration)
    }

    private var trimmed: String {
        subject.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// ✓ needs 3+ letters, and (for a running goal) a real change.
    private var canSave: Bool {
        trimmed.count >= 3 &&
        (isNewGoal || trimmed != currentGoal.subject || duration != currentGoal.duration)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                header

                GoalFormView(subject: $subject, duration: $duration)
                    .padding(.top, 36)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .preferredColorScheme(.dark)
        .overlay {
            if showConfirm {
                confirmPopup
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showConfirm)
    }

    /// "Update goal" popup: black glass Dismiss + orange glass Update.
    private var confirmPopup: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { showConfirm = false }

            VStack(alignment: .leading, spacing: 10) {
                Text("Update goal")
                    .font(.headline)
                    .foregroundColor(.white)

                Text("If you update now, your streak will start over.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))

                HStack(spacing: 12) {
                    Button {
                        showConfirm = false
                    } label: {
                        Text("Dismiss")
                            .font(.title3.weight(.medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .glassBackground(in: Capsule(), tint: .glassBlack)
                    }
                    .buttonStyle(PressScaleButtonStyle())

                    Button {
                        showConfirm = false
                        onUpdate(trimmed, duration)
                    } label: {
                        Text("Update")
                            .font(.title3.weight(.medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .glassBackground(in: Capsule(), tint: .appOrange)
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }
                .padding(.top, 10)
            }
            .padding(20)
            .frame(maxWidth: 340)
            .background(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(Color(white: 0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .padding(.horizontal, 24)
        }
        .transition(.opacity)
    }

    private var header: some View {
        ZStack {
            Text("Learning Goal")
                .font(.headline)
                .foregroundColor(.white)

            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .glassBackground(in: Circle())
                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    if isNewGoal {
                        onUpdate(trimmed, duration)
                    } else {
                        showConfirm = true
                    }
                } label: {
                    Image(systemName: "checkmark")
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .glassBackground(in: Circle(), tint: .appOrange)
                }
                .buttonStyle(.plain)
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.4)
                .animation(.easeInOut(duration: 0.2), value: canSave)
            }
        }
        .padding(.top, 12)
    }
}

#Preview {
    LearningGoalView(
        currentGoal: Goal(subject: "Swift", duration: .week),
        onBack: {},
        onUpdate: { _, _ in }
    )
}
