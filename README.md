# yocto-rk3506b-core

Vanxak **HD-RK3506B-CORE** 核心板 Yocto 构建系统，架构与 [yocto-rk3399](/home/xuning/yocto-rk3399) 一致：

- **meta-rk3506b-custom**：自包含 BSP（U-Boot、内核、机器配置、WIC）
- **meta-rockchip-updateimg**：仅负责 `update.img` 打包
- **不使用 meta-rockchip**（该层 RK3506 支持不可用）

## 目标硬件

| 项目 | 规格 |
|------|------|
| 芯片 | Rockchip RK3506B |
| CPU | 3× Cortex-A7 @ 1.5GHz（armv7a） |
| 内存 | DDR3L 512MB |
| 存储 | eMMC 8GB |
| 调试串口 | UART0 / ttyFIQ0 @ 115200 |
| 烧录口 | USB2.0 OTG0 |

## 目录结构

```
yocto-rk3506b-core/
├── poky/
├── meta-openembedded/
├── meta-rk3506b-custom/       # 完整 BSP（自研，不依赖 meta-rockchip）
├── meta-rockchip-updateimg/   # update.img 打包
└── build/conf/
```

## 首次准备

```bash
cd /home/xuning/yocto-rk3506b-core
git submodule update --init --recursive
```

## 构建

详见 `构建命令.txt`，核心步骤：

```bash
unset BB_ENV_EXTRAWHITE
cd /home/xuning/yocto-rk3506b-core
source poky/oe-init-build-env build
bitbake rk3506b-image-minimal-emmc
```

## 输出

```
build/tmp/deploy/images/hd-rk3506b-core/
├── rk3506b-image-minimal-emmc-hd-rk3506b-core.update.img
├── update.img
└── *.wic / *.ext4
```

## 层职责

| 层 | 职责 |
|----|------|
| meta-rk3506b-custom | U-Boot SPL、linux-rockchip 6.6（Rockchip 官方内核）、机器配置、WIC 分区 |
| meta-rockchip-updateimg | afptool + rkImageMaker → update.img |
| poky + meta-oe | Yocto 基础 |

## 启动链

RK3506 使用 U-Boot SPL + FIT，`trust` 已打包进 `uboot.img`：

```
idblock → uboot.img (含 trust) → boot.img → rootfs (ext4)
```

烧录工具使用 `update.img`（由 meta-rockchip-updateimg 生成）。

## 机器配置

`meta-rk3506b-custom/conf/machine/hd-rk3506b-core.conf`

当前设备树：`rk3506g-evb1-v10.dtb`（后续可替换为 HD-RK3506-IOT vendor DTS）

## 参考

- 硬件手册：`硬件相关/【数据手册】HD-RK3506b-CORE V1.0/`
- 构建命令：`构建命令.txt`
