#!/bin/bash
# 防火牆設置腳本

echo "==== 開始配置防火牆 ===="

# 安裝 UFW（如果尚未安裝）
echo "檢查並安裝 UFW..."
if ! command -v ufw &> /dev/null; then
    apt install ufw -y
    if [ $? -ne 0 ]; then
        echo "UFW 安裝失敗"
        exit 1
    fi
fi

# 重置 UFW 配置（可選）
echo "重置 UFW 配置..."
ufw --force reset

# 設置默認規則
echo "設置默認防火牆規則..."
ufw default deny incoming
ufw default allow outgoing

# 允許 SSH 連接（防止遠程服務器被鎖定）
echo "允許 SSH 連接..."
ufw allow ssh

# 允許 HTTP 和 HTTPS
echo "允許 HTTP 和 HTTPS 連接..."
ufw allow 80/tcp
ufw allow 443/tcp

# 啟用防火牆
echo "啟用防火牆..."
ufw --force enable

# 檢查防火牆狀態
echo "防火牆狀態："
ufw status verbose

echo "==== 防火牆配置完成 ===="
exit 0 