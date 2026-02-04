#!/bin/bash
# MPF 开发环境设置脚本
#
# 用法:
#   ./setup-dev.sh              # 分别下载各组件 (默认)
#   ./setup-dev.sh --bundle     # 下载完整包 (从 mpf-release)
#   ./setup-dev.sh --platform windows  # 指定平台
#
set -e

WORKSPACE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEPS_DIR="$WORKSPACE_ROOT/deps"
PLATFORM="linux"
MODE="components"  # components 或 bundle

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --bundle)
            MODE="bundle"
            shift
            ;;
        --platform)
            PLATFORM="$2"
            shift 2
            ;;
        windows|linux)
            PLATFORM="$1"
            shift
            ;;
        *)
            echo "未知参数: $1"
            exit 1
            ;;
    esac
done

echo "=== MPF 开发环境设置 ==="
echo "平台: $PLATFORM"
echo "模式: $MODE"
echo "工作区: $WORKSPACE_ROOT"

mkdir -p "$DEPS_DIR"

# ============================================================
# 模式 1: 下载完整包 (mpf-release)
# ============================================================
download_bundle() {
    echo ""
    echo "从 mpf-release 下载完整开发包..."
    
    local ext="tar.gz"
    [[ "$PLATFORM" == "windows" ]] && ext="zip"
    
    cd "$DEPS_DIR"
    
    # 下载最新 release
    gh release download --repo dyzdyz010/mpf-release -p "mpf-${PLATFORM}-x64.${ext}" --clobber || {
        echo "警告: mpf-release 暂无可用版本，回退到分组件下载"
        download_components
        return
    }
    
    # 解压
    if [[ "$ext" == "zip" ]]; then
        7z x -y "mpf-${PLATFORM}-x64.zip"
        rm -f "mpf-${PLATFORM}-x64.zip"
    else
        tar -xzf "mpf-${PLATFORM}-x64.tar.gz"
        rm -f "mpf-${PLATFORM}-x64.tar.gz"
    fi
    
    # 整理目录结构
    mkdir -p mpf-sdk mpf-http-client mpf-ui-components mpf-host
    
    # 完整包的结构已经包含所有内容
    echo "完整包下载完成"
}

# ============================================================
# 模式 2: 分别下载各组件
# ============================================================
download_component() {
    local repo=$1
    local version=${2:-latest}
    local target_dir="$DEPS_DIR/$repo"
    
    echo ""
    echo "下载 $repo ($version)..."
    mkdir -p "$target_dir"
    cd "$target_dir"
    
    local ext="tar.gz"
    [[ "$PLATFORM" == "windows" ]] && ext="zip"
    
    if [[ "$version" == "latest" ]]; then
        gh release download --repo "dyzdyz010/$repo" -p "*${PLATFORM}*" --clobber
    else
        gh release download "$version" --repo "dyzdyz010/$repo" -p "*${PLATFORM}*" --clobber
    fi
    
    # 解压
    if [[ "$ext" == "zip" ]]; then
        7z x -y *.zip
        rm -f *.zip
    else
        tar -xzf *.tar.gz
        rm -f *.tar.gz
    fi
}

download_components() {
    download_component mpf-sdk v1.0.0
    download_component mpf-http-client v1.0.0
    download_component mpf-ui-components v1.0.0
    download_component mpf-host  # 用 latest，因为可能还没打 tag
}

# ============================================================
# 执行下载
# ============================================================
if [[ "$MODE" == "bundle" ]]; then
    download_bundle
else
    download_components
fi

# ============================================================
# 创建配置文件
# ============================================================
mkdir -p "$WORKSPACE_ROOT/config"
mkdir -p "$WORKSPACE_ROOT/plugins"

cat > "$WORKSPACE_ROOT/config/paths.json" << EOF
{
  "pluginPaths": ["$WORKSPACE_ROOT/plugins"]
}
EOF

# ============================================================
# 创建 CMake 工具链文件 (方便 IDE 使用)
# ============================================================
cat > "$WORKSPACE_ROOT/mpf-dev.cmake" << EOF
# MPF 开发环境 CMake 配置
# 用法: cmake -B build -DCMAKE_TOOLCHAIN_FILE=../mpf-dev.cmake

set(MPF_WORKSPACE "$WORKSPACE_ROOT")
set(MPF_DEPS "\${MPF_WORKSPACE}/deps")

# 设置 CMAKE_PREFIX_PATH
list(APPEND CMAKE_PREFIX_PATH
    "\${MPF_DEPS}/mpf-sdk"
    "\${MPF_DEPS}/mpf-http-client"
    "\${MPF_DEPS}/mpf-ui-components"
)

# 默认安装到 plugins 目录
if(NOT DEFINED CMAKE_INSTALL_PREFIX OR CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "\${MPF_WORKSPACE}/plugins/\${PROJECT_NAME}" CACHE PATH "Install path" FORCE)
endif()

message(STATUS "MPF SDK: \${MPF_DEPS}/mpf-sdk")
message(STATUS "MPF Install: \${CMAKE_INSTALL_PREFIX}")
EOF

# ============================================================
# 完成提示
# ============================================================
echo ""
echo "============================================"
echo "  MPF 开发环境设置完成!"
echo "============================================"
echo ""
echo "目录结构:"
echo "  deps/mpf-sdk/          - SDK (接口定义)"
echo "  deps/mpf-http-client/  - HTTP 客户端库"
echo "  deps/mpf-ui-components/- UI 组件库"
echo "  deps/mpf-host/         - 宿主程序"
echo "  plugins/               - 你的插件输出目录"
echo "  config/paths.json      - 运行时配置"
echo ""
echo "开发插件:"
echo "  cd your-plugin"
echo "  cmake -B build -DCMAKE_TOOLCHAIN_FILE=$WORKSPACE_ROOT/mpf-dev.cmake"
echo "  cmake --build build"
echo "  cmake --install build"
echo ""
echo "运行测试:"
echo "  $WORKSPACE_ROOT/scripts/run-host.sh"
echo ""
