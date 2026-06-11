import SwiftUI

// MARK: - 色彩理论引擎
/// 提供色彩和谐、色轮计算等功能
struct ColorTheory {

    // MARK: - 从基础色生成和谐色板
    static func generateHarmony(
        baseColor: RGBColor,
        type: HarmonyType,
        count: Int = 5
    ) -> [RGBColor] {
        let hsb = baseColor.hsb
        let h = hsb.h

        switch type {
        case .complementary:
            return [
                baseColor,
                RGBColor.fromHSB(h: h + 0.5, s: hsb.s, b: hsb.b)
            ]

        case .analogous:
            let step = 0.05
            return (-2...2).map { i in
                let newH = (h + Double(i) * step).truncatingRemainder(dividingBy: 1.0)
                let adjustedH = newH < 0 ? newH + 1 : newH
                return RGBColor.fromHSB(h: adjustedH, s: hsb.s, b: hsb.b)
            }

        case .triadic:
            return [
                baseColor,
                RGBColor.fromHSB(h: h + 1.0/3.0, s: hsb.s, b: hsb.b),
                RGBColor.fromHSB(h: h + 2.0/3.0, s: hsb.s, b: hsb.b),
            ]

        case .splitComplementary:
            let comp = h + 0.5
            return [
                baseColor,
                RGBColor.fromHSB(h: comp - 0.05, s: hsb.s, b: hsb.b),
                RGBColor.fromHSB(h: comp + 0.05, s: hsb.s, b: hsb.b),
            ]

        case .tetradic:
            return [
                baseColor,
                RGBColor.fromHSB(h: h + 0.25, s: hsb.s, b: hsb.b),
                RGBColor.fromHSB(h: h + 0.5, s: hsb.s, b: hsb.b),
                RGBColor.fromHSB(h: h + 0.75, s: hsb.s, b: hsb.b),
            ]

        case .monochromatic:
            return (0..<count).map { i in
                let fraction = Double(i) / Double(count - 1)
                let newS = hsb.s * (0.2 + 0.8 * fraction)
                let newB = hsb.b * (0.3 + 0.7 * (1.0 - fraction))
                return RGBColor.fromHSB(h: h, s: newS, b: newB)
            }
        }
    }

    // MARK: - 色轮数据
    /// 生成完整的色轮颜色数组
    static func colorWheel(segments: Int = 360) -> [RGBColor] {
        (0..<segments).map { i in
            let hue = Double(i) / Double(segments)
            return RGBColor.fromHSB(h: hue, s: 0.9, b: 0.9)
        }
    }

    // MARK: - 颜色名称（中文）
    static func chineseColorName(_ rgb: RGBColor) -> String {
        let hsb = rgb.hsb
        let h = hsb.h * 360
        let s = hsb.s
        let b = hsb.b

        // 无彩色
        if s < 0.1 {
            if b > 0.9 { return "白色" }
            if b > 0.7 { return "浅灰" }
            if b > 0.4 { return "灰色" }
            if b > 0.15 { return "深灰" }
            return "黑色"
        }

        // 有彩色 - 根据色相
        let hueName: String
        switch h {
        case 0..<15:   hueName = "红"
        case 15..<45:  hueName = "橙红"
        case 45..<75:  hueName = "橙黄"
        case 75..<105: hueName = "黄"
        case 105..<135: hueName = "黄绿"
        case 135..<165: hueName = "绿"
        case 165..<195: hueName = "青绿"
        case 195..<225: hueName = "青蓝"
        case 225..<255: hueName = "蓝"
        case 255..<285: hueName = "蓝紫"
        case 285..<315: hueName = "紫"
        case 315..<345: hueName = "红紫"
        default:        hueName = "红"
        }

        // 根据明度和饱和度添加修饰
        if b < 0.25 { return "深\(hueName)" }
        if b < 0.45 { return "暗\(hueName)" }
        if s < 0.3 { return "灰\(hueName)" }
        if b > 0.85 && s > 0.7 { return "亮\(hueName)" }
        if s > 0.7 { return "鲜\(hueName)" }
        return hueName
    }

    // MARK: - 色温判断
    enum ColorTemperature: String {
        case warm = "暖色"
        case cool = "冷色"
        case neutral = "中性色"

        var iconName: String {
            switch self {
            case .warm: return "flame.fill"
            case .cool: return "snowflake"
            case .neutral: return "circle.fill"
            }
        }
    }

    static func temperature(_ rgb: RGBColor) -> ColorTemperature {
        // 基于红蓝比例判断色温
        let ratio = rgb.r / max(rgb.b, 0.01)
        if ratio > 1.5 { return .warm }
        if ratio < 0.6 { return .cool }
        return .neutral
    }
}

// MARK: - 色彩教学卡片数据
struct ColorLesson: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let content: String
    let iconName: String
    let exampleColors: [Color]

    static let lessons: [ColorLesson] = [
        ColorLesson(
            title: "三原色",
            subtitle: "红·黄·蓝 — 万色之源",
            content: """
            在绘画中，红、黄、蓝被称为"三原色"。它们是无法通过混合其他颜色得到的基础色彩。

            从理论上讲，所有的颜色都可以由这三种原色按不同比例混合而成。

            • 红 + 黄 = 橙
            • 黄 + 蓝 = 绿
            • 蓝 + 红 = 紫

            掌握三原色的混合比例，是调色的第一课。
            """,
            iconName: "triangle.fill",
            exampleColors: [
                Color(red: 0.9, green: 0.15, blue: 0.1),
                Color(red: 0.95, green: 0.8, blue: 0.05),
                Color(red: 0.1, green: 0.2, blue: 0.7),
            ]
        ),
        ColorLesson(
            title: "互补色",
            subtitle: "色轮对面 — 最强对比",
            content: """
            色轮上相对的两个颜色称为互补色。

            互补色并列时能产生最强烈的视觉对比，但混合时会互相中和，产生灰色或棕色。

            常见的互补色对：
            • 红 ↔ 绿
            • 蓝 ↔ 橙
            • 黄 ↔ 紫

            在调色时，加入少量互补色可以降低颜色的鲜艳度，使其更自然沉稳。
            """,
            iconName: "arrow.left.and.right",
            exampleColors: [
                Color(red: 0.9, green: 0.15, blue: 0.1),
                Color(red: 0.1, green: 0.6, blue: 0.3),
            ]
        ),
        ColorLesson(
            title: "色温感知",
            subtitle: "冷暖之间 — 画面情绪",
            content: """
            颜色给人冷暖的心理感受：

            暖色（红、橙、黄）：
            • 让人联想到阳光、火焰
            • 感觉前进、扩张、活跃
            • 适合表现温暖、热情、能量的场景

            冷色（蓝、绿、紫）：
            • 让人联想到水、天空、阴影
            • 感觉后退、收缩、沉静
            • 适合表现宁静、深远、冷静的氛围

            调色时，向暖色中加入少量冷色可以让它后退，向冷色中加入暖色可以让它更生动。
            """,
            iconName: "thermometer.medium",
            exampleColors: [
                Color(red: 0.95, green: 0.5, blue: 0.1),
                Color(red: 0.1, green: 0.3, blue: 0.7),
            ]
        ),
        ColorLesson(
            title: "明度与饱和度",
            subtitle: "控制颜色的亮度与纯度",
            content: """
            调色时改变颜色的两个关键维度：

            明度（Value）：
            • 加白 → 提高明度（变亮）
            • 加黑 → 降低明度（变暗）

            饱和度（Saturation）：
            • 颜色越接近纯色，饱和度越高
            • 加入灰色（黑白混合）→ 降低饱和度
            • 加入互补色 → 降低饱和度

            实际调色中，加白不仅提亮还会降低饱和度；
            加黑不仅变暗还会使颜色变"脏"。
            """,
            iconName: "slider.horizontal.3",
            exampleColors: [
                Color(red: 0.1, green: 0.2, blue: 0.7),
                Color(red: 0.4, green: 0.5, blue: 0.85),
                Color(red: 0.7, green: 0.75, blue: 0.92),
            ]
        ),
        ColorLesson(
            title: "灰色调色法",
            subtitle: "控制饱和度的利器",
            content: """
            在画面中，纯色使用过多会显得生硬不自然。学会调"灰"是进阶画家的关键技能。

            调出好看的灰色有几种方法：
            1. 互补色混合：红+绿、蓝+橙、黄+紫
            2. 三原色混合：红+黄+蓝（等比例）
            3. 黑白混合：最简单但缺乏色彩倾向
            4. 加互补色降纯：在蓝色中加一点橙，得到温暖的灰蓝

            有"色彩倾向"的灰色比纯灰更生动、更有空气感。
            """,
            iconName: "circle.lefthalf.filled",
            exampleColors: [
                Color(red: 0.45, green: 0.42, blue: 0.38),
                Color(red: 0.55, green: 0.58, blue: 0.60),
                Color(red: 0.40, green: 0.35, blue: 0.45),
            ]
        ),
        ColorLesson(
            title: "肤色调配秘诀",
            subtitle: "人物画最难的调色",
            content: """
            肤色不是单一颜色，而是多层色彩的重叠。基础肤色公式：

            基本肤色 = 白(60%) + 红(15%) + 黄(20%) + 蓝(5%)

            不同肤色调整：
            • 偏暖肤色：增加红和黄的比例
            • 偏冷肤色：增加蓝的比例
            • 深色肤色：适当减少白，保持红黄蓝的比例
            • 东方人肤色：在基础配方上稍加一点赭石色

            阴影处的肤色不是简单加黑，而应该加入环境反射色和互补色。
            """,
            iconName: "face.smiling",
            exampleColors: [
                Color(red: 0.94, green: 0.78, blue: 0.68),
                Color(red: 0.85, green: 0.62, blue: 0.50),
                Color(red: 0.70, green: 0.45, blue: 0.35),
            ]
        ),
    ]
}
