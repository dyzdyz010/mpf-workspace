# MPF 开发工作区

用于 MPF (Modular Plugin Framework) 多仓库开发的统一环境。

## 快速开始

```bash
# 克隆工作区
git clone https://github.com/dyzdyz010/mpf-workspace.git
cd mpf-workspace

# 设置开发环境 (下载 SDK、库、Host)
./scripts/setup-dev.sh              # Linux
./scripts/setup-dev.sh windows      # Windows
./scripts/setup-dev.sh --bundle     # 或从完整包下载
```

## 开发插件

### 方式 1: 使用工具链文件 (推荐)

```bash
cd your-plugin
cmake -B build -DCMAKE_TOOLCHAIN_FILE=../mpf-dev.cmake
cmake --build build
cmake --install build  # 自动安装到 workspace/plugins/your-plugin
```

### 方式 2: 手动指定路径

```bash
cmake -B build \
  -DCMAKE_PREFIX_PATH="../deps/mpf-sdk;../deps/mpf-http-client;../deps/mpf-ui-components" \
  -DCMAKE_INSTALL_PREFIX="../plugins/your-plugin"
```

## 测试插件

```bash
# 运行 Host (自动加载 plugins/ 下的插件)
./scripts/run-host.sh
```

## 下载的内容

| 组件 | 包含内容 | 用途 |
|------|----------|------|
| **mpf-sdk** | 头文件 + CMake 配置 | 编译插件必需 |
| **mpf-http-client** | 头文件 + 库 + CMake 配置 | 需要 HTTP 功能时 |
| **mpf-ui-components** | 头文件 + 库 + QML + CMake 配置 | 需要 UI 组件时 |
| **mpf-host** | 可执行文件 + Qt 插件 | 运行测试 |

## 目录结构

```
mpf-workspace/
├── scripts/
│   ├── setup-dev.sh     # 环境设置脚本
│   └── run-host.sh      # 运行 Host
├── deps/                # 下载的组件
│   ├── mpf-sdk/
│   │   ├── include/     # 头文件
│   │   └── lib/cmake/   # CMake 配置
│   ├── mpf-http-client/
│   ├── mpf-ui-components/
│   └── mpf-host/
│       └── bin/         # 可执行文件
├── plugins/             # 你的插件 (构建输出)
├── config/
│   └── paths.json       # 运行时配置
└── mpf-dev.cmake        # CMake 工具链文件
```

## 仓库列表

| 仓库 | 说明 |
|------|------|
| [mpf-sdk](https://github.com/dyzdyz010/mpf-sdk) | 核心 SDK |
| [mpf-http-client](https://github.com/dyzdyz010/mpf-http-client) | HTTP 客户端 |
| [mpf-ui-components](https://github.com/dyzdyz010/mpf-ui-components) | UI 组件 |
| [mpf-host](https://github.com/dyzdyz010/mpf-host) | 宿主程序 |
| [mpf-plugin-orders](https://github.com/dyzdyz010/mpf-plugin-orders) | 示例: 订单插件 |
| [mpf-plugin-rules](https://github.com/dyzdyz010/mpf-plugin-rules) | 示例: 规则插件 |
| [mpf-release](https://github.com/dyzdyz010/mpf-release) | 完整发布包 |

## Qt Creator 调试

1. File → Open Project → 选择你的插件 CMakeLists.txt
2. Projects → Run → Executable: `workspace/deps/mpf-host/bin/mpf-host`
3. Projects → Run → Working directory: `workspace/`
4. F5 开始调试

## CI/CD

各组件仓库的 CI 会自动:
1. 构建 Linux + Windows
2. 发布到 GitHub Releases
3. (可选) 触发下游仓库构建

依赖链: SDK → http-client/ui-components → host → plugins → release
