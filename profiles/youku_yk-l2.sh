#!/bin/bash
#============================================================
# File name: diy-script.sh
# Description: OpenWrt DIY script (After Update feeds)
# Lisence: MIT
# Author: cnbbx
#============================================================

# Modify default IP
sed -i 's/192.168.1.1/192.168.11.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.0./192.168.11./g' feeds/luciApp/applications/luci-app-pptp-server/root/etc/config/pptpd

# Modify hostname
sed -i 's/OpenWrt/Cnbbx/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i 's/OpenWrt/Cnbbx/g' package/base-files/files/bin/config_generate
sed -i "s/'OpenWrt'/'Cnbbx'/g" feeds/luci/modules/luci-mod-network/htdocs/luci-static/resources/view/network/wireless.js

# Cancel power on and disable WIFI
sed -i '/set wireless.radio${devidx}.disabled/d' package/kernel/mac80211/files/lib/wifi/mac80211.sh

# Modify default theme
sed -i 's/bootstrap/argon/g' feeds/luci/modules/luci-base/root/etc/config/luci
sed -i '/luci-theme-bootstrap/d' .config
for file in feeds/luci/collections/luci-light/Makefile feeds/luci/collections/luci-nginx/Makefile feeds/luci/collections/luci-ssl-nginx/Makefile; do
    sed -i 's/+luci-theme-bootstrap/+luci-theme-argon/' "$file"
done

# Modify Packages
sed -i 's/+ariang//g'  feeds/luci/applications/luci-app-aria2/Makefile
sed -i 's/+alist//g'  feeds/luciApp/applications/luci-app-alist/Makefile
rm -rf feeds/packages/net/{xray*,v2ray*,sing*,smartdns}

# ntfs-3g
sed -i '/upx --lzma --best/d' feeds/packages/utils/ntfs-3g/Makefile
sed -i -e "/\/mount.ntfs-3g/a  \\\t$\(LN\) ..\/usr\/bin\/ntfs-3g $\(1\)\/sbin\/mount.ntfs" feeds/packages/utils/ntfs-3g/Makefile

# Set lan wan
sed -i '/lenovo,newifi-d1/a \\tyouku,yk-l2\|\\'  target/linux/ramips/mt7621/base-files/etc/board.d/02_network

# Del lan3,lan4
sed -i '/port@2\s*{/,/};/d; /port@3\s*{/,/};/d' target/linux/ramips/dts/mt7621_youku_yk-l2.dts

# Rom Size
sed -i '/Rom Size/d' .config
sed -i '/CONFIG_TARGET_KERNEL_PARTSIZE/d' .config
sed -i '/CONFIG_TARGET_ROOTFS_PARTSIZE/d' .config
echo '# Rom Size' >> .config
echo 'CONFIG_TARGET_KERNEL_PARTSIZE=16' >> .config
echo 'CONFIG_TARGET_ROOTFS_PARTSIZE=32' >> .config

# Modify the version number
sed -i '/CONFIG_IMAGEOPT/d' .config
sed -i '/CONFIG_VERSIONOPT/d' .config
sed -i '/CONFIG_VERSION_DIST/d' .config
sed -i '/CONFIG_VERSION_NUMBER/d' .config
sed -i '/CONFIG_VERSION_CODE/d' .config
sed -i '/CONFIG_VERSION_HOME_URL/d' .config
sed -i '/CONFIG_VERSION_PRODUCT/d' .config
sed -i '/CONFIG_VERSION_HWREV/d' .config
sed -i '/Image Configurations/d' .config
echo '# Image Configurations' >> .config
echo 'CONFIG_IMAGEOPT=y' >> .config
echo 'CONFIG_VERSIONOPT=y' >> .config
echo 'CONFIG_VERSION_DIST="Cnbbx"' >> .config
echo 'CONFIG_VERSION_NUMBER="R23.05"' >> .config
echo "CONFIG_VERSION_CODE=\"build $(TZ=UTC-8 date "+%Y.%m.%d")"\" >> .config
echo 'CONFIG_VERSION_HOME_URL="https://autobuild.i.cnbbx.com/"' >> .config
echo 'CONFIG_VERSION_PRODUCT="CnbbxOS"' >> .config
echo 'CONFIG_VERSION_HWREV="ROS23.05"' >> .config

# Add kernel build user
[ -z $(grep "CONFIG_KERNEL_BUILD_USER=" .config) ] &&
    echo 'CONFIG_KERNEL_BUILD_USER="Cnbbx"' >>.config ||
    sed -i 's@\(CONFIG_KERNEL_BUILD_USER=\).*@\1"Cnbbx"@' .config
	
# Add kernel build domain
[ -z $(grep "CONFIG_KERNEL_BUILD_DOMAIN=" .config) ] &&
    echo 'CONFIG_KERNEL_BUILD_DOMAIN="GitHub Actions"' >>.config ||
    sed -i 's@\(CONFIG_KERNEL_BUILD_DOMAIN=\).*@\1"GitHub Actions"@' .config
