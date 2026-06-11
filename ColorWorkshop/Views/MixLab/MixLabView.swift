import SwiftUI

// MARK: - 混色实验室主视图
/// App 的核心功能：选择颜色、调整比例、查看混合结果
struct MixLabView: View {
    @StateObject private var viewModel = MixLabViewModel()
    @EnvironmentObject private var paletteVM: PaletteViewModel
    @State private var showSaveAlert = false
    @State private var showBaseColorPicker = false
    @State private var activeEditingSlot: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 混合结果展示区
                resultSection

                // 颜色选择区
                colorSlotsSection

                // 混合模式选择
                mixModePicker

                // 颜色详情
                if viewModel.mixResult != nil {
                    colorDetailSection

                    // 操作按钮
                    actionButtons
                }

                // 快速参考
                quickReferenceSection
            }
            .padding()
        }
        .background(GradientBackground())
        .navigationTitle("混色实验室")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    Button(action: { viewModel.removeSlot() }) {
                        Image(systemName: "minus.circle")
                    }
                    .disabled(viewModel.activeSlotCount <= 2)

                    Text("\(viewModel.activeSlotCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button(action: { viewModel.addSlot() }) {
                        Image(systemName: "plus.circle")
                    }
                    .disabled(viewModel.activeSlotCount >= 4)
                }
            }
        }
        .sheet(isPresented: $showBaseColorPicker) {
            BaseColorPickerView(
                selectedColor: $viewModel.selectedBaseColor,
                onSelect: { color in
                    viewModel.setBaseColor(for: activeEditingSlot, color: color)
                }
            )
            .presentationDetents([.medium, .large])
        }
        .alert("已保存", isPresented: $showSaveAlert) {
            Button("好的", role: .cancel) {}
        } message: {
            Text("调色结果已保存到色板库")
        }
        .onAppear {
            viewModel.performMix()
        }
    }

    // MARK: - 混合结果展示
    private var resultSection: some View {
        VStack(spacing: 12) {
            // 大色块展示
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(viewModel.resultColor)
                .frame(height: 160)
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                }
                .shadow(color: viewModel.resultColor.opacity(0.5), radius: 20, x: 0, y: 8)
                .overlay(alignment: .bottomTrailing) {
                    // 色温标签
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.resultTemperature.iconName)
                        Text(viewModel.resultTemperature.rawValue)
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(12)
                }

            // 颜色名称
            Text(viewModel.resultColorName)
                .font(.title2)
                .fontWeight(.bold)

            // Hex 值
            Text(viewModel.resultHex)
                .font(.title3.monospaced())
                .foregroundColor(.secondary)
        }
    }

    // MARK: - 颜色槽选择
    private var colorSlotsSection: some View {
        GlassCard {
            VStack(spacing: 16) {
                Text("选择颜料")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(0..<viewModel.activeSlotCount, id: \.self) { index in
                    colorSlotRow(index: index)
                }
            }
        }
    }

    private func colorSlotRow(index: Int) -> some View {
        let slot = viewModel.selectedColors[safe: index] ?? MixColorSlot()

        return VStack(spacing: 8) {
            HStack {
                // 颜色圆点 - 点击选择颜色
                Button(action: {
                    activeEditingSlot = index
                    showBaseColorPicker = true
                }) {
                    HStack(spacing: 12) {
                        ColorDot(
                            color: slot.color?.color ?? .gray,
                            size: 40,
                            isSelected: false
                        )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(slot.color?.name ?? "选择颜色")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(slot.color?.hexString ?? "")
                                .font(.caption.monospaced())
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }

            // 比例滑块
            HStack(spacing: 8) {
                Text("\(Int(slot.ratio * 100))%")
                    .font(.caption.monospaced())
                    .foregroundColor(.secondary)
                    .frame(width: 36, alignment: .leading)

                Slider(value: Binding(
                    get: { slot.ratio },
                    set: { viewModel.updateRatio(for: index, to: $0) }
                ), in: 0.01...0.99, step: 0.01)
                    .tint(slot.color?.color ?? .gray)

                Text("比例")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - 混合模式选择
    private var mixModePicker: some View {
        GlassCard {
            VStack(spacing: 8) {
                Text("混合模式")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Picker("混合模式", selection: $viewModel.mixMode) {
                    ForEach(PaintMixingEngine.MixMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: viewModel.mixMode) { _ in
                    viewModel.performMix()
                }

                Text(viewModel.mixMode.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - 颜色详情
    private var colorDetailSection: some View {
        GlassCard {
            VStack(spacing: 12) {
                Text("颜色数据")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 8) {
                    ColorInfoTag(label: "HEX", value: viewModel.resultHex)
                    ColorInfoTag(label: "HSB", value: viewModel.resultHSB)
                    ColorInfoTag(label: "CMYK", value: viewModel.resultCMYK)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 成分展示
                if let result = viewModel.mixResult {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("成分比例：")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack(spacing: 8) {
                            ForEach(result.ingredients) { ing in
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(Color(hex: ing.colorHex) ?? .gray)
                                        .frame(width: 10, height: 10)
                                    Text("\(Int(ing.ratio * 100))%")
                                        .font(.caption2)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(.ultraThinMaterial))
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - 操作按钮
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: {
                if let recipe = viewModel.saveAsRecipe() {
                    paletteVM.addRecipe(recipe)
                }
                showSaveAlert = true
            }) {
                Label("保存配方", systemImage: "bookmark.fill")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)

            Button(action: {
                if let palette = viewModel.saveAsPalette() {
                    paletteVM.addPalette(palette)
                }
                showSaveAlert = true
            }) {
                Label("存为色板", systemImage: "square.grid.2x2.fill")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        }
    }

    // MARK: - 快速参考
    private var quickReferenceSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("💡 调色提示")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 6) {
                    tipRow("加入白色 → 提亮 + 降低饱和度")
                    tipRow("加入黑色 → 变暗 + 颜色变'脏'")
                    tipRow("加入互补色 → 降低饱和度（变灰）")
                    tipRow("比例变化 5% → 颜色可能截然不同")
                    tipRow("少量蓝色 → 可让暖色更沉稳")
                }
            }
        }
    }

    private func tipRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•")
                .foregroundColor(.orange)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 基础色选择器
struct BaseColorPickerView: View {
    @Binding var selectedColor: PaintColor
    let onSelect: (PaintColor) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 六大基础色
                    sectionView(title: "基础六色", colors: PaintColor.baseColors)

                    // 颜色分类
                    Text("点击任意颜色即可选中")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .background(GradientBackground())
            .navigationTitle("选择颜料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }

    private func sectionView(title: String, colors: [PaintColor]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.leading, 4)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ForEach(colors) { color in
                    Button(action: {
                        selectedColor = color
                        onSelect(color)
                        dismiss()
                    }) {
                        VStack(spacing: 8) {
                            ColorDot(
                                color: color.color,
                                size: 56,
                                isSelected: selectedColor.id == color.id
                            )
                            Text(color.name)
                                .font(.caption)
                                .fontWeight(.medium)
                            Text(color.hexString)
                                .font(.caption2.monospaced())
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - 预览
#Preview {
    NavigationView {
        MixLabView()
            .environmentObject(PaletteViewModel())
    }
}
