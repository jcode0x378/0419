#!/bin/bash
# Apache 配置腳本

echo "==== 開始配置 Apache 伺服器 ===="

# 備份原始配置
echo "備份原始配置文件..."
if [ -f /etc/apache2/apache2.conf ]; then
    cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.backup
fi
if [ -f /etc/apache2/sites-available/000-default.conf ]; then
    cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.backup
fi

# 檢查配置文件是否存在
if [ ! -f "$(pwd)/configs/apache/apache2.conf" ]; then
    echo "配置文件不存在，生成默認配置..."
    # 使用現有配置作為基礎
    cp /etc/apache2/apache2.conf "$(pwd)/configs/apache/apache2.conf"
    # 添加一些安全優化設置
    echo "# 安全優化設置" >> "$(pwd)/configs/apache/apache2.conf"
    echo "ServerTokens Prod" >> "$(pwd)/configs/apache/apache2.conf"
    echo "ServerSignature Off" >> "$(pwd)/configs/apache/apache2.conf"
    echo "TraceEnable Off" >> "$(pwd)/configs/apache/apache2.conf"
fi

if [ ! -f "$(pwd)/configs/apache/sites-available/000-default.conf" ]; then
    echo "站點配置文件不存在，生成默認配置..."
    # 使用現有配置作為基礎
    cp /etc/apache2/sites-available/000-default.conf "$(pwd)/configs/apache/sites-available/000-default.conf"
    # 修改站點配置
    sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html|g' "$(pwd)/configs/apache/sites-available/000-default.conf"
fi

# 複製網站文件到 Apache 目錄
echo "複製網站文件到 Apache 目錄..."

# 確保 admin.php 和其他網頁文件已被複製
if [ -f "$(pwd)/web/admin.php" ]; then
    echo "複製 admin.php 到 Apache 目錄..."
    cp "$(pwd)/web/admin.php" /var/www/html/
fi

if [ -f "$(pwd)/web/index.html" ]; then
    echo "複製 index.html 到 Apache 目錄..."
    cp "$(pwd)/web/index.html" /var/www/html/
fi

# 複製所有網站文件
cp -r "$(pwd)/web/"* /var/www/html/

# 設置適當的權限
echo "設置文件權限..."
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

# 啟用必要的模組（使用 a2enmod 而不是手動加載）
echo "啟用必要的 Apache 模組..."
a2enmod rewrite
a2enmod ssl
a2enmod headers

# 應用配置文件（僅包含必要的設定）
echo "應用項目配置文件..."
# 僅修改部分安全配置，不完全覆蓋配置文件
echo "# 安全優化設置" >> /etc/apache2/apache2.conf
echo "ServerTokens Prod" >> /etc/apache2/apache2.conf
echo "ServerSignature Off" >> /etc/apache2/apache2.conf
echo "TraceEnable Off" >> /etc/apache2/apache2.conf

# 修改默認站點配置
cp "$(pwd)/configs/apache/sites-available/000-default.conf" /etc/apache2/sites-available/000-default.conf

# 重啟 Apache 以應用配置
echo "重啟 Apache 服務以應用配置..."
systemctl restart apache2

# 檢查重啟是否成功
if ! systemctl is-active apache2 >/dev/null; then
    echo "警告：Apache 服務未正常啟動，嘗試修復..."
    # 還原配置並重啟
    if [ -f /etc/apache2/apache2.conf.backup ]; then
        cp /etc/apache2/apache2.conf.backup /etc/apache2/apache2.conf
    fi
    systemctl restart apache2
    
    if ! systemctl is-active apache2 >/dev/null; then
        echo "Apache 重啟失敗，請手動檢查配置"
        exit 1
    else
        echo "成功還原並重啟 Apache 服務"
    fi
fi

# 確保開機自動啟動
echo "設置 Apache 開機自動啟動..."
systemctl enable apache2

# 檢查自動啟動是否成功設置
if systemctl is-enabled apache2 >/dev/null; then
    echo "Apache2 已設置為開機自動啟動"
else
    echo "警告：無法通過 systemctl 設置開機自動啟動，嘗試其他方法..."
    update-rc.d apache2 defaults
fi

# 檢查配置是否正確
apache2ctl configtest

echo "==== Apache 配置完成 ===="
exit 0 