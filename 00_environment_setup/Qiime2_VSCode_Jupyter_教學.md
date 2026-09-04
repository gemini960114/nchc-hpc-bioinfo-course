# QIIME 2 官方教學頁面 → Antigravity IDE 可執行 Notebook 教學文件

本文件記錄「把 QIIME 2 官方線上教學（例如 [Moving Pictures tutorial](https://amplicon-docs.qiime2.org/en/stable/tutorials/moving-pictures/)）
轉成一份可以在 Antigravity IDE 裡直接執行的 `.ipynb`」的完整流程，包含環境安裝、kernel 註冊，
以及實際操作中遇到的兩個常見問題與解法。

前置的 Miniconda / QIIME2 conda 環境安裝步驟，請先參考另一份文件：
[conda_miniconda_qiime2_install.md](conda_miniconda_qiime2_install.md)

---

## 1. 整體流程總覽

1. 在 `/work/$USER/Miniconda` 安裝 Miniconda，建立專屬的 QIIME2 conda 環境（例如 `rachis-qiime2-2026.7`）。
2. 在該環境裡安裝 `ipykernel`，並註冊成 Jupyter kernel，讓 Antigravity IDE 可以選用。
3. 把 QIIME 2 官方教學頁面的內容（文字＋指令）整理成一份 `.ipynb`：
   - 每個章節標題、說明文字、Question 提示 → 寫成 **markdown cell**
   - 每個 `qiime ...` / `wget` / `unzip` 等 shell 指令 → 寫成 **`%%bash` code cell**
4. 用 Antigravity IDE 打開這份 notebook，切換到剛剛註冊的 kernel，依序執行 cell。

---

## 2. 建立 conda 環境並註冊成 Jupyter kernel

```bash
# 啟用 conda
source /work/$USER/Miniconda/bin/activate

# 若尚未接受 Anaconda 頻道服務條款（只需執行一次）
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# 依官方 yml 建立 QIIME2 環境（以 2026.7 版為例）
conda env create \
  --name rachis-qiime2-2026.7 \
  --file https://raw.githubusercontent.com/qiime2/distributions/refs/heads/dev/2026.7/qiime2/released/rachis-qiime2-linux-64-conda.yml

# 測試安裝
conda activate rachis-qiime2-2026.7
qiime info

# 安裝 ipykernel 並註冊成 Jupyter kernel
conda install -y ipykernel
python -m ipykernel install --user --name rachis-qiime2-2026.7 --display-name "QIIME2 (2026.7)"
```

> **重點提醒：** 新版 conda 已內建 `libmamba` solver，速度跟 `mamba`相當，且 **QIIME2 官方建議不要用 mamba 安裝**
> （mamba 的 solver 有時會裝出版本不相容、難以追查的環境）。照官方指令用 `conda` 就好。

---

## 3. 把官方教學頁面轉成 `.ipynb` 的方法

實際操作方式：把 QIIME 2 官方教學頁面（例如 Moving Pictures tutorial）的內容整段複製貼上，
請 AI 助手（如本次使用的 Claude）依照頁面章節結構，逐段轉寫成 notebook：

- 頁面中的章節標題（Background、Sample metadata、Demultiplexing…）→ 對應的 markdown cell 標題
- 頁面中每一段 `[Command Line]` 的 shell 指令區塊 → 一個獨立的 `%%bash` code cell
- 頁面中的 `Question.` 提示框 → 寫成 markdown 的 blockquote，保留讓使用者練習時思考
- notebook 的 kernelspec metadata 直接指定成第 2 步驟註冊的 kernel（`name` 與 `display_name` 對應）

這樣產生的 notebook 可以照著章節順序，一個 cell 一個 cell 執行，跟照著官方網頁操作終端機的體驗一致。

---

## 4. 常見問題一：Antigravity IDE 裡切換 kernel 卻找不到新裝的 kernel

**現象：** 在 conda 環境裡執行完 `python -m ipykernel install --user --name ... --display-name ...` 後，
notebook 右上角的 kernel 選單卻沒有出現新的選項。

**原因排查：**
- 用 `jupyter kernelspec list` 確認 kernel 是否真的有註冊成功（通常會列在
  `~/.local/share/jupyter/kernels/<name>/kernel.json`）。如果這裡看得到，代表**後端安裝沒問題**，
  問題出在前端（Antigravity IDE）還沒重新掃描清單。

**解法：**
1. 點 notebook 右上角的 kernel 選擇器 → 不要只看預設清單，要先選 **「Select Another Kernel...」**
2. 再選 **「Jupyter Kernel...」**（而不是「Python Environments...」），新註冊的 kernel 才會顯示出來。
3. 如果還是看不到，執行 Antigravity IDE 命令面板（`Ctrl+Shift+P`）→ **「Developer: Reload Window」** 強制重新整理。

> 這次實際操作中，問題就是卡在「沒有先點 Select Another Kernel 再進 Jupyter Kernel 分類」，
> 選對路徑後 kernel 馬上就出現了。

---

## 5. 常見問題二：`%%bash` cell 執行 `qiime` 出現 `command not found`（exit code 127）

**現象：**

```
CalledProcessError: Command 'b'...\nqiime info\n'' returned non-zero exit status 127.
```

**原因：**
`%%bash` 這個 magic 會開一個全新的 subshell 來執行指令。這個 subshell 的 `PATH` 環境變數，
是繼承自「啟動這個 Jupyter kernel process 的外層程式」（也就是 Antigravity IDE 本身），
**不是**繼承自你之前手動 `source .../activate` 過的那個 terminal shell。

所以即使這個 kernel 本身用的就是 QIIME2 conda 環境的 Python（`sys.executable` 是對的），
subprocess 呼叫外部指令（如 `qiime`）時，因為 `PATH` 沒包含該環境的 `bin/` 目錄，還是會找不到指令。

**解法：** 在 notebook 最前面加一個 Python setup cell，把目前 kernel 所在環境的 `bin/` 目錄
動態加進 `PATH`，這樣同一個 kernel session 裡，之後所有 `%%bash` cell 都會自動繼承到正確的 `PATH`，
不需要每個 cell 都重新 `source activate`：

```python
import os, sys

env_bin = os.path.dirname(sys.executable)
if env_bin not in os.environ["PATH"].split(os.pathsep):
    os.environ["PATH"] = env_bin + os.pathsep + os.environ["PATH"]

print("kernel python:", sys.executable)
print("PATH now starts with:", os.environ["PATH"].split(os.pathsep)[0])
```

> 這個 cell 必須放在 notebook **最前面**、且是**第一個被執行**的 cell，之後每次重啟 kernel
> 都要記得先跑這個 cell 一次。

---

## 6. 檢查清單（每次開新的 QIIME2 notebook 前）

- [ ] `conda env list` 確認 QIIME2 環境存在
- [ ] `jupyter kernelspec list` 確認對應 kernel 已註冊
- [ ] Antigravity IDE 切 kernel 時走 **Select Another Kernel → Jupyter Kernel** 這條路徑
- [ ] notebook 第一個 code cell 是 PATH 修正 cell，且已經執行過
- [ ] 第二個 code cell（`qiime info`）能正常印出版本資訊，代表環境串接成功

---

## 7. 這台主機的補充提醒（共用 Login Node）

這台機器是多人共用的 login node（可用 `top` / `w` 觀察到同時有 20 幾位使用者）。
建議：

- 輕量測試（如 `qiime info`、小範圍指令）可以直接在 login node 上跑。
- 真正吃資源的步驟（例如 DADA2 `denoise-single`、訓練分類器 `fit-classifier-naive-bayes`）
  執行時間較長、耗 CPU/記憶體，建議改用 job scheduler（Slurm/PBS，視此主機實際安裝的排程系統）
  送到 compute node 執行，避免佔用其他使用者共用的登入節點資源。
