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
#### Device trees (Thanks to [@flakeforever](https://github.com/flakeforever))
```
git clone --depth=1 https://github.com/flakeforever/device_xiaomi_mondrian device/xiaomi/mondrian
git clone --depth=1 https://github.com/flakeforever/device_xiaomi_mondrian-kernel device/xiaomi/mondrian-kernel
git clone --depth=1 https://github.com/flakeforever/kernel_xiaomi_sm8475 kernel/xiaomi/sm8475
git clone --depth=1 https://github.com/flakeforever/vendor_xiaomi_mondrian vendor/xiaomi/mondrian
git clone --depth=1 https://github.com/AOSPA/android_device_qcom_common device/qcom/common --branch=uvite
git clone --depth=1 https://github.com/flakeforever/device_xiaomi_sepolicy device/xiaomi/sepolicy
git clone --depth=1 https://github.com/flakeforever/hardware_xiaomi hardware/xiaomi
```
#### MIUI Camera
Get it from [here](https://github.com/flakeforever/device_xiaomi_mondrian/issues/16)

#### KernelSU
```
git clone https://github.com/kde-yyds/android_external_kernelsu external/kernelsu
```
#### Patches
```
git clone --depth=1 https://github.com/kde-yyds/device_xiaomi_mondrian-patch/
```
### Fix errors for Arch Linux (Thanks to [@Finish0314](https://github.com/finish0314) for this workaround)
When building android kernel on Arch Linux, `libyaml` cannot be found and configured correctly. Copy the header and lib to `prebuilts/kernel-build-tools` manually to fix it.
```
cp -r /usr/include/yaml.h prebuilts/kernel-build-tools/linux-x86/include/yaml.h
cp -r /lib64/libyaml-0.so.2.0.9 prebuilts/kernel-build-tools/linux-x86/lib64/libyaml.so
```
### Workaround sm8450 audio issue (Thanks to [@flakeforever](https://github.com/flakeforever) for this workaround)
```
# make a full clone because we had used depth=1 flag at repo init
rm -rf hardware/qcom-caf/sm8450/audio/agm hardware/qcom-caf/sm8450/audio/pal
git clone https://github.com/LineageOS/android_vendor_qcom_opensource_agm hardware/qcom-caf/sm8450/audio/agm/
git clone https://github.com/LineageOS/android_vendor_qcom_opensource_arpal-lx hardware/qcom-caf/sm8450/audio/pal/
# checkout
cd hardware/qcom-caf/sm8450/audio/agm/
git checkout 62ac0643c907e9566ed99929d947127d8e3b123e
cd ../../../../../
cd hardware/qcom-caf/sm8450/audio/pal/
git checkout 4dfc6be2ac56b7d4aa5b2d919823e612ce1c711b
cd ../../../../../
```
### Apply patches
```
python3 device_xiaomi_mondrian-patch/apply-patches.py
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
