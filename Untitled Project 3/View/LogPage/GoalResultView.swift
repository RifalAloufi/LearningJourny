import SwiftUI

/// Shown inside Activity instead of the Log / Freeze buttons
/// when the goal is completed ("Well done!") or failed (32h without activity).
struct GoalResultView: View {
    let outcome: GoalOutcome
    var onSetGoal: () -> Void

    private var iconName: String {
        outcome == .completed ? "hands.clap.fill" : "xmark.seal"
    }

    private var title: String {
        outcome == .completed ? "Well done!" : "You didn't reach your goal this time."
    }

    private var subtitle: String {
        outcome == .completed ? "Ready for your next goal?" : "Want to set another goal?"
    }

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: iconName)
                .font(.system(size: 56))
                .foregroundColor(.appOrange)

            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 24)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 6)

            Button(action: onSetGoal) {
                Label("Set a goal", systemImage: "pencil.and.outline")
                    .font(.title3.weight(.medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .glassBackground(in: Capsule(), tint: .appOrange)
            }
            .buttonStyle(PressScaleButtonStyle())
            .padding(.top, 56)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Completed") {
    GoalResultView(outcome: .completed, onSetGoal: {})
        .background(Color.black)
}

#Preview("Failed") {
    GoalResultView(outcome: .failed, onSetGoal: {})
        .background(Color.black)
}
