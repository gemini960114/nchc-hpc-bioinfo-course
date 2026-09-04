# SLURM 排程腳本撰寫教學 — 以 QIIME2 Pipeline 為實作範例

本文件教你如何撰寫 SLURM job script、如何把一份分析流程（這裡用
[run_qiime2_pipeline.sh](run_qiime2_pipeline.sh)）拆成「邏輯腳本 + SLURM 派送腳本」兩層架構，
以及送出後如何監控、除錯。範例會直接引用我們在這台機器（台灣杉三號 GP1 生醫節點）上實際跑過的檔案。

前置文件：
- [TWCC_Taiwania3_GP1生醫節點_使用手冊.md](../00_environment_setup/TWCC_Taiwania3_GP1生醫節點_使用手冊.md) — partition 表、費率、儲存空間規範
- [Qiime2_VSCode_Jupyter_教學.md](../00_environment_setup/Qiime2_VSCode_Jupyter_教學.md) — QIIME2 環境安裝與 notebook 除錯

---

## 1. 為什麼要用 SLURM，而不是直接在終端機跑

- 這台機器是**多人共用的 login node**，直接在 login node 跑計算會影響其他 20 幾位使用者，也影響排程系統本身效能（見手冊第 2 節）。
- SLURM 負責把你的工作**排隊、分配到 compute node 執行**，跑完自動釋放資源，過程中你不需要一直開著終端機盯著。
- 工作跑在背景，就算你關閉 Antigravity IDE / 中斷 SSH 連線，工作依然會繼續執行。

---

## 2. SLURM Script 基本語法

一份 SLURM job script 本質上就是一個 shell script，差別在於開頭多了一段 `#SBATCH` 開頭的**資源宣告註解**（SLURM 會解析這些特殊註解，其他 shell 不會理它們，所以腳本本身仍然是合法的 bash 檔）。

```bash
#!/usr/bin/sh
#SBATCH -A <計畫代號>
#SBATCH -J <Job名稱>
#SBATCH -p <Partition>
#SBATCH -c <核心數>
#SBATCH --mem=<記憶體>
#SBATCH -o <標準輸出log路徑>
#SBATCH -e <標準錯誤log路徑>
#SBATCH --mail-user=<你的信箱>
#SBATCH --mail-type=<通知時機>

# 以下才是真正會被執行的 shell 指令
```

### 常用 `#SBATCH` 參數對照表

| 參數 | 意義 | 範例 |
|---|---|---|
| `-A` | 計畫代號（帳務歸屬） | `-A MST109178` |
| `-J` | Job 名稱，方便 `squeue` 辨識 | `-J qiime2_pipeline` |
| `-p` | Partition（佇列），決定資源上限與計費 | `-p ngs53G` |
| `-c` | 要求的 CPU 核心數 | `-c 8` |
| `--mem` | 要求的記憶體 | `--mem=53g` |
| `--gres=gpu:N` | 要求 N 張 GPU（GPU partition 才需要） | `--gres=gpu:1` |
| `-o` / `-e` | 標準輸出 / 標準錯誤輸出的檔案路徑 | `-o logs/out_%j.log` |
| `--mail-user` / `--mail-type` | 工作開始/結束時 email 通知 | `--mail-type=BEGIN,END` |
| `--array=1-N` | 陣列工作，一次送 N 個相同邏輯、不同輸入的工作 | `--array=1-10` |

> **`-c` 與 `--mem` 不是隨便填的**：每個 partition 都有固定的核心數/記憶體搭配（見手冊第 6.1 節的 partition 表），
> 例如 `ngs53G` 就是固定 `-c 8 --mem=53g`，填錯搭配工作會送不出去或被拒絕。

> **`%j`** 是 SLURM 的萬用字元，代表這次工作的 Job ID，寫在 log 檔名裡（`out_%j.log`）可以避免每次重跑
> 都互相覆蓋前一次的 log，方便追蹤歷史紀錄。

---

## 3. 架構設計：邏輯腳本 vs SLURM 派送腳本

與其把所有分析指令直接塞進 SLURM script，我們拆成兩個檔案：

```
run_qiime2_pipeline.sh      ← 純分析邏輯，不含任何 #SBATCH
slurm_qiime2_pipeline.sh    ← 只有資源宣告 + 呼叫 run_qiime2_pipeline.sh
```

**為什麼要拆開？**

1. **可獨立測試**：`run_qiime2_pipeline.sh` 是普通 bash script，可以先在互動節點上
   （例如 `salloc` 拿到的 shell）小規模測試、除錯，確認沒問題後再交給 SLURM 排程執行，
   不需要每次改一行就重新 `sbatch` 排隊等待。
2. **職責分離**：以後要換 partition（例如從 `ngs53G` 換成 `ngs92G`）、調整通知信箱，
   只需要改 `slurm_qiime2_pipeline.sh`，完全不會動到分析邏輯本身，降低改錯的風險。
3. **可重複使用**：同一份 `run_qiime2_pipeline.sh` 未來也可以被別的 SLURM 派送腳本引用
   （例如換成 GPU partition 版本），不用複製貼上整段分析邏輯。

### 3.1 `run_qiime2_pipeline.sh`（邏輯腳本）逐段說明

```bash
#!/usr/bin/env bash
set -euo pipefail
```
- `set -euo pipefail` 是防呆三劍客：
  - `-e`：任何指令失敗（exit code 非 0）就立即中止整個腳本，不會靜默跳過錯誤繼續往下跑。
  - `-u`：使用到未定義的變數會直接報錯，避免打錯變數名稱卻沒發現。
  - `-o pipefail`：管線（`|`）中間任何一段失敗，整條管線就算失敗（預設 bash 只看最後一段的結果）。

```bash
WORKDIR="/work/c00cjz00/notebook/qiime2-moving-pictures-tutorial"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"
```
- 先切到固定的工作目錄，之後所有相對路徑的輸出檔案都會集中在這裡，跟 notebook 版本的行為一致。

```bash
echo "=== [1/10] Sample metadata ==="
wget -N -O 'sample-metadata.tsv' '...'
```
- 每個階段前印出 `echo "=== [N/10] ... ==="`，這是**除錯時最有用的技巧之一**：
  出錯時只要看 log 印到哪一個階段標題，就能立刻定位問題發生在流程的哪一步，不用整份 log 從頭找。

之後每一段就是把 notebook 裡每個 `%%bash` cell 的內容原封不動搬過來，依照官方教學章節順序（1~10）排列。

### 3.2 `slurm_qiime2_pipeline.sh`（SLURM 派送腳本）逐段說明

```bash
#!/usr/bin/sh
#SBATCH -A MST109178
#SBATCH -J qiime2_pipeline
#SBATCH -p ngs53G
#SBATCH -c 8
#SBATCH --mem=53g
#SBATCH -o logs/out_%j.log
#SBATCH -e logs/err_%j.log
#SBATCH --mail-user=0203126@niar.org.tw
#SBATCH --mail-type=BEGIN,END

source /work/c00cjz00/Miniconda/bin/activate rachis-qiime2-2026.7

bash /work/c00cjz00/notebook/run_qiime2_pipeline.sh
```

- `source .../activate <env>`：SLURM 分配到的 compute node 是全新的 shell 環境，
  **不會**自動繼承你在 login node 手動 `conda activate` 過的狀態，所以每個 SLURM script
  裡都要重新啟用一次 conda 環境，否則會找不到 `qiime` 指令（跟我們之前在 Antigravity IDE `%%bash` cell
  遇到的 PATH 問題原理相同，見 [Qiime2_VSCode_Jupyter_教學.md](../00_environment_setup/Qiime2_VSCode_Jupyter_教學.md) 第 5 節）。
- 最後一行只是單純呼叫邏輯腳本，SLURM 派送腳本本身不含任何分析細節。

> **注意：** `-o logs/out_%j.log` 是相對路徑，SLURM 會以「你執行 `sbatch` 當下的工作目錄」為基準去找 `logs/`，
> 所以送出前一定要先 `mkdir -p logs`，並且在正確的目錄下執行 `sbatch`。

---

## 4. 送出與監控工作

```bash
cd /work/c00cjz00/notebook
sbatch slurm_qiime2_pipeline.sh
# Submitted batch job 2030402
```

**查看排隊狀態：**

```bash
squeue -u $USER
```

輸出範例：
```
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
           2030402    ngs53G qiime2_p c00cjz00  R       0:20      1 cpn3859
```
- `ST` 欄位：`PD` = Pending（排隊中）、`R` = Running（執行中）
- `NODELIST(REASON)`：Running 時顯示實際跑在哪個節點（例如 `cpn3859`）；Pending 時會顯示等待原因

**查看工作詳細設定（確認資源有沒有設對）：**

```bash
scontrol show job 2030402
```

**即時查看目前輸出到哪裡：**

```bash
tail -f logs/out_2030402.log
tail -f logs/err_2030402.log
```

**取消工作：**

```bash
scancel -i 2030402
```

**工作結束後查資源使用量（確認有沒有浪費資源、下次可以調整 partition）：**

```bash
sacct -j 2030402 -o JobID,JobName,Partition,NCPUS,MaxRSS,Start,End,Elapsed,State,ExitCode
```

---

## 5. 除錯技巧（Debugging）

### 5.1 先看 log 印到哪個階段標題
因為 `run_qiime2_pipeline.sh` 每步都有 `echo "=== [N/10] ... ==="`，
出錯時打開 `out_<jobid>.log`，看最後印出的階段標題，就能知道是卡在哪一步（下載？匯入？DADA2？分類器訓練？）。

### 5.2 常見錯誤模式對照

| 現象 | 常見原因 | 解法 |
|---|---|---|
| `qiime: command not found`（exit 127） | SLURM script 忘記 `source activate` 對應 conda 環境 | 在 `#SBATCH` 區塊後面補上 `source .../activate <env>` |
| Job 一直是 `PD`，`squeue` 顯示 `(Resources)` 或 `(QOSMaxJobsPerUserLimit)` | Partition 額滿，或個人 Job 數已達上限 | 用 `qstat -ngs` / `sinfo -s \| grep ngs` 查看該 partition 是否額滿，或換一個 partition |
| `sbatch: error: ...` 送出當下就失敗 | `-c`、`--mem` 跟 partition 規定的固定搭配不符 | 對照手冊 partition 表，修正參數組合 |
| log 檔案完全沒有產生 | `-o`/`-e` 用相對路徑，但送出 `sbatch` 時所在目錄不對，或 `logs/` 目錄不存在 | `mkdir -p logs` 後，確認在正確目錄下 `sbatch` |
| `wget`/`curl` 卡住或 `Connection timed out` | Compute node 沒有直接對外網路（本機經實測 `cpn3859`、`cpn3852` 皆連不到外網） | **在 SLURM script 裡設定 proxy**（本機實測有效，見下方 5.2.1），不必再繞回 login node 手動下載 |
| 中途某步驟輸入檔案 `.qza` 找不到 | 前一步驟其實失敗了，但沒有 `set -e` 導致腳本繼續往下跑 | 確認腳本開頭有 `set -euo pipefail` |
| `qiime ... --output-dir <dir>` 報錯 `Invalid value for '--output-dir'` | 該目錄已存在（QIIME2 的 `--output-dir` 拒絕寫入既有目錄，避免覆蓋），常發生在重複執行同一腳本時 | 在該指令前加 `rm -rf <dir>`，讓腳本可重複執行（見 [run_qiime2_pipeline.sh](run_qiime2_pipeline.sh) 第 7 步的寫法） |
| Notebook 手動跑到一半突然報錯（如 metadata 檔案讀不到內容） | 跟同時在跑的 SLURM job 共用同一個工作目錄，job 裡的 `wget -O` 覆寫/截斷了正在被讀取的檔案 | 手動探索用的工作目錄跟 SLURM 自動化用的工作目錄要分開（例如 `xxx/` vs `xxx-slurm/`），不要共用同一份資料 |

#### 5.2.1 本機實測有效的 proxy 設定

本機（台灣杉三號 GP1 生醫節點）的 compute node 需要透過 login node 開的 proxy 才能連外網，
在 SLURM script 裡 `source activate` 之前加上：

```bash
export http_proxy=http://lgn304-v304:53128
export https_proxy=http://lgn304-v304:53128
```

即可讓 `wget`/`curl`/`pip install` 等對外連線指令正常運作。[slurm_qiime2_pipeline.sh](slurm_qiime2_pipeline.sh) 已內建這兩行設定。

### 5.3 背景監控技巧

工作跑很久時（DADA2 denoise、訓練分類器都要幾分鐘到十幾分鐘），與其一直手動 `squeue` 查看，
可以寫一個簡單的等待迴圈，直到 log 出現關鍵錯誤字樣或工作結束才通知自己：

```bash
until ! squeue -j <jobid> -h -o "%T" | grep -q .; do
  sleep 30
  if grep -qiE "error|traceback|command not found|no such file|permission denied|failed" \
      logs/out_<jobid>.log logs/err_<jobid>.log 2>/dev/null; then
    echo "DETECTED POSSIBLE ERROR"
    break
  fi
done
```

這個迴圈會每 30 秒檢查一次：工作是否已經離開排程佇列（代表結束），或者 log 裡是否出現常見錯誤關鍵字，
只要符合其中一個條件就跳出迴圈，不用一直盯著螢幕。

---

## 6. 檢查清單（每次送 SLURM 工作前）

- [ ] `mkdir -p logs`（log 輸出目錄已存在）
- [ ] `-c` / `--mem`（/ `--gres`）跟選定的 partition 規定搭配一致
- [ ] SLURM script 裡有 `source .../activate <env>`，不依賴 login node 的環境
- [ ] 邏輯腳本開頭有 `set -euo pipefail`
- [ ] 邏輯腳本每個階段都有印出進度標題，方便事後從 log 定位問題
- [ ] 確認在正確的工作目錄下執行 `sbatch`（相對路徑的 log/輸出檔案位置才會對）
