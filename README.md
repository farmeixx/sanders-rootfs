# Moto G5S Plus (sanders) — mainline Linux builder

Sanders mainline Linux builder. The `main` branch compiles the kernel,
maintains the GitHub Actions entry workflows and publishes a reusable,
validated kernel checkpoint. Alpine, Debian and Ubuntu live together in
the [`rootfs` branch](https://github.com/farmeixx/sanders-rootfs/tree/rootfs).

## Branches

- **`main`**: kernel scripts, persistent `ccache` and GitHub Actions YAMLs.
- **`rootfs`**: `alpine/`, `debian/`, `ubuntu/`, and shared rootfs scripts.
- **`help`**: recovery, SSH, resize2fs and usage instructions.
- The former per-distro branches were consolidated into `rootfs`.
- Experimental QCDT/Potter tests are not used by these builders.

## Kernel (main)

Run **Build mainline kernel** on `main` or locally on an x86_64 Linux host:

```sh
bash mainline/run.sh
```

The source is `https://gitlab.com/vanadium-oss/motorola-msm8953/mainline/linux.git`,
branch `msm8953/latest` by default, using ARM64 `defconfig` merged with
`msm8953.config` then `motorola-sanders.config`. This is **not** the Potter
configuration. The DTB is `msm8953-motorola-sanders.dtb`; the Android boot
image keeps the existing `root=PARTLABEL=userdata rootfstype=ext4 rootwait`
configuration and 16 MiB size limit.

The dedicated workflow caches ARM64 GCC objects with `ccache` (up to 2 GiB
and compression enabled). The first build populates the cache and later builds
can reuse compiler objects. The kernel checkpoint preserves `Image.gz`, DTB,
modules, `boot-sanders.img`, SHA256SUMS and build metadata.

## Alpine, Debian and Ubuntu (rootfs)

Select one workflow from the GitHub Actions UI **on branch `main`**:
`alpine.yml`, `debian.yml` or `ubuntu.yml`.

Each YAML checks out the single `rootfs` branch and runs only one shell command:

```sh
bash scripts/ci/build-rootfs.sh alpine   # or debian / ubuntu
```

Rootfs scripts download the **latest successful, unexpired**
`mainline.yml` checkpoint from this repo's `main`. They do **not** request
a run ID, dispatch a kernel build, compile the kernel or reuse Channel
artifacts. If no validated kernel checkpoint is available, rootfs builds fail.

The outputs include `<distro>-sanders-rootfs.ext4.zst`, `boot.img` and
`rootfs.ext4`, with hashes and metadata. Each distribution retains its
original build scripts and independent rootfs overlays.

## Firmware / device safety

Unlike Channel, Sanders does **not** have an integrated, tested WCNSS
firmware package in this builder. The rootfs branch does not carry Channel
firmware blobs, clone the Channel firmware repo or load Channel Wi-Fi drivers.
Standard networking userspace packages are retained as before. Sanders
firmware should be integrated later only from a verified Sanders-specific
source with known hashes and hardware testing.

USB gadget, SSH and kernel boot are still subject to validation on a real
Moto G5S Plus. Changes to `ccache` and branch organization do not solve an
existing hardware boot failure.
