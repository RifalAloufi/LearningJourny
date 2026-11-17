import SwiftUI

struct GoalFailedView: View {
    let subject: String
    var onStartAgain: () -> Void
    var onSetNewGoal: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Image(systemName: "flame.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.gray.opacity(0.5))

                Text("You didn't reach your goal")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 28)

                Text("It's been more than 32 hours without learning \(subject). Your streak has ended, but you can start again.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
                    .padding(.horizontal, 12)

                Spacer()

                VStack(spacing: 18) {
                    Button("Start Again", action: onStartAgain)
                        .buttonStyle(StartButtonStyle())

                    Button("Set a new goal", action: onSetNewGoal)
                        .font(.body)
                        .foregroundColor(.appOrange)
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    GoalFailedView(subject: "Swift", onStartAgain: {}, onSetNewGoal: {})
}
