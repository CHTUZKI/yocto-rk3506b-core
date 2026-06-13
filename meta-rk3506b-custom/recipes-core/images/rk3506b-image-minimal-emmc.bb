SUMMARY = "Minimal eMMC image for HD-RK3506B-CORE"
DESCRIPTION = "Minimal Linux eMMC image for Vanxak HD-RK3506B-CORE with update.img output"

inherit core-image
inherit rk3506b-image
inherit rockchip-updateimg

IMAGE_INSTALL = " \
    packagegroup-core-boot \
    kernel-modules \
    kernel-image \
    kernel-devicetree \
    ${CORE_IMAGE_EXTRA_INSTALL} \
"

IMAGE_INSTALL += "u-boot-rockchip"

IMAGE_FEATURES += " \
    debug-tweaks \
    ssh-server-openssh \
"

IMAGE_FSTYPES = "wic wic.bmap ext4"

WKS_FILE = "rk3506-gptdisk.wks.in"

RK_UPDATEIMG_SOC = "RK3506"
RK_UPDATEIMG_PARAMETER_MODE = "gpt"
RK_UPDATEIMG_ROOTDEV = "PARTLABEL=root"
RK_UPDATEIMG_REQUIRED_IMAGES = "loader.bin uboot.img trust.img boot.img rootfs.img"
RK_UPDATEIMG_EXTRA_DEPENDS = "u-boot-rockchip:do_deploy"

do_image[depends] += "u-boot-rockchip:do_deploy"
do_image_complete[depends] += "u-boot-rockchip:do_deploy rk-binary-native:do_populate_sysroot"
