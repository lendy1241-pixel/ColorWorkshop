import SwiftUI

// MARK: - 渐变背景 (高性能)
struct GradientBackground: View {
    @Environment(\.colorScheme) var colorScheme

    private let darkColors: [Color] = [
        Color(red: 0.06, green: 0.06, blue: 0.10),
        Color(red: 0.10, green: 0.08, blue: 0.14),
        Color(red: 0.08, green: 0.09, blue: 0.12),
    ]

    private let lightColors: [Color] = [
        Color(red: 0.98, green: 0.97, blue: 0.94),
        Color(red: 0.96, green: 0.94, blue: 0.90),
        Color(red: 0.94, green: 0.93, blue: 0.91),
    ]

    var body: some View {
        LinearGradient(
            colors: colorScheme == .dark ? darkColors : lightColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
