# Zeabur Headscale 部署手冊

這份文件紀錄了如何在 Zeabur 環境下，透過自定義 Dockerfile 成功架設
Headscale
伺服器的完整流程。此方案已解決常見的權限、新版配置格式及使用者建立問題。

---

## 📂 1. 專案結構

請確保你的 GitHub 倉庫根目錄如下：

    .
    ├── Dockerfile
    └── config/
        └── config.yaml

---

## 🛠️ 2. 關鍵檔案內容

### 📄 Dockerfile

採用 Alpine 基礎鏡像並動態獲取最新版 Headscale，避開官方鏡像的指令衝突。

```dockerfile
FROM alpine:latest
RUN apk add --no-cache bash coreutils ca-certificates curl

WORKDIR /app

# 自動獲取最新版 Headscale 並安裝
RUN LATEST_VERSION=$(curl -s https://api.github.com/repos/juanfont/headscale/releases/latest | grep -o '"tag_name": "[^"]*' | cut -d'"' -f4) && \
    curl -L "https://github.com/juanfont/headscale/releases/download/${LATEST_VERSION}/headscale_${LATEST_VERSION#v}_linux_amd64" -o /usr/local/bin/headscale && \
    chmod +x /usr/local/bin/headscale

# 複製配置文件
COPY ./config /etc/headscale

EXPOSE 8080

# 啟動指令
CMD ["headscale", "serve"]
```

---

### 📄 config/config.yaml (v0.23+ 規範)

> 重要：`server_url` 必須與 Zeabur 產生的域名一致。

```yaml
server_url: https://`你的域名`.zeabur.app
listen_addr: 0.0.0.0:8080

database:
  type: sqlite3
  sqlite:
    path: /var/lib/headscale/db.sqlite

private_key_path: /var/lib/headscale/private.key
noise:
  private_key_path: /var/lib/headscale/noise_private.key

derp:
  server:
    enabled: true
    region_id: 999
    private_key_path: /var/lib/headscale/derp_server.key
    stun_listen_addr: "0.0.0.0:3478"

dns:
  magic_dns: true
  base_domain: headscale.internal
  nameservers:
    global:
      - 1.1.1.1
      - 8.8.8.8
  override_local_dns: true
```

---

## ☁️ 3. Zeabur 設定要點

### 持久化磁碟 (Volume)

- 進入 Resources → Add Volume\
- Mount Path 務必設為：`/var/lib/headscale`

### 域名與 Port

- 產生域名
- 確保指向內部埠號 `8080`

---

## 🔑 4. 設備連接流程 (SOP)

### 第一步：建立使用者

在 Zeabur 服務頁面的 Console 執行：

```bash
headscale users create alex
```

---

### 第二步：客戶端發起請求

在你的電腦 (Windows PowerShell) 執行：

```powershell
tailscale up --login-server https://你的域名 --force-reauth
```

點擊跳出的網址，複製網頁給你的：

```bash
headscale nodes register --key <KEY> --user alex
```

---

### 第三步：伺服器授權

將該指令貼回 Zeabur 的 Console 執行。

成功後，輸入：

```bash
tailscale status
```

即可看到分配到的 IP。

---

## 🆘 5. 常見問題排錯

---

問題描述 解決方法

---

tailscale status 卡住不動 管理員執行 `Stop-Service Tailscale` 再
`Start-Service Tailscale`

Console 顯示 Reconnect 失敗 容器重啟中或未完全啟動，請等待 Log
穩定或重整網頁

User not found 檢查 Volume
是否正確掛載。掛載後資料庫會重設，需重新
`users create`

DNS 配置錯誤 (FTL) 確保 `dns.nameservers.global`
層級正確，v0.23+ 不再支援 `dns_config`

---

---

## 💾 如何保存？

1.  點擊上方文件下載。
2.  或將內容放入專案根目錄並命名為 `README.md`。
