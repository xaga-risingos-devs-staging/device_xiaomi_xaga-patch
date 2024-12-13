# A guide on how to build RisingOS with Lindroid for Redmi K60/POCO F5 Pro (Mondrian)
## Preparation 
### OS
Make sure you have a GNU/Linux environment. Debian and Ubuntu are recommended.  
If you are using Arch Linux, you will encounter errors during build. Chroot into a Debian or Ubuntu rootfs (or other containers like lxc).
### Hardware
You need a high performance computer. The most important thing is RAM. At least 16GB RAM is required to build smoothly.
Be sure to enable enough swap if you have a small RAM.
### Fetch repositories
Switch to a working directory.
```
mkdir risingos
cd risingos
```
#### RisingOS
```
repo init -u https://github.com/RisingTechOSS/android -b fifteen --git-lfs --depth=1
repo sync -c --no-clone-bundle --optimized-fetch --prune --force-sync -j$(nproc --all)
```
#### Device trees
```
git clone --depth=1 https://github.com/flakeforever/device_xiaomi_mondrian device/xiaomi/mondrian
git clone --depth=1 https://github.com/flakeforever/device_xiaomi_mondrian-kernel device/xiaomi/mondrian-kernel
git clone --depth=1 https://github.com/flakeforever/kernel_xiaomi_sm8475 kernel/xiaomi/sm8475
git clone --depth=1 https://github.com/flakeforever/vendor_xiaomi_mondrian vendor/xiaomi/mondrian
git clone --depth=1 https://GitHub.com/AOSPA/android_device_qcom_common device/qcom/common --branch=uvite
git clone --depth=1 https://github.com/flakeforever/device_xiaomi_sepolicy device/xiaomi/sepolicy
git clone --depth=1 https://github.com/flakeforever/hardware_xiaomi hardware/xiaomi
```
#### Lindroid
```
git clone --depth=1 https://github.com/Linux-on-droid/vendor_lindroid vendor/lindroid
git clone --depth=1 https://github.com/Linux-on-droid/libhybris libhybris
git clone --depth=1 https://github.com/Linux-on-droid/external_lxc external/lxc
```
#### Patches
```
git clone --depth=1 https://github.com/kde-yyds/device_xiaomi_mondrian-patch/
```
### Apply patches
```
python3 device_xiaomi_mondrian-patch/apply-patches.py
```
Apply what you need. Maybe not all patches are required.
### Build RisingOS
Switch to bash if you are not on it.
```
. build/envsetup.sh
riseup mondrian userdebug
rise b
```
Then wait for hours until the build progress complete.
