# MPF 开发工作区

本仓库用于协调 MPF (Modular Plugin Framework) 多仓库开发。

## 快速开始

### 1. 设置开发环境

```bash
# 克隆工作区
git clone https://github.com/dyzdyz010/mpf-workspace.git
cd mpf-workspace

# 下载所有依赖 (需要 GitHub CLI)
./scripts/setup-dev.sh          # Linux
./scripts/setup-dev.sh windows  # Windows
```

### 2. 开发你的插件

```bash
# 克隆你的插件仓库 (以 orders 为例)
git clone https://github.com/dyzdyz010/mpf-plugin-orders.git
cd mpf-plugin-orders

# 配置并构建
cmake -B build \
  -DCMAKE_PREFIX_PATH="$PWD/../deps/mpf-sdk;$PWD/../deps/mpf-http-client;$PWD/../deps/mpf-ui-components" \
  -DCMAKE_INSTALL_PREFIX="$PWD/../plugins/orders"

cmake --build build
cmake --install build
```

### 3. 测试插件

```bash
# 回到工作区
cd ..

# 运行 Host
./scripts/run-host.sh

# 或者直接指定配置
./deps/mpf-host/bin/mpf-host --config ./config/paths.json
```

## 目录结构

```
mpf-workspace/
├── scripts/
│   ├── setup-dev.sh     # 下载依赖脚本
│   └── run-host.sh      # 运行 Host 脚本
├── deps/                # 下载的预构建组件
│   ├── mpf-sdk/
│   ├── mpf-http-client/
│   ├── mpf-ui-components/
│   └── mpf-host/
├── plugins/             # 本地构建的插件
│   ├── orders/
│   └── rules/
└── config/
    └── paths.json       # 插件路径配置
```

## 各组件仓库

| 仓库 | 说明 | 依赖 |
|------|------|------|
| [mpf-sdk](https://github.com/dyzdyz010/mpf-sdk) | 核心接口定义 | - |
| [mpf-http-client](https://github.com/dyzdyz010/mpf-http-client) | HTTP 客户端库 | SDK |
| [mpf-ui-components](https://github.com/dyzdyz010/mpf-ui-components) | UI 组件库 | SDK |
| [mpf-host](https://github.com/dyzdyz010/mpf-host) | 宿主应用 | SDK, HTTP, UI |
| [mpf-plugin-orders](https://github.com/dyzdyz010/mpf-plugin-orders) | 订单插件示例 | SDK, HTTP, UI |
| [mpf-plugin-rules](https://github.com/dyzdyz010/mpf-plugin-rules) | 规则插件示例 | SDK |

## 环境变量

| 变量 | 说明 |
|------|------|
| `MPF_SDK` | SDK 安装路径 |
| `MPF_CONFIG_PATH` | 配置文件目录 |
| `QT_QPA_PLATFORM` | Qt 平台插件 (Linux: xcb, 无头: offscreen) |

## 常见问题

### Q: 插件加载失败
检查 `paths.json` 中的路径是否正确，确保插件 .so/.dll 文件存在。

### Q: 找不到 Qt 库
确保 Qt 6.8+ 已安装，`QT_ROOT_DIR` 环境变量正确设置。

### Q: 如何调试插件
1. 使用 Qt Creator 打开插件项目
2. 设置可执行文件为 `deps/mpf-host/bin/mpf-host`
3. 设置工作目录为 workspace 根目录
