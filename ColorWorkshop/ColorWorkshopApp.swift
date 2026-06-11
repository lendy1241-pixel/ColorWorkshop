import SwiftUI

// MARK: - App 入口
/// 调色工坊 - 画家调色助手
/// 兼容 iOS 15+，通过巨魔（TrollStore）安装
@main
struct ColorWorkshopApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(nil) // 跟随系统
        }
    }
}
