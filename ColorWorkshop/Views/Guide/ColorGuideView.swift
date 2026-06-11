import SwiftUI

// MARK: - 调色指南视图
/// 提供色彩理论知识和预设调色配方
struct ColorGuideView: View {
    @EnvironmentObject private var paletteVM: PaletteViewModel
    @State private var selectedTab: GuideTab = .lessons
    @State private var selectedLesson: ColorLesson?
    @State private var showLessonDetail = false

    enum GuideTab: String, CaseIterable {
        case lessons = "色彩课程"
        case recipes = "预设配方"
        case wheel = "色轮参考"

        var icon: String {
            switch self {
            case .lessons: return "book.fill"
            case .recipes: return "flask.fill"
            case .wheel:   return "circle.circle.fill"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 分段选择器
            Picker("指南分类", selection: $selectedTab) {
                ForEach(GuideTab.allCases, id: \.self) { tab in
                    Label(tab.rawValue, systemImage: tab.icon).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // 内容区域
            TabView(selection: $selectedTab) {
                lessonsTab.tag(GuideTab.lessons)
                recipesTab.tag(GuideTab.recipes)
                colorWheelTab.tag(GuideTab.wheel)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(GradientBackground())
        .navigationTitle("调色指南")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showLessonDetail) {
            if let lesson = selectedLesson {
                LessonDetailView(lesson: lesson)
            }
        }
    }

    // MARK: - 色彩课程
    private var lessonsTab: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("掌握色彩理论，让调色不再迷茫")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                LazyVStack(spacing: 14) {
                    ForEach(ColorLesson.lessons) { lesson in
                        lessonCard(lesson)
                            .onTapGesture {
                                selectedLesson = lesson
                                showLessonDetail = true
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding(.vertical)
        }
    }

    private func lessonCard(_ lesson: ColorLesson) -> some View {
        GlassCard {
            HStack(spacing: 14) {
                // 图标区
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: lesson.exampleColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)

                    Image(systemName: lesson.iconName)
                        .font(.title3)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.headline)
                    Text(lesson.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // 预览色条
                HStack(spacing: -4) {
                    ForEach(Array(lesson.exampleColors.enumerated()), id: \.offset) { _, color in
                        Circle()
                            .fill(color)
                            .frame(width: 16, height: 16)
                            .overlay(Circle().stroke(.white.opacity(0.5), lineWidth: 1))
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - 预设配方
    private var recipesTab: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("常用调色配方，可直接参考使用")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                LazyVStack(spacing: 14) {
                    ForEach(MixRecipe.presets) { recipe in
                        recipeCard(recipe)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding(.vertical)
        }
    }

    private func recipeCard(_ recipe: MixRecipe) -> some View {
        GlassCard {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(recipe.name)
                            .font(.headline)
                        if !recipe.tags.isEmpty {
                            HStack(spacing: 4) {
                                ForEach(recipe.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Capsule().fill(.ultraThinMaterial))
                                }
                            }
                        }
                    }

                    Spacer()

                    // 结果颜色
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: recipe.resultColor.r,
                                   green: recipe.resultColor.g,
                                   blue: recipe.resultColor.b))
                        .frame(width: 44, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                }

                // 成分可视化
                HStack(spacing: 0) {
                    ForEach(recipe.ingredients) { ing in
                        Color(hex: ing.colorHex)
                            .frame(width: max(20, CGFloat(ing.ratio) * 280), height: 4)
                    }
                }
                .clipShape(Capsule())

                // 成分详情
                HStack(spacing: 6) {
                    ForEach(recipe.ingredients) { ing in
                        HStack(spacing: 3) {
                            Circle()
                                .fill(Color(hex: ing.colorHex) ?? .gray)
                                .frame(width: 8, height: 8)
                            Text("\(ing.colorName) \(Int(ing.ratio * 100))%")
                                .font(.caption2)
                        }
                        if ing.id != recipe.ingredients.last?.id {
                            Text("+")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: {
                    paletteVM.addRecipe(recipe)
                }) {
                    Label("收藏配方", systemImage: "bookmark")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .tint(.orange)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - 色轮参考
    private var colorWheelTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 色轮绘制
                colorWheelView
                    .frame(width: 260, height: 260)
                    .padding(.top, 20)

                Text("12色相环")
                    .font(.headline)

                Text("了解色轮上各颜色的关系\n是掌握调色的基础")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                // 和谐类型说明
                VStack(spacing: 12) {
                    ForEach(HarmonyType.allCases, id: \.self) { type in
                        harmonyInfoCard(type)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }

    private var colorWheelView: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let outerR = min(cx, cy) - 4
            let innerR = outerR - 28

            // 绘制 360 度色环 (一次性离屏渲染)
            for deg in 0..<360 {
                let hue = Double(deg) / 360.0
                let rad = Double(deg) * .pi / 180 - .pi / 2
                let color = Color(hue: hue, saturation: 0.85, brightness: 0.9)

                var path = Path()
                let x1 = cx + innerR * cos(rad)
                let y1 = cy + innerR * sin(rad)
                let x2 = cx + outerR * cos(rad)
                let y2 = cy + outerR * sin(rad)
                path.move(to: CGPoint(x: x1, y: y1))
                path.addLine(to: CGPoint(x: x2, y: y2))

                context.stroke(path, with: .color(color), lineWidth: 2.5)
            }

            // 内圈
            let centerRect = CGRect(x: cx - 58, y: cy - 58, width: 116, height: 116)
            context.fill(Path(ellipseIn: centerRect), with: .color(.white.opacity(0.15)))
            context.stroke(Path(ellipseIn: centerRect), with: .color(.white.opacity(0.3)), lineWidth: 1)

            // 文字
            context.draw(
                Text("色轮").font(.caption).foregroundColor(.secondary),
                at: CGPoint(x: cx, y: cy)
            )
        }
        .drawingGroup()
    }

    private func harmonyInfoCard(_ type: HarmonyType) -> some View {
        GlassCard(padding: 12) {
            HStack(spacing: 10) {
                Image(systemName: harmonyIcon(for: type))
                    .font(.title3)
                    .foregroundColor(.orange)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text(type.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(type.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
        .padding(.horizontal)
    }

    private func harmonyIcon(for type: HarmonyType) -> String {
        switch type {
        case .complementary:     return "arrow.left.and.right"
        case .analogous:         return "arrow.triangle.branch"
        case .triadic:           return "triangle.fill"
        case .splitComplementary: return "arrow.triangle.pull"
        case .tetradic:          return "square.fill"
        case .monochromatic:     return "slider.horizontal.3"
        }
    }
}

// MARK: - 课程详情视图
struct LessonDetailView: View {
    let lesson: ColorLesson
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 示例色展示
                    HStack(spacing: -8) {
                        ForEach(Array(lesson.exampleColors.enumerated()), id: \.offset) { _, color in
                            RoundedRectangle(cornerRadius: 16)
                                .fill(color)
                                .frame(width: 80, height: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.white.opacity(0.4), lineWidth: 1)
                                )
                                .shadow(color: color.opacity(0.4), radius: 10)
                        }
                    }
                    .padding(.top, 20)

                    // 标题
                    VStack(spacing: 6) {
                        Text(lesson.title)
                            .font(.title)
                            .fontWeight(.bold)
                        Text(lesson.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    // 正文
                    GlassCard {
                        Text(lesson.content)
                            .font(.body)
                            .lineSpacing(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
            .background(GradientBackground())
            .navigationTitle("色彩课程")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ColorGuideView()
            .environmentObject(PaletteViewModel())
    }
}
