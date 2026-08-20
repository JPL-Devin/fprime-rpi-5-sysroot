#!/usr/bin/env bash
#
# enable-interfaces.sh: enable SPI, I2C, UART, and GPIO on a Raspberry Pi 5.
#
# Uses raspi-config's non-interactive mode when available, falling back to
# editing the firmware config directly. A reboot is required for the
# device-tree changes to take effect.
#
# Usage: sudo ./enable-interfaces.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: this script must be run as root (use sudo)." >&2
    exit 1
fi

# Locate the firmware config (Bookworm: /boot/firmware/config.txt; older: /boot/config.txt)
CONFIG_TXT="/boot/firmware/config.txt"
[ -f "${CONFIG_TXT}" ] || CONFIG_TXT="/boot/config.txt"
if [ ! -f "${CONFIG_TXT}" ]; then
    echo "Error: could not find config.txt (is this a Raspberry Pi?)" >&2
    exit 1
fi

# Ensure a key=value setting exists in config.txt, replacing any existing entry
set_config() {
    local key="$1" value="$2"
    if grep -Eq "^#?${key}=" "${CONFIG_TXT}"; then
        sed -i -E "s|^#?${key}=.*|${key}=${value}|" "${CONFIG_TXT}"
    else
        echo "${key}=${value}" >> "${CONFIG_TXT}"
    fi
}

if command -v raspi-config >/dev/null 2>&1; then
    echo "Enabling SPI, I2C, and UART via raspi-config"
    raspi-config nonint do_spi 0          # 0 = enable
    raspi-config nonint do_i2c 0
    # Enable the serial hardware without a login console on it
    raspi-config nonint do_serial_hw 0
    raspi-config nonint do_serial_cons 1  # 1 = console disabled
else
    echo "raspi-config not found; editing ${CONFIG_TXT} directly"
    set_config "dtparam=spi" "on"
    set_config "dtparam=i2c_arm" "on"
    set_config "enable_uart" "1"
    # Load the i2c-dev module at boot for /dev/i2c-*
    grep -q '^i2c-dev$' /etc/modules || echo 'i2c-dev' >> /etc/modules
fi

# GPIO character devices (/dev/gpiochip*) are always present; install the
# libgpiod tools and ensure the invoking user is in the hardware groups.
echo "Installing GPIO/I2C userspace tools"
apt-get update
apt-get install -y gpiod i2c-tools

TARGET_USER="${SUDO_USER:-}"
if [ -n "${TARGET_USER}" ] && [ "${TARGET_USER}" != "root" ]; then
    for group in gpio spi i2c dialout; do
        getent group "${group}" >/dev/null && usermod -aG "${group}" "${TARGET_USER}"
    done
    echo "Added ${TARGET_USER} to gpio/spi/i2c/dialout groups (re-login required)"
fi

echo "Done. Reboot for changes to take effect: sudo reboot"
echo "Verify after reboot: ls /dev/spidev* /dev/i2c-* /dev/ttyAMA0 /dev/gpiochip*"
