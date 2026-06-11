import SwiftUI

// MARK: - 色板模型
/// 用户保存的配色方案，可包含多个颜色
struct ColorPalette: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var colors: [PaletteColor]
    var createdAt: Date
    var modifiedAt: Date
    var isFavorite: Bool
    var harmony: HarmonyType?

    struct PaletteColor: Identifiable, Codable {
        let id: UUID
        var colorHex: String
        var label: String

        var color: Color {
            Color(hex: colorHex) ?? .gray
        }
    }

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        colors: [PaletteColor] = [],
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        isFavorite: Bool = false,
        harmony: HarmonyType? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.colors = colors
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.isFavorite = isFavorite
        self.harmony = harmony
    }

    /// 从 MixRecipe 创建色板
    init(from recipe: MixRecipe, name: String? = nil) {
        self.id = UUID()
        self.name = name ?? recipe.name
        self.description = recipe.notes
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.isFavorite = false
        self.harmony = nil

        self.colors = [
            PaletteColor(id: UUID(), colorHex: recipe.resultColor.hexString, label: "混合结果")
        ] + recipe.ingredients.map { ing in
            PaletteColor(id: UUID(), colorHex: ing.colorHex, label: ing.colorName)
        }
    }
}

// MARK: - 色彩和谐类型
enum HarmonyType: String, Codable, CaseIterable {
    case complementary     = "互补色"
    case analogous         = "近似色"
    case triadic           = "三角色"
    case splitComplementary = "分裂互补"
    case tetradic          = "四角色"
    case monochromatic     = "单色系"

    var description: String {
        switch self {
        case .complementary:
            return "色轮上相对的颜色，对比强烈"
        case .analogous:
            return "色轮上相邻的颜色，和谐柔和"
        case .triadic:
            return "色轮上均匀分布的三个颜色"
        case .splitComplementary:
            return "一个基色 + 其互补色两侧的颜色"
        case .tetradic:
            return "两组互补色，形成矩形"
        case .monochromatic:
            return "同一色相的不同明度和饱和度"
        }
    }
}

// MARK: - Color Hex 扩展
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&int) else { return nil }

        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            return nil
        }
        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r*255), Int(g*255), Int(b*255))
    }
}
