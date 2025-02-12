#!/bin/bash

# Function to execute command with retry
retry_command() {
    local command="$*"
    local retries=0
    local max_retries=10
    local wait_time=3  # Wait 3 seconds between retries

    until [ $retries -ge $max_retries ]
    do
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

# Function to initialize and sync RisingOS repo
init_risingos() {
    echo "Initializing RisingOS repository..."
    retry_command "repo init -u https://github.com/RisingOS-Revived/android -b fifteen --git-lfs --depth=1"
    echo "Syncing RisingOS repository..."
    rm -rf device/xiaomi/mondrian
    rm -rf hardware/qcom-caf/sm8450/audio/agm
    rm -rf hardware/qcom-caf/sm8450/audio/pal
    retry_command "repo sync -c --no-clone-bundle --optimized-fetch --prune --force-sync -j$(nproc --all)"
}

# Function to clone device trees and related repositories
clone_repositories() {
    echo "Cleaning up device tree and lindroid and kernelsu repositories..."
    rm -rf device/xiaomi/mondrian/ device/xiaomi/mondrian-kernel/ device/xiaomi/sepolicy/ device/qcom/common hardware/xiaomi kernel/xiaomi/sm8475/ vendor/xiaomi/mondrian/ vendor/lindroid/ libhybris/ external/lxc external/kernelsu

    echo "Cloning device trees and related repositories..."

    # Device trees
    retry_command "git clone --depth=1 https://github.com/flakeforever/device_xiaomi_mondrian device/xiaomi/mondrian"
    retry_command "git clone --depth=1 https://github.com/flakeforever/device_xiaomi_mondrian-kernel device/xiaomi/mondrian-kernel"
    retry_command "git clone --depth=1 https://github.com/flakeforever/kernel_xiaomi_sm8475 kernel/xiaomi/sm8475"
    retry_command "git clone --depth=1 https://github.com/flakeforever/vendor_xiaomi_mondrian vendor/xiaomi/mondrian"
    retry_command "git clone --depth=1 https://github.com/AOSPA/android_device_qcom_common device/qcom/common --branch=uvite"
    retry_command "git clone --depth=1 https://github.com/flakeforever/device_xiaomi_sepolicy device/xiaomi/sepolicy"
    retry_command "git clone --depth=1 https://github.com/flakeforever/hardware_xiaomi hardware/xiaomi"

    # Lindroid
    retry_command "git clone --depth=1 https://github.com/Linux-on-droid/vendor_lindroid vendor/lindroid --branch=lindroid-22.1"
    retry_command "git clone --depth=1 https://github.com/Linux-on-droid/libhybris libhybris"
    retry_command "git clone --depth=1 https://github.com/Linux-on-droid/external_lxc external/lxc"

    # KernelSU
    retry_command "git clone https://github.com/kde-yyds/android_external_kernelsu external/kernelsu"

    # Patches
    retry_command "git clone --depth=1 https://github.com/kde-yyds/device_xiaomi_mondrian-patch/"
}

# Function to fix audio issues
fix_audio() {
    echo "Fixing sm8450 audio issues..."
    rm -rf hardware/qcom-caf/sm8450/audio/agm hardware/qcom-caf/sm8450/audio/pal
    retry_command "git clone https://github.com/LineageOS/android_vendor_qcom_opensource_agm hardware/qcom-caf/sm8450/audio/agm/"
    retry_command "git clone https://github.com/LineageOS/android_vendor_qcom_opensource_arpal-lx hardware/qcom-caf/sm8450/audio/pal/"

    # Checkout specific commits
    cd hardware/qcom-caf/sm8450/audio/agm/
    try_command "git checkout 62ac0643c907e9566ed99929d947127d8e3b123e"
    cd ../../../../../

    cd hardware/qcom-caf/sm8450/audio/pal/
    try_command "git checkout 4dfc6be2ac56b7d4aa5b2d919823e612ce1c711b"
    cd ../../../../../
}

# Function to apply patches
apply_patches() {
    echo "Applying patches..."
    try_command "python3 device_xiaomi_mondrian-patch/apply-patches.py --quiet"
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
    try_command "riseup mondrian userdebug"
    try_command "rise b"
}

# Main execution
main() {
    echo "=== Starting RisingOS build process ==="
    echo "Build started at: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    echo "User: $USER"

    init_risingos
    clone_repositories
    fix_audio
    fix_arch_linux
    apply_patches
    build_risingos

    echo "=== Build process completed ==="
    echo "Build finished at: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
}

# Run main function
main
