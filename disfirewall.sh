#!/usr/bin/env bash

disable_firewall() {
    # 检查系统上安装的防火墙服务，并禁用相应的服务
    if systemctl is-active --quiet firewalld; then
        # 如果 firewalld 正在运行，停止并禁用它
        systemctl disable --now firewalld &> /dev/null
        echo "firewalld 防火墙已禁用"
    elif systemctl is-active --quiet ufw; then
        # 如果 ufw (Uncomplicated Firewall) 正在运行，停止并禁用它
        systemctl disable --now ufw &> /dev/null
        echo "ufw 防火墙已禁用"
    elif systemctl is-active --quiet iptables; then
        # 如果 iptables 服务正在运行，停止并禁用它
        systemctl disable --now iptables &> /dev/null
        echo "iptables 防火墙已禁用"
    else
        # 如果没有已知的防火墙正在运行
        echo "未检测到已启用的防火墙服务"
    fi
}

disable_firewall