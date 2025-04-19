## 安裝步驟二選一

### 方法一：從 GitHub clone

1. 安裝必要的工具：

```bash
sudo apt update
sudo apt install -y git curl wget
```

2. 克隆此專案到您的 Ubuntu 系統：

```bash
git clone https://github.com/jcode0x378/0419.git
cd 0419
```

3. 設置腳本執行權限：

```bash
chmod +x setup.sh
chmod +x scripts/*.sh
```

4. 執行主安裝腳本：

```bash
sudo ./setup.sh
```

### 方法二：一鍵安裝指令

如果您想要快速安裝，可以使用以下單行指令（適用於全新安裝的 Ubuntu）：

```bash
sudo apt update && sudo apt install -y git && git clone https://github.com/jcode0x378/0419.git && cd 0419 && chmod +x setup.sh scripts/*.sh && sudo ./setup.sh
```

## 腳本結構

- `setup.sh`: 主要安裝腳本，協調其他腳本的執行
- `scripts/update_system.sh`: 更新系統套件
- `scripts/install_apache.sh`: 安裝 Apache 伺服器
- `scripts/configure_apache.sh`: 配置 Apache 設定
- `scripts/install_database.sh`: 安裝 MariaDB 和 phpMyAdmin
- `scripts/configure_firewall.sh`: 設定 UFW 防火牆規則

## 安裝後的訪問

安裝完成後，您可以通過以下 URL 訪問您的網站：

- 網站主頁: http://您的伺服器 IP/
- 管理介面: http://您的伺服器 IP/admin.php
- phpMyAdmin: http://您的伺服器 IP/phpmyadmin

## 資料庫資訊

預設的資料庫設定：

- 資料庫名稱: webappdb
- 使用者名稱: webuser
- 密碼: userpassword

> **重要安全提示**: 在生產環境中，請務必修改預設密碼和設定。

## 常見問題解決

### Apache 無法啟動

檢查 Apache 錯誤日誌：

```bash
sudo tail -f /var/log/apache2/error.log
```

重新啟動 Apache 服務：

```bash
sudo systemctl restart apache2
```

### 無法連接到資料庫

確認 MariaDB 服務正在運行：

```bash
sudo systemctl status mariadb
```

重新啟動 MariaDB：

```bash
sudo systemctl restart mariadb
```

### 網頁顯示錯誤

檢查 PHP 錯誤日誌：

```bash
sudo tail -f /var/log/apache2/error.log
```

### 防火牆問題

檢查 UFW 狀態：

```bash
sudo ufw status
```

確保 Apache 端口開放：

```bash
sudo ufw allow 'Apache Full'
```

## 客製化設定

### 修改網頁內容

網頁文件位於 `/var/www/html/` 目錄，您可以直接修改這些文件。

### 修改 Apache 設定

Apache 配置文件位於 `/etc/apache2/` 目錄。

主要設定文件：

- `/etc/apache2/apache2.conf`
- `/etc/apache2/sites-available/000-default.conf`

修改後重新啟動 Apache：

```bash
sudo systemctl restart apache2
```

### 修改 MariaDB 設定

編輯 MariaDB 配置文件：

```bash
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
```
