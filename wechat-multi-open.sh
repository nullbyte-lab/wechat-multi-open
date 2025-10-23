#!/usr/bin/env bash
#
# 微信多开管理脚本 - 交互式增强版
# 支持无限多开、智能检测、增量创建、一键恢复
# 使用方法: chmod +x wechat-multi-open.sh && ./wechat-multi-open.sh
#

set -euo pipefail

# ==================== 配置 ====================
SRC="/Applications/WeChat.app"
BASE_BUNDLE_ID="com.tencent.xinWeChat"

# ==================== 颜色输出 ====================
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }
title() { echo -e "${CYAN}${BOLD}$1${NC}"; }

# ==================== 核心功能 ====================

# 扫描现有微信副本
scan_wechat_copies() {
    local copies=()
    for i in {2..99}; do
        local app="/Applications/WeChat${i}.app"
        if [ -d "$app" ]; then
            copies+=("$i")
        fi
    done
    echo "${copies[@]:-}"
}

# 获取副本数量
get_copy_count() {
    local copies=($(scan_wechat_copies))
    echo "${#copies[@]}"
}

# 显示当前状态
show_status() {
    clear
    title "=========================================="
    title "        微信多开管理工具 v2.0"
    title "=========================================="
    echo ""

    # 检查原版微信
    if [ -d "$SRC" ]; then
        info "原版微信: $SRC"
    else
        error "未找到原版微信: $SRC"
    fi

    # 扫描副本
    local copies=($(scan_wechat_copies))
    local count="${#copies[@]}"

    if [ "$count" -eq 0 ]; then
        warn "当前没有创建任何副本（单开模式）"
    else
        info "已创建 ${count} 个副本:"
        for i in "${copies[@]}"; do
            echo "   - WeChat${i}.app"
        done
    fi

    echo ""
    echo -e "${BLUE}总共可用:${NC} $((count + 1)) 个微信实例（1 个原版 + ${count} 个副本）"
    echo ""
}

# 创建微信副本
create_copy() {
    local num=$1
    local dst="/Applications/WeChat${num}.app"
    local bundle_id="${BASE_BUNDLE_ID}${num}"

    echo ""
    info "正在创建 WeChat${num}.app..."

    # 复制应用
    echo -n "  [1/6] 复制应用文件..."
    sudo cp -R "$SRC" "$dst" 2>/dev/null
    echo -e " ${GREEN}完成${NC}"

    # 修改 Bundle ID
    echo -n "  [2/6] 修改 Bundle ID..."
    sudo /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $bundle_id" \
        "$dst/Contents/Info.plist" 2>/dev/null
    echo -e " ${GREEN}完成${NC}"

    # 修改显示名称
    echo -n "  [3/6] 修改显示名称..."
    sudo /usr/libexec/PlistBuddy -c "Set :CFBundleName WeChat${num}" \
        "$dst/Contents/Info.plist" 2>/dev/null || true
    sudo /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName WeChat${num}" \
        "$dst/Contents/Info.plist" 2>/dev/null || true
    echo -e " ${GREEN}完成${NC}"

    # 清除扩展属性
    echo -n "  [4/6] 清除扩展属性..."
    sudo xattr -cr "$dst" 2>/dev/null || true
    echo -e " ${GREEN}完成${NC}"

    # 重新签名
    echo -n "  [5/6] 重新签名..."
    sudo codesign --force --deep --sign - "$dst" 2>/dev/null || {
        echo -e " ${YELLOW}警告${NC}"
    }
    echo -e " ${GREEN}完成${NC}"

    # 修复权限
    echo -n "  [6/6] 修复权限..."
    sudo chown -R "$(whoami)" "$dst" 2>/dev/null
    echo -e " ${GREEN}完成${NC}"

    info "WeChat${num}.app 创建成功！"
}

# 批量创建副本
batch_create() {
    local total_instances=$1  # 总实例数（包含原版）
    local target_copies=$((total_instances - 1))  # 需要的副本数
    local copies=($(scan_wechat_copies))
    local current_count="${#copies[@]}"

    if [ "$current_count" -ge "$target_copies" ]; then
        warn "当前已有 $((current_count + 1)) 个实例，无需创建"
        return
    fi

    local to_create=$((target_copies - current_count))
    echo ""
    title "=========================================="
    title "  批量创建副本"
    title "=========================================="
    echo ""
    info "当前实例数: $((current_count + 1)) 个（1 个原版 + ${current_count} 个副本）"
    info "目标实例数: ${total_instances} 个（1 个原版 + ${target_copies} 个副本）"
    info "需要创建: ${to_create} 个副本"
    echo ""

    # 确认
    read -p "$(echo -e ${YELLOW}是否继续？[y/N]: ${NC})" confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        warn "已取消创建"
        return
    fi

    # 找出需要创建的编号
    local next_num=2
    for ((i=1; i<=to_create; i++)); do
        while [ -d "/Applications/WeChat${next_num}.app" ]; do
            ((next_num++))
        done
        create_copy "$next_num"
        ((next_num++))
    done

    echo ""
    info "全部创建完成！现在共有 ${total_instances} 个微信实例"
}

# 删除所有副本（恢复单开）
remove_all_copies() {
    local copies=($(scan_wechat_copies))
    local count="${#copies[@]}"

    if [ "$count" -eq 0 ]; then
        warn "当前没有任何副本，已经是单开模式"
        return
    fi

    echo ""
    title "=========================================="
    title "  恢复单开模式"
    title "=========================================="
    echo ""
    warn "将删除以下 ${count} 个副本:"
    for i in "${copies[@]}"; do
        echo "   - WeChat${i}.app"
    done
    echo ""

    # 二次确认
    read -p "$(echo -e ${RED}${BOLD}确认删除？此操作不可恢复！[y/N]: ${NC})" confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        warn "已取消删除"
        return
    fi

    echo ""
    info "正在删除副本..."

    # 先停止所有进程
    for i in "${copies[@]}"; do
        killall "WeChat${i}" 2>/dev/null || true
    done

    # 删除应用
    for i in "${copies[@]}"; do
        local app="/Applications/WeChat${i}.app"
        echo -n "  删除 WeChat${i}.app..."
        sudo rm -rf "$app"
        echo -e " ${GREEN}完成${NC}"
    done

    # 清理数据目录（可选）
    echo ""
    read -p "$(echo -e ${YELLOW}是否同时清理数据目录？[y/N]: ${NC})" clean_data
    if [[ "$clean_data" =~ ^[Yy]$ ]]; then
        for i in "${copies[@]}"; do
            local data_dir="${HOME}/Library/Containers/${BASE_BUNDLE_ID}${i}"
            if [ -d "$data_dir" ]; then
                echo -n "  清理数据: WeChat${i}..."
                rm -rf "$data_dir"
                echo -e " ${GREEN}完成${NC}"
            fi
        done
    fi

    echo ""
    info "已恢复单开模式，所有副本已删除"
}

# 选择性删除副本
remove_selected_copies() {
    local copies=($(scan_wechat_copies))
    local count="${#copies[@]}"

    if [ "$count" -eq 0 ]; then
        warn "当前没有任何副本"
        return
    fi

    echo ""
    title "=========================================="
    title "  选择性删除副本"
    title "=========================================="
    echo ""
    info "当前副本列表:"
    for i in "${copies[@]}"; do
        echo "  [$i] WeChat${i}.app"
    done
    echo ""

    read -p "$(echo -e ${CYAN}请输入要删除的副本编号（多个用空格分隔，如: 2 3 5）: ${NC})" input

    if [ -z "$input" ]; then
        warn "未输入任何编号，已取消"
        return
    fi

    # 解析输入
    local to_delete=()
    for num in $input; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ -d "/Applications/WeChat${num}.app" ]; then
            to_delete+=("$num")
        else
            warn "忽略无效编号: $num"
        fi
    done

    if [ "${#to_delete[@]}" -eq 0 ]; then
        warn "没有有效的副本编号"
        return
    fi

    echo ""
    warn "将删除以下 ${#to_delete[@]} 个副本:"
    for i in "${to_delete[@]}"; do
        echo "   - WeChat${i}.app"
    done
    echo ""

    read -p "$(echo -e ${RED}${BOLD}确认删除？[y/N]: ${NC})" confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        warn "已取消删除"
        return
    fi

    echo ""
    info "正在删除副本..."

    # 停止进程并删除
    for i in "${to_delete[@]}"; do
        killall "WeChat${i}" 2>/dev/null || true
        echo -n "  删除 WeChat${i}.app..."
        sudo rm -rf "/Applications/WeChat${i}.app"
        echo -e " ${GREEN}完成${NC}"
    done

    # 清理数据目录（可选）
    echo ""
    read -p "$(echo -e ${YELLOW}是否同时清理这些副本的数据目录？[y/N]: ${NC})" clean_data
    if [[ "$clean_data" =~ ^[Yy]$ ]]; then
        for i in "${to_delete[@]}"; do
            local data_dir="${HOME}/Library/Containers/${BASE_BUNDLE_ID}${i}"
            if [ -d "$data_dir" ]; then
                echo -n "  清理数据: WeChat${i}..."
                rm -rf "$data_dir"
                echo -e " ${GREEN}完成${NC}"
            fi
        done
    fi

    echo ""
    info "已删除 ${#to_delete[@]} 个副本"
}

# 选择性启动微信实例
launch_selected() {
    local copies=($(scan_wechat_copies))
    local count="${#copies[@]}"

    echo ""
    title "=========================================="
    title "  选择启动微信实例"
    title "=========================================="
    echo ""

    if [ "$count" -eq 0 ]; then
        warn "当前只有原版微信"
        read -p "$(echo -e ${YELLOW}是否启动原版微信？[y/N]: ${NC})" confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            open -a "$SRC"
            info "已启动原版微信"
        fi
        return
    fi

    info "可用实例:"
    echo "  [0] WeChat.app (原版)"
    for i in "${copies[@]}"; do
        echo "  [$i] WeChat${i}.app"
    done
    echo ""
    echo -e "${CYAN}提示:${NC}"
    echo "  - 输入 'all' 启动所有"
    echo "  - 输入编号用空格分隔，如: 0 2 3"
    echo "  - 原版编号为 0"
    echo ""

    read -p "$(echo -e ${CYAN}请选择要启动的实例: ${NC})" input

    if [ -z "$input" ]; then
        warn "未输入任何选择，已取消"
        return
    fi

    local to_launch=()

    # 处理 all
    if [ "$input" = "all" ]; then
        to_launch=(0)
        [ "$count" -gt 0 ] && to_launch+=("${copies[@]}")
    else
        # 解析输入
        for num in $input; do
            if [ "$num" = "0" ]; then
                to_launch+=(0)
            elif [[ "$num" =~ ^[0-9]+$ ]] && [ -d "/Applications/WeChat${num}.app" ]; then
                to_launch+=("$num")
            else
                warn "忽略无效编号: $num"
            fi
        done
    fi

    if [ "${#to_launch[@]}" -eq 0 ]; then
        warn "没有有效的实例编号"
        return
    fi

    echo ""
    info "正在启动 ${#to_launch[@]} 个微信实例..."

    for num in "${to_launch[@]}"; do
        if [ "$num" = "0" ]; then
            open -a "$SRC"
            echo "  启动 WeChat.app (原版)"
        else
            sleep 0.5
            open -a "/Applications/WeChat${num}.app"
            echo "  启动 WeChat${num}.app"
        fi
    done

    echo ""
    info "已启动 ${#to_launch[@]} 个微信实例"
}

# 停止所有微信进程
stop_all() {
    echo ""
    info "正在停止所有微信进程..."

    killall WeChat 2>/dev/null || true
    local copies=($(scan_wechat_copies))
    for i in "${copies[@]}"; do
        killall "WeChat${i}" 2>/dev/null || true
    done

    sleep 1
    info "所有微信进程已停止"
}

# ==================== 交互式菜单 ====================
show_menu() {
    echo ""
    echo -e "${BOLD}请选择操作:${NC}"
    echo "  1) 查看当前状态"
    echo "  2) 设置微信实例数量（含原版）"
    echo "  3) 删除指定副本"
    echo "  4) 删除所有副本（恢复单开）"
    echo "  5) 选择启动微信实例"
    echo "  6) 停止所有微信进程"
    echo "  7) 退出"
    echo ""
}

# ==================== 主函数 ====================
main() {
    # 检查原版微信
    [ ! -d "$SRC" ] && error "未找到微信应用: $SRC"

    while true; do
        show_status
        show_menu

        read -p "$(echo -e ${CYAN}请输入选项 [1-7]: ${NC})" choice

        case "$choice" in
            1)
                # 已在 show_status 中显示
                read -p "$(echo -e ${CYAN}按回车继续...${NC})"
                ;;
            2)
                echo ""
                read -p "$(echo -e ${CYAN}请输入总共需要的微信实例数量 [2-20]: ${NC})" count
                if [[ "$count" =~ ^[0-9]+$ ]] && [ "$count" -ge 2 ] && [ "$count" -le 20 ]; then
                    batch_create "$count"
                else
                    warn "无效的数量，请输入 2-20 之间的数字"
                fi
                read -p "$(echo -e ${CYAN}按回车继续...${NC})"
                ;;
            3)
                remove_selected_copies
                read -p "$(echo -e ${CYAN}按回车继续...${NC})"
                ;;
            4)
                remove_all_copies
                read -p "$(echo -e ${CYAN}按回车继续...${NC})"
                ;;
            5)
                launch_selected
                read -p "$(echo -e ${CYAN}按回车继续...${NC})"
                ;;
            6)
                stop_all
                read -p "$(echo -e ${CYAN}按回车继续...${NC})"
                ;;
            7)
                echo ""
                info "再见！"
                exit 0
                ;;
            *)
                warn "无效的选项，请重新选择"
                sleep 1
                ;;
        esac
    done
}

# ==================== 执行 ====================
main "$@"
