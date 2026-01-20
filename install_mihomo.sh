source ./env.conf

# 1. base url
GITHUB_URL="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest"

# 2. 检查系统架构
ARCH=$(uname -m)
case $ARCH in
    x86_64)  PLATFORM="linux-amd64" ;;
    aarch64) PLATFORM="linux-arm64" ;;
    *) echo "不支持的架构: $ARCH"; exit 1 ;;
esac

echo "检测到系统架构: $PLATFORM"

# 3. 获取下载链接并下载
echo "正在获取最新版本下载链接..."
DOWNLOAD_URL=$(curl -s $GITHUB_URL | grep "browser_download_url" | grep "$PLATFORM" | grep -v "compatible" | head -n 1 | cut -d '"' -f 4)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "获取下载链接失败，请检查网络。"
    echo "请尝试开启 autodl 资源加速服务，source /etc/network_turbo"
    read -n 1 -s -r -p "按任意键退出..."
    echo "" # 打印一个换行，让终端显示更美白
    exit 1
fi

echo "正在下载: $DOWNLOAD_URL"
curl -L -o "$MOD_NAME.gz" "$DOWNLOAD_URL"

# 4. 安装
echo "正在解压并安装..."
gunzip -f "$MOD_NAME.gz"
chmod +x $MOD_NAME
mv $MOD_NAME $BIN_PATH
echo "解压安装成功...正在删除安装包"
rm -f "$MOD_NAME.gz" > /dev/null 2>&1

# 5. 创建配置目录和基础配置
mkdir -p $CONF_DIR
if [ ! -f "$CONF_DIR/config.yaml" ]; then
    cat << 'CONF' > "$CONF_DIR/config.yaml"
mixed-port: 7890
allow-lan: false
allow-left-side: true
mode: rule
log-level: info
external-controller: 0.0.0.0:9090
proxies:
# 请在此处粘贴你的代理节点或订阅转换后的内容
# 如果能直接从Windows平台代理处复制配置文件更妥当！
CONF
    echo "已生成默认配置文件: $CONF_DIR/config.yaml"
fi

# # 6. 创建 Systemd 服务
# cat << 'SERVICE' > /etc/systemd/system/mihomo.service
# [Unit]
# Description=mihomo Daemon, A rule-based tunnel in Go.
# After=network.target

# [Service]
# Type=simple
# User=root
# ExecStart=/usr/local/bin/mihomo -d /etc/mihomo
# Restart=on-failure

# [Install]
# WantedBy=multi-user.target
# SERVICE

# # 7. 启动服务
# systemctl daemon-reload
# systemctl enable mihomo
# systemctl start mihomo

# echo "------------------------------------------"
# echo "安装完成！"
# echo "配置文件路径: $CONF_DIR/config.yaml"
# echo "查看日志命令: journalctl -u mihomo -f"
# echo "管理服务: systemctl start|stop|restart mihomo"
# echo "控制面板默认 Secret: admin123"
# echo "------------------------------------------"