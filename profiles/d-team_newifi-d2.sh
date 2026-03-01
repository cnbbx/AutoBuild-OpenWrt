#!/bin/bash
#============================================================
# File name: diy-script.sh
# Description: OpenWrt DIY script (After Update feeds)
# Lisence: MIT
# Author: cnbbx
#============================================================
cp -f ../banner package/base-files/files/etc/banner

# Modify default IP
sed -i 's/192.168.1.1/192.168.99.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.1.1/192.168.99.1/g' .config

# Modify hostname
sed -i "s/'OpenWrt'/'Cnbbx'/g" package/base-files/files/bin/config_generate
sed -i "s/GMT0/CST-8/g" package/base-files/files/bin/config_generate
sed -i "s/UTC/Asia\/Shanghai/g" package/base-files/files/bin/config_generate

# Cancel power on and disable WIFI
sed -i "s/'OpenWrt'/'Cnbbx'/g" package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
sed -i "/.disabled=/d" package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
sed -i "s/'OpenWrt'/'Cnbbx'/g" feeds/luci/modules/luci-mod-network/htdocs/luci-static/resources/view/network/wireless.js

# Modify default theme
sed -i 's/bootstrap/argon/g' feeds/luci/modules/luci-base/root/etc/config/luci
sed -i '/luci-theme-bootstrap/d' .config
sed -i '/luci-theme-bootstrap/d' ./feeds/luci/collections/luci-nginx/Makefile
sed -i '/luci-theme-bootstrap/d' ./feeds/luci/collections/luci-light/Makefile

sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/g' /etc/shadow

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
echo 'CONFIG_VERSION_NUMBER="R25.12"' >> .config
echo "CONFIG_VERSION_CODE=\"build $(TZ=UTC-8 date "+%Y.%m.%d")"\" >> .config
echo 'CONFIG_VERSION_HOME_URL="https://autobuild.i.cnbbx.com/"' >> .config
echo 'CONFIG_VERSION_PRODUCT="CnbbxOS"' >> .config
echo 'CONFIG_VERSION_HWREV="ROS25.12"' >> .config

# Add kernel build user
[ -z $(grep "CONFIG_KERNEL_BUILD_USER=" .config) ] &&
    echo 'CONFIG_KERNEL_BUILD_USER="Cnbbx"' >>.config ||
    sed -i 's@\(CONFIG_KERNEL_BUILD_USER=\).*@\1"Cnbbx"@' .config
	
# Add kernel build domain
[ -z $(grep "CONFIG_KERNEL_BUILD_DOMAIN=" .config) ] &&
    echo 'CONFIG_KERNEL_BUILD_DOMAIN="GitHub Actions"' >>.config ||
    sed -i 's@\(CONFIG_KERNEL_BUILD_DOMAIN=\).*@\1"GitHub Actions"@' .config
