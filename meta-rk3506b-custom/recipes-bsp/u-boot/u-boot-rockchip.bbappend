# HD-RK3506B-CORE U-Boot configuration

do_configure:append() {
    if [ ! -f "${S}/configs/${UBOOT_MACHINE}" ]; then
        return
    fi

    cfg="${S}/configs/${UBOOT_MACHINE}"

    if grep -q "^CONFIG_BAUDRATE=" "${cfg}"; then
        sed -i 's/^CONFIG_BAUDRATE=.*/CONFIG_BAUDRATE=115200/' "${cfg}"
    else
        echo "CONFIG_BAUDRATE=115200" >> "${cfg}"
    fi
}
