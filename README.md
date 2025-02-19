# **A guide on how to build RisingOS with Lindroid and KernelSU for Redmi K60/POCO F5 Pro (Mondrian)**
# Build manually
## Preparation 
### OS
Make sure you have a GNU/Linux environment. Debian and Ubuntu are recommended.  
If you are using Arch Linux, you will encounter errors when building kernel. See the guide below to workaround it.
### Hardware
You need a high performance computer. The most important thing is RAM. At least 16GB RAM is required to build smoothly.  
Be sure to enable enough swap if you have a small RAM.  
Reference: AMD Ryzen 7 7700X + 2*8=16GB DDR5 RAM + TiPlus7100 SSD, 8GB Zram and 64GB Swap (Zswap enabled). Around 3 hour for first full build without ccache.
### Fetch repositories
Switch to a working directory.
```
mkdir risingos
cd risingos
```
#### RisingOS
```
repo init -u https://github.com/RisingOS-Revived/android -b fifteen --git-lfs --depth=1
repo sync -c --no-clone-bundle --optimized-fetch --prune --force-sync -j$(nproc --all)
```
#### Device trees (Thanks to [@XagaForge](https://github.com/XagaForge))
```
git clone --depth=1 https://github.com/XagaForge/android_device_xiaomi_xaga device/xiaomi/xaga
git clone --depth=1 https://github.com/XagaForge/android_device_xiaomi_mt6895-common device/xiaomi/mt6895-common
git clone --depth=1 https://github.com/XagaForge/android_kernel_xiaomi_mt6895 kernel/xiaomi/mt6895
git clone --depth=1 https://gitlab.com/priiii1808/android_vendor_xiaomi_xaga vendor/xiaomi/xaga
git clone --depth=1 https://github.com/XagaForge/android_vendor_xiaomi_mt6895-common vendor/xiaomi/mt6895-common
git clone --depth=1 https://github.com/XagaForge/android_vendor_firmware vendor/firmware
git clone --depth=1 https://github.com/xiaomi-mediatek-devs/android_hardware_xiaomi hardware/xiaomi
git clone --depth=1 https://github.com/xiaomi-mediatek-devs/android_hardware_mediatek hardware/mediatek
git clone --depth=1 https://github.com/xiaomi-mediatek-devs/android_device_mediatek_sepolicy_vndr device/mediatek/sepolicy/vndr
```
#### MIUI Camera
```
git clone --depth=1 https://gitlab.com/priiii1808/proprietary_vendor_xiaomi_miuicamera-xaga.git vendor/xiaomi/miuicamera-xaga
```

#### KernelSU
```
git clone https://github.com/kde-yyds/android_external_kernelsu external/kernelsu
```
#### Patches
```
git clone --depth=1 https://github.com/kde-yyds/device_xiaomi_xaga-patch/
```
### Fix errors for Arch Linux (Thanks to [@Finish0314](https://github.com/finish0314) for this workaround)
When building android kernel on Arch Linux, `libyaml` cannot be found and configured correctly. Copy the header and lib to `prebuilts/kernel-build-tools` manually to fix it.
```
cp -r /usr/include/yaml.h prebuilts/kernel-build-tools/linux-x86/include/yaml.h
cp -r /lib64/libyaml-0.so.2.0.9 prebuilts/kernel-build-tools/linux-x86/lib64/libyaml.so
```

### Apply patches
```
python3 device_xiaomi_xgag-patch/apply-patches.py
```
### Build RisingOS
Switch to bash if you are not on other shell.
```
. build/envsetup.sh
riseup mondrian userdebug
rise b
```
Then wait for hours until the build progress complete.
# Success! So… what’s next?
You’ve done it! Welcome to the elite club of self-builders. You’ve built your operating system from scratch, from the ground up. You are the master/mistress of your domain… and hopefully you’ve learned a bit on the way and had some fun too.  
# Do you need some testing before flash?
## DSU
Select `odm` `product` `system` `system_ext` `vendor` `product` images and compress them into a zip (select Store).  
Push to your mondrian.  
Install with DSU Sideloader, reboot and test.

It works well? Congratulations!  
Then flash it to your device and then share your image with others (if possible).
