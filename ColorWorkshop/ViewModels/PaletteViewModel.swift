import SwiftUI
import Combine

// MARK: - 色板管理 ViewModel
@MainActor
final class PaletteViewModel: ObservableObject {

    @Published var palettes: [ColorPalette] = []
    @Published var savedRecipes: [MixRecipe] = []
    @Published var selectedPalette: ColorPalette?
    @Published var isEditing = false
    @Published var searchText = ""

    private let palettesKey = "saved_palettes"
    private let recipesKey = "saved_recipes"

    var filteredPalettes: [ColorPalette] {
        if searchText.isEmpty { return palettes }
        return palettes.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var favoritePalettes: [ColorPalette] {
        palettes.filter { $0.isFavorite }
    }

    init() {
        loadAll()
        if palettes.isEmpty {
            createSamplePalettes()
        }
    }

    // MARK: - 增删改查
    func addPalette(_ palette: ColorPalette) {
        palettes.insert(palette, at: 0)
        savePalettes()
    }

    func updatePalette(_ palette: ColorPalette) {
        if let index = palettes.firstIndex(where: { $0.id == palette.id }) {
            var updated = palette
            updated.modifiedAt = Date()
            palettes[index] = updated
            savePalettes()
        }
    }

    func deletePalette(_ palette: ColorPalette) {
        palettes.removeAll { $0.id == palette.id }
        savePalettes()
    }

    func deletePalettes(at offsets: IndexSet) {
        palettes.remove(atOffsets: offsets)
        savePalettes()
    }

    func toggleFavorite(_ palette: ColorPalette) {
        if let index = palettes.firstIndex(where: { $0.id == palette.id }) {
            palettes[index].isFavorite.toggle()
            palettes[index].modifiedAt = Date()
            savePalettes()
        }
    }

    func duplicatePalette(_ palette: ColorPalette) {
        let copy = ColorPalette(
            id: UUID(),
            name: palette.name + " (副本)",
            description: palette.description,
            colors: palette.colors,
            createdAt: Date(),
            modifiedAt: Date(),
            isFavorite: false,
            harmony: palette.harmony
        )
        palettes.insert(copy, at: 0)
        savePalettes()
    }

    // MARK: - 配方管理
    func addRecipe(_ recipe: MixRecipe) {
        savedRecipes.insert(recipe, at: 0)
        saveRecipes()
    }

    func deleteRecipe(_ recipe: MixRecipe) {
        savedRecipes.removeAll { $0.id == recipe.id }
        saveRecipes()
    }

    // MARK: - 色彩和谐生成
    func generateHarmonyPalette(
        baseColor: RGBColor,
        type: HarmonyType,
        name: String? = nil
    ) -> ColorPalette {
        let harmonyColors = ColorTheory.generateHarmony(baseColor: baseColor, type: type)

        let paletteColors = harmonyColors.map { rgb in
            ColorPalette.PaletteColor(
                id: UUID(),
                colorHex: rgb.hexString,
                label: ColorTheory.chineseColorName(rgb)
            )
        }

        return ColorPalette(
            name: name ?? "\(type.rawValue)色板",
            description: type.description,
            colors: paletteColors,
            harmony: type
        )
    }

    // MARK: - 数据持久化
    private func savePalettes() {
        if let data = try? JSONEncoder().encode(palettes) {
            UserDefaults.standard.set(data, forKey: palettesKey)
        }
    }

    private func saveRecipes() {
        if let data = try? JSONEncoder().encode(savedRecipes) {
            UserDefaults.standard.set(data, forKey: recipesKey)
        }
    }

    private func loadAll() {
        if let data = UserDefaults.standard.data(forKey: palettesKey),
           let decoded = try? JSONDecoder().decode([ColorPalette].self, from: data) {
            palettes = decoded
        }
        if let data = UserDefaults.standard.data(forKey: recipesKey),
           let decoded = try? JSONDecoder().decode([MixRecipe].self, from: data) {
            savedRecipes = decoded
        }
    }

    // MARK: - 示例数据
    private func createSamplePalettes() {
        let samples: [(String, [String], HarmonyType)] = [
            ("暖秋色系", ["#D4452A", "#E8913A", "#F2C94C", "#8B4513", "#FDEBD0"], .analogous),
            ("深海静谧", ["#0D1B2A", "#1B3A5C", "#2E5F8A", "#4A90C4", "#A8D8EA"], .monochromatic),
            ("春意盎然", ["#2D5A27", "#4A8C3F", "#7BC67E", "#A8D8A8", "#D4EDD4"], .monochromatic),
            ("落日余晖", ["#8B2252", "#D4452A", "#E8753A", "#F2A65A", "#FDE0A6"], .analogous),
            ("紫韵", ["#4A0E4E", "#7B2D8E", "#9B59B6", "#C39BD3", "#E8DAEF"], .monochromatic),
        ]

        for (name, hexColors, harmony) in samples {
            let paletteColors = hexColors.map { hex in
                ColorPalette.PaletteColor(id: UUID(), colorHex: hex, label: "")
            }
            let palette = ColorPalette(
                name: name,
                description: "\(harmony.rawValue)配色",
                colors: paletteColors,
                harmony: harmony
            )
            palettes.append(palette)
        }
        savePalettes()
    }
}
