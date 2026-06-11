import SwiftUI

// MARK: - 颜料颜色模型
/// 画家的颜料颜色，支持从基础色创建和自定义
struct PaintColor: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var rgb: RGBColor
    var category: ColorCategory

    /// 颜料特性：透明度、染色力、干燥速度
    var opacity: Double      // 0 = 透明, 1 = 不透明
    var tintingStrength: Double // 染色力 0-1
    var isBaseColor: Bool

    init(
        id: UUID = UUID(),
        name: String,
        rgb: RGBColor,
        category: ColorCategory = .custom,
        opacity: Double = 0.9,
        tintingStrength: Double = 0.7,
        isBaseColor: Bool = false
    ) {
        self.id = id
        self.name = name
        self.rgb = rgb
        self.category = category
        self.opacity = min(1, max(0, opacity))
        self.tintingStrength = min(1, max(0, tintingStrength))
        self.isBaseColor = isBaseColor
    }

    var color: Color {
        Color(red: rgb.r, green: rgb.g, blue: rgb.b)
    }

    var hexString: String {
        rgb.hexString
    }

    // MARK: - 六大基础色
    static let titaniumWhite = PaintColor(
        name: "钛白",
        rgb: RGBColor(r: 0.98, g: 0.98, b: 0.97),
        category: .white,
        opacity: 1.0,
        tintingStrength: 0.3,
        isBaseColor: true
    )

    static let ivoryBlack = PaintColor(
        name: "象牙黑",
        rgb: RGBColor(r: 0.08, g: 0.08, b: 0.09),
        category: .black,
        opacity: 1.0,
        tintingStrength: 0.9,
        isBaseColor: true
    )

    static let cadmiumRed = PaintColor(
        name: "镉红",
        rgb: RGBColor(r: 0.89, g: 0.15, b: 0.11),
        category: .red,
        opacity: 0.9,
        tintingStrength: 0.75,
        isBaseColor: true
    )

    static let ultramarineBlue = PaintColor(
        name: "群青蓝",
        rgb: RGBColor(r: 0.10, g: 0.15, b: 0.65),
        category: .blue,
        opacity: 0.85,
        tintingStrength: 0.8,
        isBaseColor: true
    )

    static let cadmiumYellow = PaintColor(
        name: "镉黄",
        rgb: RGBColor(r: 0.98, g: 0.85, b: 0.05),
        category: .yellow,
        opacity: 0.9,
        tintingStrength: 0.7,
        isBaseColor: true
    )

    static let viridianGreen = PaintColor(
        name: "翠绿",
        rgb: RGBColor(r: 0.05, g: 0.55, b: 0.30),
        category: .green,
        opacity: 0.8,
        tintingStrength: 0.75,
        isBaseColor: true
    )

    static let baseColors: [PaintColor] = [
        .titaniumWhite, .ivoryBlack,
        .cadmiumRed, .ultramarineBlue,
        .cadmiumYellow, .viridianGreen
    ]
}

// MARK: - RGB 颜色值
struct RGBColor: Codable, Equatable, Hashable {
    let r: Double  // 0...1
    let g: Double  // 0...1
    let b: Double  // 0...1

    init(r: Double, g: Double, b: Double) {
        self.r = min(1, max(0, r))
        self.g = min(1, max(0, g))
        self.b = min(1, max(0, b))
    }

    var hexString: String {
        let ri = Int(r * 255)
        let gi = Int(g * 255)
        let bi = Int(b * 255)
        return String(format: "#%02X%02X%02X", ri, gi, bi)
    }

    var hsb: (h: Double, s: Double, b: Double) {
        let minVal = min(r, g, b)
        let maxVal = max(r, g, b)
        let delta = maxVal - minVal

        var h: Double = 0
        var s: Double = 0
        let v = maxVal

        if delta > 0.0001 {
            s = delta / maxVal
            if r == maxVal {
                h = (g - b) / delta + (g < b ? 6 : 0)
            } else if g == maxVal {
                h = (b - r) / delta + 2
            } else {
                h = (r - g) / delta + 4
            }
            h /= 6
        }

        return (h, s, v)
    }

    var cmyk: (c: Double, m: Double, y: Double, k: Double) {
        let k = 1 - max(r, g, b)
        if k >= 1.0 { return (0, 0, 0, 1) }
        let c = (1 - r - k) / (1 - k)
        let m = (1 - g - k) / (1 - k)
        let y = (1 - b - k) / (1 - k)
        return (c, m, y, k)
    }

    static func fromHSB(h: Double, s: Double, b: Double) -> RGBColor {
        let h = h.truncatingRemainder(dividingBy: 1.0)
        let h6 = h * 6
        let i = Int(h6)
        let f = h6 - Double(i)
        let p = b * (1 - s)
        let q = b * (1 - f * s)
        let t = b * (1 - (1 - f) * s)

        switch i {
        case 0: return RGBColor(r: b, g: t, b: p)
        case 1: return RGBColor(r: q, g: b, b: p)
        case 2: return RGBColor(r: p, g: b, b: t)
        case 3: return RGBColor(r: p, g: q, b: b)
        case 4: return RGBColor(r: t, g: p, b: b)
        case 5: return RGBColor(r: b, g: p, b: q)
        default: return RGBColor(r: 0, g: 0, b: 0)
        }
    }

    static func fromCMYK(c: Double, m: Double, y: Double, k: Double) -> RGBColor {
        let r = (1 - c) * (1 - k)
        let g = (1 - m) * (1 - k)
        let b = (1 - y) * (1 - k)
        return RGBColor(r: r, g: g, b: b)
    }
}

// MARK: - 颜色分类
enum ColorCategory: String, Codable, CaseIterable {
    case white  = "白色系"
    case black  = "黑色系"
    case red    = "红色系"
    case blue   = "蓝色系"
    case yellow = "黄色系"
    case green  = "绿色系"
    case orange = "橙色系"
    case purple = "紫色系"
    case brown  = "棕色系"
    case custom = "自定义"

    var displayColor: Color {
        switch self {
        case .white:  return Color(white: 0.95)
        case .black:  return Color(white: 0.1)
        case .red:    return Color(red: 0.9, green: 0.15, blue: 0.1)
        case .blue:   return Color(red: 0.1, green: 0.2, blue: 0.7)
        case .yellow: return Color(red: 0.95, green: 0.8, blue: 0.05)
        case .green:  return Color(red: 0.1, green: 0.6, blue: 0.3)
        case .orange: return Color(red: 0.95, green: 0.5, blue: 0.1)
        case .purple: return Color(red: 0.5, green: 0.1, blue: 0.6)
        case .brown:  return Color(red: 0.4, green: 0.25, blue: 0.15)
        case .custom: return .gray
        }
    }
}
