FROM alpine:latest
LABEL "language"="go"
LABEL "framework"="headscale"

RUN apk add --no-cache bash coreutils ca-certificates curl

WORKDIR /app

# 下載最新的 Headscale 二進制文件
# 從 GitHub API 獲取最新版本，然後下載對應的二進制文件
RUN LATEST_VERSION=$(curl -s https://api.github.com/repos/juanfont/headscale/releases/latest | grep -o '"tag_name": "[^"]*' | cut -d'"' -f4) && \
    curl -L "https://github.com/juanfont/headscale/releases/download/${LATEST_VERSION}/headscale_${LATEST_VERSION#v}_linux_amd64" -o /usr/local/bin/headscale && \
    chmod +x /usr/local/bin/headscale

# 複製配置文件
COPY ./config /etc/headscale

EXPOSE 8080

CMD ["headscale", "serve"]