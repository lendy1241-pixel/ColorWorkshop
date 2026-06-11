import SwiftUI
import Combine

// MARK: - 混色实验室 ViewModel
@MainActor
final class MixLabViewModel: ObservableObject {

    // MARK: - 已发布的属性
    @Published var selectedColors: [MixColorSlot] = [
        MixColorSlot(color: .cadmiumRed, ratio: 0.5),
        MixColorSlot(color: .cadmiumYellow, ratio: 0.5),
    ]

    @Published var mixMode: PaintMixingEngine.MixMode = .realistic
    @Published var mixResult: PaintMixingEngine.MixResult?
    @Published var showColorPicker = false
    @Published var colorPickerSlotIndex: Int = 0
    @Published var selectedBaseColor: PaintColor = .cadmiumRed

    // 颜色选择器相关
    @Published var customHue: Double = 0
    @Published var customSaturation: Double = 0.8
    @Published var customBrightness: Double = 0.9

    @Published var activeSlotCount: Int = 2 {
        didSet {
            adjustSlotCount()
        }
    }

    // MARK: - 计算属性
    var resultColor: Color {
        if let result = mixResult {
            return Color(red: result.resultColor.r,
                        green: result.resultColor.g,
                        blue: result.resultColor.b)
        }
        return .gray
    }

    var resultHex: String {
        mixResult?.hex ?? "#808080"
    }

    var resultCMYK: String {
        guard let cmyk = mixResult?.cmykBreakdown else { return "C:0 M:0 Y:0 K:0" }
        return String(format: "C:%.0f%% M:%.0f%% Y:%.0f%% K:%.0f%%",
                      cmyk.c * 100, cmyk.m * 100, cmyk.y * 100, cmyk.k * 100)
    }

    var resultHSB: String {
        guard let hsb = mixResult?.hsbBreakdown else { return "H:0° S:0% B:0%" }
        return String(format: "H:%.0f° S:%.0f%% B:%.0f%%",
                      hsb.h * 360, hsb.s * 100, hsb.b * 100)
    }

    var resultColorName: String {
        guard let result = mixResult else { return "未知" }
        return ColorTheory.chineseColorName(result.resultColor)
    }

    var resultTemperature: ColorTheory.ColorTemperature {
        guard let result = mixResult else { return .neutral }
        return ColorTheory.temperature(result.resultColor)
    }

    // MARK: - 方法
    func performMix() {
        let activeSlots = selectedColors.prefix(activeSlotCount).filter { !$0.isEmpty }
        guard activeSlots.count >= 2 else { return }

        // 归一化比例
        let totalRatio = activeSlots.reduce(0) { $0 + $1.ratio }
        guard totalRatio > 0 else { return }

        let ingredients = activeSlots.map { slot in
            MixRecipe.Ingredient(
                colorName: slot.color?.name ?? "自定义",
                colorHex: slot.color?.hexString ?? "#000000",
                ratio: slot.ratio / totalRatio
            )
        }

        mixResult = PaintMixingEngine.mix(ingredients: ingredients, mode: mixMode)
    }

    func addSlot() {
        guard activeSlotCount < 4 else { return }
        activeSlotCount += 1
    }

    func removeSlot() {
        guard activeSlotCount > 2 else { return }
        activeSlotCount -= 1
    }

    func setBaseColor(for index: Int, color: PaintColor) {
        guard index < selectedColors.count else { return }
        selectedColors[index].color = color
        performMix()
    }

    func updateRatio(for index: Int, to value: Double) {
        guard index < selectedColors.count else { return }
        selectedColors[index].ratio = value
        performMix()
    }

    func saveAsPalette() -> ColorPalette? {
        guard let result = mixResult else { return nil }
        let recipe = MixRecipe(
            name: "调色结果",
            ingredients: result.ingredients,
            resultColor: result.resultColor,
            notes: "使用\(result.mode.rawValue)模式混合"
        )
        return ColorPalette(from: recipe, name: "混合色板 \(Date().formatted(date: .numeric, time: .shortened))")
    }

    func saveAsRecipe() -> MixRecipe? {
        guard let result = mixResult else { return nil }
        return MixRecipe(
            name: "配方 \(Date().formatted(date: .numeric, time: .shortened))",
            ingredients: result.ingredients,
            resultColor: result.resultColor,
            notes: "使用\(result.mode.rawValue)模式混合"
        )
    }

    // MARK: - 私有方法
    private func adjustSlotCount() {
        while selectedColors.count < activeSlotCount {
            let defaultColors: [PaintColor] = [.cadmiumRed, .cadmiumYellow, .ultramarineBlue, .titaniumWhite]
            let idx = selectedColors.count
            selectedColors.append(MixColorSlot(
                color: defaultColors[safe: idx] ?? .viridianGreen,
                ratio: 1.0 / Double(activeSlotCount)
            ))
        }
        if selectedColors.count > activeSlotCount {
            selectedColors = Array(selectedColors.prefix(activeSlotCount))
        }
        performMix()
    }
}

// MARK: - 混合颜色槽
struct MixColorSlot: Identifiable {
    let id = UUID()
    var color: PaintColor?
    var ratio: Double

    var isEmpty: Bool { color == nil }

    init(color: PaintColor? = nil, ratio: Double = 0) {
        self.color = color
        self.ratio = ratio
    }
}

// MARK: - 安全数组访问
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
