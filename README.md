# RK3506B CORE Yocto 项目

基于 Yocto Project 的 **Vanxak HD-RK3506B-CORE** 核心板嵌入式 Linux 构建环境。

与同系列的 [yocto-rk3506-evm](https://github.com/CHTUZKI/yocto-rk3506-evm) 相比，本项目面向 **RK3506B 核心板模组**（512MB DDR3L + 8GB eMMC），采用 **自包含 BSP**，不依赖 `meta-rockchip`，并通过子模块 `meta-rockchip-updateimg` 生成 RKDevTool 可用的 `update.img`。

## 硬件参数

**HD-RK3506B-CORE（HD-RK3506B-512F8GLW）**

| 项目 | 参数 |
|------|------|
| 处理器 | Rockchip RK3506B（3× Cortex-A7） |
| 主频 | 1.5GHz |
| 内存 | 512MB DDR3L |
| 存储 | 8GB eMMC（板载，非 SD 卡） |
| 调试串口 | UART0 / ttyFIQ0 @ **1500000** |
| 烧录口 | USB2.0 OTG0（Maskrom / Loader） |
| 设备树 | `rockchip/hd-rk3506b-core.dtb` |

核心板仅保留模组必要外设（eMMC、串口、USB OTG 等）；以太网、LCD、音频等载板外设已在设备树中关闭。

## 项目结构

```
yocto-rk3506b-core/
├── poky/                      # Yocto 官方发行版核心层 (kirkstone)
├── meta-openembedded/         # OpenEmbedded 元层 (kirkstone)
├── meta-rk3506b-custom/       # HD-RK3506B-CORE 自包含 BSP 层
├── meta-rockchip-updateimg/   # update.img 打包层（git 子模块）
└── build/                     # BitBake 构建目录
```

### 层说明

| 层 | 职责 |
|----|------|
| **meta-rk3506b-custom** | 完整 BSP：U-Boot SPL + FIT、linux-rockchip 6.6（Rockchip 官方内核）、机器配置、WIC 分区、核心板设备树 |
| **meta-rockchip-updateimg** | `afptool` + `rkImageMaker` → 生成 `update.img` |
| **poky + meta-oe** | Yocto 基础系统 |

> **不使用 meta-rockchip**：该层对 RK3506 的支持不完整；本仓库已将所需 U-Boot / 内核 recipe 内置于 `meta-rk3506b-custom`。

更多信息请查看 [meta-rockchip-updateimg/README.md](meta-rockchip-updateimg/README.md)。

## 启动链

RK3506 使用 U-Boot SPL + FIT，`trust` 已打包进 `uboot.img`：

```
idblock → uboot.img (含 trust) → boot.img → rootfs (ext4)
```

烧录工具使用 `update.img`（由 meta-rockchip-updateimg 生成）。芯片标识为 **350F**（RKDevTool 界面可能显示 RK350F），不是 `RK35`。

## 设备树

| 文件 | 说明 |
|------|------|
| `meta-rk3506b-custom/recipes-kernel/linux/files/hd-rk3506b-core.dts` | 顶层设备树 |
| `meta-rk3506b-custom/recipes-kernel/linux/files/hd-rk3506b-core.dtsi` | 核心板外设配置 |
| `meta-rk3506b-custom/conf/machine/hd-rk3506b-core.conf` | 机器配置 |

启动成功后串口应显示：`Machine model: Vanxak HD-RK3506B-CORE`

## 已知问题

- ⚠️ **镜像体积**：`update.img` 约 2.1 GB，因 rootfs 分区固定预分配 2 GiB（RKDevTool 整包烧录需固定扇区，不能使用 `:grow`）。实际 rootfs 内容约 40 MB，分区剩余空间会随使用被占满。
- ⚠️ **U-Boot 型号显示**：U-Boot 阶段仍可能显示 `Rockchip RK3506 EVB Board`，内核阶段已正确识别为核心板型号。
- ⚠️ **fiq-debugger 告警**：启动日志可能出现 `IRQ fiq not found`，不影响 `ttyFIQ0` 串口正常使用。
- ⚠️ **RTC**：模组无硬件 RTC，系统时间需通过 NTP 或手动设置。

## 串口配置

使用串口调试工具连接设备时，波特率须设为 **1500000**（Rockchip fiq-debugger 默认，非 115200）：

```bash
# screen
screen /dev/ttyUSB0 1500000

# minicom
minicom -D /dev/ttyUSB0 -b 1500000
```

## 快速开始

### 构建准备

```bash
sudo apt-get update
sudo apt-get install build-essential chrpath cpio debianutils diffstat file gawk gcc git \
  iputils-ping libacl1 lz4 locales python3 python3-jinja2 python3-pexpect python3-pip \
  python3-subunit socat texinfo unzip wget xz-utils zstd
```

### 克隆与子模块

```bash
git clone --recursive https://github.com/CHTUZKI/yocto-rk3506b-core.git
cd yocto-rk3506b-core
git submodule update --init --recursive
```

### 初始化构建环境

```bash
cd yocto-rk3506b-core
source poky/oe-init-build-env build
```

### 构建镜像

```bash
bitbake rk3506b-image-minimal-emmc
```

构建完成后，产物位于：

```
build/tmp/deploy/images/hd-rk3506b-core/
├── update.img                                          # RKDevTool 烧录（符号链接）
├── rk3506b-image-minimal-emmc-hd-rk3506b-core.update.img
├── boot.img / uboot.img / loader.bin / idblock.img
└── *.rootfs.ext4 / *.wic
```

详细构建、清理、单独重建内核/U-Boot 及 RKDevTool 烧录步骤请参考 [`构建命令.txt`](构建命令.txt)。

### RKDevTool 烧录要点

- 工具：**RKDevTool v3.32** eMMC 版 + DriverAssistant 驱动
- 推荐 **Loader 模式**整包升级（RECOVERY + RESET 进入 Loader）
- 将 `update.img` 复制到 Windows 本地路径（如 `C:\rk\update.img`），避免直接使用 `\\wsl.localhost\...`
- 烧录成功判据：日志 `total` 约 2GB+，且出现 `download rootfs, offset=0x14800, size=2147483648`

## 登录信息

- **用户名**：`root`
- **密码**：无（直接回车即可）

## 致谢

特别感谢：

- [**Yocto Project**](https://www.yoctoproject.org/) 团队和社区，为嵌入式 Linux 开发提供了强大而灵活的构建系统和工具链
- [**Rockchip 官方内核 / U-Boot**](https://github.com/rockchip-linux) 仓库，提供 RK3506 平台基础软件栈
- 同系列项目 [yocto-rk3506-evm](https://github.com/CHTUZKI/yocto-rk3506-evm) 在 RK3506 平台上的探索与实践经验

## License

本项目遵循 MIT 许可证。

## 免责声明

**重要提示：**

本 Yocto 项目为实验性开发环境，主要用于 HD-RK3506B-CORE 平台的功能验证和技术探索。当前状态说明：

- ⚠️ 本项目**仅用于功能测试和开发调试**，未经充分的生产环境验证
- ⚠️ 不保证系统的稳定性、安全性和长期可靠性
- ⚠️ 是否具备实际生产部署能力需要根据具体应用场景进行全面测试和评估
- ⚠️ 使用本项目所产生的任何问题、损失或后果，作者不承担任何责任

**建议：**

- 在生产环境部署前，请进行充分的功能测试、压力测试和稳定性测试
- 根据实际需求完善设备树配置、驱动程序和系统安全设置
- 建议由专业团队评估后再决定是否用于商业产品

**本项目按"原样"提供，不附带任何明示或暗示的保证。使用者需自行承担使用风险。**
