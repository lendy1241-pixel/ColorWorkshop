# 🎨 调色工坊 (Color Workshop)

> **画家的调色伴侣** — 专为画家设计的 iOS 调色学习与辅助工具

[![Platform](https://img.shields.io/badge/platform-iOS%2015%2B-orange)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/swift-5.7%2B-red)](https://swift.org)
[![Install](https://img.shields.io/badge/install-TrollStore-blue)](https://github.com/opa334/TrollStore)

## 📱 功能概览

| 功能 | 描述 |
|------|------|
| 🔬 **混色实验室** | 选择 2-4 种颜料，调整比例，实时查看混合结果 |
| 📖 **调色指南** | 6 大色彩理论课程 + 12+ 预设调色配方 |
| 🎭 **色板管理** | 保存、收藏、复制你的配色方案 |
| 🌈 **色彩和谐生成** | 自动生成互补色、近似色、三角色等方案 |
| 🎯 **智能配色建议** | 输入目标颜色，反向推荐可能配方 |

## 🎨 六大基础颜料

```
⬜ 钛白    ⬛ 象牙黑
🟥 镉红    🟦 群青蓝
🟨 镉黄    🟩 翠绿
```

## 🧪 混色引擎

内置三种混合模式，模拟真实颜料混合：

- **真实颜料模式** — 基于 Kubelka-Munk 理论的简化模型，最接近实际颜料效果
- **减色混合模式** — CMYK 颜色空间中的减色混合
- **加权平均模式** — 直接按比例加权，适合快速估算

## 📦 安装方式

### 通过巨魔（TrollStore）安装

1. 确保你的 iPhone 已安装 [TrollStore](https://github.com/opa334/TrollStore)
2. 下载 `调色工坊.ipa`
3. 在 TrollStore 中打开 IPA 文件
4. 点击 **Install**
5. 在桌面上找到「调色工坊」图标

> ✅ 无需签名、无需描述文件、无需证书  
> ✅ 兼容 iOS 15.0 - 17.0（TrollStore 支持的版本）

### 从源码构建

```bash
# 1. 克隆项目
git clone <repo-url>
cd ColorWorkshop

# 2. 安装依赖 & 生成图标
pip3 install Pillow
python3 Scripts/generate_icons.py

# 3. 生成 Xcode 项目（需要安装 XcodeGen）
brew install xcodegen
xcodegen generate

# 4. 在 Mac 上用 Xcode 打开 ColorWorkshop.xcodeproj
# 5. Product > Archive > Distribute App > Development > 导出 IPA
```

### GitHub Actions 自动构建

推送代码到 GitHub 后，Actions 会自动构建 IPA：

1. 在 Actions 页面找到 Build IPA workflow
2. 点击最新运行的 workflow
3. 在 Artifacts 中下载 `调色工坊.ipa`

## 🏗️ 项目结构

```
ColorWorkshop/
├── ColorWorkshop/                 # Swift 源码
│   ├── ColorWorkshopApp.swift     # App 入口
│   ├── ContentView.swift          # 主界面（TabView + 启动动画）
│   ├── Models/
│   │   ├── PaintColor.swift       # 颜料颜色模型
│   │   ├── MixRecipe.swift        # 调色配方模型
│   │   └── ColorPalette.swift     # 色板模型
│   ├── Engine/
│   │   ├── PaintMixingEngine.swift # 颜料混合引擎
│   │   └── ColorTheory.swift      # 色彩理论算法
│   ├── ViewModels/
│   │   ├── MixLabViewModel.swift  # 混色实验室状态管理
│   │   └── PaletteViewModel.swift # 色板管理状态
│   ├── Views/
│   │   ├── MixLab/                # 混色实验室界面
│   │   ├── Guide/                 # 调色指南界面
│   │   ├── Palettes/              # 色板库界面
│   │   ├── Settings/              # 设置界面
│   │   └── Components/            # 可复用组件
│   ├── Resources/
│   │   └── Assets.xcassets/       # 资源目录
│   └── Info.plist                 # App 配置
├── Scripts/
│   ├── generate_icons.py          # 图标生成脚本
│   └── build_ipa.sh               # IPA 构建脚本
├── .github/workflows/build.yml    # CI/CD 自动构建
├── project.yml                    # XcodeGen 项目配置
└── README.md
```

## 🎯 使用场景

- **作画前**：参考调色指南确认色彩理论
- **调色时**：在混色实验室中模拟颜料比例
- **配色时**：使用和谐生成器快速获得配色方案
- **积累中**：将成功的调色保存为色板/配方
- **学习中**：阅读色彩课程，理解色彩原理

## 🔧 技术栈

- **语言**: Swift 5.7+
- **框架**: SwiftUI
- **最低版本**: iOS 15.0
- **数据持久化**: UserDefaults (JSON)
- **构建配置**: XcodeGen

## 📝 待扩展功能（按需迭代）

- [ ] 扩展颜料库（增加更多基础色）
- [ ] iCloud 同步色板
- [ ] 从照片提取颜色
- [ ] AR 取色（用相机取现实中颜色）
- [ ] 色彩无障碍辅助（色弱模式）
- [ ] 导出色板为 PDF/图片
- [ ] Apple Pencil 支持
- [ ] iPad 分屏适配

## 📄 许可

MIT License — 自由使用、修改、分发

---

> 🎨 **每一笔颜色，都有它的故事。**  
> 调色工坊，让你的调色不再迷茫。
