#!/bin/bash

# UFW 一键配置脚本
# 自动配置指定的防火墙规则，其他端口保持关闭

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}错误：此脚本需要 root 权限运行${NC}"
    echo "请使用: sudo $0"
    exit 1
fi

# 检查 UFW 是否安装
if ! command -v ufw &> /dev/null; then
    echo -e "${YELLOW}检测到 UFW 未安装，正在安装...${NC}"
    apt update && apt install -y ufw
    if [ $? -ne 0 ]; then
        echo -e "${RED}UFW 安装失败！${NC}"
        exit 1
    fi
    echo -e "${GREEN}UFW 安装成功！${NC}"
fi

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           UFW 防火墙一键配置脚本（风佬机场客户端）                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}\n"

# 询问 SSH 端口
echo -e "${YELLOW}⚠️  重要：请确认你的 SSH 端口${NC}"
echo -e "如果配置错误，你可能会失去远程连接！\n"
read -p "你的 SSH 端口是 5522 吗？(y/n): " ssh_confirm

if [ "$ssh_confirm" = "y" ] || [ "$ssh_confirm" = "Y" ]; then
    SSH_PORT=5522
    echo -e "${GREEN}✓ 使用 SSH 端口: 5522${NC}\n"
else
    read -p "请输入你的 SSH 端口号: " custom_ssh_port
    if [[ $custom_ssh_port =~ ^[0-9]+$ ]] && [ $custom_ssh_port -ge 1 ] && [ $custom_ssh_port -le 65535 ]; then
        SSH_PORT=$custom_ssh_port
        echo -e "${GREEN}✓ 使用 SSH 端口: $SSH_PORT${NC}\n"
    else
        echo -e "${RED}错误：无效的端口号！${NC}"
        exit 1
    fi
fi

echo -e "${YELLOW}将配置以下规则：${NC}"
echo -e "  ${GREEN}✓${NC} ${SSH_PORT}/tcp   (SSH)"
echo -e "  ${GREEN}✓${NC} 1234/tcp   (风佬机场节点服务)"
echo -e "  ${GREEN}✓${NC} 1234/udp   (风佬机场节点服务)"
echo -e "  ${GREEN}✓${NC} 80/tcp     (HTTP)"
echo -e "  ${GREEN}✓${NC} 443/tcp    (HTTPS)"
echo -e "\n${YELLOW}默认策略：${NC}"
echo -e "  ${RED}✗${NC} 入站：拒绝所有其他端口"
echo -e "  ${GREEN}✓${NC} 出站：允许所有"
echo ""

read -p "是否继续？这将重置所有现有的 UFW 规则 (y/n): " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo -e "${YELLOW}已取消配置${NC}"
    exit 0
fi

echo -e "\n${BLUE}=====================================================${NC}"
echo -e "${BLUE}开始配置 UFW...${NC}"
echo -e "${BLUE}=====================================================${NC}\n"

# 步骤 1: 禁用 UFW
echo -e "${YELLOW}[1/6]${NC} 禁用 UFW..."
ufw --force disable
echo -e "${GREEN}✓ 完成${NC}\n"

# 步骤 2: 重置所有规则
echo -e "${YELLOW}[2/6]${NC} 重置所有规则..."
ufw --force reset
echo -e "${GREEN}✓ 完成${NC}\n"

# 步骤 3: 设置默认策略
echo -e "${YELLOW}[3/6]${NC} 设置默认策略..."
ufw default deny incoming
ufw default allow outgoing
ufw default deny routed
echo -e "${GREEN}✓ 入站：拒绝${NC}"
echo -e "${GREEN}✓ 出站：允许${NC}"
echo -e "${GREEN}✓ 路由：拒绝${NC}\n"

# 步骤 4: 添加允许的端口规则
echo -e "${YELLOW}[4/6]${NC} 添加允许的端口规则..."
ufw allow ${SSH_PORT}/tcp comment 'SSH'
echo -e "${GREEN}✓ ${SSH_PORT}/tcp 已允许 (SSH)${NC}"

ufw allow 1234/tcp comment 'Custom Service TCP'
echo -e "${GREEN}✓ 1234/tcp 已允许${NC}"

ufw allow 1234/udp comment 'Custom Service UDP'
echo -e "${GREEN}✓ 1234/udp 已允许${NC}"

ufw allow 80/tcp comment 'HTTP'
echo -e "${GREEN}✓ 80/tcp 已允许${NC}"

ufw allow 443/tcp comment 'HTTPS'
echo -e "${GREEN}✓ 443/tcp 已允许${NC}\n"

# 步骤 5: 启用 UFW
echo -e "${YELLOW}[5/6]${NC} 启用 UFW..."
echo "y" | ufw enable
echo -e "${GREEN}✓ UFW 已启用${NC}\n"

# 步骤 6: 显示最终状态
echo -e "${YELLOW}[6/6]${NC} 显示最终配置...\n"
echo -e "${BLUE}=====================================================${NC}"
ufw status verbose
echo -e "${BLUE}=====================================================${NC}\n"

echo -e "${BLUE}==================== 规则列表 ====================${NC}"
ufw status numbered
echo -e "${BLUE}=====================================================${NC}\n"

echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              UFW 配置完成！                       ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}\n"

echo -e "${YELLOW}注意事项：${NC}"
echo -e "  1. SSH 端口 ${GREEN}${SSH_PORT}${NC} 已开放，请确保配置正确"
echo -e "  2. 如需修改规则，可运行: ${BLUE}sudo ufw status numbered${NC}"
echo -e "  3. 如需删除规则，可运行: ${BLUE}sudo ufw delete [编号]${NC}"
echo -e "  4. 如需完全禁用防火墙: ${BLUE}sudo ufw disable${NC}"
echo ""
