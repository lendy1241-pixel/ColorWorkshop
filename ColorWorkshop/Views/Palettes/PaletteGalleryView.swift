import SwiftUI

// MARK: - 色板库视图
/// 展示用户保存的所有色板和配方
struct PaletteGalleryView: View {
    @EnvironmentObject private var paletteVM: PaletteViewModel
    @State private var selectedSegment: Segment = .palettes
    @State private var showDeleteAlert = false
    @State private var paletteToDelete: ColorPalette?
    @State private var showHarmonyGenerator = false

    enum Segment: String, CaseIterable {
        case palettes = "色板"
        case recipes = "配方"
        case harmony = "和谐"

        var icon: String {
            switch self {
            case .palettes: return "square.grid.2x2"
            case .recipes:  return "flask"
            case .harmony:  return "circle.hexagongrid"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 分段选择
            Picker("分类", selection: $selectedSegment) {
                ForEach(Segment.allCases, id: \.self) { seg in
                    Label(seg.rawValue, systemImage: seg.icon).tag(seg)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // 内容
            TabView(selection: $selectedSegment) {
                palettesTab.tag(Segment.palettes)
                recipesTab.tag(Segment.recipes)
                harmonyTab.tag(Segment.harmony)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(GradientBackground())
        .navigationTitle("色板库")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $paletteVM.searchText, prompt: "搜索色板...")
        .alert("删除色板", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                if let palette = paletteToDelete {
                    paletteVM.deletePalette(palette)
                }
            }
        } message: {
            Text("确定要删除这个色板吗？此操作不可撤销。")
        }
    }

    // MARK: - 色板列表
    private var palettesTab: some View {
        ScrollView {
            if paletteVM.filteredPalettes.isEmpty {
                emptyStateView(
                    icon: "square.grid.2x2",
                    title: "还没有色板",
                    message: "在混色实验室中创建的色板\n会出现在这里"
                )
            } else {
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
                    spacing: 14
                ) {
                    ForEach(paletteVM.filteredPalettes) { palette in
                        paletteCard(palette)
                            .contextMenu {
                                Button {
                                    paletteVM.toggleFavorite(palette)
                                } label: {
                                    Label(
                                        palette.isFavorite ? "取消收藏" : "收藏",
                                        systemImage: palette.isFavorite ? "heart.slash" : "heart"
                                    )
                                }

                                Button {
                                    paletteVM.duplicatePalette(palette)
                                } label: {
                                    Label("复制", systemImage: "doc.on.doc")
                                }

                                Button(role: .destructive) {
                                    paletteToDelete = palette
                                    showDeleteAlert = true
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }

    private func paletteCard(_ palette: ColorPalette) -> some View {
        VStack(spacing: 0) {
            // 色条展示
            HStack(spacing: 0) {
                ForEach(palette.colors) { color in
                    color.color
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.3), lineWidth: 0.5)
            )
            .overlay(alignment: .topTrailing) {
                if palette.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(6)
                        .background(Circle().fill(.ultraThinMaterial))
                        .padding(4)
                }
            }

            // 信息
            VStack(alignment: .leading, spacing: 2) {
                Text(palette.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)

                if let harmony = palette.harmony {
                    Text(harmony.rawValue)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 6)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .onTapGesture {
            // 选中详情（未来可扩展为展开色板详情）
        }
    }

    // MARK: - 配方列表
    private var recipesTab: some View {
        ScrollView {
            if paletteVM.savedRecipes.isEmpty {
                emptyStateView(
                    icon: "flask",
                    title: "还没有保存配方",
                    message: "在混色实验室或调色指南中\n保存的配方会出现在这里"
                )
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(paletteVM.savedRecipes) { recipe in
                        savedRecipeCard(recipe)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }

    private func savedRecipeCard(_ recipe: MixRecipe) -> some View {
        GlassCard(padding: 14) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: recipe.resultColor.r,
                               green: recipe.resultColor.g,
                               blue: recipe.resultColor.b))
                    .frame(width: 48, height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name.isEmpty ? "未命名配方" : recipe.name)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    HStack(spacing: 4) {
                        ForEach(recipe.ingredients.prefix(3)) { ing in
                            Text(ing.colorName)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        if recipe.ingredients.count > 3 {
                            Text("+\(recipe.ingredients.count - 3)")
                                .font(.caption2)
                        }
                    }
                }

                Spacer()

                Text(recipe.resultColor.hexString)
                    .font(.caption.monospaced())
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                paletteVM.deleteRecipe(recipe)
            } label: {
                Label("删除", systemImage: "trash")
            }
        }
    }

    // MARK: - 和谐色生成器
    private var harmonyTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("色彩和谐生成器")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("选择一个基础色与和谐类型\n自动生成配色方案")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                // 预设色选择
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("基础色")
                            .font(.headline)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                            ForEach(PaintColor.baseColors) { color in
                                Circle()
                                    .fill(color.color)
                                    .frame(width: 36, height: 36)
                                    .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 1))
                                    .onTapGesture {
                                        generateForBase(color: color.rgb, name: color.name)
                                    }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // 和谐类型
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("和谐类型")
                            .font(.headline)

                        ForEach(HarmonyType.allCases, id: \.self) { type in
                            Button(action: {
                                let baseColor = PaintColor.ultramarineBlue.rgb
                                generateForBase(color: baseColor, type: type)
                            }) {
                                HStack {
                                    Text(type.rawValue)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text(type.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                    Image(systemName: "plus.circle")
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.vertical, 4)

                            if type != HarmonyType.allCases.last {
                                Divider()
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // 生成的和谐色板
                if !paletteVM.palettes.filter({ $0.harmony != nil }).isEmpty {
                    VStack(alignment: .leading) {
                        Text("最近生成")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(paletteVM.palettes.filter { $0.harmony != nil }.prefix(10)) { palette in
                                    harmonyPaletteCard(palette)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.bottom, 30)
        }
    }

    private func harmonyPaletteCard(_ palette: ColorPalette) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 0) {
                ForEach(palette.colors) { color in
                    color.color
                        .frame(width: 30, height: 60)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(width: CGFloat(palette.colors.count) * 30, height: 60)

            Text(palette.name)
                .font(.caption2)
                .lineLimit(1)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }

    private func generateForBase(color: RGBColor, name: String? = nil, type: HarmonyType? = nil) {
        let harmonyType = type ?? .analogous
        let palette = paletteVM.generateHarmonyPalette(
            baseColor: color,
            type: harmonyType,
            name: name.map { "\($0) \(harmonyType.rawValue)" }
        )
        paletteVM.addPalette(palette)
    }

    // MARK: - 空状态
    private func emptyStateView(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))

            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)

            Text(message)
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

#Preview {
    NavigationView {
        PaletteGalleryView()
            .environmentObject(PaletteViewModel())
    }
}
