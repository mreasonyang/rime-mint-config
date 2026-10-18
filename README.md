# rime-mint-config

把一套调好的 **Rime 鼠须管（macOS）输入法配置**打包，在新 Mac 上一条命令复现。
底层是 **薄荷 oh-my-rime** 基座（**自带万象词库**）+ **万象 LTS 语言模型**，本仓库只放**自定义覆盖**（`*.custom.yaml` + 一个 Lua 滤镜）。

> 许可证：**GPL-3.0**（聚合了上游 GPL 内容，全文见文末）。
> 仅面向 macOS；Linux 请用 fcitx5-rime / ibus-rime 自行移植这些 `.custom.yaml`。

## 它能给你什么

- **前端**：鼠须管 Squirrel（macOS）
- **默认方案**：薄荷·小鹤混输（全拼、小鹤都能打，无需切换）；备选纯小鹤双拼、薄荷·全拼
- **词库与语言模型**：薄荷基座自带**万象词库** + **万象 LTS** 整句语言模型（`wanxiang-lts-zh-hans.gram`，脚本自动下载）
- **默认中英状态**：默认**英文**；未列出的 App 默认英文
- **按 App 自动中英**：15 个 App 固定中文（微信、Telegram、Chrome、Obsidian、Notion、ChatGPT、Gemini……），6 个固定英文（Finder、kitty、系统设置、Clash Verge、Karabiner、Tinycast）
- **外观**：横排候选 + `ink` 黑白皮肤（跟随系统深浅色）+ 苹方字体
- **候选**：每页 6 个，**长词优先**
- **编码长度上限**：100（可打长句）
- **全角防误触**：保留全角开关，把易误触的 `Shift+空格` 改回普通空格
- **修复**：补齐混输方案缺失的零声母小鹤码（`an→aj`、`ai→ad` 等）

按 App 中英的完整清单见 `squirrel.custom.yaml` 里的 `app_options`。

## 快捷键 / 常用操作

| 操作 | 按键 |
|---|---|
| 中英切换 | `Shift` |
| 下一页 | `Ctrl+j` / `⌥+j` |
| 上一页 | `Ctrl+k` / `⌥+k` |
| 切换全角 | `Ctrl+Shift+3`，或点菜单 |
| 切换输入方案 | 点菜单栏的鼠须管图标 |

中文模式下，`@ - + = | % # ~ & *` 均使用半角，`$` 保留映射为 `￥`；逗号、句号等仍按中文标点输入。`=` 保留原有计算器入口，单独输入后按空格上屏半角等号。

## 前置要求

- macOS
- **Homebrew**（用来装鼠须管；没装脚本会报错并提示你手动安装）
- 能访问 GitHub（要下载约 386MB 的语言模型，国内可能需要代理）

## 安装

```bash
git clone https://github.com/mreasonyang/rime-mint-config.git ~/rime-mint-config \
  && bash ~/rime-mint-config/install.sh
```

脚本会自动：装鼠须管 → 克隆薄荷基座到 `~/Library/Rime` → 覆盖本仓库自定义 → 下载万象模型 → 重新部署。
安装鼠须管时可能要求输入密码。安装前若 `~/Library/Rime` 已存在且不是薄荷，会先备份为 `~/Library/Rime.bak.<时间戳>`。

**装完还要手动两步：**

1. 系统设置 → 键盘 → 文字输入 → 输入法 →「编辑…」→ 添加「**鼠须管**」
2. 若某些软件里打不出字，**注销并重新登录**一次

## 更新

```bash
cd ~/rime-mint-config && git pull && bash install.sh
```

## 改配置后重新部署

改完 `~/Library/Rime` 里的配置，执行：

```bash
"/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" --reload
```

> 薄荷的配置分**全局级**（`default`）和**方案级**；改 `default` 级有时要 `--reload` **两次**才传导到各方案。

## 想改哪块，改哪个文件

本仓库只含自定义覆盖，安装时会拷进 `~/Library/Rime`：

| 文件 | 作用 |
|---|---|
| `install.sh` | 一键安装 / 更新脚本 |
| `default.custom.yaml` | 方案列表与默认方案、`Shift` 切中英、Vim 翻页键、`Shift+空格` 防误触 |
| `double_pinyin_flypy.custom.yaml` | 小鹤双拼（纯双拼）方案级覆盖 |
| `rime_mint.custom.yaml` | 全拼方案级覆盖 |
| `rime_mint_flypy.custom.yaml` | 小鹤混输方案级覆盖（含零声母补丁、长词优先） |
| `squirrel.custom.yaml` | 外观（`ink` 皮肤 / 横排）+ 按 App 中英文（`app_options`） |
| `lua/long_word_filter.lua` | 长词优先滤镜 |

> 未放进仓库（体积太大，脚本自动获取）：薄荷基座（`oh-my-rime`）与万象 LTS 模型 `wanxiang-lts-zh-hans.gram`（约 386MB）。

## 卸载 / 回退

- **输入法本身**：系统设置里移除「鼠须管」，再删 `/Library/Input Methods/Squirrel.app`
- **配置**：删掉 `~/Library/Rime`；想回退就用安装时备份的 `~/Library/Rime.bak.<时间戳>`

## 语言模型下载失败怎么办

脚本会打印手动下载地址。手动下载后把文件放到 `~/Library/Rime/wanxiang-lts-zh-hans.gram`，再执行一次上面的 `--reload`。

## 致谢

本仓库只是自定义覆盖，主要工作归功于上游：

- [rime/squirrel](https://github.com/rime/squirrel) · 鼠须管前端
- [Mintimate/oh-my-rime](https://github.com/Mintimate/oh-my-rime) · 薄荷输入法基座
- [amzxyz/RIME-LMDG](https://github.com/amzxyz/RIME-LMDG) · 万象词库与万象 LTS 语言模型
- [iDvel/rime-ice](https://github.com/iDvel/rime-ice) · `long_word_filter.lua` 取自此处（原始出处 [tumuyan/rime-melt](https://github.com/tumuyan/rime-melt)，见文件头注释）

## 许可

因聚合了上游 GPL-3.0 的配置内容，本仓库同样以 **GPL-3.0** 发布，全文见 [LICENSE](LICENSE)。
