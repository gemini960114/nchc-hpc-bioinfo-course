# 📘 Antigravity IDE × Jupyter Notebook 全方位實戰教學指南

本指南專為在 Antigravity IDE / 雲端開發環境中高效使用 Jupyter Notebook 所設計，從環境安裝、視覺客製化、極速虛擬環境配置到套件管理，手把手帶您完整上手。

---

## 📑 目錄
1. [第一章：在 Antigravity IDE 安裝 Jupyter 延伸模組（Extensions）](#第一章在-vs-code-安裝-jupyter-延伸模組extensions)
2. [第二章：客製化外觀與主題配色（附 AI 自然語言切換 Prompt）](#第二章客製化外觀與主題配色附-ai-自然語言切換-prompt)
3. [第三章：使用 uv 快速建立 venv 虛擬環境並綁定 Jupyter Kernel](#第三章使用-uv-快速建立-venv-虛擬環境並綁定-jupyter-kernel)
4. [第四章：在 Jupyter Cell 中直接使用 uv 安裝 Python 套件](#第四章在-jupyter-cell-中直接使用-uv-安裝-python-套件)

---

## 第一章：在 Antigravity IDE 安裝 Jupyter 延伸模組（Extensions）

要在 Antigravity IDE 內流暢使用 `.ipynb` 筆記本，需要先安裝官方支援的延伸模組。

> ⚠️ **未實測確認事項**：Antigravity IDE 是 VS Code 相容分支，介面操作（左側活動列、`Ctrl+Shift+X`
> 快捷鍵、Extensions 面板）理論上相通，但**延伸模組市集是否為同一套 Microsoft Marketplace、
> 下方表格的識別碼 ID 是否完全通用，目前尚未實際驗證**。如果搜尋不到對應套件，
> 可以直接請 Antigravity 內建的 AI Agent 協助檢查/安裝（做法可參考
> [aicloud-docs 第 2 章](https://github.com/gemini960114/aicloud-docs/blob/main/docs/guide/02_ssh_proxyjump_and_dev_env.md)
> 的自然語言 Prompt 配方），比手動比對套件 ID 更省事。

### 1. 開啟延伸模組市集
* 點擊 Antigravity IDE 左側活動列的 **「Extensions（延伸模組）」圖示**（或按快捷鍵 `Ctrl + Shift + X` / Mac: `Cmd + Shift + X`）。

### 2. 搜尋並安裝必備模組
在搜尋框中依序搜尋並點擊 **Install（安裝）**：

| 模組名稱 | 識別碼 ID | 用途說明 |
| :--- | :--- | :--- |
| **Jupyter** (必裝) | `ms-toolsai.jupyter` | 提供 Notebook 核心介面、Cell 執行、互動輸出支援 |
| **Python** (必裝) | `ms-python.python` | 提供 Python 語法高亮、語意補全與環境偵測 |
| **Jupyter Cell Tags** (推薦) | `ms-toolsai.vscode-jupyter-cell-tags` | 方便為 Cell 加上標籤進行分類 |
| **Jupyter Keymap** (推薦) | `ms-toolsai.jupyter-keymap` | 還原傳統 Jupyter Notebook 的經典快捷鍵習慣（如按 `Esc` + `B` 插入下方 Cell） |

### 3. 驗證安裝
* 在 Antigravity IDE 檔案總管中新增或開啟任意 `.ipynb` 檔案（例如 `demo.ipynb`）。
* 檔案應呈現為互動式 Cell 畫面，即代表安裝成功。

---

## 第二章：客製化外觀與主題配色（附 AI 自然語言切換 Prompt）

Antigravity IDE 預設的 Notebook Cell 邊界較不明顯。透過配置 `settings.json`，可以大幅提升視覺層次與長時間閱讀舒適度。

以下為三種精選配色，您可以直接複製下方的 **「AI 提示詞（Prompt）」**，貼給 AI 助手為您一鍵自動套用！

---

### 🎨 方案一：現代卡片暖白風（GitHub / Notion 風格）
* **適用情境**：喜愛淺色、希望 Cell 像白色卡片一樣立體浮起、邊界清爽分明。
* **特色**：護眼淡暖灰底色 (`#f6f8fa`) + 純白 Cell 卡片 (`#ffffff`) + 科技藍選取外框 (`#0969da`)。

> 💬 **給 AI 的自然語言切換 Prompt**（直接複製使用）：
> ```text
> 請幫我把 Antigravity IDE 的 Jupyter Notebook 外觀切換為「方案一：現代卡片暖白風」。
> 包含淺色主題 Default Light Modern、底色設為 #f6f8fa、Cell 底色設為純白 #ffffff、加上 #d0d7de 細灰邊框與 #0969da 藍色聚焦框，並關閉 compactView。
> ```

---

### 📜 方案二：Solarized Light 復古羊皮紙暖色風
* **適用情境**：極度注重護眼、不喜歡強光刺眼、習慣長時間閱讀大量文本與程式碼。
* **特色**：溫和淡米黃羊皮紙底色 (`#fdf6e3`) + 米褐 Cell 底色 (`#eee8d5`) + 經典海藍聚焦框 (`#268bd2`)。

> 💬 **給 AI 的自然語言切換 Prompt**（直接複製使用）：
> ```text
> 請幫我把 Antigravity IDE 主題切換為「方案二：Solarized Light 復古羊皮紙暖色風」。
> 包含 Solarized Light 主題、米黃底色 #fdf6e3、Cell 背景 #eee8d5、暖灰框線 #d3cbb7 與經典海藍聚焦框 #268bd2，並開啟邊框模式。
> ```

---

### 🌌 方案三：Nord 極光冷灰藍風（護眼深色首選）
* **適用情境**：夜間工作、偏好深色系但排斥死沉純黑的開發者。
* **特色**：北歐極光冷石板深灰 (`#242933`) + 凸顯層次的深灰藍 Cell (`#2e3440`) + 極光冰藍選取框 (`#88c0d0`)。

> 💬 **給 AI 的自然語言切換 Prompt**（直接複製使用）：
> ```text
> 請幫我把 Antigravity IDE 主題切換為「方案三：Nord 極光冷灰藍風」。
> 包含深色主題 Default Dark Modern、極光冷灰背景 #242933、Cell 內部 #2e3440、細微框線 #434c5e 與極光冰藍聚焦框 #88c0d0。
> ```

---

## 第三章：使用 uv 快速建立 venv 虛擬環境並綁定 Jupyter Kernel

`uv` 是由 Astral 開發、以 Rust 編寫的次世代極速 Python 套件與環境管理工具，執行速度比傳統 `pip` 與 `venv` 快 10~100 倍。

### 1. 安裝 uv（各平台安裝方式）

如果您的系統中尚未安裝 `uv`，請依作業系統選擇對應指令：

#### 🔹 Linux / macOS（官方一鍵安裝腳本，推薦）
開啟終端機（Terminal）執行：
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

> ⚠️ **若安裝後終端機顯示 `command not found: uv`**：
> 代表尚未將 `uv` 的安裝路徑 (`~/.local/bin`) 加入環境變數，請執行以下指令：
> ```bash
> # 1. 永久將 ~/.local/bin 加入 PATH（寫入 ~/.bashrc）
> echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
> 
> # 2. 立即重新載入設定檔生效
> source ~/.bashrc
> ```
> *(若是 macOS 或使用 zsh，請將 `~/.bashrc` 替換為 `~/.zshrc`)*

#### 🔹 Windows（PowerShell 官方安裝腳本）
以 PowerShell 執行：
```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

#### 🔹 透過現有的 pip 或套件管理器安裝（通用）
```bash
# 使用 pip 安裝
pip install uv

# 或 macOS Homebrew
brew install uv

# 或 Windows WinGet
winget install --id=astral-sh.uv -e
```

#### 🔍 驗證安裝是否成功
```bash
uv --version
# 若輸出如 uv 0.x.x 代表安裝成功！
```

---

### 2. 建立獨立虛擬環境（.venv）
在終端機進入您的專案目錄（如 `notebook2`），執行以下指令：

```bash
# 建立名為 .venv 的獨立虛擬環境
uv venv .venv
```

---

### 3. 在虛擬環境中安裝 `ipykernel`
要讓 Jupyter Notebook 能辨識並切換到此虛擬環境，必須在該環境內安裝 `ipykernel`：

```bash
# 使用 uv 在 .venv 中高速安裝 ipykernel
uv pip install --python .venv/bin/python ipykernel
```

---

### 4. 將環境註冊為自訂 Jupyter Kernel（例如命名為 `16S`）
預設情況下 Antigravity IDE 會將環境顯示為 `.venv`，若有多個專案容易混淆。將其正式註冊並命名（如 `16S`、`RNA-seq`、`ML-Project`）能讓選單清晰明瞭：

```bash
# 將 .venv 註冊為自訂名稱的 Jupyter Kernel（以 16S 為例）
.venv/bin/python -m ipykernel install --user --name 16S --display-name "16S"
```

> 💡 **實用管理指令**：
> ```bash
> # 查詢目前系統已註冊的所有 Kernel
> jupyter kernelspec list
> 
> # 移除不再使用的舊 Kernel
> jupyter kernelspec uninstall 16S
> ```

---

### 5. 在 Antigravity IDE Notebook 中選取 Kernel
1. 開啟任何 `.ipynb` 筆記本。
2. 點擊畫面右上角的 **「Select Kernel（選擇核心）」** 按鈕。
3. 您可以透過以下任一方式選取：
   * **方式 A（推薦，使用自訂名稱）**：點選 **「Jupyter Kernel...」** ➔ 選擇剛剛註冊的 **`16S`**。
   * **方式 B（使用 Python 環境）**：點選 **「Python Environments...」** ➔ 選擇 **`.venv (Python 3.x.x)`**。
4. 右上角顯示 **`16S`**（或 `.venv`）即代表環境已成功切換！

---

## 第四章：在 Jupyter Cell 中直接使用 uv 安裝 Python 套件

在編寫 Notebook 的過程中，若發現缺少某個套件，不需要中斷工作切換到外面終端機，可以直接在 Cell 內安裝！

### 1. 在 Cell 內高速安裝套件
在 Notebook 的程式碼 Cell 中輸入並執行以下指令（前方加上驚嘆號 `!` 執行 Shell 指令）：

```python
# 使用 uv pip 安裝常見資料科學與分析套件
!uv pip install --python .venv/bin/python pandas numpy matplotlib seaborn
```

> 💡 **小撇步**：加上 `--python .venv/bin/python` 可百分之百確保套件準確安裝到當前 Notebook 綁定的虛擬環境中，避免裝到系統 Python。

---

### 2. 一鍵安裝生物資訊 / 特殊領域套件範例
例如分析 16S 微生物多樣性或機器學習常用工具：

```python
!uv pip install --python .venv/bin/python scipy scikit-learn biom-format openpyxl
```

---

### 3. 立即驗證套件是否安裝成功
在下一個 Cell 內直接 import 驗證：

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

print(f"Pandas 版本: {pd.__version__}")
print("環境配置與套件載入成功！🎉")
```

---

## 🎯 總結與最佳實踐
1. **主題隨心切換**：善用第二章提供的 Prompt，隨時請 AI 根據當前光線調整適合的 Notebook 配色。
2. **專案環境隔離**：每個專案透過 `uv venv` 建立獨立 `.venv`，搭配 `ipykernel` 讓依賴清晰不打架。
3. **極速套件擴充**：在 Cell 內直接使用 `!uv pip install`，省時又高效！
