# Moto G5S Plus (sanders) — Alpine rootfs

Standalone Alpine Linux rootfs for Sanders. Requires newest successful mainline kernel checkpoint from this repository, with no Run ID or kernel rebuild.

Standard Alpine userspace is preserved: NetworkManager, WPA supplicant, `iw`, wireless regulatory data, eudev/OpenRC, USB RNDIS, DHCP and direct-USB SSH. Only Channel-specific WCNSS firmware, firmware injection, hardware Wi-Fi fixes and Android modem/vendor mounts are omitted. USB and wireless behavior still require real Sanders hardware verification.

Start Build alpine rootfs on main or select branch alpine. Outputs: alpine-sanders-rootfs.ext4.zst, boot.img and rootfs.ext4.
