# Vanxak HD-RK3506B-CORE custom device tree

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://hd-rk3506b-core.dts;subdir=git/arch/arm/boot/dts/rockchip \
    file://hd-rk3506b-core.dtsi;subdir=git/arch/arm/boot/dts/rockchip \
"

do_configure:append() {
    makefile="${S}/arch/${ARCH}/boot/dts/rockchip/Makefile"
    [ -f "${makefile}" ] || return 0

    # Remove malformed dtb line from older bbappend (missing tab and trailing \)
    sed -i '/^[[:space:]]*hd-rk3506b-core\.dtb[[:space:]]*$/d' "${makefile}"
    sed -i '/^hd-rk3506b-core\.dtb/d' "${makefile}"

    grep -q $'\thd-rk3506b-core.dtb \\' "${makefile}" && return 0

    awk '
        /^[[:space:]]*rk3506b-evb1-v10\.dtb \\$/ && !done {
            print "\thd-rk3506b-core.dtb \\"
            done=1
        }
        { print }
    ' "${makefile}" > "${makefile}.tmp" && mv "${makefile}.tmp" "${makefile}"
}
