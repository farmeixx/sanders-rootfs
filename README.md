# Moto G5S Plus (sanders) — mainline kernel

Standalone Sanders adaptation of the existing Channel builder. The Channel repository is unchanged.

## Layout

- `main`: mainline kernel scripts and GitHub Actions entry workflows.
- `alpine`, `debian`, `ubuntu`: independent headless rootfs builders.
- `help`: USB SSH, image and ext4 usage.

## Build

First run **Build mainline kernel** on `main`. The existing MSM8953 source must contain `arch/arm64/configs/sanders_defconfig` from the Sanders builder and `arch/arm64/boot/dts/qcom/msm8953-motorola-sanders.dts`. There is no fallback to a generic or other-device config. If missing, the build fails before compilation.

Its validated checkpoint contains `Image.gz`, Sanders DTB, modules, `boot-sanders.img`, SHA256SUMS and revision metadata. Boot image has the Sanders **16 MiB limit**.

Run Alpine, Debian or Ubuntu workflows on `main` to check out their own branches and reuse the latest successful, unexpired kernel checkpoint. No Run ID input, no kernel dispatch from rootfs and no cross-repository artifacts.

Each distro uploads `*-sanders-rootfs.ext4.zst`, `boot.img`, and `rootfs.ext4`.

## No Wi-Fi integration

Channel WCNSS blobs, WCN36xx-specific config checks, firmware installer, NetworkManager Wi-Fi setup and modem/vendor mounts are intentionally excluded. Sanders Wi-Fi is not configured or claimed working.

USB RNDIS/SSH scripts are adapted from Channel but require real Sanders hardware verification. The default USB address is `172.16.42.1`; inherited root SSH access over trusted USB is permissive and should not be exposed elsewhere.
