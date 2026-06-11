import Foundation

// MARK: - 调色配方模型
/// 记录一次调色操作：用了哪些颜色、各占比多少、混合结果
struct MixRecipe: Identifiable, Codable {
    let id: UUID
    var name: String
    var ingredients: [Ingredient]
    var resultColor: RGBColor
    var createdAt: Date
    var notes: String
    var tags: [String]

    struct Ingredient: Identifiable, Codable {
        let id: UUID
        let colorName: String
        let colorHex: String
        let ratio: Double  // 占比 0...1，所有 ingredient 的 ratio 总和应为 1

        init(id: UUID = UUID(), colorName: String, colorHex: String, ratio: Double) {
            self.id = id
            self.colorName = colorName
            self.colorHex = colorHex
            self.ratio = ratio
        }
    }

    init(
        id: UUID = UUID(),
        name: String = "",
        ingredients: [Ingredient],
        resultColor: RGBColor,
        createdAt: Date = Date(),
        notes: String = "",
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.ingredients = ingredients
        self.resultColor = resultColor
        self.createdAt = createdAt
        self.notes = notes
        self.tags = tags
    }

    /// 验证 ingredients 比例总和为 1
    var isRatioValid: Bool {
        abs(ingredients.reduce(0) { $0 + $1.ratio } - 1.0) < 0.01
    }
}

// MARK: - 预设调色配方
extension MixRecipe {
    /// 常用调色配方
    static let presets: [MixRecipe] = [
        MixRecipe(
            name: "暖肤色",
            ingredients: [
                Ingredient(colorName: "钛白", colorHex: "#FAFAF7", ratio: 0.60),
                Ingredient(colorName: "镉红", colorHex: "#E3261C", ratio: 0.15),
                Ingredient(colorName: "镉黄", colorHex: "#FAD90D", ratio: 0.20),
                Ingredient(colorName: "群青蓝", colorHex: "#1A26A6", ratio: 0.05),
            ],
            resultColor: RGBColor(r: 0.94, g: 0.78, b: 0.68),
            tags: ["人物", "肤色"]
        ),
        MixRecipe(
            name: "冷肤色",
            ingredients: [
                Ingredient(colorName: "钛白", colorHex: "#FAFAF7", ratio: 0.55),
                Ingredient(colorName: "镉红", colorHex: "#E3261C", ratio: 0.12),
                Ingredient(colorName: "群青蓝", colorHex: "#1A26A6", ratio: 0.10),
                Ingredient(colorName: "翠绿", colorHex: "#0D8C4D", ratio: 0.03),
                Ingredient(colorName: "镉黄", colorHex: "#FAD90D", ratio: 0.20),
            ],
            resultColor: RGBColor(r: 0.90, g: 0.76, b: 0.70),
            tags: ["人物", "肤色"]
        ),
        MixRecipe(
            name: "生赭色（土黄）",
            ingredients: [
                Ingredient(colorName: "镉黄", colorHex: "#FAD90D", ratio: 0.45),
                Ingredient(colorName: "镉红", colorHex: "#E3261C", ratio: 0.20),
                Ingredient(colorName: "群青蓝", colorHex: "#1A26A6", ratio: 0.15),
                Ingredient(colorName: "钛白", colorHex: "#FAFAF7", ratio: 0.20),
            ],
            resultColor: RGBColor(r: 0.75, g: 0.55, b: 0.20),
            tags: ["大地色", "风景"]
        ),
        MixRecipe(
            name: "橄榄绿",
            ingredients: [
                Ingredient(colorName: "镉黄", colorHex: "#FAD90D", ratio: 0.35),
                Ingredient(colorName: "翠绿", colorHex: "#0D8C4D", ratio: 0.30),
                Ingredient(colorName: "象牙黑", colorHex: "#141417", ratio: 0.10),
                Ingredient(colorName: "钛白", colorHex: "#FAFAF7", ratio: 0.25),
            ],
            resultColor: RGBColor(r: 0.35, g: 0.42, b: 0.15),
            tags: ["风景", "军旅"]
        ),
        MixRecipe(
            name: "紫罗兰",
            ingredients: [
                Ingredient(colorName: "群青蓝", colorHex: "#1A26A6", ratio: 0.40),
                Ingredient(colorName: "镉红", colorHex: "#E3261C", ratio: 0.35),
                Ingredient(colorName: "钛白", colorHex: "#FAFAF7", ratio: 0.25),
            ],
            resultColor: RGBColor(r: 0.42, g: 0.18, b: 0.52),
            tags: ["花卉", "装饰"]
        ),
        MixRecipe(
            name: "天灰蓝",
            ingredients: [
                Ingredient(colorName: "钛白", colorHex: "#FAFAF7", ratio: 0.55),
                Ingredient(colorName: "群青蓝", colorHex: "#1A26A6", ratio: 0.25),
                Ingredient(colorName: "象牙黑", colorHex: "#141417", ratio: 0.05),
                Ingredient(colorName: "翠绿", colorHex: "#0D8C4D", ratio: 0.15),
            ],
            resultColor: RGBColor(r: 0.45, g: 0.55, b: 0.68),
            tags: ["风景", "天空"]
        ),
        MixRecipe(
            name: "深棕（熟赭）",
            ingredients: [
                Ingredient(colorName: "镉红", colorHex: "#E3261C", ratio: 0.30),
                Ingredient(colorName: "翠绿", colorHex: "#0D8C4D", ratio: 0.25),
                Ingredient(colorName: "象牙黑", colorHex: "#141417", ratio: 0.20),
                Ingredient(colorName: "镉黄", colorHex: "#FAD90D", ratio: 0.25),
            ],
            resultColor: RGBColor(r: 0.32, g: 0.18, b: 0.10),
            tags: ["大地色", "木材"]
        ),
        MixRecipe(
            name: "橙橘色",
            ingredients: [
                Ingredient(colorName: "镉黄", colorHex: "#FAD90D", ratio: 0.50),
                Ingredient(colorName: "镉红", colorHex: "#E3261C", ratio: 0.35),
                Ingredient(colorName: "钛白", colorHex: "#FAFAF7", ratio: 0.15),
            ],
            resultColor: RGBColor(r: 0.92, g: 0.42, b: 0.08),
            tags: ["暖色", "水果"]
        ),
    ]
}
