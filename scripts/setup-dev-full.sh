#!/bin/bash
# MPF 组件开发者环境设置
# 
# 用于 SDK/库开发者：从源码构建所有组件
#
# 用法:
#   ./setup-dev-full.sh                    # 克隆并构建所有组件
#   ./setup-dev-full.sh --only-clone       # 只克隆不构建
#   ./setup-dev-full.sh --rebuild sdk      # 重新构建指定组件
#
set -e

WORKSPACE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC_DIR="$WORKSPACE_ROOT/src"
BUILD_DIR="$WORKSPACE_ROOT/build"
INSTALL_DIR="$WORKSPACE_ROOT/local"

REPOS=(
    "mpf-sdk"
    "mpf-http-client"
    "mpf-ui-components"
    "mpf-host"
    "mpf-plugin-orders"
    "mpf-plugin-rules"
)

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[MPF]${NC} $1"; }
warn() { echo -e "${YELLOW}[MPF]${NC} $1"; }

# ============================================================
# 克隆所有仓库
# ============================================================
clone_repos() {
    log "克隆所有仓库..."
    mkdir -p "$SRC_DIR"
    
    for repo in "${REPOS[@]}"; do
        if [ -d "$SRC_DIR/$repo" ]; then
            warn "$repo 已存在，跳过克隆"
        else
            log "克隆 $repo..."
            git clone "https://github.com/dyzdyz010/$repo.git" "$SRC_DIR/$repo"
        fi
    done
}

# ============================================================
# 构建单个组件
# ============================================================
build_component() {
    local name=$1
    local src="$SRC_DIR/$name"
    local build="$BUILD_DIR/$name"
    
    log "构建 $name..."
    
    mkdir -p "$build"
    cd "$build"
    
    # 构建 CMAKE_PREFIX_PATH (依赖已安装的组件)
    local prefix_path="$INSTALL_DIR"
    
    cmake "$src" \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_PREFIX_PATH="$prefix_path" \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR"
    
    cmake --build .
    cmake --install .
    
    log "$name 构建完成"
}

# ============================================================
# 按依赖顺序构建所有组件
# ============================================================
build_all() {
    log "按依赖顺序构建所有组件..."
    
    # 安装 ninja (如果没有)
    if ! command -v ninja &> /dev/null; then
        warn "安装 ninja..."
        sudo apt-get update && sudo apt-get install -y ninja-build
    fi
    
    mkdir -p "$INSTALL_DIR"
    
    # 构建顺序很重要！
    # 1. SDK (无依赖)
    build_component "mpf-sdk"
    
    # 2. 库 (依赖 SDK)
    build_component "mpf-http-client"
    build_component "mpf-ui-components"
    
    # 3. Host (依赖 SDK + 库)
    build_component "mpf-host"
    
    # 4. 插件 (依赖 SDK + 库)
    build_component "mpf-plugin-orders"
    build_component "mpf-plugin-rules"
}

# ============================================================
# 创建开发配置
# ============================================================
create_config() {
    mkdir -p "$WORKSPACE_ROOT/config"
    
    cat > "$WORKSPACE_ROOT/config/paths.json" << EOF
{
  "pluginPaths": ["$INSTALL_DIR/lib/mpf/plugins", "$WORKSPACE_ROOT/plugins"]
}
EOF

    # 创建运行脚本
    cat > "$WORKSPACE_ROOT/run-local.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export LD_LIBRARY_PATH="$SCRIPT_DIR/local/lib:$LD_LIBRARY_PATH"
export QML2_IMPORT_PATH="$SCRIPT_DIR/local/qml:$QML2_IMPORT_PATH"
exec "$SCRIPT_DIR/local/bin/mpf-host" "$@"
EOF
    chmod +x "$WORKSPACE_ROOT/run-local.sh"
    
    log "配置文件已创建"
}

# ============================================================
# 主函数
# ============================================================
main() {
    local only_clone=false
    local rebuild_target=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --only-clone)
                only_clone=true
                shift
                ;;
            --rebuild)
                rebuild_target="$2"
                shift 2
                ;;
            *)
                echo "未知参数: $1"
                exit 1
                ;;
        esac
    done
    
    echo "============================================"
    echo "  MPF 组件开发环境设置"
    echo "============================================"
    echo ""
    echo "源码目录: $SRC_DIR"
    echo "构建目录: $BUILD_DIR"
    echo "安装目录: $INSTALL_DIR"
    echo ""
    
    if [ -n "$rebuild_target" ]; then
        # 重新构建指定组件
        build_component "$rebuild_target"
    elif $only_clone; then
        # 只克隆
        clone_repos
    else
        # 完整设置
        clone_repos
        build_all
        create_config
    fi
    
    echo ""
    echo "============================================"
    echo "  设置完成!"
    echo "============================================"
    echo ""
    echo "目录结构:"
    echo "  src/        - 各组件源码"
    echo "  build/      - 构建目录"
    echo "  local/      - 本地安装 (bin, lib, include)"
    echo ""
    echo "开发组件:"
    echo "  1. 修改源码: src/mpf-sdk/..."
    echo "  2. 重新构建: ./scripts/setup-dev-full.sh --rebuild mpf-sdk"
    echo "  3. 测试: ./run-local.sh"
    echo ""
    echo "单独构建某个组件:"
    echo "  cd build/mpf-sdk && cmake --build . && cmake --install ."
    echo ""
}

main "$@"
