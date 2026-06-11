#!/bin/bash
# ============================================
# 调色工坊 IPA 构建脚本
# 生成可通过巨魔(TrollStore)安装的 IPA 文件
# ============================================
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED_DATA="${PROJECT_DIR}/build/DerivedData"
BUILD_DIR="${PROJECT_DIR}/build"
APP_NAME="ColorWorkshop"
IPA_NAME="调色工坊"

echo "🎨 ======================================"
echo "   调色工坊 - IPA 构建"
echo "   iOS 15+ | TrollStore Compatible"
echo "🎨 ======================================"

# 清理
echo "📦 清理旧的构建文件..."
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# 生成图标
echo "🖼️  生成 App 图标..."
pip3 install Pillow -q 2>/dev/null || true
python3 "${PROJECT_DIR}/Scripts/generate_icons.py" || echo "⚠️  图标生成跳过（可选）"

# 方案 1: 使用 xcodebuild（需要有 Xcode 项目）
if command -v xcodebuild &> /dev/null; then
    echo "🔨 使用 xcodebuild 构建..."

    # 如果有 xcodeproj
    XCODEPROJ=$(find "${PROJECT_DIR}" -name "*.xcodeproj" -maxdepth 2 | head -1)
    if [ -n "${XCODEPROJ}" ]; then
        SCHEME="${APP_NAME}"
        echo "  项目: ${XCODEPROJ}"
        echo "  Scheme: ${SCHEME}"

        xcodebuild \
            -project "${XCODEPROJ}" \
            -scheme "${SCHEME}" \
            -configuration Release \
            -derivedDataPath "${DERIVED_DATA}" \
            -destination 'generic/platform=iOS' \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO \
            CODE_SIGNING_ALLOWED=NO \
            DEVELOPMENT_TEAM="" \
            clean build

        APP_PATH="${DERIVED_DATA}/Build/Products/Release-iphoneos/${APP_NAME}.app"
    else
        echo "❌ 未找到 .xcodeproj 文件"
        echo ""
        echo "📋 手动构建步骤:"
        echo "   1. 在 Mac 上用 Xcode 打开此项目"
        echo "   2. 选择 Product > Archive"
        echo "   3. 在 Organizer 中选择 Distribute App > Development"
        echo "   4. 导出 IPA"
        exit 1
    fi
else
    echo "⚠️  xcodebuild 不可用（需要在 macOS 上运行）"
    echo ""
    echo "📋 请按以下步骤手动构建:"
    echo ""
    echo "方法一（推荐）: 使用 Xcode"
    echo "   1. 将此项目文件夹复制到 Mac"
    echo "   2. 打开终端，cd 到项目目录"
    echo "   3. 运行: xcodegen generate  （如果安装了 XcodeGen）"
    echo "   4. 或者手动创建 Xcode 项目并添加所有 .swift 文件"
    echo "   5. 在 Xcode 中: Product > Archive"
    echo "   6. 导出为 IPA"
    echo ""
    echo "方法二: 使用 GitHub Actions"
    echo "   git push 到 GitHub 仓库即可自动构建"
    echo "   详见 .github/workflows/build.yml"
    exit 0
fi

# 打包 IPA
if [ -d "${APP_PATH}" ]; then
    echo "📦 打包 IPA..."

    PAYLOAD_DIR="${BUILD_DIR}/Payload"
    mkdir -p "${PAYLOAD_DIR}"
    cp -R "${APP_PATH}" "${PAYLOAD_DIR}/"

    IPA_PATH="${BUILD_DIR}/${IPA_NAME}.ipa"
    cd "${BUILD_DIR}"
    zip -rq "${IPA_NAME}.ipa" Payload
    cd "${PROJECT_DIR}"

    echo ""
    echo "✅ IPA 构建成功！"
    echo "   📱 ${IPA_PATH}"
    echo ""
    echo "📲 安装方法:"
    echo "   1. 将 IPA 文件传输到 iPhone"
    echo "   2. 在巨魔(TrollStore)中打开此 IPA"
    echo "   3. 点击 Install"
    echo ""
    ls -lh "${IPA_PATH}"
else
    echo "❌ 构建失败：找不到 .app 文件"
    exit 1
fi
