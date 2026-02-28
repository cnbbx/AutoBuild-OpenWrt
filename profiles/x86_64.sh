#!/bin/bash
#============================================================
# File name: diy-script.sh
# Description: OpenWrt DIY script (After Update feeds)
# Lisence: MIT
# Author: cnbbx
#============================================================

# Modify default IP
sed -i 's/192.168.1.1/192.168.86.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.0./192.168.86./g' feeds/luciApp/applications/luci-app-pptp-server/root/etc/config/pptpd

# Modify hostname
sed -i 's/OpenWrt/Cnbbx/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i 's/OpenWrt/Cnbbx/g' package/base-files/files/bin/config_generate
sed -i "s/'OpenWrt'/'Cnbbx'/g" feeds/luci/modules/luci-mod-network/htdocs/luci-static/resources/view/network/wireless.js

# Cancel power on and disable WIFI
sed -i '/set wireless.radio${devidx}.disabled/d' package/kernel/mac80211/files/lib/wifi/mac80211.sh

# Modify default theme
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
sed -i 's/bootstrap/argon/g' feeds/luci/modules/luci-base/root/etc/config/luci

# Modify Packages
sed -i 's/+ariang//g'  feeds/luci/applications/luci-app-aria2/Makefile
sed -i 's/+alist//g'  feeds/luciApp/applications/luci-app-alist/Makefile

# Compressed Go
sed -i '/upx --lzma --best/d' .config
sed -i -e "/GoPackage/a  \\\t$\(STAGING_DIR_HOST\)\/bin\/upx --lzma --best $\(PKG_INSTALL_DIR\)\/usr\/bin\/main \| true" feeds/small/xray-core/Makefile
sed -i '/upx --lzma --best/d' feeds/packages/net/frp/Makefile
sed -i -e "/define Package\/frp\/install/a  \\\t$\(STAGING_DIR_HOST\)\/bin\/upx --lzma --best $\(PKG_INSTALL_DIR\)\/usr\/bin\/$\(2\) \| true" feeds/packages/net/frp/Makefile

# ntfs-3g
sed -i '/upx --lzma --best/d' feeds/packages/utils/ntfs-3g/Makefile
sed -i -e "/\/mount.ntfs-3g/a  \\\t$\(LN\) ..\/usr\/bin\/ntfs-3g $\(1\)\/sbin\/mount.ntfs" feeds/packages/utils/ntfs-3g/Makefile

# remove
cp -f /dev/null feeds/kenzo/luci-app-ssr-plus/root/etc/ssrplus/gfw_list.conf
cp -f /dev/null feeds/kenzo/luci-app-ssr-plus/root/etc/ssrplus/china_ssr.txt

# Set lan wan
# sed -i '/youku,yk-l2/d' .config
# sed -i '/lenovo,newifi-d1/a \\tyouku,yk-l2\|\\'  target/linux/ramips/mt7621/base-files/etc/board.d/02_network

# Rom Size
sed -i '/Rom Size/d' .config
sed -i '/CONFIG_TARGET_KERNEL_PARTSIZE/d' .config
sed -i '/CONFIG_TARGET_ROOTFS_PARTSIZE/d' .config
echo '# Rom Size' >> .config
echo 'CONFIG_TARGET_KERNEL_PARTSIZE=16' >> .config
echo 'CONFIG_TARGET_ROOTFS_PARTSIZE=512' >> .config

# Modify the version number
sed -i '/CONFIG_IMAGEOPT/d' .config
sed -i '/CONFIG_VERSIONOPT/d' .config
sed -i '/CONFIG_VERSION_DIST/d' .config
sed -i '/CONFIG_VERSION_NUMBER/d' .config
sed -i '/CONFIG_VERSION_CODE/d' .config
sed -i '/CONFIG_VERSION_HOME_URL/d' .config
sed -i '/Image Configurations/d' .config
echo '# Image Configurations' >> .config
echo 'CONFIG_IMAGEOPT=y' >> .config
echo 'CONFIG_VERSIONOPT=y' >> .config
echo 'CONFIG_VERSION_DIST="Cnbbx"' >> .config
echo 'CONFIG_VERSION_NUMBER="R22.03"' >> .config
echo "CONFIG_VERSION_CODE=\"build $(TZ=UTC-8 date "+%Y.%m.%d")"\" >> .config
echo 'CONFIG_VERSION_HOME_URL="http://autobuild.i.cnbbx.com/"' >> .config

# sed -i 's/not//g'  feeds/luci/modules/luci-base/src/mkversion.sh

# Add kernel build user
[ -z $(grep "CONFIG_KERNEL_BUILD_USER=" .config) ] &&
    echo 'CONFIG_KERNEL_BUILD_USER="Cnbbx"' >>.config ||
    sed -i 's@\(CONFIG_KERNEL_BUILD_USER=\).*@\1"Cnbbx"@' .config
	
# Add kernel build domain
[ -z $(grep "CONFIG_KERNEL_BUILD_DOMAIN=" .config) ] &&
    echo 'CONFIG_KERNEL_BUILD_DOMAIN="GitHub Actions"' >>.config ||
    sed -i 's@\(CONFIG_KERNEL_BUILD_DOMAIN=\).*@\1"GitHub Actions"@' .config

# Replace xray-core
cd feeds/packages/net/
rm -rf xray-core
ln -sf ../../../feeds/small/xray-core/ xray-core
