# Moto G5S Plus (sanders) — Alpine rootfs

Standalone Alpine Linux rootfs for Sanders. Requires newest successful mainline kernel checkpoint from this repository, with no Run ID or kernel rebuild.

No Channel WCNSS firmware, NetworkManager, wireless packages, Wi-Fi fixes or Android modem/vendor mounts. USB RNDIS and direct-USB SSH retained for bring-up, not yet verified on Sanders hardware.

Start Build alpine rootfs on main or select branch alpine. Outputs: alpine-sanders-rootfs.ext4.zst, boot.img and rootfs.ext4.
