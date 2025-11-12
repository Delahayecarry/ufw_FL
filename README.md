# UFW 防火墙一键配置脚本

## 功能说明

这个脚本可以自动配置 UFW 防火墙，只开启指定的端口，其他端口保持关闭状态。

### 开放的端口

| 端口 | 协议 | 用途 |
|------|------|------|
| 5522 | TCP  | 自定义 SSH |
| 1234 | TCP  | 自定义服务 |
| 1234 | UDP  | 自定义服务 |
| 80   | TCP  | HTTP |
| 443  | TCP  | HTTPS |

### 默认策略

- **入站流量**: 拒绝（只允许上述端口）
- **出站流量**: 允许所有
- **路由流量**: 拒绝

## 使用方法

### 方法 1: 本地运行

```bash
# 克隆或下载脚本后
sudo bash ufw-quick-setup.sh
```

### 方法 2: 从 GitHub 一键安装（推荐）

#### 交互式安装（会询问 SSH 端口）
```bash
# 使用 curl
curl -fsSL https://raw.githubusercontent.com/Delahayecarry/ufw_FL/main/ufw-quick-setup.sh | sudo bash

# 使用 wget
wget -qO- https://raw.githubusercontent.com/Delahayecarry/ufw_FL/main/ufw-quick-setup.sh | sudo bash
```

#### 完全自动化安装（指定 SSH 端口，跳过确认）
```bash
# 如果你的 SSH 端口是 22
curl -fsSL https://raw.githubusercontent.com/Delahayecarry/ufw_FL/main/ufw-quick-setup.sh | sudo bash -s -- --ssh-port 22 --yes

# 如果你的 SSH 端口是 5522
curl -fsSL https://raw.githubusercontent.com/Delahayecarry/ufw_FL/main/ufw-quick-setup.sh | sudo bash -s -- --ssh-port 5522 --yes

# 使用 wget
wget -qO- https://raw.githubusercontent.com/Delahayecarry/ufw_FL/main/ufw-quick-setup.sh | sudo bash -s -- --ssh-port 22 --yes
```

### 方法 3: 下载后执行

```bash
# 下载脚本
wget https://raw.githubusercontent.com/Delahayecarry/ufw_FL/main/ufw-quick-setup.sh

# 添加执行权限
chmod +x ufw-quick-setup.sh

# 运行脚本
sudo ./ufw-quick-setup.sh
```

## 命令行参数

脚本支持以下命令行参数，特别适用于自动化部署：

```bash
# 查看帮助
sudo bash ufw-quick-setup.sh --help

# 指定 SSH 端口
sudo bash ufw-quick-setup.sh --ssh-port 22

# 跳过确认提示（自动化脚本）
sudo bash ufw-quick-setup.sh --ssh-port 22 --yes

# 参数说明
#   --ssh-port PORT    指定 SSH 端口号（1-65535）
#   --yes, -y          跳过确认提示，直接执行
#   --help, -h         显示帮助信息
```

### 自动化部署示例

```bash
# 完全自动化（适用于脚本、Ansible 等）
curl -fsSL https://raw.githubusercontent.com/Delahayecarry/ufw_FL/main/ufw-quick-setup.sh | \
  sudo bash -s -- --ssh-port 22 --yes

# 本地自动化
sudo bash ufw-quick-setup.sh --ssh-port 5522 -y
```

## 注意事项

⚠️ **重要警告**:

1. **SSH 端口**:
   - 交互式安装：脚本会询问你的 SSH 端口，请务必正确填写
   - 自动化安装：使用 `--ssh-port` 参数指定正确的 SSH 端口
   - 如果配置错误，可能失去远程连接！

2. **备份连接**: 在远程服务器上运行前，建议：
   - 确保有其他方式访问服务器（如控制台）
   - 或先测试配置：`sudo ufw --dry-run enable`

3. **规则重置**: 此脚本会**重置所有现有 UFW 规则**，如果你已有其他规则需要保留，请先备份。

## 常用命令

```bash
# 查看防火墙状态
sudo ufw status verbose

# 查看所有规则（带编号）
sudo ufw status numbered

# 临时禁用防火墙
sudo ufw disable

# 重新启用防火墙
sudo ufw enable

# 删除指定规则（按编号）
sudo ufw delete [编号]

# 添加新端口
sudo ufw allow [端口]/[协议]

# 重置所有规则
sudo ufw reset
```

## 自定义配置

如果需要修改开放的端口，编辑 `ufw-quick-setup.sh` 文件中的这部分：

```bash
# 步骤 4: 添加允许的端口规则
ufw allow 5522/tcp comment 'Custom SSH'
ufw allow 1234/tcp comment 'Custom Service TCP'
ufw allow 1234/udp comment 'Custom Service UDP'
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'
```

## 脚本文件

- `ufw-quick-setup.sh` - 一键配置脚本（自动设置指定规则）
- `ufw.bash` - 完整的 UFW 管理脚本（交互式菜单）

## 故障排除

### 问题：失去 SSH 连接

**解决方案**: 通过服务器控制台访问，运行：

```bash
sudo ufw allow 22/tcp  # 或你的实际 SSH 端口
sudo ufw reload
```

### 问题：需要临时开放某个端口

```bash
sudo ufw allow [端口号]/tcp
```

### 问题：想恢复默认设置

```bash
sudo ufw reset
sudo ufw default allow incoming
sudo ufw default allow outgoing
```

## 系统要求

- Ubuntu / Debian / 其他支持 UFW 的 Linux 发行版
- root 权限（sudo）
- UFW（脚本会自动安装）

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！
