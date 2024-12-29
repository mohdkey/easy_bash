#!/bin/bash

while true; do
  # 提示用户选择要执行的功能
  echo "请选择要执行的任务："
  echo "0) 退出"
  echo "1) 获取操作系统和内核信息"
  echo "2) 获取当前用户名和路径"
  echo "3) 获取当前进程ID"
  echo "4) 探测是否为Docker/K8s云容器"
  echo "5) 探测当前开放端口"
  echo "6) 检查数据库版本"
  echo "7) 启用被禁用的内部命令or禁用内部命令"
  echo "8) 设置HISTCONTROL并删除历史记录"
  echo "9) 查看历史命令匹配敏感信息"
  echo "10) 查找suid和sgid文件"
  echo "请输入选项（0-10）："
  read option

  case $option in
    0)
      echo "退出脚本。"
      exit 0
      ;;

    1)
      echo "操作系统和内核信息："
      echo "--------------------"
      echo "操作系统信息："
      cat /etc/redhat-release 2>/dev/null || cat /etc/os-release || cat /etc/issue
      echo "\n内核版本："
      uname -r
      echo "\n详细内核信息："
      uname -ar
      echo "\nCPU信息："
      lscpu
      cat /proc/cpuinfo | grep "model name" | uniq
      echo "\n内存信息："
      free -h
      cat /proc/meminfo | grep "MemTotal"
      echo "\n磁盘分区信息："
      lsblk
      cat /proc/partitions
      echo "\n系统架构："
      arch
      ;;

    2)
      echo "当前用户名和路径："
      echo "--------------------"
      echo "用户名：$(whoami)"
      echo "当前路径：$(pwd)"
      ;;

    3)
      echo "当前进程ID："
      echo "--------------------"
      echo "当前进程ID：$$"
      ;;

    4)
      echo "检测是否为云容器环境："
      echo "--------------------"
      if [ -f "/.dockerenv" ]; then
        echo "运行在Docker环境中。"
      elif [ -f "/var/run/secrets/kubernetes.io/serviceaccount" ]; then
        echo "运行在Kubernetes环境中。"
      else
        echo "未检测到Docker或Kubernetes环境。"
      fi

      echo "检查特权挂载："
      if grep -q ":/sys/fs/cgroup" /proc/mounts; then
        echo "存在特权挂载。"
      else
        echo "未检测到特权挂载。"
      fi
      ;;

    5)
      echo "当前开放端口和服务："
      echo "--------------------"
      netstat -tuln | grep LISTEN || ss -tuln | grep LISTEN
      echo "\n服务对应端口："
      if command -v lsof >/dev/null 2>&1; then
        lsof -i -P -n | grep LISTEN
      else
        echo "lsof 命令不可用，无法列出服务对应的端口。"
      fi
      ;;

    6)
      echo "检查数据库版本："
      echo "--------------------"
      if command -v mysql >/dev/null 2>&1; then
        echo "MySQL版本："
        mysql --version
      else
        echo "未安装MySQL。"
      fi

      if command -v postgres >/dev/null 2>&1; then
        echo "PostgreSQL版本："
        postgres --version
      else
        echo "未安装PostgreSQL。"
      fi

      if command -v mongo >/dev/null 2>&1; then
        echo "MongoDB版本："
        mongo --version
      else
        echo "未安装MongoDB。"
      fi

      if command -v redis-cli >/dev/null 2>&1; then
        echo "Redis版本："
        redis-cli --version
      else
        echo "未安装Redis。"
      fi
      ;;

    7)
      echo "启用被禁用的命令："
      echo "--------------------"
      disabled_cmds=$(enable -n)
      if [ -z "$disabled_cmds" ]; then
        echo "未检测到被禁用的命令。"
      else
        echo "以下是被禁用的命令："
        echo "$disabled_cmds"
        echo "请输入要启用的命令："
        read cmd
        enable $cmd
        echo "$cmd 已启用。"
      fi

      echo "是否需要设置禁用命令？(yes/no)"
      read disable_choice
      if [ "$disable_choice" == "yes" ]; then
        echo "请输入要禁用的命令："
        read disable_cmd
        enable -n $disable_cmd
        echo "$disable_cmd 已被禁用。"
      fi
      ;;

    8)
      echo "设置HISTCONTROL并删除历史记录："
      echo "--------------------"
      export HISTCONTROL=ignoreboth
      echo "HISTCONTROL已设置为ignoreboth。"
      history -d $(history 1)
      echo "最近一条命令已从历史记录中删除。"
      ;;

    9)
      echo "匹配历史命令中的敏感信息："
      echo "--------------------"
      HISTFILE=~/.bash_history
      if [ "$(set -o | grep 'history' | awk '{print $2}')" == "off" ]; then
        set -o history
      fi
      history -a
      history | grep -E '(-u|-p|\\-u|\\-p)'
      set +o history
      ;;

    10)
      echo "查找suid文件："
      echo "--------------------"
      find / -perm -u=s -type f 2>/dev/null
      echo "\n查找sgid文件："
      echo "--------------------"
      find / -perm -g=s -type f 2>/dev/null
      ;;

    *)
      echo "无效选项，请重新运行脚本并选择0-10之间的选项。"
      ;;
  esac

done














