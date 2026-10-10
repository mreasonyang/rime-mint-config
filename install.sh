#!/usr/bin/env bash
# ============================================================
# rime-mint-config · 一键配置 Rime 鼠须管（macOS）
#   薄荷基座 + 万象词库 + 万象 LTS 语言模型 + 本仓库自定义
#
# 用法：bash install.sh
#
# 流程：
#   1) 缺鼠须管则安装（brew，需输入密码）
#   2) 缺薄荷基座则克隆到 ~/Library/Rime
#   3) 用本仓库的 *.custom.yaml + lua 覆盖
#   4) 下载万象 LTS 语言模型（约 386MB）
#   5) 重新部署
# ============================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RIME_DIR="$HOME/Library/Rime"
BASE_REPO="https://github.com/Mintimate/oh-my-rime.git"
MODEL_NAME="wanxiang-lts-zh-hans.gram"
MODEL_URL="https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/${MODEL_NAME}"
SQUIRREL="/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel"

c_say()  { printf "\033[1;36m==> %s\033[0m\n" "$*"; }
c_warn() { printf "\033[1;33m[!] %s\033[0m\n" "$*"; }
c_ok()   { printf "\033[1;32m[✓] %s\033[0m\n" "$*"; }

[[ "$(uname)" == "Darwin" ]] || { c_warn "此脚本面向 macOS（鼠须管 Squirrel）。Linux 请用 fcitx5/ibus-rime，见 README。"; exit 1; }

# 1) 鼠须管
if [ ! -e "/Library/Input Methods/Squirrel.app" ]; then
  c_say "安装鼠须管 Squirrel（会提示输入密码）"
  if command -v brew >/dev/null 2>&1; then
    brew install --cask squirrel
  else
    c_warn "未检测到 Homebrew。请先安装鼠须管后重跑本脚本："
    c_warn "  · 装 Homebrew: https://brew.sh  或执行  brew install --cask squirrel"
    c_warn "  · 或手动下载: https://rime.im/download/"
    exit 1
  fi
else
  c_ok "鼠须管已安装"
fi

# 2) 薄荷基座
if [ -f "$RIME_DIR/rime_mint.schema.yaml" ]; then
  c_ok "检测到薄荷基座，尝试更新"
  if git -C "$RIME_DIR" pull --ff-only 2>/dev/null; then c_ok "基座已更新"; else c_warn "跳过基座更新（非 git 仓库或有本地改动）"; fi
else
  if [ -e "$RIME_DIR" ]; then
    BACKUP="${RIME_DIR}.bak.$(date +%Y%m%d-%H%M%S)"
    c_warn "已存在 $RIME_DIR 且不是薄荷，先备份到：$BACKUP"
    mv "$RIME_DIR" "$BACKUP"
  fi
  c_say "克隆薄荷基座 oh-my-rime → $RIME_DIR"
  mkdir -p "$(dirname "$RIME_DIR")"
  git clone --depth 1 "$BASE_REPO" "$RIME_DIR"
fi

# 3) 覆盖自定义配置
c_say "写入自定义配置（*.custom.yaml + lua）"
cp "$REPO_DIR"/*.custom.yaml "$RIME_DIR"/
mkdir -p "$RIME_DIR/lua"
cp "$REPO_DIR"/lua/*.lua "$RIME_DIR/lua/"

# 4) 万象 LTS 语言模型
SIZE=0
[ -f "$RIME_DIR/$MODEL_NAME" ] && SIZE=$(stat -f%z "$RIME_DIR/$MODEL_NAME" 2>/dev/null || echo 0)
if [ "$SIZE" -gt 100000000 ]; then
  c_ok "语言模型已存在（跳过下载）"
else
  c_say "下载万象 LTS 语言模型（约 386MB，国内可能需要代理）"
  if ! curl -fL --retry 3 --connect-timeout 20 -o "$RIME_DIR/$MODEL_NAME" "$MODEL_URL"; then
    c_warn "下载失败。请手动下载后放到：$RIME_DIR/$MODEL_NAME"
    c_warn "下载地址：$MODEL_URL"
  fi
fi

# 5) 部署
if [ -x "$SQUIRREL" ]; then
  c_say "部署（--reload）"
  "$SQUIRREL" --reload || true
  "$SQUIRREL" --enable-input-source || true
fi

c_ok "脚本执行完成！"
cat <<'TIP'

还需要手动做两步：
  1. 系统设置 → 键盘 → 文字输入 → 输入法 →「编辑…」→ 添加「鼠须管」
  2. 若某些软件里调不出，注销并重新登录一次

日常改配置后部署：
  "/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" --reload
TIP
