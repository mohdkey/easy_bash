#!/usr/bin/env bash

# 打印 LOGO
print_logo() {
    echo "======================================================"
    echo '____   __   ____  _  _      ____   __   ____  _  _ '
    echo '(  __) / _\ / ___)( \/ )    (  _ \ / _\ / ___)/ )( \'
    echo ' ) _) /    \\___ \ )  /____  ) _ (/    \\___ \) __ ('
    echo '(____)\_/\_/(____/(__/(____)(____/\_/\_/(____/\_)(_/'
    echo "======================================================"
    echo "                        xces                  "
    echo "======================================================"
    echo ""
}

# 打印 LOGO
print_logo

# 获取当前脚本所在的目录
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# 定义脚本的路径
DETECTION_SCRIPT="$SCRIPT_DIR/detection.sh"
DIS_FIREWALL_SCRIPT="$SCRIPT_DIR/disfirewall.sh"
PING_SCRIPT="$SCRIPT_DIR/ping.sh"
INSTALL_WGET_SCRIPT="$SCRIPT_DIR/install_wget.sh"
NMAP_SCRIPT="$SCRIPT_DIR/nmap.sh"
SUDO_ELEVATE_SCRIPT="$SCRIPT_DIR/Sudo_Elevate_privileges.sh"
PING_ELEVATE_SCRIPT="$SCRIPT_DIR/Ping_Elevate_privileges.sh"
PDF_XSS_SCRIPT="$SCRIPT_DIR/pdfxss.py" 

# 定义函数，使用 source 或 . 执行脚本
execute_script() {
    local script=$1
    local script_name=$(basename "$script")

    if [ -f "$script" ]; then
        echo "以 source 方式执行 $script_name..."
        if [ "$USE_SUDO" = true ]; then
            sudo bash "$script" || echo "警告：执行 $script_name 失败！"
        else
            bash "$script" || echo "警告：执行 $script_name 失败！"
        fi
    else
        echo "警告：无法找到 $script_name，跳过此步骤。"
    fi
}

# 主菜单循环
while true; do
    # 提供功能模块选择
    echo "请选择要执行的功能模块（可多选，输入编号以空格分隔）："
    echo "0: 退出"
    echo "1: 本机信息收集（detection.sh）"
    echo "2: 安装 wget（install_wget.sh）"
    echo "3: 关闭防火墙（disfirewall.sh）"
    echo "4: 探测存活主机（ping.sh）"
    echo "5: nmap 扫描（nmap.sh）"
    echo "6: 提权操作（选择要执行的提权脚本）"
    echo "7: PDF XSS 注入（pdfxss.py）" # 新增选项
    read -p "请输入选项（例如：1 3 5）: " choices

    # 检查是否选择了退出
    if [[ "$choices" =~ (^| )0($| ) ]]; then
        echo "退出脚本。"
        break
    fi

    # 按选项执行对应脚本
    for choice in $choices; do
        case $choice in
        1)
            echo "执行本机信息收集（detection.sh）..."
            execute_script "$DETECTION_SCRIPT"
            ;;
        2)
            echo "执行安装 wget（install_wget.sh）..."
            execute_script "$INSTALL_WGET_SCRIPT"
            ;;
        3)
            echo "执行关闭防火墙（disfirewall.sh）..."
            execute_script "$DIS_FIREWALL_SCRIPT"
            ;;
        4)
            echo "执行探测存活主机（ping.sh）..."
            execute_script "$PING_SCRIPT"
            ;;
        5)
            echo "执行 nmap 扫描（nmap.sh）..."
            execute_script "$NMAP_SCRIPT"
            ;;
        6)
            echo "请选择要执行的提权方式"
            echo "1: sudo提权（Sudo_Elevate_privileges.sh）"
            echo "2: 低版本的Centos5-6利用ping提权（Ping_Elevate_privileges.sh）"
            read -p "请输入选项（1 或 2）: " elevate_choice

            case $elevate_choice in
            1)
                if [ -f "$SUDO_ELEVATE_SCRIPT" ]; then
                    echo "执行提权脚本 Sudo_Elevate_privileges.sh..."
                    bash "$SUDO_ELEVATE_SCRIPT"
                    if [ $? -eq 0 ]; then
                        echo "Sudo_Elevate_privileges.sh 执行成功！"
                    else
                        echo "警告：Sudo_Elevate_privileges.sh 执行失败，请检查脚本是否正确。"
                    fi
                else
                    echo "警告：无法找到 Sudo_Elevate_privileges.sh，跳过此步骤。"
                fi
                ;;
            2)
                if [ -f "$PING_ELEVATE_SCRIPT" ]; then
                    echo "执行提权脚本 Ping_Elevate_privileges.sh..."
                    bash "$PING_ELEVATE_SCRIPT"
                    if [ $? -eq 0 ]; then
                        echo "Ping_Elevate_privileges.sh 执行成功！"
                    else
                        echo "警告：Ping_Elevate_privileges.sh 执行失败，请检查脚本是否正确。"
                    fi
                else
                    echo "警告：无法找到 Ping_ELEVATE_SCRIPT，跳过此步骤。"
                fi
                ;;
            *)
                echo "无效选项：$elevate_choice，跳过提权操作。"
                ;;
            esac
            ;;
        7)
            echo "执行 PDF XSS 注入（pdfxss.py）..."
            if [ -f "$PDF_XSS_SCRIPT" ]; then
                python3 "$PDF_XSS_SCRIPT" || echo "警告：执行 pdfxss.py 失败！"
            else
                echo "警告：无法找到 pdfxss.py，跳过此步骤。"
            fi
            ;;
        *)
            echo "无效选项：$choice，跳过。"
            ;;
        esac
    done

    echo "所有选定任务完成！"
    echo ""
done





