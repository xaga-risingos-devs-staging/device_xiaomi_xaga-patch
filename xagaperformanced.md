# xagaperformanced: Simple Performance Daemon for MT6895-based Devices

## Overview

`xagaperformanced` is a lightweight Android service designed for MT6895 (MediaTek Dimensity 8100) devices running any custom ROM.  
Its main function is to switch CPU governor profiles between "performance" and "schedutil" modes.  
It is not specific to any single device or ROM and can be adapted for any MT6895-based device.

---

## How It Works

- The service is started at boot (via `on post-fs-data` in the init `.rc` file).
- It can also be triggered any time by changing the property `persist.sys.xaga_performance_mode`.
- When triggered, it checks the current value of `persist.sys.xaga_performance_mode`:
  - If set to `1`, it sets the CPU governor to `performance` for all CPU clusters (cpu0, cpu4, cpu7).
  - If set to `0`, it sets the governor to `schedutil` for all CPU clusters.
- After setting the governors, the service exits (it is a `oneshot` service).

---
### Settings UI
- For me, directly patching `Settings` is simpler than using overlay. A switch is added in `Battery` page to control a prop `persist.sys.xaga_performance_mode`. [patch](https://github.com/xaga-risingos-devs-staging/device_xiaomi_xaga-patch/blob/lineage-23.0/packages%2Capps%2CSettings/0001-Add-a-switch-to-control-prop-persist.sys.xaga_perfor.patch)

---
### Service
- A service written in c++ controls cpu governor. [source](https://github.com/xaga-risingos-devs-staging/android_device_xiaomi_mt6895-common/blob/lineage-23.0/performanced/xagaperformanced.cpp)
- An .rc file controls when to trigger the service. Both on boot and prop `persist.sys.xaga_performance_mode` change. [source](https://github.com/xaga-risingos-devs-staging/android_device_xiaomi_mt6895-common/blob/lineage-23.0/performanced/init.xagaperformanced.rc)

### SELinux Policy
- We need to allow init executing this service.
- We need to allow this service to access and write to sysfs.
- Find more at this [commit](https://github.com/xaga-risingos-devs-staging/android_device_xiaomi_mt6895-common/commit/167ed641bf6cde8aa0c8885c257c0a9e59567057#diff-267d2c2eac9a053a127596fd3b76999b9b61723c7db83d964da50d1c8ea73fe0).
- SELinux is so tricky on android. Too many neverallow. To make it simpler, I [patched](https://github.com/xaga-risingos-devs-staging/device_xiaomi_xaga-patch/blob/lineage-23.0/system%2Csepolicy/0001-Allow-vendor_-to-access-sys.-prop-and-sysfs.patch)
out some neverallow rules.
---

## Equivalent Shell Commands

The following shell commands perform the same function.

```sh
# Set all clusters to 'performance'
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor

# Set all clusters to 'schedutil'
echo schedutil > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo schedutil > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
echo schedutil > /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor
```

## Troubleshooting (for buildbot)

- If the service works with `setenforce 0` but not in enforcing mode, check your SELinux policy and platform neverallow rules.
- Use `adb logcat | grep xagaperformanced` to see daemon output and debug.

---
