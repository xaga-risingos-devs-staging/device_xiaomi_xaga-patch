#!/bin/bash

# Function to execute command with retry
retry_command() {
    local command="$*"
    local retries=0
    local max_retries=10
    local wait_time=3  # Wait 3 seconds between retries

    until [ $retries -ge $max_retries ]; do
        echo "Executing: $command"
        if eval "$command"; then
            return 0
        else
            retries=$((retries + 1))
            if [ $retries -lt $max_retries ]; then
                echo "Command failed. Attempt $retries of $max_retries. Retrying in $wait_time seconds..."
                sleep $wait_time
            else
                echo "Command failed after $max_retries attempts. Exiting..."
                return 1
            fi
        fi
    done
    return 1
}

# Function to execute command once and exit if it fails
try_command() {
    local command="$*"
    echo "Executing (single attempt): $command"
    if eval "$command"; then
        return 0
    else
        echo "Command failed. This operation requires manual intervention. Exiting..."
        exit 1
    fi
}

remove_dir() {
    local dir="$1"
    echo "Checking directory: $dir"
    if [ -d "$dir" ]; then
        echo "Removing existing directory: $dir"
        rm -rf "$dir"
        if [ $? -ne 0 ]; then
            echo "Failed to remove directory: $dir"
            return 1
        fi
        echo "Successfully removed: $dir"
    else
        echo "Directory does not exist, skipping: $dir"
    fi
    return 0
}

# Function to cleanup existing directories
cleanup() {
    echo "=== Cleaning up ==="

    # List of directories to clean
    local directories=(
        "device/xiaomi/xaga"
        "device/xiaomi/mt6895-common"
        "kernel/xiaomi/mt6895"
        "vendor/xiaomi/xaga"
        "vendor/xiaomi/mt6895-common"
        "vendor/firmware"
        "hardware/xiaomi"
        "hardware/mediatek"
        "device/mediatek/sepolicy_vndr"
        "vendor/xiaomi/miuicamera-xaga"
        "vendor/lindroid"
        "libhybris"
        "external/lxc"
        "external/kernelsu"
    )

    for dir in "${directories[@]}"; do
        remove_dir $dir
    done

    echo "=== Cleanup completed ==="
}

# Function to initialize and sync RisingOS repo
init_risingos() {
    echo "Initializing RisingOS repository..."
    retry_command "repo init -u https://github.com/RisingOS-Revived/android -b fifteen --git-lfs --depth=1"
    echo "Syncing RisingOS repository..."
    retry_command "repo sync -c --no-clone-bundle --optimized-fetch --prune --force-sync -j$(nproc --all)"
}

# Function to clone device trees and related repositories
clone_repositories() {
    echo "Cloning device trees and related repositories..."

    retry_command "git clone --depth=1 https://github.com/XagaForge/android_device_xiaomi_xaga device/xiaomi/xaga"
    retry_command "git clone --depth=1 https://github.com/XagaForge/android_device_xiaomi_mt6895-common device/xiaomi/mt6895-common"
    retry_command "git clone --depth=1 https://github.com/XagaForge/android_kernel_xiaomi_mt6895 kernel/xiaomi/mt6895"
    retry_command "git clone --depth=1 https://gitlab.com/priiii1808/android_vendor_xiaomi_xaga vendor/xiaomi/xaga"
    retry_command "git clone --depth=1 https://github.com/XagaForge/android_vendor_xiaomi_mt6895-common vendor/xiaomi/mt6895-common"
    retry_command "git clone --depth=1 https://github.com/XagaForge/android_vendor_firmware vendor/firmware"
    retry_command "git clone --depth=1 https://github.com/xiaomi-mediatek-devs/android_hardware_xiaomi hardware/xiaomi"
    retry_command "git clone --depth=1 https://github.com/xiaomi-mediatek-devs/android_hardware_mediatek hardware/mediatek"
    retry_command "git clone --depth=1 https://github.com/xiaomi-mediatek-devs/android_device_mediatek_sepolicy_vndr device/mediatek/sepolicy_vndr"
    retry_command "git clone --depth=1 https://gitlab.com/priiii1808/proprietary_vendor_xiaomi_miuicamera-xaga.git vendor/xiaomi/miuicamera-xaga"
    retry_command "git clone --depth=1 https://github.com/Linux-on-droid/vendor_lindroid vendor/lindroid --branch=lindroid-22.1"
    retry_command "git clone --depth=1 https://github.com/Linux-on-droid/libhybris libhybris"
    retry_command "git clone --depth=1 https://github.com/Linux-on-droid/external_lxc external/lxc"
    retry_command "git clone https://github.com/kde-yyds/android_external_kernelsu external/kernelsu"
}

# Function to apply patches
apply_patches() {
    echo "Applying patches..."
    try_command "python3 device_xiaomi_xaga-patch/apply-patches.py --quiet"
}

# Function to fix Arch Linux specific issues
fix_arch_linux() {
    if [ -f /etc/arch-release ]; then
        echo "Fixing Arch Linux specific issues..."
        try_command "cp -r /usr/include/yaml.h prebuilts/kernel-build-tools/linux-x86/include/yaml.h"
        try_command "cp -r /lib64/libyaml-0.so.2.0.9 prebuilts/kernel-build-tools/linux-x86/lib64/libyaml.so"
    fi
}

# Function to build RisingOS
build_risingos() {
    echo "Starting RisingOS build..."
    try_command "source build/envsetup.sh"
    try_command "riseup xaga userdebug"
    try_command "rise b"
}

# Main execution
main() {
    echo "=== Starting RisingOS build process ==="
    echo "Build started at: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    echo "User: $USER"

    cleanup
    init_risingos
    clone_repositories
    fix_arch_linux
    apply_patches
    build_risingos

    echo "=== Build process completed ==="
    echo "Build finished at: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
}

# Run main function
main
