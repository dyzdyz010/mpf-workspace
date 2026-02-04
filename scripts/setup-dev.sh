#!/bin/bash
# MPF 开发环境设置脚本
set -e

WORKSPACE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEPS_DIR="$WORKSPACE_ROOT/deps"
PLATFORM=${1:-linux}  # linux or windows

echo "=== MPF 开发环境设置 ==="
echo "平台: $PLATFORM"
echo "工作区: $WORKSPACE_ROOT"

mkdir -p "$DEPS_DIR"

# 下载依赖组件
download_component() {
    local repo=$1
    local version=${2:-v1.0.0}
    local target_dir="$DEPS_DIR/$repo"
    
    echo "下载 $repo $version..."
    mkdir -p "$target_dir"
    cd "$target_dir"
    
    if [ "$PLATFORM" = "windows" ]; then
        gh release download "$version" -R "dyzdyz010/$repo" -p "*windows*" --clobber
        7z x -y *.zip
        rm -f *.zip
    else
        gh release download "$version" -R "dyzdyz010/$repo" -p "*linux*" --clobber
        tar -xzf *.tar.gz
        rm -f *.tar.gz
    fi
}

# 下载核心组件
download_component mpf-sdk
download_component mpf-http-client
download_component mpf-ui-components
download_component mpf-host

# 创建配置
mkdir -p "$WORKSPACE_ROOT/config"
mkdir -p "$WORKSPACE_ROOT/plugins"

cat > "$WORKSPACE_ROOT/config/paths.json" << EOF
{
  "pluginPaths": ["$WORKSPACE_ROOT/plugins"]
}
EOF

echo ""
echo "=== 设置完成 ==="
echo ""
echo "SDK 路径:  $DEPS_DIR/mpf-sdk"
echo "Host 路径: $DEPS_DIR/mpf-host"
echo ""
echo "构建插件时使用:"
echo "  cmake -B build \\"
echo "    -DCMAKE_PREFIX_PATH=\"$DEPS_DIR/mpf-sdk;$DEPS_DIR/mpf-http-client;$DEPS_DIR/mpf-ui-components\" \\"
echo "    -DCMAKE_INSTALL_PREFIX=\"$WORKSPACE_ROOT/plugins/your-plugin\""
echo ""
echo "运行 Host:"
echo "  $WORKSPACE_ROOT/scripts/run-host.sh"
