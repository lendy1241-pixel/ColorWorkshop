import Foundation

// MARK: - 颜料混合引擎
/// 模拟真实颜料混合的引擎，使用减色法模型
struct PaintMixingEngine {

    // MARK: - 混合模式
    enum MixMode: String, CaseIterable {
        case realistic = "真实颜料"
        case subtractive = "减色混合"
        case weighted = "加权平均"

        var description: String {
            switch self {
            case .realistic:  return "模拟真实颜料混合效果，考虑颜料特性"
            case .subtractive: return "基于 CMYK 减色模型进行混合"
            case .weighted:    return "按比例直接加权平均各颜色分量"
            }
        }
    }

    // MARK: - 混合结果
    struct MixResult {
        let resultColor: RGBColor
        let mode: MixMode
        let ingredients: [MixRecipe.Ingredient]
        let cmykBreakdown: (c: Double, m: Double, y: Double, k: Double)
        let hsbBreakdown: (h: Double, s: Double, b: Double)

        var hex: String { resultColor.hexString }
    }

    // MARK: - 核心混合算法
    /// 混合多种颜料颜色
    /// - Parameters:
    ///   - ingredients: 参与混合的颜色及其比例
    ///   - mode: 混合模式
    /// - Returns: 混合结果
    static func mix(
        ingredients: [MixRecipe.Ingredient],
        mode: MixMode = .realistic
    ) -> MixResult? {
        guard !ingredients.isEmpty else { return nil }
        guard ingredients.count > 1 else {
            // 只有一种颜色，直接返回
            if let first = ingredients.first,
               let color = parseHex(first.colorHex) {
                return MixResult(
                    resultColor: color,
                    mode: mode,
                    ingredients: ingredients,
                    cmykBreakdown: color.cmyk,
                    hsbBreakdown: color.hsb
                )
            }
            return nil
        }

        // 解析所有颜色
        let parsed: [(rgb: RGBColor, ratio: Double)] = ingredients.compactMap { ing in
            guard let color = parseHex(ing.colorHex) else { return nil }
            return (color, ing.ratio)
        }
        guard parsed.count == ingredients.count else { return nil }

        let resultRGB: RGBColor

        switch mode {
        case .realistic:
            resultRGB = realisticMix(parsed)
        case .subtractive:
            resultRGB = subtractiveMix(parsed)
        case .weighted:
            resultRGB = weightedMix(parsed)
        }

        return MixResult(
            resultColor: resultRGB,
            mode: mode,
            ingredients: ingredients,
            cmykBreakdown: resultRGB.cmyk,
            hsbBreakdown: resultRGB.hsb
        )
    }

    /// 混合两种颜色（便捷方法）
    static func mixTwo(
        color1: RGBColor,
        color2: RGBColor,
        ratio1: Double = 0.5,
        mode: MixMode = .realistic
    ) -> MixResult {
        let ratio2 = 1.0 - ratio1
        let ingredients = [
            MixRecipe.Ingredient(colorName: "颜色A", colorHex: color1.hexString, ratio: ratio1),
            MixRecipe.Ingredient(colorName: "颜色B", colorHex: color2.hexString, ratio: ratio2),
        ]
        return mix(ingredients: ingredients, mode: mode)!
    }

    // MARK: - 真实颜料混合（考虑颜料特性）
    /// 使用简化的 Kubelka-Munk 模型
    private static func realisticMix(_ colors: [(rgb: RGBColor, ratio: Double)]) -> RGBColor {
        // K/S 吸收散射比 → 对每个波长近似计算
        // K/S = (1-R)² / (2R)，其中 R 是反射率
        // 混合时 K/S_mix = Σ(ratio_i × K/S_i)

        // 对 R, G, B 三个"波段"分别计算
        func ksValue(_ reflectance: Double) -> Double {
            let r = max(0.001, min(0.999, reflectance))
            return pow(1 - r, 2) / (2 * r)
        }

        func reflectanceFromKS(_ ks: Double) -> Double {
            let ks = max(0.001, ks)
            return 1 + ks - sqrt(pow(ks, 2) + 2 * ks)
        }

        let ksR = colors.reduce(0.0) { $0 + $1.ratio * ksValue($1.rgb.r) }
        let ksG = colors.reduce(0.0) { $0 + $1.ratio * ksValue($1.rgb.g) }
        let ksB = colors.reduce(0.0) { $0 + $1.ratio * ksValue($1.rgb.b) }

        return RGBColor(
            r: reflectanceFromKS(ksR),
            g: reflectanceFromKS(ksG),
            b: reflectanceFromKS(ksB)
        )
    }

    // MARK: - 减色混合（CMYK 空间）
    private static func subtractiveMix(_ colors: [(rgb: RGBColor, ratio: Double)]) -> RGBColor {
        let c = weightedAverage(colors.map { ($0.rgb.cmyk.c, $0.ratio) })
        let m = weightedAverage(colors.map { ($0.rgb.cmyk.m, $0.ratio) })
        let y = weightedAverage(colors.map { ($0.rgb.cmyk.y, $0.ratio) })
        let k = weightedAverage(colors.map { ($0.rgb.cmyk.k, $0.ratio) })

        return RGBColor.fromCMYK(c: c, m: m, y: y, k: k)
    }

    // MARK: - 加权平均混合
    private static func weightedMix(_ colors: [(rgb: RGBColor, ratio: Double)]) -> RGBColor {
        let r = weightedAverage(colors.map { ($0.rgb.r, $0.ratio) })
        let g = weightedAverage(colors.map { ($0.rgb.g, $0.ratio) })
        let b = weightedAverage(colors.map { ($0.rgb.b, $0.ratio) })
        return RGBColor(r: r, g: g, b: b)
    }

    // MARK: - 工具方法
    private static func weightedAverage(_ values: [(value: Double, weight: Double)]) -> Double {
        let totalWeight = values.reduce(0) { $0 + $1.weight }
        guard totalWeight > 0 else { return 0 }
        return values.reduce(0) { $0 + $1.value * $1.weight } / totalWeight
    }

    private static func parseHex(_ hex: String) -> RGBColor? {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&int), hex.count == 6 else { return nil }

        return RGBColor(
            r: Double((int >> 16) & 0xFF) / 255,
            g: Double((int >> 8) & 0xFF) / 255,
            b: Double(int & 0xFF) / 255
        )
    }

    // MARK: - 调色建议
    /// 给定目标颜色，尝试找出接近的混合配方
    static func suggestMix(
        targetColor: RGBColor,
        baseColors: [PaintColor] = PaintColor.baseColors,
        maxIngredients: Int = 4
    ) -> [MixRecipe] {
        var suggestions: [MixRecipe] = []

        // 简单策略：尝试 2-3 种颜色的组合
        for count in 2...min(maxIngredients, baseColors.count) {
            let combos = combinations(from: baseColors, count: count)
            for combo in combos {
                // 尝试不同的比例分配
                let ratiosList = generateRatioCombinations(count: count, steps: 5)
                for ratios in ratiosList {
                    let ingredients = zip(combo, ratios).map { (color, ratio) in
                        MixRecipe.Ingredient(
                            colorName: color.name,
                            colorHex: color.hexString,
                            ratio: ratio
                        )
                    }
                    if let result = mix(ingredients: ingredients, mode: .realistic) {
                        let distance = colorDistance(result.resultColor, targetColor)
                        if distance < 0.15 { // 阈值
                            suggestions.append(MixRecipe(
                                name: "建议配方",
                                ingredients: ingredients,
                                resultColor: result.resultColor,
                                notes: "与目标色差: \(String(format: "%.1f", distance * 100))%"
                            ))
                        }
                    }
                }
            }
        }

        return suggestions
            .sorted { colorDistance($0.resultColor, targetColor) < colorDistance($1.resultColor, targetColor) }
            .prefix(5)
            .map { $0 }
    }

    // MARK: - 辅助方法
    private static func combinations(from colors: [PaintColor], count: Int) -> [[PaintColor]] {
        guard count <= colors.count else { return [] }
        var result: [[PaintColor]] = []

        func backtrack(_ start: Int, _ current: [PaintColor]) {
            if current.count == count {
                result.append(current)
                return
            }
            for i in start..<colors.count {
                backtrack(i + 1, current + [colors[i]])
            }
        }

        backtrack(0, [])
        return result
    }

    private static func generateRatioCombinations(count: Int, steps: Int) -> [[Double]] {
        // 生成所有可能的比例组合，总和为 1
        var results: [[Double]] = []

        func generate(_ remaining: Int, _ total: Double, _ current: [Double]) {
            if remaining == 1 {
                results.append(current + [1.0 - total])
                return
            }
            let stepSize = (1.0 - total) / Double(steps)
            for i in 0...steps {
                let ratio = Double(i) * stepSize
                if total + ratio <= 1.0 {
                    generate(remaining - 1, total + ratio, current + [ratio])
                }
            }
        }

        generate(count, 0, [])
        return results
    }

    static func colorDistance(_ c1: RGBColor, _ c2: RGBColor) -> Double {
        // 使用加权欧几里得距离（人眼对各颜色敏感度不同）
        let dr = (c1.r - c2.r) * 0.299
        let dg = (c1.g - c2.g) * 0.587
        let db = (c1.b - c2.b) * 0.114
        return sqrt(dr * dr + dg * dg + db * db)
    }
}
