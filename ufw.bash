#!/bin/bash

# UFW 管理脚本
# 自动检测、安装、配置和管理 UFW 防火墙

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查是否为 root 用户
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}错误：此脚本需要 root 权限运行${NC}"
        echo "请使用: sudo $0"
        exit 1
    fi
}

# 检测 UFW 是否安装
check_ufw_installed() {
    if command -v ufw &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# 安装 UFW
install_ufw() {
    echo -e "${YELLOW}检测到 UFW 未安装，正在安装...${NC}"

    # 更新软件包列表
    echo -e "${BLUE}更新软件包列表...${NC}"
    apt update

    # 安装 UFW
    echo -e "${BLUE}安装 UFW...${NC}"
    apt install -y ufw

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}UFW 安装成功！${NC}"
        return 0
    else
        echo -e "${RED}UFW 安装失败！${NC}"
        return 1
    fi
}

# 显示当前规则
show_rules() {
    echo -e "\n${BLUE}==================== UFW 状态 ====================${NC}"
    ufw status verbose
    echo -e "${BLUE}=================================================${NC}\n"

    echo -e "${BLUE}==================== 所有规则 ====================${NC}"
    ufw status numbered
    echo -e "${BLUE}=================================================${NC}\n"
}

# 主菜单
show_menu() {
    echo -e "\n${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         UFW 防火墙管理脚本                ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}\n"

    echo -e "${YELLOW}【状态管理】${NC}"
    echo "  1)  查看 UFW 状态和规则"
    echo "  2)  启用 UFW"
    echo "  3)  禁用 UFW"
    echo "  4)  重新加载 UFW"
    echo "  5)  重置 UFW（删除所有规则）"

    echo -e "\n${YELLOW}【规则管理 - 添加】${NC}"
    echo "  6)  允许端口"
    echo "  7)  拒绝端口"
    echo "  8)  允许服务（如 ssh, http, https）"
    echo "  9)  允许来自特定 IP"
    echo "  10) 允许来自特定 IP 的特定端口"
    echo "  11) 允许端口范围"

    echo -e "\n${YELLOW}【规则管理 - 删除】${NC}"
    echo "  12) 删除规则（按编号）"
    echo "  13) 删除允许的端口"
    echo "  14) 删除拒绝的端口"

    echo -e "\n${YELLOW}【高级设置】${NC}"
    echo "  15) 设置默认策略（incoming/outgoing/routed）"
    echo "  16) 启用/禁用日志"
    echo "  17) 限制连接（防暴力破解）"
    echo "  18) 允许特定网卡的流量"

    echo -e "\n${YELLOW}【快捷配置】${NC}"
    echo "  19) 快速配置：允许 SSH (22)"
    echo "  20) 快速配置：允许 HTTP (80) + HTTPS (443)"
    echo "  21) 快速配置：允许常用服务"

    echo -e "\n${YELLOW}【其他】${NC}"
    echo "  22) 显示应用配置文件"
    echo "  0)  退出"

    echo -e "\n${GREEN}================================================${NC}"
}

# 允许端口
allow_port() {
    read -p "请输入要允许的端口号: " port
    if [[ $port =~ ^[0-9]+$ ]]; then
        ufw allow $port
        echo -e "${GREEN}已允许端口 $port${NC}"
    else
        echo -e "${RED}无效的端口号${NC}"
    fi
}

# 拒绝端口
deny_port() {
    read -p "请输入要拒绝的端口号: " port
    if [[ $port =~ ^[0-9]+$ ]]; then
        ufw deny $port
        echo -e "${GREEN}已拒绝端口 $port${NC}"
    else
        echo -e "${RED}无效的端口号${NC}"
    fi
}

# 允许服务
allow_service() {
    read -p "请输入服务名称（如 ssh, http, https）: " service
    ufw allow $service
    echo -e "${GREEN}已允许服务 $service${NC}"
}

# 允许来自特定 IP
allow_from_ip() {
    read -p "请输入 IP 地址: " ip
    ufw allow from $ip
    echo -e "${GREEN}已允许来自 $ip 的所有连接${NC}"
}

# 允许来自特定 IP 的特定端口
allow_from_ip_to_port() {
    read -p "请输入 IP 地址: " ip
    read -p "请输入端口号: " port
    ufw allow from $ip to any port $port
    echo -e "${GREEN}已允许来自 $ip 到端口 $port 的连接${NC}"
}

# 允许端口范围
allow_port_range() {
    read -p "请输入起始端口: " start_port
    read -p "请输入结束端口: " end_port
    read -p "协议 (tcp/udp，留空则两者都允许): " proto

    if [ -z "$proto" ]; then
        ufw allow ${start_port}:${end_port}/tcp
        ufw allow ${start_port}:${end_port}/udp
    else
        ufw allow ${start_port}:${end_port}/$proto
    fi
    echo -e "${GREEN}已允许端口范围 ${start_port}-${end_port}${NC}"
}

# 删除规则（按编号）
delete_rule_by_number() {
    ufw status numbered
    read -p "请输入要删除的规则编号: " rule_num
    ufw --force delete $rule_num
    echo -e "${GREEN}已删除规则 $rule_num${NC}"
}

# 删除允许的端口
delete_allow_port() {
    read -p "请输入要删除的允许端口: " port
    ufw delete allow $port
    echo -e "${GREEN}已删除允许端口 $port 的规则${NC}"
}

# 删除拒绝的端口
delete_deny_port() {
    read -p "请输入要删除的拒绝端口: " port
    ufw delete deny $port
    echo -e "${GREEN}已删除拒绝端口 $port 的规则${NC}"
}

# 设置默认策略
set_default_policy() {
    echo "选择方向:"
    echo "  1) incoming（入站）"
    echo "  2) outgoing（出站）"
    echo "  3) routed（路由）"
    read -p "请选择 (1-3): " direction_choice

    case $direction_choice in
        1) direction="incoming" ;;
        2) direction="outgoing" ;;
        3) direction="routed" ;;
        *) echo -e "${RED}无效选择${NC}"; return ;;
    esac

    echo "选择策略:"
    echo "  1) allow（允许）"
    echo "  2) deny（拒绝）"
    echo "  3) reject（拒绝并通知）"
    read -p "请选择 (1-3): " policy_choice

    case $policy_choice in
        1) policy="allow" ;;
        2) policy="deny" ;;
        3) policy="reject" ;;
        *) echo -e "${RED}无效选择${NC}"; return ;;
    esac

    ufw default $policy $direction
    echo -e "${GREEN}已设置 $direction 默认策略为 $policy${NC}"
}

# 启用/禁用日志
toggle_logging() {
    echo "日志级别:"
    echo "  1) off（关闭）"
    echo "  2) low（低）"
    echo "  3) medium（中）"
    echo "  4) high（高）"
    echo "  5) full（完整）"
    read -p "请选择 (1-5): " log_choice

    case $log_choice in
        1) ufw logging off ;;
        2) ufw logging low ;;
        3) ufw logging medium ;;
        4) ufw logging high ;;
        5) ufw logging full ;;
        *) echo -e "${RED}无效选择${NC}"; return ;;
    esac

    echo -e "${GREEN}日志设置已更新${NC}"
}

# 限制连接
limit_connection() {
    read -p "请输入要限制的端口（防暴力破解）: " port
    ufw limit $port
    echo -e "${GREEN}已对端口 $port 设置连接限制${NC}"
}

# 允许特定网卡
allow_interface() {
    read -p "请输入网卡名称（如 eth0, wlan0）: " iface
    read -p "方向 (in/out): " direction
    ufw allow $direction on $iface
    echo -e "${GREEN}已允许网卡 $iface 的 $direction 流量${NC}"
}

# 快速配置 SSH
quick_ssh() {
    ufw allow 22/tcp
    echo -e "${GREEN}已允许 SSH (端口 22)${NC}"
}

# 快速配置 HTTP + HTTPS
quick_web() {
    ufw allow 80/tcp
    ufw allow 443/tcp
    echo -e "${GREEN}已允许 HTTP (80) 和 HTTPS (443)${NC}"
}

# 快速配置常用服务
quick_common() {
    echo -e "${BLUE}正在配置常用服务...${NC}"
    ufw allow 22/tcp    # SSH
    ufw allow 80/tcp    # HTTP
    ufw allow 443/tcp   # HTTPS
    echo -e "${GREEN}已允许: SSH (22), HTTP (80), HTTPS (443)${NC}"

    read -p "是否添加 FTP (21)? (y/n): " add_ftp
    [ "$add_ftp" = "y" ] && ufw allow 21/tcp && echo -e "${GREEN}已添加 FTP${NC}"

    read -p "是否添加 MySQL (3306)? (y/n): " add_mysql
    [ "$add_mysql" = "y" ] && ufw allow 3306/tcp && echo -e "${GREEN}已添加 MySQL${NC}"

    read -p "是否添加 PostgreSQL (5432)? (y/n): " add_pgsql
    [ "$add_pgsql" = "y" ] && ufw allow 5432/tcp && echo -e "${GREEN}已添加 PostgreSQL${NC}"
}

# 显示应用配置文件
show_app_profiles() {
    echo -e "${BLUE}可用的应用配置文件:${NC}"
    ufw app list
}

# 主程序
main() {
    # 检查 root 权限
    check_root

    # 检查并安装 UFW
    if ! check_ufw_installed; then
        install_ufw
        if [ $? -ne 0 ]; then
            exit 1
        fi
    else
        echo -e "${GREEN}UFW 已安装${NC}"
    fi

    # 显示当前规则
    show_rules

    # 主循环
    while true; do
        show_menu
        read -p "请输入选项 (0-22): " choice

        case $choice in
            1) show_rules ;;
            2) ufw enable; echo -e "${GREEN}UFW 已启用${NC}" ;;
            3) ufw disable; echo -e "${YELLOW}UFW 已禁用${NC}" ;;
            4) ufw reload; echo -e "${GREEN}UFW 已重新加载${NC}" ;;
            5)
                read -p "确定要重置所有规则吗? (yes/no): " confirm
                if [ "$confirm" = "yes" ]; then
                    ufw --force reset
                    echo -e "${YELLOW}UFW 已重置${NC}"
                fi
                ;;
            6) allow_port ;;
            7) deny_port ;;
            8) allow_service ;;
            9) allow_from_ip ;;
            10) allow_from_ip_to_port ;;
            11) allow_port_range ;;
            12) delete_rule_by_number ;;
            13) delete_allow_port ;;
            14) delete_deny_port ;;
            15) set_default_policy ;;
            16) toggle_logging ;;
            17) limit_connection ;;
            18) allow_interface ;;
            19) quick_ssh ;;
            20) quick_web ;;
            21) quick_common ;;
            22) show_app_profiles ;;
            0)
                echo -e "${GREEN}退出 UFW 管理脚本${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}无效选项，请重新选择${NC}"
                ;;
        esac

        # 操作后暂停
        echo ""
        read -p "按 Enter 继续..."
    done
}

# 运行主程序
main
