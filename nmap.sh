#!/usr/bin/env bash

# 函数：打印脚本使用说明
usage() {
    echo "用法: $0"
    echo "运行脚本后将提供交互式选项以选择扫描模式，并从 /tmp/scan.txt 文件读取目标。"
    exit 0
}

# 检查是否安装了 nmap
check_nmap() {
    if ! command -v nmap &> /dev/null; then
        echo "错误：未检测到 Nmap，请先安装 Nmap。"
        exit 1
    fi
}

# 执行扫描
run_nmap() {
    # 从 /tmp/scan.txt 读取目标
    if [[ -f "/tmp/scan.txt" ]]; then
        target=$(cat /tmp/scan.txt | tr '\n' ' ')
        if [[ -z "$target" ]]; then
            echo "错误：/tmp/scan.txt 文件为空，未提供目标主机或范围！"
            exit 1
        fi
    else
        echo "错误：未找到 /tmp/scan.txt 文件！"
        exit 1
    fi

    echo ""
    echo "请选择扫描模式："
    echo "1) 基本服务扫描 (版本检测)"
    echo "2) 特定端口扫描 (1-1024, 7000-9000)"
    echo "3) 全端口扫描 (1-65535)"
    echo "4) 操作系统检测"
    read -p "请输入扫描模式的编号 (1-4): " mode

    case "$mode" in
        1)
            echo "执行基本服务扫描 (版本检测)..."
            nmap -sV -Pn "$target" -v -n
            ;;
        2)
            echo "执行特定端口扫描 (1-1024, 7000-9000)..."
            nmap -sV -Pn -p 1-1024,7000-9000 "$target" -v -n
            ;;
        3)
            echo "执行全端口扫描 (1-65535)..."
            nmap -sV -Pn -p1-65535 "$target" -v -n
            ;;
        4)
            echo "执行操作系统检测..."
            nmap -O -Pn "$target"
            ;;
        *)
            echo "错误：无效的扫描模式选择！"
            exit 1
            ;;
    esac
}

# 检查是否提供了帮助选项
if [[ "$#" -gt 0 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
    usage
fi

# 检查是否安装了 Nmap
check_nmap

# 执行 Nmap 扫描
run_nmap
