import SwiftUI

// MARK: - 主内容视图
/// App 的 TabView 主框架
struct ContentView: View {
    @StateObject private var paletteVM = PaletteViewModel()
    @State private var selectedTab = 0
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                splashView
                    .transition(.opacity)
            } else {
                mainTabView
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showSplash = false
                }
            }
        }
    }

    // MARK: - 启动画面
    private var splashView: some View {
        ZStack {
            // 艺术感渐变背景
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.08, blue: 0.18),
                    Color(red: 0.18, green: 0.10, blue: 0.25),
                    Color(red: 0.12, green: 0.06, blue: 0.15),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // 动态色环 logo
                SplashLogoView()
                    .frame(width: 120, height: 120)

                VStack(spacing: 8) {
                    Text("调色工坊")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundColor(.white)

                    Text("画家的色彩伴侣")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }

                // 底部六个颜色点
                HStack(spacing: 16) {
                    ForEach(PaintColor.baseColors, id: \.id) { color in
                        Circle()
                            .fill(color.color)
                            .frame(width: 12, height: 12)
                            .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 0.5))
                    }
                }
                .padding(.top, 8)
            }
        }
    }

    // MARK: - 主 TabView
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: 混色实验室
            NavigationView {
                MixLabView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("实验室", systemImage: "drop.fill")
            }
            .tag(0)

            // Tab 2: 调色指南
            NavigationView {
                ColorGuideView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("指南", systemImage: "book.fill")
            }
            .tag(1)

            // Tab 3: 色板库
            NavigationView {
                PaletteGalleryView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("色板", systemImage: "square.grid.2x2.fill")
            }
            .tag(2)

            // Tab 4: 设置
            NavigationView {
                SettingsView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("设置", systemImage: "gearshape.fill")
            }
            .tag(3)
        }
        .tint(.orange)
        .environmentObject(paletteVM)
        .onAppear {
            // 自定义 TabBar 外观
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - 启动画面 Logo (静态高性能)
struct SplashLogoView: View {
    var body: some View {
        ZStack {
            // 六个色点
            ForEach(0..<6) { i in
                let angle = Double(i) * 60.0
                let hue = Double(i) / 6.0
                Circle()
                    .fill(Color(hue: hue, saturation: 0.85, brightness: 0.9))
                    .frame(width: 24, height: 24)
                    .offset(
                        x: cos(angle * .pi / 180) * 36,
                        y: sin(angle * .pi / 180) * 36
                    )
            }

            // 内圈
            Circle()
                .fill(.white.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
                .overlay(
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                )
        }
    }
}

#Preview {
    ContentView()
}
