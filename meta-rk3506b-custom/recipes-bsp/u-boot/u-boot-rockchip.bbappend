# HD-RK3506B-CORE U-Boot configuration

do_configure:append() {
    # 512MB DDR3L (B 款) 必须用 rk3506b_ddr，不能用默认 rk3506(LPDDR) 的 MINIALL
    if [ -f "${S}/configs/rk3506b.config" ] && [ -f "${B}/.config" ]; then
        merge_config.sh -m -O ${B} ${B}/.config ${S}/configs/rk3506b.config
    fi
}
