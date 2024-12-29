# 项目名称
“easy_bash”

## 功能
本机信息收集
detection.sh:
获取操作系统和内核信息
获取当前用户名和路径
获取当前进程ID
探测是否为Docker/K8s云容器
探测当前开放端口
检查数据库版本
启用被禁用的内部命令or禁用内部命令
设置HISTCONTROL并删除历史记录
查看历史命令匹配敏感信息
查找suid和sgid文件

服务器探测
Ping.sh 用于扫描内网主机是否能ping通（可修改网段）。（结果保存到/tmp/scan.txt中）
nmap.sh 通过ping.sh出来的结果进行nmap扫描

关闭防火墙
disfirewall.sh 用于扫描并且关闭linux服务系统的防火墙。

提权
Sudo_Elevate_privileges.sh sudo提权脚本

安装wget
install_wget.sh 若存在curl不存在wget的情况下通过下载busybox之后安装wget命令。

## 使用方法
bash main.sh
