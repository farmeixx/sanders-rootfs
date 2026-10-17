# Motorola Moto G5S Plus (sanders) — unified rootfs builders

The `rootfs` branch contains the three independent root filesystems for Sanders:
`alpine/`, `debian/` and `ubuntu/`. They share the same kernel-checkpoint
fetch/validation scripts; no kernel compilation is done here.

## Layout

```text
alpine/                     # Alpine build.sh, run.sh and Alpine-specific overlays
debian/                     # Debian build.sh, run.sh and Debian-specific overlays
ubuntu/                     # Ubuntu build.sh, run.sh and Ubuntu-specific overlays
scripts/ci/build-rootfs.sh  # Select alpine, debian or ubuntu
scripts/ci/fetch-kernel.sh  # Fetch last valid kernel checkpoint from main
scripts/rootfs/run.sh       # Common validation, assembly and artifact handling
scripts/host-deps.sh        # Host dependencies
scripts/kernel/validate.sh  # Checkpoint integrity
```

## GitHub Actions

Run the **Build alpine rootfs**, **Build debian rootfs** or **Build ubuntu rootfs**
workflow from the `main` branch. Each workflow checks out `rootfs` and executes:

```sh
bash scripts/ci/build-rootfs.sh alpine   # or debian / ubuntu
```

The script reuses the newest successful, unexpired `mainline.yml` kernel
checkpoint **from this same repository's `main` branch**. There is no
kernel dispatch, no kernel rebuild and no manual Run ID. If no valid checkpoint
exists, the build fails with an explanation.

Outputs remain separate in `out/rootfs/alpine/`, `out/rootfs/debian/` and
`out/rootfs/ubuntu/`, with their respective `*.ext4.zst`, `boot.img`
and `rootfs.ext4` artifacts.

## Local builds

On an Ubuntu/Debian x86_64 host, place a valid Sanders kernel checkpoint
under `out/kernel/checkpoint/`, then run one of:

```sh
bash alpine/run.sh
bash debian/run.sh
bash ubuntu/run.sh
```

## Firmware and hardware safety

The Sanders builder **does not bundle proprietary firmware**. At build time,
`scripts/firmware/sanders.sh` fetches the stock Oreo 8.1 firmware from the
[Sanders-specific GitLab repository](https://gitlab.com/vanadium-oss/motorola-msm8953/mainline/sanders-firmware).
By default it stages only the WCNSS segments and the default Wi-Fi NV under
`/lib/firmware`, with no automatic Wi-Fi driver or service activation. No
Channel firmware is imported. Use `SANDERS_FIRMWARE_MODE=off` to skip firmware
entirely, or `SANDERS_FIRMWARE_REF` to pin a specific GitLab revision.
A `SHA256SUMS` manifest at the GitLab repository root is verified when available.
This is not a guarantee that Sanders Wi-Fi boots or works; hardware testing
and kernel driver support are still required.

The Sanders-specific kernel Kconfig fragments, DTB, boot command line and
kernel build with ccache live on `main` and are not changed by the rootfs
unification. Headless USB gadget / SSH still requires hardware verification.

The former `alpine`, `debian` and `ubuntu` branches were consolidated and
are no longer needed. Use this `rootfs` branch for future distro changes.
