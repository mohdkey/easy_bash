#!/usr/bin/env bash

# 检查是否安装了 wget 和 curl
function check_tools() {
    local tools=("$@")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo "$tool 不存在"
            return 1
        fi
    done
    return 0
}

# 使用 curl 下载并安装 wget
function install_wget() {
    local server_ip=$1
    local busybox_url="http://$server_ip/busybox"

    echo "使用 curl 下载 busybox..."
    curl -o /root/busybox "$busybox_url"
    if [ $? -ne 0 ]; then
        echo "下载失败，请检查 URL 是否正确或网络连接。"
        exit 1
    fi

    echo "为 busybox 添加执行权限..."
    chmod +x /root/busybox

    echo "通过 busybox 安装 wget..."
    /root/busybox --install /usr/local/sbin/
    if [ $? -eq 0 ]; then
        echo "wget 安装成功！"
    else
        echo "wget 安装失败！"
        exit 1
    fi

    echo "清理临时文件..."
    rm -rf /root/busybox
}

# 主程序
function main() {
    # 检查 wget 和 curl
    check_tools "wget" "curl"
    local status=$?

    if [ $status -eq 0 ]; then
        echo "wget 和 curl 均存在"
    elif command -v curl &> /dev/null; then
        echo "curl 存在但 wget 不存在，请输入服务器的 IP 地址以安装 wget："
        read -p "请输入 IP 地址：" server_ip

        if [[ ! $server_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "输入的 IP 地址格式无效！"
            exit 1
        fi

        install_wget "$server_ip"
        echo "1"
    else
        echo "curl 和 wget 均不存在，无法继续。"
        exit 1
    fi
}

main

