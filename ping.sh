#!/usr/bin/env bash

# 定义扫描 IP 的函数
scan_network() {
    local network_prefix=$1  # 接受网段前缀，例如 "192.168.1" 或 "192.168"
    local output_file="/tmp/scan.txt"  # 输出文件路径固定为 /tmp/scan.txt

    # 检查输出文件所在的目录是否存在
    if [ ! -d "$(dirname "$output_file")" ]; then
        echo "目录 $(dirname "$output_file") 不存在，正在创建..."
        mkdir -p "$(dirname "$output_file")"
    fi

    # 清空输出文件（如果存在）
    > "$output_file"

    # 并发扫描 IP
    for ip in {1..254}; do
        {
            if ping -c 1 -W 1 "$network_prefix.$ip" | grep -q "ttl="; then
                echo "$network_prefix.$ip" >> "$output_file"
            fi
        } &
    done

    # 等待所有后台任务完成
    wait

    echo "扫描完成，结果保存在：$output_file"
}

# 主程序逻辑
main() {
    echo "请选择扫描模式："
    echo "1) 扫描 IP 的第三个字节和第四个字节范围 (例如 192.168.x.x)"
    echo "2) 扫描 IP 的第四个字节范围 (直接输入前三个字节，例如 192.168.1.x)"
    read -p "请输入选项 (1 或 2): " choice

    case $choice in
        1)
            read -p "请输入网段的前两个字节 (例如 192.168): " first_two_bytes
            if [[ -z "$first_two_bytes" ]]; then
                echo "错误：网段前两个字节不能为空！"
                exit 1
            fi

            read -p "请输入第三个字节的范围 (例如 1-3): " third_byte_range
            if [[ -z "$third_byte_range" ]]; then
                echo "错误：第三个字节范围不能为空！"
                exit 1
            fi

            # 扫描第三个字节和第四个字节的范围
            for third_byte in $(seq $(echo $third_byte_range | cut -d '-' -f 1) $(echo $third_byte_range | cut -d '-' -f 2)); do
                scan_network "$first_two_bytes.$third_byte"
            done
            ;;
        2)
            read -p "请输入前三个字节 (例如 192.168.3): " first_three_bytes
            if [[ -z "$first_three_bytes" ]]; then
                echo "错误：前三个字节不能为空！"
                exit 1
            fi

            # 扫描指定第三个字节的第四个字节范围
            scan_network "$first_three_bytes"
            ;;
        *)
            echo "无效选项，请选择 1 或 2。"
            exit 1
            ;;
    esac
}

# 调用主函数
main




