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

```bash
# 下载并执行
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/ufw-quick-setup.sh | sudo bash
```

或者使用 wget：

```bash
wget -qO- https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/ufw-quick-setup.sh | sudo bash
```

### 方法 3: 下载后执行

```bash
# 下载脚本
wget https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/ufw-quick-setup.sh

# 添加执行权限
chmod +x ufw-quick-setup.sh

# 运行脚本
sudo ./ufw-quick-setup.sh
```

## 注意事项

⚠️ **重要警告**:

1. **SSH 端口**: 脚本默认开放 5522 端口作为 SSH。如果你的 SSH 使用其他端口，请先修改脚本中的端口号，否则可能失去远程连接！

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
