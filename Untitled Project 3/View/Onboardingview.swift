import SwiftUI

struct OnboardingView: View {
    @State private var subject: String = ""
    @State private var duration: LearningDuration = .week

    var onStart: (String, LearningDuration) -> Void = { _, _ in }

    private var isStartEnabled: Bool {
        subject.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.appOrange)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 70)

                VStack(alignment: .leading, spacing: 8) {
                    (Text("Hello ").fontWeight(.regular) + Text("Learner").fontWeight(.bold))
                        .font(.system(size: 44))
                        .foregroundColor(.white)

                    Text("This app will help you learn everyday!")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .padding(.top, 110)

                GoalFormView(subject: $subject, duration: $duration)
                    .padding(.top, 40)

                Spacer()

                VStack(spacing: 14) {
                    Button("Start Learning") {
                        onStart(
                            subject.trimmingCharacters(in: .whitespacesAndNewlines),
                            duration
                        )
                    }
                    .buttonStyle(StartButtonStyle())
                    .disabled(!isStartEnabled)
                    .animation(.easeInOut(duration: 0.2), value: isStartEnabled)

                    Text("You can edit your desire later")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }
        .preferredColorScheme(.dark)
    }
}


struct StartButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.weight(.medium))
            .foregroundColor(isEnabled ? .white : .gray)
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
            .glassBackground(in: Capsule(), tint: isEnabled ? .appOrange : .glassBlack)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    OnboardingView()
}
