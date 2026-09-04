# HUMAnN3 分析結果：生物學解讀指南

前面的教學文件聚焦在「怎麼跑、怎麼除錯」，這份文件聚焦在**跑完之後，這些輸出檔案在生物學上代表什麼**。
建議跑完 [03_humann3_demo.ipynb](03_humann3_demo.ipynb) 之後回來對照著看。

---

## 0. 跟 QIIME2 的分析邏輯差在哪

| | QIIME2（16S） | HUMAnN3（shotgun metagenomics） |
|---|---|---|
| 定序策略 | 只定序 16S rRNA 基因的一小段（V4 區） | 對整個宏基因體（所有 DNA）打散定序 |
| 回答的問題 | 「這個社群裡**有哪些物種**、比例多少」 | 「這個社群**能做哪些代謝功能**、由哪些物種貢獻」 |
| 解析度 | 物種層級為主 | 基因/代謝路徑層級，且知道是哪個物種帶有這個功能 |
| 分析單位 | ASV（序列變異體） | Gene family（UniRef）→ 彙整成 Pathway（代謝路徑） |

簡單說：QIIME2 告訴你「誰在那裡」，HUMAnN3 告訴你「他們在做什麼」。
兩者常常搭配使用——先用 16S 便宜快速地看整體社群組成，再挑重點樣本用 shotgun + HUMAnN3 深入看功能。

---

## 1. `demo_genefamilies.tsv`：基因家族層級輸出怎麼看

每一列格式類似：

```
UniRef90_A0A3E2VJ85|g__Bacteroides.s__Bacteroides_vulgatus    12.34
UNMAPPED                                                       87234.0
```

- `UniRef90_xxx`：這個基因家族在 UniRef90 資料庫裡的 ID（可以拿去 UniProt 查對應的蛋白質功能）
- `|g__屬.s__種`：**這一行的數值是「這個物種對這個基因家族的貢獻量」**，是 HUMAnN3 最大的價值所在——
  不只告訴你有這個基因，還告訴你是哪個物種帶有它
- `UNMAPPED`：完全比對不上任何已知基因的 reads，數值通常會很大（尤其是像本課程 demo 這種用縮小版資料庫的情況）
- 數值單位是 **RPK（Reads Per Kilobase）**，已經對基因長度做過標準化，但**還沒對定序深度（每個樣本的總 read 數）標準化**，
  正式分析比較多個樣本時，通常還要再跑 `humann_renorm_table` 轉成 CPM（Counts Per Million）才能公平比較

---

## 2. `demo_pathabundance.tsv` / `demo_pathcoverage.tsv`：代謝路徑層級輸出怎麼看

- **Pathway abundance（豐度）**：這個代謝路徑（例如某個胺基酸合成路徑）在樣本裡的**定量豐度**，
  數值一樣是 RPK，一樣是「有這個路徑的物種貢獻量加總」
- **Pathway coverage（覆蓋度）**：0~1 之間的信心值，代表「這條代謝路徑上的各個反應步驟，有多少比例真的被偵測到」——
  就算某條路徑的 abundance 算出一個數字，coverage 低代表這條路徑可能**不完整**（缺了幾個關鍵酵素基因），
  結果比較不可信；**看 abundance 的同時一定要對照 coverage**，coverage 太低的路徑不要直接拿來下結論
- Pathway ID 對應到 **MetaCyc** 資料庫（跟 QIIME2 分類器對應到 Greengenes/SILVA 分類資料庫是類似的概念，
  只是這裡對應的是「功能」資料庫而不是「物種」分類資料庫）

---

## 3. 用這次課程實測的 demo 結果實際示範解讀

本課程實測（見 [03_Singularity_HUMAnN3_教學.md](03_Singularity_HUMAnN3_教學.md) 第 5.1 節）跑出來的真實數字：

```
Total bugs from nucleotide alignment: 2
  g__Bacteroides.s__Bacteroides_dorei: 1270 hits
  g__Bacteroides.s__Bacteroides_vulgatus: 1335 hits
Unaligned reads after nucleotide alignment: 87.6%

Total bugs after translated alignment: 3
  （多比對到 1017 個 unclassified hits）
Unaligned reads after translated alignment: 82.9%
```

**該怎麼解讀這組數字：**

- 只比對到 2~3 個物種、**87.6% 的 reads 完全比對不上**——這不是分析失敗，是因為 demo 特意用了官方縮小版的
  `DEMO` 版 ChocoPhlAn/UniRef 資料庫（教學設計就是要快、要小），資料庫裡本來就只收錄極少數物種/基因家族
- **正式研究分析換成完整版資料庫後，unaligned 比例通常會大幅下降**（但真實資料一般還是會有 30~50% 甚至更高的
  unmapped，這在 shotgun metagenomics 是常態，因為總是有很多微生物的基因體還沒被定序收錄進資料庫）
- 這組數字很適合當作教學案例：**unaligned/UNMAPPED 比例本身就是一個重要的資料品質/資料庫完整度指標**，
  拿到任何 HUMAnN3 結果，第一件事就該先看這個比例，再決定要不要相信後面的 pathway 結果

---

## 4. 何時用 QIIME2、何時用 HUMAnN3

| 情境 | 建議工具 |
|---|---|
| 想快速、便宜地比較很多樣本的整體社群組成差異 | QIIME2（16S） |
| 想知道某個社群的代謝功能（例如能不能合成某種維生素、分解某種物質） | HUMAnN3（shotgun） |
| 想追蹤「哪個物種帶有某個抗藥性基因/毒力因子」 | HUMAnN3（shotgun），16S 做不到這麼細的功能歸因 |
| 預算/定序深度有限，樣本數很多 | QIIME2（16S 定序成本遠低於 shotgun） |
| 已經用 16S 篩出幾個重點樣本，想深入研究 | 對這幾個重點樣本另外做 shotgun + HUMAnN3 |

兩者不是互斥選項，**16S 篩查 + shotgun 深入分析**是常見的研究設計組合。
