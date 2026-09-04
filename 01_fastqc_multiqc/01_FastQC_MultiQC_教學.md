# 範例 1 教學：FastQC + MultiQC 定序資料品質管控（QC）

對應 notebook：[01_fastqc_multiqc_demo.ipynb](01_fastqc_multiqc_demo.ipynb)

---

## 1. 為什麼分析的第一步永遠是 QC

不管接下來要做 16S（QIIME2）、RNA-seq 還是 WGS，原始定序資料（FASTQ）都可能有各種問題：
定序品質隨讀長下降、殘留 adapter 序列、PCR 重複、汙染、GC 含量異常等。
**不先檢查就直接丟進下游分析，這些問題會偷偷影響結果，卻很難事後追查。**

業界標準做法：

1. **FastQC**：對「每一個」FASTQ 檔案產生一份獨立的品質報告
2. **MultiQC**：把「所有」FastQC（以及其他工具，如比對、定量結果）的輸出彙整成一份總覽報告，方便橫向比較多個樣本

---

## 2. 本機環境（不需要額外安裝）

這台機器（台灣杉三號 GP1 生醫節點）已經預裝：

```bash
module load biology
module load FastQC/0.11.9
module load MultiQC/1.18
```

或直接呼叫完整路徑（notebook 範例採用這種方式，原因見下一節）：

```
/opt/ohpc/Taiwania3/pkg/biology/FastQC/FastQC_v0.11.9/fastqc
/opt/ohpc/Taiwania3/pkg/biology/MultiQC/MultiQC_v1.18/bin/multiqc
```

---

## 3. 在 Jupyter `%%bash` cell 裡為什麼用完整路徑而不是 `module load`

我們在 QIIME2 那份教學（[Qiime2_VSCode_Jupyter_教學.md](../../Qiime2_VSCode_Jupyter_教學.md)）裡已經踩過一次：
`%%bash` 開的 subshell 不會自動繼承你手動 `source activate` 過的環境變數。

`module` 指令本身是靠 shell function（`module()` 這個 bash function，由 Lmod 系統在登入 shell 時載入）運作的，
在 `%%bash` 這種非登入、非互動的 subshell 裡，這個 function 不一定存在，容易出現
`module: command not found`。**與其在每個 cell 裡重新處理這個問題，教學範例直接呼叫程式完整路徑最穩定、最不會出錯。**

正式生產環境（SLURM script）裡因為是完整的 login shell 情境（`#!/usr/bin/sh` + 一般 bash 執行），`module load` 通常沒問題，
但用完整路徑一樣穩定，兩種寫法都可以。

---

## 4. 這次範例刻意製造的 6 種品質問題

notebook 用 Python 直接生成 6 個模擬 FASTQ 檔案（不需要下載真實資料，也不依賴外部網路），
分別對應 FastQC 報告裡最常見的幾種警訊：

| 樣本 | 模擬手法 | FastQC/MultiQC 上會看到 |
|---|---|---|
| `sample_A_good` | 均勻高品質、隨機序列 | 對照組，大部分綠色 PASS |
| `sample_B_degrading` | 讀長後 40% 品質線性下降 | **Per base sequence quality** 尾端變黃/紅 |
| `sample_C_adapter` | 35% 的 reads 中間插入 Illumina TruSeq adapter 片段 | **Overrepresented sequences** / adapter 相關警告 |
| `sample_D_duplicates` | 70% 的 reads 來自一小群模板重複 | **Sequence Duplication Levels** 出現紅色 |
| `sample_E_gc_skew` | GC 含量刻意偏高（bias=0.85） | **Per Sequence GC Content** 明顯偏離理論常態分布 |
| `sample_F_lowqual` | 全長 Phred 品質壓在 Q8~16 | 整體品質模組偏黃/紅 |

---

## 5. 已知的小狀況：MultiQC 執行時出現 `_ARRAY_API not found` 警告

實際測試時會看到：

```
AttributeError: _ARRAY_API not found
##### ERROR! MatPlotLib library could not be loaded!    #####
##### Flat plots will instead be plotted as interactive #####
```

**這是無害的警告**，原因是這個 MultiQC 模組內建的 numpy/matplotlib 版本組合有 ABI 不相容問題，
導致靜態圖（flat plot）畫不出來，MultiQC 會自動改用互動式圖表（interactive plot）代替 ——
報告仍然會正常產生（`multiqc | MultiQC complete`），而且互動式圖表其實體驗更好（可以縮放、hover 看數值），
不影響教學使用，看到這個警告不用緊張。

---

## 6. 練習後可以延伸思考的問題

- 如果 `sample_C_adapter` 是真實資料，正式分析前一般會先用什麼工具做 adapter trimming？
  （提示：`cutadapt`，QIIME2 也有內建 `q2-cutadapt` 插件）
- `sample_D_duplicates` 的重複序列，在 PCR-based 定序（如 16S amplicon）裡是正常現象還是異常？
  跟 shotgun 定序（如後面 HUMAnN3 範例用的 metagenomics 資料）的判斷標準一樣嗎？
- 如果要把這個 QC 步驟也串成 SLURM 自動化 pipeline，該怎麼設計？
  可以參考 [SLURM_腳本撰寫教學_QIIME2實作範例.md](../../SLURM_腳本撰寫教學_QIIME2實作範例.md) 的
  「邏輯腳本 vs SLURM 派送腳本」架構，自己練習寫一個 `run_fastqc_multiqc_pipeline.sh`。
