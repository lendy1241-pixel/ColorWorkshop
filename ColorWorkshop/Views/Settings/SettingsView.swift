import SwiftUI

// MARK: - 设置视图
struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showAbout = false
    @State private var showResetAlert = false
    @AppStorage("preferredMixMode") private var preferredMixMode: String = PaintMixingEngine.MixMode.realistic.rawValue
    @AppStorage("showColorTips") private var showColorTips: Bool = true
    @AppStorage("autoSavePalettes") private var autoSavePalettes: Bool = true

    var body: some View {
        List {
            // 应用信息
            Section {
                HStack(spacing: 14) {
                    // App 图标占位
                    appIconView
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .orange.opacity(0.3), radius: 8)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("调色工坊")
                            .font(.headline)
                        Text("画家调色助手")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("v1.0.0")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button("关于") {
                        showAbout = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                }
                .padding(.vertical, 4)
            }

            // 默认设置
            Section("默认设置") {
                Picker("默认混合模式", selection: $preferredMixMode) {
                    ForEach(PaintMixingEngine.MixMode.allCases, id: \.rawValue) { mode in
                        Text(mode.rawValue).tag(mode.rawValue)
                    }
                }

                Toggle("显示调色提示", isOn: $showColorTips)
                Toggle("自动保存色板", isOn: $autoSavePalettes)
            }

            // 色彩参考
            Section("色彩参考") {
                NavigationLink(destination: EmptyView()) {
                    Label("管理基础颜料", systemImage: "paintpalette")
                }
                .disabled(true)

                NavigationLink(destination: EmptyView()) {
                    Label("自定义颜料库", systemImage: "plus.square.on.square")
                }
                .disabled(true)
            }

            // 数据管理
            Section("数据") {
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    Label("重置所有数据", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }

            // 页脚
            Section {
                VStack(spacing: 8) {
                    Text("🎨 调色工坊")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("为画家打造 · 用心调好每一笔颜色")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
        }
        .background(GradientBackground())
        .scrollContentBackground(.hidden)
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAbout) {
            aboutView
        }
        .alert("重置数据", isPresented: $showResetAlert) {
            Button("取消", role: .cancel) {}
            Button("确认重置", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("这将删除所有保存的色板和配方。此操作不可撤销。")
        }
    }

    // MARK: - App 图标（程序化绘制）
    private var appIconView: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [
                    Color(red: 0.9, green: 0.3, blue: 0.2),
                    Color(red: 0.3, green: 0.2, blue: 0.7),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 色环抽象图案
            ZStack {
                ForEach(0..<6) { i in
                    let angle = Double(i) * 60.0
                    let hue = Double(i) / 6.0
                    Circle()
                        .fill(Color(hue: hue, saturation: 0.8, brightness: 0.9))
                        .frame(width: 16, height: 16)
                        .offset(x: cos(angle * .pi / 180) * 14,
                                y: sin(angle * .pi / 180) * 14)
                }

                Circle()
                    .fill(.white)
                    .frame(width: 12, height: 12)
            }
        }
    }

    // MARK: - 关于页面
    private var aboutView: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    appIconView
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.top, 30)

                    VStack(spacing: 6) {
                        Text("调色工坊")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Color Workshop")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("版本 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("关于此 App")
                                .font(.headline)

                            Text("""
                            调色工坊是一款专为画家打造的调色助手应用。

                            功能特点：
                            • 六大基础颜料色：黑白红蓝黄绿
                            • 真实颜料混合模拟引擎
                            • 12+ 预设调色配方
                            • 色彩和谐自动生成
                            • 色板保存与管理
                            • 完整的色彩理论课程

                            适用于巨魔（TrollStore）安装。
                            iOS 15+ 兼容。
                            """)
                            .font(.caption)
                            .lineSpacing(4)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
            .background(GradientBackground())
            .navigationTitle("关于")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { showAbout = false }
                }
            }
        }
    }

    private func resetAllData() {
        UserDefaults.standard.removeObject(forKey: "saved_palettes")
        UserDefaults.standard.removeObject(forKey: "saved_recipes")
        // 需要通知 PaletteViewModel 重新加载
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
