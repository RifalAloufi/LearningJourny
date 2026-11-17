import SwiftUI
struct LogButton: View {
    let isLogged: Bool
    var isBlocked: Bool = false
    let action: () -> Void

    private var isDisabled: Bool { isLogged || isBlocked }

    var body: some View {
        Button(action: action) {
            Text(isLogged ? "Logged as Learned" : "Log as Learned")
                .font(.title3.weight(.bold))
                .foregroundColor(isDisabled ? .gray : .white)
                .frame(width: 310, height: 310)
                .glassBackground(in: Circle(), tint: isDisabled ? .glassBlack : .appOrange)
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(isDisabled)
        .animation(.easeInOut(duration: 0.25), value: isDisabled)
    }
}

struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 24) {
        LogButton(isLogged: false, action: {})
        LogButton(isLogged: true, action: {})
        LogButton(isLogged: false, isBlocked: true, action: {})
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.gray.opacity(0.3))
}
