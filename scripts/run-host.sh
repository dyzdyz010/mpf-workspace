#!/bin/bash
# 运行 MPF Host 进行插件测试

WORKSPACE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOST_DIR="$WORKSPACE_ROOT/deps/mpf-host"
CONFIG_DIR="$WORKSPACE_ROOT/config"

# 检查 host 是否存在
if [ ! -f "$HOST_DIR/bin/mpf-host" ] && [ ! -f "$HOST_DIR/mpf-host.exe" ]; then
    echo "错误: Host 未找到，请先运行 setup-dev.sh"
    exit 1
fi

# 设置环境变量
export MPF_CONFIG_PATH="$CONFIG_DIR"
export QT_QPA_PLATFORM=${QT_QPA_PLATFORM:-xcb}  # Linux GUI

# 运行
if [ -f "$HOST_DIR/bin/mpf-host" ]; then
    exec "$HOST_DIR/bin/mpf-host" "$@"
else
    exec "$HOST_DIR/mpf-host.exe" "$@"
fi
