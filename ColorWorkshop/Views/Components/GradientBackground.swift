import SwiftUI

// MARK: - 渐变背景
/// 整个 App 使用的艺术感渐变背景
struct GradientBackground: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            if colorScheme == .dark {
                // 深色模式 - 深沉的画室氛围
                LinearGradient(
                    colors: [
                        Color(red: 0.06, green: 0.06, blue: 0.10),
                        Color(red: 0.10, green: 0.08, blue: 0.14),
                        Color(red: 0.08, green: 0.09, blue: 0.12),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                // 浅色模式 - 温暖的画室光线
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.97, blue: 0.94),
                        Color(red: 0.96, green: 0.94, blue: 0.90),
                        Color(red: 0.94, green: 0.93, blue: 0.91),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

            // 微妙纹理叠加
            NoiseTexture()
                .opacity(0.03)
        }
        .ignoresSafeArea()
    }
}

// MARK: - 噪点纹理（模拟画布质感）
struct NoiseTexture: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<Int(size.width * size.height * 0.01) {
                let x = Double.random(in: 0..<size.width)
                let y = Double.random(in: 0..<size.height)
                let gray = Double.random(in: 0...1)
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: 1.5, height: 1.5)),
                    with: .color(Color(white: gray))
                )
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - 动画渐变背景 (iOS 15+ 兼容)
struct AnimatedGradientBackground: View {
    @State private var animate = false

    let colors: [Color]

    init(colors: [Color]? = nil) {
        self.colors = colors ?? [
            Color(red: 0.4, green: 0.2, blue: 0.6),
            Color(red: 0.2, green: 0.3, blue: 0.7),
            Color(red: 0.3, green: 0.5, blue: 0.6),
        ]
    }

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animate ? .topLeading : .bottomTrailing,
            endPoint: animate ? .bottomTrailing : .topLeading
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}
