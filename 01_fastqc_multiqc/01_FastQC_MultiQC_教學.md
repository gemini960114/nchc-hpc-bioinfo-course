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
| `sample_E_gc_skew` | 混合兩群不同 GC bias（85% / 15%）的雙峰分布 | **Per Sequence GC Content** 明顯偏離理論常態分布 |
| `sample_F_lowqual` | 全長 Phred 品質壓在 Q8~16 | 整體品質模組偏黃/紅 |

> **附註（工具敏感度噪點，實測確認）**：`sample_B_degrading` 除了預期的品質模組變紅之外，
> 還會在 **Per Sequence GC Content** 看到 FAIL，但這**不是刻意設計的問題**——
> A、B 兩個樣本的 GC 分布統計上幾乎完全一樣（50.2%±4.12 vs 49.9%±4.06），FastQC 這個模組對
> 「形狀接近常態但不完全相同」的分布相當敏感，純隨機序列偶爾會越界。
> 因為 seed 固定（`random.seed(42)`），學員重跑一定會看到這個紅字，
> 上課時如果被問到，正好是討論「工具閾值 vs 統計噪音」的現成素材。

---

## 5. 真實踩坑案例：資料產生器原本有兩個 bug

這份模擬資料產生器最初版本，實際送 SLURM job 跑過一輪、逐行比對 `fastqc_data.txt` 之後，
發現對照組 `sample_A_good` 全部品質模組顯示 FAIL、`sample_E_gc_skew` 的 GC 模組卻顯示 PASS——
跟教學文件原本寫的預期完全相反。兩個都是真的 bug，不是分析結果的隨機波動。

### 5.1 Bug 1：Phred+64 編碼誤判

原本的品質分數固定壓在 Q34–38，換算成 ASCII 全部 ≥64。FastQC 判斷編碼格式的邏輯是：
「如果整個檔案裡的品質字元全部 ≥64，就假設是舊式的 Illumina 1.3/1.5（Phred+64）」。
結果 Q35 被誤判成 Phred+64 解讀成 Q3~7，害對照組品質模組全部變 FAIL：

```
Basic Statistics: Encoding = Illumina 1.5   ← 誤判，實際應該是 Phred+33
```

**解法**：讓每個 base 有 2% 機率掉到 Q10~20（低於誤判門檻），FastQC 就能正確判斷成
`Sanger / Illumina 1.9`（標準 Phred+33）。這個修正還有一個附帶好處：真實定序資料本來就會有零星低品質
base，加了這個雜訊反而讓模擬資料更接近真實情況。

### 5.2 Bug 2：GC skew 設計方式沒觸發到對應模組

原本 `sample_E_gc_skew` 是整批 reads 都用同一個偏高的 GC bias（0.85）產生。但 FastQC 的
"Per Sequence GC Content" 模組比對的是「觀測分布」跟「以觀測平均值為中心建出來的理論常態分布」——
**整批一起偏移不會被抓到**，因為觀測平均值本身也跟著偏移，兩者形狀仍然吻合。

**解法**：改成混合兩群不同 GC bias 的 reads（85% 與 15%），產生真正的雙峰分布，
形狀偏離常態分布才會讓這個模組真的觸發警告。

### 5.3 附帶修正：意外的 duplication 警告

原本非刻意設計重複的樣本（A/B/C/E/F）用 `random.choice(template_pool)` 重複抽樣產生每一條 read，
即使 pool 大小等於 read 數，帶放回抽樣還是會統計性地產生不少重複，導致對照組也出現
"Sequence Duplication Levels" WARN。**解法**：改成依序（`i % len(template_pool)`）取用模板，
只有 `sample_D_duplicates` 這種刻意設計高重複率的樣本才用 `random.choice` 從小子集重複抽樣。

---

## 6. 已知的小狀況：MultiQC 執行時出現 `_ARRAY_API not found` 警告

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

## 7. 練習後可以延伸思考的問題

- 如果 `sample_C_adapter` 是真實資料，正式分析前一般會先用什麼工具做 adapter trimming？
  （提示：`cutadapt`，QIIME2 也有內建 `q2-cutadapt` 插件）
- `sample_D_duplicates` 的重複序列，在 PCR-based 定序（如 16S amplicon）裡是正常現象還是異常？
  跟 shotgun 定序（如後面 HUMAnN3 範例用的 metagenomics 資料）的判斷標準一樣嗎？
- 如果要把這個 QC 步驟也串成 SLURM 自動化 pipeline，該怎麼設計？
  可以參考 [SLURM_腳本撰寫教學_QIIME2實作範例.md](../../SLURM_腳本撰寫教學_QIIME2實作範例.md) 的
  「邏輯腳本 vs SLURM 派送腳本」架構，自己練習寫一個 `run_fastqc_multiqc_pipeline.sh`。
