import SwiftUI

// MARK: - Flame icon (orange flame with a dark inner flame, like the design)

struct FlameIcon: View {
    var size: CGFloat = 64

    var body: some View {
        ZStack {
            Image(systemName: "flame.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.appOrange.opacity(0.95), Color.appOrange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Inner "cutout" flame
            Image(systemName: "flame.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color.black)
                .scaleEffect(0.38)
                .offset(y: size * 0.14)
        }
        .frame(width: size, height: size)
        .shadow(color: Color.appOrange.opacity(0.35), radius: 16, y: 4)
        .accessibilityHidden(true)
    }
}

// MARK: - Start button (glass on iOS 26+, solid capsule fallback)

struct StartButton: View {
    var title: String = "Start Learning"
    var isEnabled: Bool
    var action: () -> Void

    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                Button(title, action: action)
                    .buttonStyle(.glassProminent)
                    .tint(.appOrange)
                    .controlSize(.large)
            } else {
                Button(title, action: action)
                    .buttonStyle(StartButtonStyle())
            }
        }
        .font(.title3.weight(.medium))
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

#Preview {
    VStack(spacing: 40) {
        FlameIcon()
        StartButton(isEnabled: true) {}
        StartButton(isEnabled: false) {}
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)
}
