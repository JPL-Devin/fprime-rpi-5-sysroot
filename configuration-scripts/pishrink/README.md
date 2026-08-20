# PiShrink (vendored)

Vendored copy of [PiShrink](https://github.com/Drewsif/PiShrink) by Drew Bonasera,
MIT licensed (see `LICENSE`). Vendored at upstream commit
`5f358d03eed4b7334657ee93867826a2b42f112a` (v26.03.16), unmodified.

Used by `../shrink-sd-image.sh` to re-arm first-boot filesystem auto-expansion
and truncate/compress shrunk SD card images.

Security audit notes (at vendoring time):
- Sole network access is an optional version check against the GitHub API;
  disabled by passing `-n` (as `shrink-sd-image.sh` does).
- No remote code execution, no data exfiltration; operates only on the local
  image file via loop devices with standard tools (parted, e2fsck, resize2fs).
- Writes an `/etc/rc.local` into the image to trigger `raspi-config
  --expand-rootfs` on first boot, backing up and restoring any existing
  rc.local.
