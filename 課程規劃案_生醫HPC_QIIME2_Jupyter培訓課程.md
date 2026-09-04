# 課程規劃案：生醫 HPC 環境下的 QIIME2 × Jupyter × SLURM 實作培訓

> 本規劃案盤點 `class/` 課程資料夾內已產出的所有教學文件與程式碼，
> 分析彼此關係、涵蓋範圍與落差，並據此提出一套可直接開課的課程大綱。
>
> 對應課程資料夾索引：[README.md](README.md)（Module 0～3 的檔案總覽，本文件則是更細顆粒度的逐時段教案）

---

## 1. 現有教材盤點（Content Audit）

| 檔案 | 類型 | 涵蓋主題 | 定位 |
|---|---|---|---|
| [Jupyter_Notebook_Tutorial.md](00_environment_setup/Jupyter_Notebook_Tutorial.md) | md | VS Code Jupyter 擴充套件安裝、主題客製化、`uv` + venv + ipykernel、cell 內裝套件 | 通用 Jupyter 入門（**未涉及 conda / HPC**） |
| [conda_miniconda_qiime2_install.md](00_environment_setup/conda_miniconda_qiime2_install.md) | md | Miniconda 安裝、ToS 接受、QIIME2 conda 環境建立、ipykernel 註冊、conda vs mamba 建議 | QIIME2 環境安裝 SOP |
| [Qiime2_VSCode_Jupyter_教學.md](00_environment_setup/Qiime2_VSCode_Jupyter_教學.md) | md | 把官方 QIIME2 教學頁面轉成 notebook 的方法、VS Code kernel 選擇問題、`%%bash` PATH 問題 | 環境安裝 → notebook 實際可跑的橋接層 |
| [TWCC_Taiwania3_GP1生醫節點_使用手冊.md](00_environment_setup/TWCC_Taiwania3_GP1生醫節點_使用手冊.md) | md | 帳號/計畫申請、登入、儲存空間與費率、模組系統、SLURM partition 表、job script、常用查詢、桌面環境、RAPIDS（含 Singularity GPU 容器範例）/Parabricks/AlphaFold2 | 平台總覽手冊（範圍最廣，資訊密度最高） |
| [01_FastQC_MultiQC_教學.md](01_fastqc_multiqc/01_FastQC_MultiQC_教學.md) + [01_fastqc_multiqc_demo.ipynb](01_fastqc_multiqc/01_fastqc_multiqc_demo.ipynb) | md + ipynb | 用模擬 FASTQ 資料跑 FastQC + MultiQC，練習判讀 QC 報告 | 分析前置作業的第一課，取代原本的文字接龍範例 |
| [SLURM_腳本撰寫教學_QIIME2實作範例.md](02_qiime2_moving_pictures/SLURM_腳本撰寫教學_QIIME2實作範例.md) | md | SLURM script 語法、pipeline 腳本與 SLURM 派送腳本分離架構、送出/監控/除錯指令 | SLURM 專項深化教學，後續 HUMAnN3 模組沿用同一套架構 |
| [qiime2_moving_pictures_tutorial.ipynb](02_qiime2_moving_pictures/qiime2_moving_pictures_tutorial.ipynb) | ipynb | QIIME2 官方 Moving Pictures tutorial 全流程（10 章節，DADA2/Deblur 可選） | 互動式實作教材主體（主線） |
| [run_qiime2_pipeline.sh](02_qiime2_moving_pictures/run_qiime2_pipeline.sh) / [slurm_qiime2_pipeline.sh](02_qiime2_moving_pictures/slurm_qiime2_pipeline.sh) | script | 把 notebook 轉成可重複執行、可送 SLURM 的生產級腳本 | 從「互動探索」過渡到「自動化生產」的範例，已實測完整跑通（job 2030543，14分44秒，COMPLETED） |
| [03_Singularity_HUMAnN3_教學.md](03_singularity_humann3/03_Singularity_HUMAnN3_教學.md) + [03_humann3_demo.ipynb](03_singularity_humann3/03_humann3_demo.ipynb) + [run_humann3_pipeline.sh](03_singularity_humann3/run_humann3_pipeline.sh) / [slurm_humann3_pipeline.sh](03_singularity_humann3/slurm_humann3_pipeline.sh) | md + ipynb + script | 把 Docker Hub 容器轉成 Singularity，跑 HUMAnN3 功能性宏基因體分析，沿用 QIIME2 模組的 SLURM 分離式架構 | 補充模組：容器化生資工具 + SLURM，已實測完整跑通（job 2030736，70秒，COMPLETED） |
| [00_environment_setup/快速上手.md](00_environment_setup/快速上手.md) | md | 三步驟登入→選 kernel→跑分析，遇到問題查對照表 | 給「環境已經裝好、只想趕快跑分析」的人看的懶人包，不用先讀完 Module 0 其他四份完整文件 |
| [02_qiime2_moving_pictures/QIIME2_結果解讀指南.md](02_qiime2_moving_pictures/QIIME2_結果解讀指南.md) | md | Alpha/beta diversity、taxonomy barplot、ANCOM-BC 的生物學解讀，對照 Moving Pictures 資料集本身的實驗設計（抗生素擾動 + 恢復）解讀 | 補齊「分析為重」定位下最重要的一塊：不只會跑指令，還看得懂結果 |
| [03_singularity_humann3/HUMAnN3_結果解讀指南.md](03_singularity_humann3/HUMAnN3_結果解讀指南.md) | md | Gene family/pathway abundance 解讀、用本次實測的真實 demo 數字示範判讀、QIIME2 vs HUMAnN3 使用時機比較 | 同上，HUMAnN3 版本 |
| [jobscript_ngs53G.sh](../jobscript_ngs53G.sh) | script | 單一 partition 的 SLURM script 範例 | 已被 `run_qiime2_pipeline.sh` + `slurm_qiime2_pipeline.sh` 取代，維持放在 `class/` 外層當作過時草稿，不建議參考 |

**真實除錯案例（已全部落成教材，不再是「隱性知識」）：**

| 案例 | 記錄位置 |
|---|---|
| VS Code kernel 選單裝好卻找不到新 kernel | [Qiime2_VSCode_Jupyter_教學.md](00_environment_setup/Qiime2_VSCode_Jupyter_教學.md) 第 4 節 |
| `%%bash` cell 找不到 `qiime`（exit 127，PATH 不繼承 conda activate） | [Qiime2_VSCode_Jupyter_教學.md](00_environment_setup/Qiime2_VSCode_Jupyter_教學.md) 第 5 節 |
| Compute node 完全連不到外網，需要設定 proxy | [SLURM_腳本撰寫教學_QIIME2實作範例.md](02_qiime2_moving_pictures/SLURM_腳本撰寫教學_QIIME2實作範例.md) 第 5.2.1 節 |
| `qiime ... --output-dir` 目錄已存在導致報錯 | [SLURM_腳本撰寫教學_QIIME2實作範例.md](02_qiime2_moving_pictures/SLURM_腳本撰寫教學_QIIME2實作範例.md) 第 5.2 節 |
| 手動 notebook 操作跟 SLURM job 共用目錄互相覆寫檔案 | [SLURM_腳本撰寫教學_QIIME2實作範例.md](02_qiime2_moving_pictures/SLURM_腳本撰寫教學_QIIME2實作範例.md) 第 5.2 節 |
| MultiQC 執行出現無害的 `_ARRAY_API not found` 警告 | [01_FastQC_MultiQC_教學.md](01_fastqc_multiqc/01_FastQC_MultiQC_教學.md) 第 5 節 |
| HUMAnN3 預設會嘗試下載 39GB 的 MetaPhlAn 資料庫 | [03_Singularity_HUMAnN3_教學.md](03_singularity_humann3/03_Singularity_HUMAnN3_教學.md) 第 5.1 節 |

這 7 個案例都是真的在這台機器上操作時踩到、驗證過解法的，不是憑空編的練習題，出情境題時可以直接引用。

---

## 2. 落差分析（Gap Analysis）

| 缺口 | 說明 | 建議處理方式 | 狀態 |
|---|---|---|---|
| 沒有「為什麼是 QIIME2 / 16S 分析」的背景理論模組 | 現有教材直接進入操作，沒有先建立微生物體分析的基礎概念（OTU/ASV、alpha/beta diversity 的生物意義等） | 已新增 [QIIME2_結果解讀指南.md](02_qiime2_moving_pictures/QIIME2_結果解讀指南.md) 用「跑完之後對照解讀」的方式補上核心概念，不用額外排一段理論投影片時間 | 🟡 部分解決（用結果解讀取代正式理論課，若要更完整仍可額外補投影片） |
| conda 與 uv 兩套環境管理方式並存，未說明取捨 | `Jupyter_Notebook_Tutorial.md` 用 `uv`，其餘教材用 `conda` | 已在 README 與 `Qiime2_VSCode_Jupyter_教學.md` 明確寫出取捨原則 | ✅ 已解決 |
| 除錯案例未文件化 | 原本 5 個真實踩坑案例只存在對話紀錄 | 已全數整理進對應模組文件的除錯章節，並在 README、本文件第 1 節彙整成對照表（現已擴增為 7 個案例） | ✅ 已解決 |
| 沒有費用/計費意識的實作練習 | 手冊有費率表，但沒有讓學員實際計算「這次跑的 job 花了多少 SU」的練習 | 用 `sacct` 查出的 `Elapsed × NCPUS` 搭配費率表，設計一個計費計算練習 | ⬜ 未處理 |
| 沒有「何時該用 login node、何時該用 SLURM」的具體判斷練習 | 手冊有規則說明，但偏原則性 | 用真實案例（手動跑 notebook vs SLURM 自動化互相覆寫檔案那次）當教材，讓學員判斷分類 | ⬜ 未處理 |
| ANCOM-BC / 分類器等進階統計方法缺乏原理說明 | notebook 只給指令跟 Question，沒有解釋方法論 | [QIIME2_結果解讀指南.md](02_qiime2_moving_pictures/QIIME2_結果解讀指南.md) 第 4 節已說明 ANCOM-BC 的參考組、compositional data 限制等核心概念；分類器原理（Naive Bayes 訓練機制）仍未涵蓋 | 🟡 部分解決 |
| 沒有涵蓋資料安全 / 分享權限實作練習 | 手冊有 `setfacl` 指令，但沒有實際演練 | 可在課程最後加一個「跟同組夥伴分享分析結果」的小練習 | ⬜ 未處理 |
| **（新增）FastQC/HUMAnN3 兩個模組還沒排進正式課程時段** | 這兩個模組是後來才補上的，§4 課程大綱最初沒算進這兩段時間 | 本次更新已將兩者排入大綱（Module 4、Module 7），並重新估算總時數 | ✅ 本次已解決 |
| **（新增）新增兩模組後總時數超過原訂 6 小時** | 加入 FastQC（30分）與 Singularity/HUMAnN3（45分）後，總時數來到約 7.75 小時 | 建議拆成一天半，或把 Singularity/HUMAnN3 模組列為選修（見 §3、§4） | ⬜ 待課程籌備者決定 |
| **（新增）Module 0 環境設定教材偏長，跟「HPC 操作簡易為主」的定位有落差** | 四份完整文件份量不小，對只想跑分析的人門檻偏高 | 已新增 [快速上手.md](00_environment_setup/快速上手.md)，三步驟講完最短路徑，詳細文件留作參考不強制全讀 | ✅ 本次已解決 |

---

## 3. 課程定位與對象

- **課程名稱（暫定）**：《生醫 HPC 實戰：用 QIIME2 + Jupyter + SLURM 跑一次完整的微生物體分析（含 QC 與容器化工具）》
- **對象**：已具備基礎 Linux/命令列操作經驗、需要在國網中心台灣杉三號 GP1 生醫節點上執行 16S/宏基因體分析的研究人員或研究助理
- **先備知識**：
  - 基本 shell 指令（`cd`、`ls`、`wget` 等）
  - 對「什麼是虛擬環境」有基本概念（不要求精通）
  - 不要求 QIIME2 / SLURM / Singularity 先備知識（本課程從零帶起）
- **課程形式**：講解 + 現場實作（Bring Your Own Laptop，透過 VS Code Remote-SSH 連進 T3），全程用真實帳號跑一次完整流程
- **建議總時數**：約 7.75 小時。兩種排法擇一：
  - **一天半**（推薦）：第一天上到 Module 6（SLURM 排程實戰），第二天上午收尾 Module 7（Singularity/HUMAnN3）+ Module 8（總結）
  - **一天（壓縮版）**：把 Module 4（FastQC/MultiQC）與 Module 7（Singularity/HUMAnN3）列為**選修/課後自學教材**（教材本身已經是可獨立自學的完整單元，不強制排在課堂時段內），課堂只上核心的 Module 0~3、5、6、8，壓回約 6 小時

---

## 4. 課程大綱（對應現有教材）

### Module 0｜環境準備（30 分鐘，課前作業 + 開場檢查）
- 目標：確保每位學員在開課前就能用 VS Code 連上 T3 並開啟 `.ipynb`
- 教材：[Jupyter_Notebook_Tutorial.md](00_environment_setup/Jupyter_Notebook_Tutorial.md) 第一章（VS Code Jupyter 擴充套件安裝）
- 課前作業：安裝 `ms-toolsai.jupyter` / `ms-python.python`，並確認能開啟一個測試 notebook

### Module 1｜認識這台超級電腦（45 分鐘）
- 目標：知道去哪裡申請、怎麼登入、資料放哪裡、規則是什麼
- 教材：[TWCC_Taiwania3_GP1生醫節點_使用手冊.md](00_environment_setup/TWCC_Taiwania3_GP1生醫節點_使用手冊.md) 第 1~5 節、第 11 節
- 重點強調：**不要在 login node 跑計算**、**/work 沒有備份**、費率表怎麼看、**compute node 對外網路需要 proxy**
- 小練習：每人執行 `wallet`、`hfs-quota`，確認自己的計畫額度與儲存空間

### Module 2｜建立 QIIME2 環境並接上 Jupyter（60 分鐘）
- 目標：從零裝出一個能在 notebook 裡跑 `qiime` 的環境
- 教材：[conda_miniconda_qiime2_install.md](00_environment_setup/conda_miniconda_qiime2_install.md)
- 實作：Miniconda 安裝 → 接受 ToS → 建立 QIIME2 conda env → 裝 ipykernel → 註冊 kernel
- **穿插案例 1**：kernel 裝好卻在 VS Code 選單找不到 → 示範「Select Another Kernel → Jupyter Kernel」

### Module 3｜把官方教學轉成可執行 Notebook（45 分鐘）
- 目標：學會「不是每次都要別人給你 ipynb，自己能把官方文件轉成可跑的 notebook」
- 教材：[Qiime2_VSCode_Jupyter_教學.md](00_environment_setup/Qiime2_VSCode_Jupyter_教學.md)
- **穿插案例 2**：`%%bash` 執行 `qiime` 出現 `command not found`（exit 127）→ 講解 PATH 繼承原理，示範 PATH 修正 cell
- 動手：打開 [qiime2_moving_pictures_tutorial.ipynb](02_qiime2_moving_pictures/qiime2_moving_pictures_tutorial.ipynb)，執行前 3 章（metadata、匯入、demultiplex）

### Module 4｜FastQC + MultiQC 定序品質管控（30 分鐘）**新增**
- 目標：養成「分析前先看資料品質」的習慣，學會判讀 FastQC/MultiQC 報告
- 教材：[01_FastQC_MultiQC_教學.md](01_fastqc_multiqc/01_FastQC_MultiQC_教學.md) / [01_fastqc_multiqc_demo.ipynb](01_fastqc_multiqc/01_fastqc_multiqc_demo.ipynb)
- 動手：跑完 6 個模擬樣本的 FastQC + MultiQC，對照報告找出每個樣本被設計的品質問題
- 承上啟下：這一步概念上該接在 Module 3 demultiplex 之後、DADA2 denoise 之前（真實分析流程的順序），但因為用的是獨立模擬資料，教學上拆成獨立模組，不影響銜接

### Module 5｜完整跑一次 Moving Pictures Tutorial（90 分鐘，含休息）
- 目標：理解 QIIME2 完整分析流程的每個階段在做什麼
- 教材：[qiime2_moving_pictures_tutorial.ipynb](02_qiime2_moving_pictures/qiime2_moving_pictures_tutorial.ipynb) 全部 10 章
- 建議：DADA2 denoise、分類器訓練這類耗時步驟可以邊跑邊講解下一段理論，不用乾等
- 每章保留的 **Question** 提示可以當堂討論用，不用寫成正式作業

### Module 6｜從互動探索到自動化生產：SLURM 排程實戰（90 分鐘）
- 目標：學會把 notebook 流程轉成可重複執行、可排隊送出的生產級腳本
- 教材：[SLURM_腳本撰寫教學_QIIME2實作範例.md](02_qiime2_moving_pictures/SLURM_腳本撰寫教學_QIIME2實作範例.md)、[run_qiime2_pipeline.sh](02_qiime2_moving_pictures/run_qiime2_pipeline.sh)、[slurm_qiime2_pipeline.sh](02_qiime2_moving_pictures/slurm_qiime2_pipeline.sh)
- **穿插案例 3、4、5**（本課程最有價值的部分，建議作為 Live Debugging 示範，而非單純講解）：
  - 案例 3：compute node 連不到外網 → `srun --jobid=<id> --pty bash` 進節點測試 → 設定 proxy 解決
  - 案例 4：`--output-dir` 目錄已存在導致失敗 → 讀懂錯誤訊息、修腳本讓它可重複執行
  - 案例 5：手動 notebook 跟 SLURM job 共用目錄互相覆寫 → 設計獨立工作目錄的架構原則
- 實作：學員修改 `slurm_qiime2_pipeline.sh` 裡的 partition/資源設定，送出屬於自己的 job，用 `squeue`/`sacct` 追蹤

### Module 7｜Singularity 容器 + HUMAnN3（45 分鐘）**新增，可列選修**
- 目標：學會用容器解決「工具依賴太複雜、自己裝不動」的問題，並沿用 Module 6 的 SLURM 架構跑一個不同的分析工具
- 教材：[03_Singularity_HUMAnN3_教學.md](03_singularity_humann3/03_Singularity_HUMAnN3_教學.md) / [03_humann3_demo.ipynb](03_singularity_humann3/03_humann3_demo.ipynb)
- **穿插案例 6、7**：
  - 案例 6：HUMAnN3 預設會嘗試下載 39GB 的 MetaPhlAn 資料庫 → 用 `--bypass-prescreen` 解決，順便講解「demo 用縮小版資料庫、正式分析要換回完整版」的取捨
  - 對照 Module 1 提過的 RAPIDS 段落（TWCC 手冊），比較 Singularity 在互動式（GPU + Jupyter tunnel）跟批次式（HUMAnN3 + SLURM）兩種場景的用法差異
- 實作：學員修改 `slurm_humann3_pipeline.sh` 送出一次 SLURM job

### Module 8｜總結與 Q&A（30 分鐘）
- 檢查清單複習（SLURM 教學文件第 6 節、QIIME2 教學文件第 6 節）
- 開放討論：學員各自的分析資料要怎麼套用今天學的架構

---

## 5. 建議的實作練習 / 簡易評量

1. **環境檢查**：`jupyter kernelspec list` 截圖繳交，證明自己的 kernel 有正確註冊
2. **除錯情境題**（可直接用第 1 節列出的 7 個真實案例出題）：給一段錯誤訊息，讓學員判斷是哪一類問題、該怎麼修
3. **計費計算**：給定一個 `sacct` 輸出，讓學員算出這個 job 花了多少 SU（對照手冊費率表）
4. **QC 判讀**：給一份 MultiQC 報告（可直接用 Module 4 產生的），讓學員指出哪個樣本有問題、問題類型是什麼
5. **送出自己的 job**：修改 partition 為適合自己資料量的等級，成功送出並在 `logs/` 產生正確的輸出檔案即算過關（QIIME2 或 HUMAnN3 任一皆可）

---

## 6. 後續行動建議（給課程籌備者）

- [x] ~~把 5 個真實除錯案例整理成獨立案例集~~ —— 已改用「分散記錄在對應模組文件 + 在 README 和本文件彙整成對照表」的方式處理，不另外開新檔案（避免同一內容多處維護）
- [x] ~~統一說明 conda vs uv 的使用場景~~ —— 已寫入 README 與 `Qiime2_VSCode_Jupyter_教學.md`
- [ ] `jobscript_ngs53G.sh` 已被分離式架構取代，目前維持放在 `class/` 外層當草稿，**建議在確認沒人再參考後直接移除**
- [ ] 若學員程度較高，可設計選修模組深入 ANCOM-BC、分類器訓練的統計原理
- [ ] 確認開課當天的 partition（如 `ngsTest`／`ngs53G`）在該時段有空餘資源，避免全班同時送 job 卡在排隊
- [ ] **（新增）跟課程籌備者確認**：一天半 vs 一天壓縮版，兩種時數規劃選哪一種（見 §3）
- [ ] **（新增）Module 4、Module 7 的定位**：若選一天壓縮版，這兩個模組的教材品質已經是可獨立自學的完整單元（各自的 `.md` 有完整原理說明 + 已實測過的 notebook），可以直接當課後指定閱讀，不用擔心自學品質打折扣
