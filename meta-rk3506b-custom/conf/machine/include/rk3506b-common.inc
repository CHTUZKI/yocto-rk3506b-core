# Common configuration for HD-RK3506B-CORE (self-contained, no meta-rockchip)

require conf/machine/include/arm/armv7a/tune-cortexa7.inc

TARGET_ARCH = "arm"
MACHINEOVERRIDES .= ":rockchip"

# Bootloader / kernel providers
PREFERRED_PROVIDER_virtual/bootloader = "u-boot-rockchip"
PREFERRED_PROVIDER_virtual/kernel = "linux-rockchip"
PREFERRED_VERSION_linux-rockchip ?= "6.6%"

# Rockchip SoC
RK_SOC_FAMILY = "rk3506"
RK_UBOOT_SPL = "1"
KBUILD_DEFCONFIG = "rk3506_defconfig"

# Rockchip fiq-debugger (ttyFIQ0) 默认 1500000；PC 串口工具须设相同波特率
SERIAL_CONSOLES = "1500000;ttyFIQ0"

# Kernel
KERNEL_IMAGETYPE = "zImage"
ROCKCHIP_KERNEL_IMAGES = "1"
ROCKCHIP_KERNEL_COMPRESSED = "1"
LINUXLIBCVERSION = "6.6-custom%"
OLDEST_KERNEL = "${@d.getVar('LINUXLIBCVERSION').split('-')[0]}"

# Boot device / image layout
BOOT_DEVICE = "mmc"
UBOOT_SUFFIX = "img"
UBOOT_BINARY = "uboot.img"

WKS_FILE = "rk3506-gptdisk.wks.in"
RK_ROOTFS_TYPE = "ext4"
RK_ROOTFS_EXTRAOPTS = "-F -i 8192 -b 4096"
RK_ROOTDEV_UUID = "614e0000-0000-4b53-8000-1d28000054a9"
RK_PARTITION_GROW = "1"

MACHINE_EXTRA_RRECOMMENDS += "kernel-modules"

# Bypass patch QA noise from vendor trees
ERROR_QA:remove = "patch-status patch-fuzz"
WARN_QA:remove = "patch-fuzz"
