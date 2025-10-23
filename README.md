# 🚀 WeChat Multi-Instance Manager for macOS

<p align="center">
  <img src="https://img.shields.io/badge/macOS-10.15+-blue?logo=apple" alt="macOS">
  <img src="https://img.shields.io/badge/WeChat-4.0.6.17+-green?logo=wechat" alt="WeChat">
  <img src="https://img.shields.io/badge/license-MIT-orange" alt="License">
  <img src="https://img.shields.io/github/stars/你的用户名/wechat-multi-open?style=social" alt="Stars">
</p>

<p align="center">
  <b>交互式微信多开管理工具 - 智能、灵活、易用</b>
</p>

<p align="center">
  <a href="#-features">功能特性</a> •
  <a href="#-installation">安装使用</a> •
  <a href="#-usage">使用说明</a> •
  <a href="#-demo">演示</a> •
  <a href="#-faq">常见问题</a>
</p>

---

## ✨ Features

- 🎯 **交互式菜单** - 傻瓜式操作，无需记忆命令
- 🔍 **智能检测** - 自动扫描已有副本，避免重复创建
- ➕ **增量创建** - 只创建缺失的实例，节省时间
- 🎪 **选择启动** - 指定启动哪些实例，支持多选和 `all`
- 🗑️ **灵活删除** - 可删除指定副本或全部清理
- 🎨 **彩色输出** - 清晰易读的彩色交互界面
- 🛡️ **安全保护** - 二次确认、错误处理、权限隔离

---

## 📦 Installation

### Quick Install

```bash
# 下载脚本
curl -fsSL https://raw.githubusercontent.com/你的用户名/wechat-multi-open/main/wechat-multi-open.sh -o ~/wechat-multi.sh

# 添加执行权限
chmod +x ~/wechat-multi.sh

# 运行
~/wechat-multi.sh
```

### Manual Install

```bash
# 克隆仓库
git clone https://github.com/你的用户名/wechat-multi-open.git

# 进入目录
cd wechat-multi-open

# 运行脚本
./wechat-multi-open.sh
```

---

## 🎮 Usage

### 主菜单

运行脚本后会显示交互式菜单：

```
==========================================
        微信多开管理工具 v2.0
==========================================

[✓] 原版微信: /Applications/WeChat.app
[✓] 已创建 5 个副本:
   - WeChat2.app
   - WeChat3.app
   - WeChat4.app
   - WeChat5.app
   - WeChat6.app

总共可用: 6 个微信实例（1 个原版 + 5 个副本）

请选择操作:
  1) 查看当前状态
  2) 设置微信实例数量（含原版）
  3) 删除指定副本
  4) 删除所有副本（恢复单开）
  5) 选择启动微信实例
  6) 停止所有微信进程
  7) 退出

请输入选项 [1-7]:
```

### 功能说明

#### 1️⃣ 查看当前状态

实时显示已创建的副本数量和列表。

#### 2️⃣ 设置微信实例数量

输入目标数量（含原版），脚本会自动计算并创建缺失的副本。

**示例**：
```
当前: 1 个原版 + 2 个副本
输入: 5
结果: 只创建 2 个新副本（WeChat4、WeChat5）
```

#### 3️⃣ 删除指定副本

选择要删除的副本编号（支持多选）。

**示例**：
```
输入: 3 5 7
结果: 删除 WeChat3、WeChat5、WeChat7
```

#### 4️⃣ 删除所有副本（恢复单开）

一键删除所有副本，恢复到只有原版微信的状态。

#### 5️⃣ 选择启动微信实例

指定要启动的实例。

**示例**：
```
输入: 0 2 3    # 启动原版、WeChat2、WeChat3
输入: all      # 启动所有实例
```

#### 6️⃣ 停止所有微信进程

批量停止所有正在运行的微信实例。

---

## 🎬 Demo

### 创建副本

```bash
$ ./wechat-multi-open.sh

请输入总共需要的微信实例数量 [2-20]: 5

==========================================
  批量创建副本
==========================================

当前实例数: 1 个（1 个原版 + 0 个副本）
目标实例数: 5 个（1 个原版 + 4 个副本）
需要创建: 4 个副本

是否继续？[y/N]: y

[✓] 正在创建 WeChat2.app...
  [1/6] 复制应用文件... 完成
  [2/6] 修改 Bundle ID... 完成
  [3/6] 修改显示名称... 完成
  [4/6] 清除扩展属性... 完成
  [5/6] 重新签名... 完成
  [6/6] 修复权限... 完成
[✓] WeChat2.app 创建成功！

[✓] 正在创建 WeChat3.app...
...

[✓] 全部创建完成！现在共有 5 个微信实例
```

### 选择启动

```bash
==========================================
  选择启动微信实例
==========================================

可用实例:
  [0] WeChat.app (原版)
  [2] WeChat2.app
  [3] WeChat3.app
  [4] WeChat4.app
  [5] WeChat5.app

提示:
  - 输入 'all' 启动所有
  - 输入编号用空格分隔，如: 0 2 3
  - 原版编号为 0

请选择要启动的实例: 0 2 5

[✓] 正在启动 3 个微信实例...
  启动 WeChat.app (原版)
  启动 WeChat2.app
  启动 WeChat5.app

[✓] 已启动 3 个微信实例
```

---

## 🔧 Technical Details

### Bundle ID 隔离

每个副本使用独立的 Bundle ID：

```
原版:   com.tencent.xinWeChat
副本2:  com.tencent.xinWeChat2
副本3:  com.tencent.xinWeChat3
...
```

### 数据目录

每个实例的数据存储在独立的沙盒目录：

```
~/Library/Containers/com.tencent.xinWeChat/
~/Library/Containers/com.tencent.xinWeChat2/
~/Library/Containers/com.tencent.xinWeChat3/
...
```

### 签名方式

使用 ad-hoc 签名（本地自签名）：

```bash
codesign --force --deep --sign - /Applications/WeChat2.app
```

### 核心函数

| 函数名 | 功能 | 行数 |
|--------|------|------|
| `scan_wechat_copies()` | 扫描已存在的副本 | 12 |
| `batch_create()` | 批量创建副本 | 42 |
| `remove_selected_copies()` | 选择性删除副本 | 83 |
| `launch_selected()` | 选择性启动实例 | 79 |
| `stop_all()` | 停止所有进程 | 14 |

---

## 📋 Requirements

| 项目 | 要求 |
|------|------|
| **操作系统** | macOS 10.15 Catalina 或更高 |
| **微信版本** | 4.0.6.17 或更高 |
| **权限** | sudo（管理员权限） |
| **依赖** | Xcode Command Line Tools |

### 检查依赖

```bash
# 检查 Xcode Command Line Tools
xcode-select -p

# 如果未安装，运行
xcode-select --install
```

---

## 💡 Use Cases

### 案例 1: 工作生活分离

```
原版:    工作账号
WeChat2: 生活账号
```

早上上班只启动工作账号：
```bash
选择 5 → 输入 0
```

### 案例 2: 多账号客服

```
原版:    主账号
WeChat2-6: 5 个客服账号
```

批量启动所有客服账号：
```bash
选择 5 → 输入 2 3 4 5 6
或
选择 5 → 输入 all
```

### 案例 3: 开发测试

```
原版:    正常账号
WeChat2-5: 测试账号
```

测试完毕批量清理：
```bash
选择 3 → 输入 2 3 4 5
```

---

## ❓ FAQ

<details>
<summary><b>为什么需要 sudo 权限？</b></summary>

复制应用到 `/Applications/` 目录需要管理员权限。脚本只在必要的操作中使用 sudo，不会滥用权限。
</details>

<details>
<summary><b>副本会占用多少空间？</b></summary>

每个副本约 300MB（和原版微信大小相同）。5 个副本总共约 1.5GB。
</details>

<details>
<summary><b>数据会混淆吗？</b></summary>

不会。每个副本使用独立的 Bundle ID 和数据目录，数据完全隔离。
</details>

<details>
<summary><b>支持最新版微信吗？</b></summary>

理论上支持所有 4.0+ 版本。如遇问题请提交 Issue。
</details>

<details>
<summary><b>可以创建多少个副本？</b></summary>

默认限制 2-20 个。可以修改脚本第 449 行调整限制：

```bash
if [[ "$count" =~ ^[0-9]+$ ]] && [ "$count" -ge 2 ] && [ "$count" -le 50 ]; then
```
</details>

<details>
<summary><b>原版微信会被修改吗？</b></summary>

不会。脚本只复制原版，不会修改任何原版文件。
</details>

<details>
<summary><b>创建失败怎么办？</b></summary>

1. 检查是否有 sudo 权限
2. 确认原版微信路径正确
3. 查看错误信息，提交 Issue
</details>

<details>
<summary><b>启动时提示不能打开怎么办？</b></summary>

去【系统偏好设置 → 隐私与安全性】，点击"仍要打开"。
</details>

---

## 🗺️ Roadmap

- [ ] 支持自定义副本名称
- [ ] 支持图标替换（区分不同账号）
- [ ] 支持配置文件（保存启动组合）
- [ ] 添加日志功能
- [ ] 支持 GUI 界面
- [ ] 支持备份/恢复数据

---

## 🤝 Contributing

欢迎贡献代码、报告问题、提出建议！

### 开发流程

```bash
# Fork 项目
git clone https://github.com/你的用户名/wechat-multi-open.git
cd wechat-multi-open

# 创建分支
git checkout -b feature/your-feature

# 提交代码
git commit -am 'Add some feature'

# 推送到远程
git push origin feature/your-feature

# 创建 Pull Request
```

### 代码风格

- 使用 4 空格缩进
- 函数名使用 snake_case
- 添加必要的注释
- 遵循 ShellCheck 规范

---

## 📜 License

MIT License - 详见 [LICENSE](LICENSE) 文件

---

## 🙏 Acknowledgments

- 感谢所有贡献者
- 灵感来源于各种微信多开教程
- 使用 [ShellCheck](https://www.shellcheck.net/) 进行代码检查

---

## 📞 Contact

- **GitHub Issues**: [提交问题](https://github.com/你的用户名/wechat-multi-open/issues)
- **Discussions**: [参与讨论](https://github.com/你的用户名/wechat-multi-open/discussions)
- **Email**: your@email.com

---

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=你的用户名/wechat-multi-open&type=Date)](https://star-history.com/#你的用户名/wechat-multi-open&Date)

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/你的用户名">@你的用户名</a>
</p>

<p align="center">
  <b>如果这个项目对你有帮助，请给个 ⭐️ Star！</b>
</p>
