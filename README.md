# aarch64-none-linux sysroot (glibc 2.31)

Extracted from Arm GNU Toolchain 10.2-2020.11 (gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu.tar.xz,
https://developer.arm.com/-/media/Files/downloads/gnu-a/10.2-2020.11/binrel/).

Contents:
- `libc/` tree from the toolchain (glibc 2.31 headers/libs, Linux kernel headers, crt objects)
- libstdc++ 10.2.1 headers copied to `usr/include/c++/10.2.1`
- GCC runtime (crtbegin/crtend, libgcc.a, libgcc_eh.a) copied to
  `usr/lib/gcc/aarch64-none-linux-gnu/10.2.1` so clang's GCC-toolchain detection
  finds it inside the sysroot

Contains no host binaries — the same tarball is usable from Linux (x86_64/aarch64)
and macOS hosts.

## Usage with clang/lld (e.g. llvm.org release binaries)

```sh
clang++ --target=aarch64-none-linux-gnu --sysroot=/path/to/sysroot -fuse-ld=lld main.cpp -o main
```

Verified: C and C++ binaries built this way on x86_64 Ubuntu with clang 14 + lld
execute correctly under qemu-aarch64 against this sysroot.

Target compatibility: binaries require glibc <= the target system's glibc
(Raspberry Pi OS Bullseye = 2.31, Bookworm = 2.36 — both satisfied).
