import SwiftUI

// MARK: - 玻璃质感卡片
/// 毛玻璃效果的卡片组件，用于统一 App 的卡片风格
struct GlassCard<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme

    let content: Content
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 16
    var shadowRadius: CGFloat = 8

    init(
        cornerRadius: CGFloat = 20,
        padding: CGFloat = 16,
        shadowRadius: CGFloat = 8,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.shadowRadius = shadowRadius
    }

    var body: some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(colorScheme == .dark ? 0.15 : 0.4),
                                        .white.opacity(colorScheme == .dark ? 0.05 : 0.1),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.8
                            )
                    }
            }
            .shadow(
                color: .black.opacity(colorScheme == .dark ? 0.3 : 0.08),
                radius: shadowRadius,
                x: 0,
                y: 4
            )
    }
}

// MARK: - 浮雕卡片（更立体的效果）
struct EmbossedCard<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let content: Content
    var backgroundColor: Color?

    init(
        backgroundColor: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        content
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(backgroundColor ?? Color(.systemBackground).opacity(0.5))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(.white.opacity(0.2), lineWidth: 0.5)
                    }
            }
            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
            .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 1)
    }
}

// MARK: - 颜色圆点
struct ColorDot: View {
    let color: Color
    var size: CGFloat = 44
    var isSelected: Bool = false
    var showBorder: Bool = true

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .overlay {
                if showBorder {
                    Circle()
                        .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                }
            }
            .overlay {
                if isSelected {
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: size + 6, height: size + 6)

                    Image(systemName: "checkmark")
                        .font(.system(size: size * 0.35, weight: .bold))
                        .foregroundColor(color.isLightColor ? .black : .white)
                }
            }
            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

// MARK: - 颜色信息标签
struct ColorInfoTag: View {
    let label: String
    let value: String
    var color: Color = .primary

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption.monospaced())
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - 颜色亮度判断
extension Color {
    var isLightColor: Bool {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > 0.55
    }
}
