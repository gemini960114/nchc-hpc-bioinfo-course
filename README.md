# Class 課程資料夾

`class/` 是這門課程的**根目錄**：所有教材（先備知識、主線範例、補充範例）都收在這裡，
照編號資料夾（`00_` → `01_` → `02_` → `03_`）順序上課即可，不需要再跳到上層目錄找檔案。

> **這裡的檔案是「複製」進來的，不是「搬移」**：`00_environment_setup/`、`02_qiime2_moving_pictures/`
> 底下的文件，原始檔案仍然完整保留在上層 `notebook/` 根目錄（未被修改），
> 這裡是獨立的一份課程用副本，日後兩邊各自維護即可，互不影響。

對應的整體課程規劃：[課程規劃案_生醫HPC_QIIME2_Jupyter培訓課程.md](課程規劃案_生醫HPC_QIIME2_Jupyter培訓課程.md)

---

## Module 0｜環境與背景知識

| 主題 | 文件 | 這份文件解決什麼問題 |
|---|---|---|
| Antigravity IDE + Jupyter 擴充套件安裝、kernel 基本操作、用 `uv` 建虛擬環境 | [00_environment_setup/Jupyter_Notebook_Tutorial.md](00_environment_setup/Jupyter_Notebook_Tutorial.md) | 讓 Antigravity IDE 能開 `.ipynb`、認識 kernel 選單、輕量 Python 專案用 `uv` 管理套件 |
| Miniconda 安裝、QIIME2 conda 環境建立、ipykernel 註冊 | [00_environment_setup/conda_miniconda_qiime2_install.md](00_environment_setup/conda_miniconda_qiime2_install.md) | 重量級生資工具（有官方 conda yml 的）該怎麼裝、怎麼註冊成 notebook 可選的 kernel |
| 把官方教學轉成可執行 notebook、Antigravity IDE kernel 選單找不到新 kernel、`%%bash` PATH 問題 | [00_environment_setup/Qiime2_VSCode_Jupyter_教學.md](00_environment_setup/Qiime2_VSCode_Jupyter_教學.md) | Notebook 端最常見的兩個「明明裝好了卻跑不動」的坑 |
| 台灣杉三號 GP1 生醫節點使用手冊（登入、儲存、計費、SLURM partition 表、桌面環境、**RAPIDS + Singularity** GPU 容器範例） | [00_environment_setup/TWCC_Taiwania3_GP1生醫節點_使用手冊.md](00_environment_setup/TWCC_Taiwania3_GP1生醫節點_使用手冊.md) | 這台機器的操作規則與資源限制，所有範例的大前提。RAPIDS 段落是本課程另一處用到 Singularity 的地方（GPU 容器 + Jupyter port tunnel），跟 Module 3 的 CPU 容器 + SLURM pipeline 用法互相對照 |
| **快速上手**（環境已經裝好、只想趕快跑分析的人看這份就夠） | [00_environment_setup/快速上手.md](00_environment_setup/快速上手.md) | 三步驟講完「登入 → 選 kernel → 跑分析」，遇到問題查對照表，不用先讀完上面四份完整文件 |

**`conda` vs `uv` 該用哪個？**
- QIIME2、HUMAnN3 這類**官方已經包好整套依賴（conda yml / Docker image）的重量級生資工具**：直接用官方提供的方式（conda 或 Singularity 容器），不要自己重兜。
- 一般 **Python 資料處理／自己寫的小工具**：用 `uv venv` 建立輕量虛擬環境即可，啟動快、不用扛整個 conda 的體積。

---

## Module 1｜FastQC + MultiQC 定序品質管控

| 教學文件 | 對應程式碼 | 重點 |
|---|---|---|
| [01_fastqc_multiqc/01_FastQC_MultiQC_教學.md](01_fastqc_multiqc/01_FastQC_MultiQC_教學.md) | [01_fastqc_multiqc_demo.ipynb](01_fastqc_multiqc/01_fastqc_multiqc_demo.ipynb) | 用模擬 FASTQ 資料練習判讀 QC 報告，作為分析前置作業的第一課，已實測（6 樣本 FastQC + MultiQC 彙整成功） |

---

## Module 2（主線）｜QIIME2 Moving Pictures Tutorial

| 主題 | 教學文件 | 對應程式碼 | 重點 |
|---|---|---|---|
| 16S 微生物體分析完整流程 | [02_qiime2_moving_pictures/SLURM_腳本撰寫教學_QIIME2實作範例.md](02_qiime2_moving_pictures/SLURM_腳本撰寫教學_QIIME2實作範例.md) | [qiime2_moving_pictures_tutorial.ipynb](02_qiime2_moving_pictures/qiime2_moving_pictures_tutorial.ipynb)（互動探索版）+ [run_qiime2_pipeline.sh](02_qiime2_moving_pictures/run_qiime2_pipeline.sh) / [slurm_qiime2_pipeline.sh](02_qiime2_moving_pictures/slurm_qiime2_pipeline.sh)（SLURM 生產版） | 從匯入序列到 ANCOM-BC 差異豐度檢定的完整 10 章流程；SLURM 版本已實測跑完整條 pipeline（job 2030543，14 分 44 秒，`COMPLETED`） |
| **結果怎麼解讀（生物學意義）** | [02_qiime2_moving_pictures/QIIME2_結果解讀指南.md](02_qiime2_moving_pictures/QIIME2_結果解讀指南.md) | — | Alpha/beta diversity、taxonomy barplot、ANCOM-BC 這些輸出在生物學上代表什麼，跑完 notebook 後對照著看 |

這一份也是 SLURM script 語法與「邏輯腳本 + SLURM 派送腳本」分離架構的教學來源，
後面 Module 3（HUMAnN3）沿用的就是這裡建立的架構。

---

## Module 3｜Singularity 容器 + HUMAnN3（功能性宏基因體分析）

| 教學文件 | 對應程式碼 | 重點 |
|---|---|---|
| [03_singularity_humann3/03_Singularity_HUMAnN3_教學.md](03_singularity_humann3/03_Singularity_HUMAnN3_教學.md) | [03_humann3_demo.ipynb](03_singularity_humann3/03_humann3_demo.ipynb) + [run_humann3_pipeline.sh](03_singularity_humann3/run_humann3_pipeline.sh) / [slurm_humann3_pipeline.sh](03_singularity_humann3/slurm_humann3_pipeline.sh) | 把 Docker Hub 上的容器（`biobakery/humann`）轉成 Singularity image，在 Jupyter kernel 裡互動測試、也用 SLURM 批次送出正式工作。已端到端實測成功（job 2030736，70 秒，`COMPLETED`），並記錄了「預設會嘗試下載 39GB MetaPhlAn 資料庫」這個真實踩坑案例 |
| **結果怎麼解讀（生物學意義）** | [03_singularity_humann3/HUMAnN3_結果解讀指南.md](03_singularity_humann3/HUMAnN3_結果解讀指南.md) | — | Gene family / pathway abundance 這些輸出代表什麼、跟 QIIME2 的分析邏輯差在哪、何時該用哪個工具 |

> **課程裡另一個用到 Singularity 的地方**：Module 0 的 TWCC 手冊「如何使用 RAPIDS」段落，
> 用 `singularity run --nv` 跑 GPU 容器 + 開 Jupyter port tunnel，跟這裡「CPU 容器 + SLURM 批次送出」是不同使用情境，
> 可以對照著看，體會 Singularity 在互動式（RAPIDS/Jupyter tunnel）跟批次式（HUMAnN3/SLURM）兩種場景下的用法差異。

---

## 建議的上課順序

```
Module 0（環境與背景知識）
   00_environment_setup/
   Jupyter/Antigravity IDE 安裝 → conda/QIIME2 環境 → notebook 轉寫技巧 → HPC 平台手冊（含 RAPIDS/Singularity 範例）
        │
        ▼
Module 1：FastQC + MultiQC（分析前的 QC 習慣）
   01_fastqc_multiqc/
        │
        ▼
Module 2（主線）：QIIME2 Moving Pictures Tutorial
   02_qiime2_moving_pictures/
   notebook 互動版 → SLURM script 語法 → SLURM 生產版
        │
        ▼
Module 3：Singularity + HUMAnN3（容器化生資工具 + SLURM，補 QIIME2 以外的分析情境）
   03_singularity_humann3/
```

---

## 這些教材已記錄的真實除錯案例

以下問題都是實際操作這台機器時踩到、驗證過解法的案例，分散記錄在各模組的教學文件裡：

| 案例 | 記錄位置 |
|---|---|
| Antigravity IDE kernel 選單裝好卻找不到新 kernel | [00_environment_setup/Qiime2_VSCode_Jupyter_教學.md](00_environment_setup/Qiime2_VSCode_Jupyter_教學.md) 第 4 節 |
| `%%bash` cell 找不到指令（PATH 沒繼承 conda activate） | [00_environment_setup/Qiime2_VSCode_Jupyter_教學.md](00_environment_setup/Qiime2_VSCode_Jupyter_教學.md) 第 5 節 |
| Compute node 連不到外網，需要設定 proxy | [02_qiime2_moving_pictures/SLURM_腳本撰寫教學_QIIME2實作範例.md](02_qiime2_moving_pictures/SLURM_腳本撰寫教學_QIIME2實作範例.md) 第 5.2.1 節、[00_environment_setup/TWCC_Taiwania3_GP1生醫節點_使用手冊.md](00_environment_setup/TWCC_Taiwania3_GP1生醫節點_使用手冊.md) 第 2 節 |
| `qiime ... --output-dir` 目錄已存在導致報錯 | [02_qiime2_moving_pictures/SLURM_腳本撰寫教學_QIIME2實作範例.md](02_qiime2_moving_pictures/SLURM_腳本撰寫教學_QIIME2實作範例.md) 第 5.2 節 |
| 手動 notebook 操作跟 SLURM job 共用目錄互相覆寫檔案 | [02_qiime2_moving_pictures/SLURM_腳本撰寫教學_QIIME2實作範例.md](02_qiime2_moving_pictures/SLURM_腳本撰寫教學_QIIME2實作範例.md) 第 5.2 節 |
| HUMAnN3 預設會嘗試下載 39GB 的 MetaPhlAn 資料庫 | [03_singularity_humann3/03_Singularity_HUMAnN3_教學.md](03_singularity_humann3/03_Singularity_HUMAnN3_教學.md) 第 5.1 節 |
| MultiQC 執行出現無害的 `_ARRAY_API not found` 警告 | [01_fastqc_multiqc/01_FastQC_MultiQC_教學.md](01_fastqc_multiqc/01_FastQC_MultiQC_教學.md) 第 6 節 |
| 模擬 FASTQ 產生器誤觸發 FastQC 的 Phred+64 編碼偵測，導致對照組全部品質模組顯示 FAIL | [01_fastqc_multiqc/01_FastQC_MultiQC_教學.md](01_fastqc_multiqc/01_FastQC_MultiQC_教學.md) 第 5.1 節 |

---

## 設計原則

1. **`class/` 是自成一體的課程根目錄**：Module 0～3 都收在這裡，資料夾編號跟 Module 編號一一對應（`01_`=Module 1、`02_`=Module 2...），不用再跳到上層目錄找先備教材。
2. **原始檔案不動，這裡是課程用複本**：`00_environment_setup/`、`02_qiime2_moving_pictures/` 底下的內容
   是從上層 `notebook/` 根目錄複製進來的，原始檔案維持原樣，日後若要更新課程內容，
   直接修改 `class/` 底下的複本即可，不影響外面原本的工作檔案。
3. **每個範例資料夾自成一體**：教學 `.md` 放解說跟原理，`.ipynb`/`.sh` 放可以實際跑的程式碼，兩者互相對照。
4. **盡量不依賴外部大型資料下載**：能用模擬資料或工具官方內建示範資料講清楚觀念的，就不強迫學員先花時間下載真實資料。
5. **同一個觀念只寫一次，其他地方用連結引用**：例如 `%%bash` PATH 問題、SLURM 除錯技巧，只在來源文件寫一次，其他模組用連結引用，不重複貼一次全文。

---

## 授權

- **程式碼**（`.sh` 腳本、`.ipynb` 裡的 code cell、設定檔）：[MIT License](LICENSE)
- **教學文字內容**（`.md` 文件、`.ipynb` 裡的 markdown 說明）：[CC BY 4.0](LICENSE-CONTENT.md)

歡迎自由使用、修改、分享，商業或非商業用途皆可，請標示來源。
