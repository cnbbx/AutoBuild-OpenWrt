#!/bin/bash
#============================================================
# File name: diy-script.sh
# Description: OpenWrt DIY script (After Update feeds)
# License: MIT
# Author: cnbbx
#============================================================

# === 1. 添加自定义 banner ===
cp -f "../banner" "package/base-files/files/etc/banner" || echo "⚠️ Banner not found, skipped."

# === 2. 修改默认 IP ===
sed -i 's/192.168.1.1/192.168.99.1/g' "package/base-files/files/bin/config_generate"
sed -i 's/192.168.1.1/192.168.99.1/g' ".config"

# === 3. 修改主机名、时区 ===
sed -i "s/'OpenWrt'/'Cnbbx'/g" "package/base-files/files/bin/config_generate"
sed -i "s/GMT0/CST-8/g" "package/base-files/files/bin/config_generate"
sed -i "s/UTC/Asia\/Shanghai/g" "package/base-files/files/bin/config_generate"

# === 4. 禁用 Wi-Fi 开机自动开启（防止设备重启后暴露）===
# 注释掉 .disabled=1 项，避免启动时被覆盖
sed -i '/\.disabled=/d' "package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc"
# 替换名称显示
sed -i "s/'OpenWrt'/'Cnbbx'/g" "package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc"
sed -i "s/'OpenWrt'/'Cnbbx'/g" "feeds/luci/modules/luci-mod-network/htdocs/luci-static/resources/view/network/wireless.js"

# === 5. 切换默认主题为 Argon ===
sed -i 's/bootstrap/argon/g' "feeds/luci/modules/luci-base/root/etc/config/luci"
# 移除 bootstrap 相关组件（避免残留）
sed -i '/luci-theme-bootstrap/d' ".config"
sed -i '/luci-theme-bootstrap/d' "feeds/luci/collections/luci-nginx/Makefile"
sed -i '/luci-theme-bootstrap/d' "feeds/luci/collections/luci-light/Makefile"

# === 6. 设置 root 密码（加密方式）===
# 使用 \$1$ 加密口令（可替换为你自己的密码）
# 示例：echo -e "root:$(openssl passwd -1 'yourpassword')" | sed 's/.*://'
sed -i 's/root:::0:99999:7:::/root:\$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/g' "package/base-files/files/etc/shadow"

# === 7. 配置版本信息与构建者 ===
CONFIG=".config"

# 清理所有旧配置项（包括注释行）
for pattern in \
    "# Image Configurations" \
    "CONFIG_IMAGEOPT" \
    "CONFIG_VERSIONOPT" \
    "CONFIG_VERSION_DIST" \
    "CONFIG_VERSION_NUMBER" \
    "CONFIG_VERSION_CODE" \
    "CONFIG_VERSION_HOME_URL" \
    "CONFIG_VERSION_PRODUCT" \
    "CONFIG_VERSION_HWREV" \
    "CONFIG_KERNEL_BUILD_USER" \
    "CONFIG_KERNEL_BUILD_DOMAIN"; do
    sed -i "/${pattern}/d" "$CONFIG"
done

# 写入新配置（使用标准格式，确保兼容）
{
    echo '# Image Configurations'
    echo 'CONFIG_IMAGEOPT=y'
    echo 'CONFIG_VERSIONOPT=y'
    echo 'CONFIG_VERSION_DIST="Cnbbx"'
    echo 'CONFIG_VERSION_NUMBER="R25.12"'
    echo "CONFIG_VERSION_CODE=\"build $(TZ=UTC-8 date '+%Y.%m.%d')\""
    echo 'CONFIG_VERSION_HOME_URL="https://autobuild.i.cnbbx.com/"'
    echo 'CONFIG_VERSION_PRODUCT="CnbbxOS"'
    echo 'CONFIG_VERSION_HWREV="ROS25.12"'
    echo '# Add kernel build'
    echo 'CONFIG_KERNEL_BUILD_USER="Cnbbx"'
    echo 'CONFIG_KERNEL_BUILD_DOMAIN="GitHub Actions"'
} >> "$CONFIG"

echo "✅ Cnbbx 版本信息配置完成！"

# === 8. 可选：添加编译时间戳到系统信息 ===
# 如果你想在启动时看到时间，也可以：
# echo "Build Date: $(date '+%Y-%m-%d %H:%M:%S')" >> package/base-files/files/etc/banner

