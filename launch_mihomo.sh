echo "自动启动 autodl 资源加速，用于下载 mihomo 相关文件"
source /etc/network_turbo

# 1. 加载公共配置
if [ -f "./env.conf" ]; then
    source ./env.conf
else
    echo "配置 ./env.conf 未找到，请重新下载并配置路径"
    # -n 1 表示只读取一个字符，-s 表示不回显（隐藏输入），-p 是提示语
    read -n 1 -s -r -p "按任意键退出..."
    echo "" # 打印一个换行，让终端显示更美白
    exit 1
fi

echo "------------------------------------------"
echo "正在启动 $MOD_NAME..."
echo "------------------------------------------"

# 3. 直接运行 (不进入后台)
# -d 指定配置目录 >写入日志 (2>&1 包括错误)
mkdir -p $LOG_DIR
touch $LOG_DIR/mihomo.log
nohup "$BIN_PATH/$MOD_NAME" -d $CONF_DIR > "$LOG_DIR/mihomo.log" 2>&1 &

echo "关闭 autodl 资源加速"
unset http_proxy && unset https_proxy
