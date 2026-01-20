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

echo "正在尝试停止 $MOD_NAME 进程..."

# 2. 查找并停止进程
# 使用 pgrep 查找匹配 MOD_NAME 的进程号
PID=$(pgrep -f "$MOD_NAME")

if [ -z "$PID" ]; then
    echo "未发现正在运行的 $MOD_NAME 进程。"
else
    echo "发现进程 PID: $PID，正在发送终止信号..."
    # 先尝试正常关闭 (SIGTERM)
    sudo kill $PID
    
    # 等待 2 秒检查是否成功关闭
    sleep 2
    if pgrep -f "$MOD_NAME" > /dev/null; then
        echo "进程未响应，正在强制停止 (SIGKILL)..."
        sudo kill -9 $PID
    else
        echo "$MOD_NAME 已成功停止。"
    fi
fi

# 3. 清理终端代理环境变量 (仅对当前 shell 脚本有效，建议手动执行)
echo "------------------------------------------"
echo "提示：如果你在当前终端执行过 export http_proxy=..."
echo "请手动执行 'unset http_proxy https_proxy' 来恢复原生网络环境。"
echo "若修改过 ~/.bashrc ，需要再次修改文件并 source ~/.bashrc "
echo "------------------------------------------"