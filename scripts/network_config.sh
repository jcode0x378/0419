#!/bin/bash
# 網絡配置腳本

echo "==== 開始配置網絡設置 ===="

# 獲取網絡介面信息
echo "獲取網絡介面信息..."
INTERFACES=$(ip -o link show | awk -F': ' '{print $2}' | grep -v "lo")
IP_ADDRESS=$(hostname -I | awk '{print $1}')

echo "檢測到的網絡介面："
echo "$INTERFACES"
echo "當前 IP 地址: $IP_ADDRESS"

# 檢查網絡連接
echo "檢查網絡連接..."
if ping -c 3 8.8.8.8 &> /dev/null; then
    echo "網絡連接正常，可訪問外部網絡"
else
    echo "警告：外部網絡連接可能有問題，但會繼續進行安裝"
fi

# 檢查本地連接
echo "檢查本地網絡設置..."
if [ -z "$IP_ADDRESS" ]; then
    echo "警告：未檢測到本地 IP 地址"
    IP_ADDRESS="127.0.0.1"
    echo "使用本地回環地址：$IP_ADDRESS"
else
    echo "本地 IP 地址設置正確：$IP_ADDRESS"
fi

# 診斷網絡問題
echo "執行網絡診斷..."
# 檢查 Apache 是否監聽 80 端口
if netstat -tulpn | grep :80 > /dev/null; then
    echo "Apache 正確監聽 80 端口"
else
    echo "警告：Apache 未監聽 80 端口"
    echo "正在嘗試重新啟動 Apache..."
    systemctl restart apache2
fi

# 檢查防火牆是否允許 80 端口
if ufw status | grep "80/tcp" | grep "ALLOW" > /dev/null; then
    echo "防火牆已允許 80 端口訪問"
else
    echo "警告：防火牆可能阻止了 80 端口訪問"
    echo "嘗試開放防火牆端口..."
    ufw allow 80/tcp
fi

# 顯示網絡設置建議
echo ""
echo "============================================================"
echo "網絡設置建議："
echo "============================================================"
echo "1. VirtualBox 網絡設置："
echo "   - 目前檢測到的 IP 地址：$IP_ADDRESS"
echo "   - 確保使用橋接網卡模式(Bridged Adapter)，這樣虛擬機能夠直接連接到實體網絡"
echo "   - 在 VirtualBox 設置中，選擇：設備 > 網絡 > 網卡1 > 使用方式：橋接網卡"
echo ""
echo "2. 檢查主機防火牆："
echo "   - 確保主機防火牆允許虛擬機 IP ($IP_ADDRESS) 的連接"
echo "   - Windows：檢查 Windows Defender 防火牆設置"
echo "   - Mac/Linux：檢查系統防火牆設置"
echo ""
echo "3. 啟用主機與虛擬機間的複製貼上功能："
echo "   - VirtualBox：設備 > 共用剪貼簿 > 雙向"
echo "   - VirtualBox：設備 > 拖放 > 雙向"
echo "   - 安裝增強功能：設備 > 安裝增強功能 (Guest Additions)"
echo "     安裝指令："
echo "     sudo apt update"
echo "     sudo apt install -y build-essential dkms linux-headers-\$(uname -r)"
echo "     sudo mount /dev/cdrom /mnt"
echo "     sudo sh /mnt/VBoxLinuxAdditions.run"
echo "     sudo reboot"
echo ""
echo "4. 測試連接："
echo "   - 從主機系統使用瀏覽器訪問：http://$IP_ADDRESS"
echo "   - 如果無法連接，請先嘗試從虛擬機內部訪問：curl http://localhost"
echo "============================================================"

# 測試 Apache 服務
echo "測試 Apache 連接..."
if curl -s --head http://localhost | grep "200 OK" > /dev/null; then
    echo "Apache 服務運行正常，可從本機訪問"
else
    echo "警告：無法訪問 Apache 本地服務"
    echo "檢查 Apache 狀態..."
    systemctl status apache2
fi

# 顯示訪問信息
echo "網站訪問信息："
echo "從宿主機可通過以下地址訪問網站："
echo "http://$IP_ADDRESS"
echo "https://$IP_ADDRESS（如果啟用了 SSL）"

echo "==== 網絡配置完成 ===="
exit 0 