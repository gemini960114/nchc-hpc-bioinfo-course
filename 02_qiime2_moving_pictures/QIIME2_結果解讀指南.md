# QIIME2 Moving Pictures 分析結果：生物學解讀指南

前面的教學文件聚焦在「怎麼跑、怎麼除錯」，這份文件聚焦在**跑完之後，這些數字/圖表在生物學上代表什麼**。
建議跑完 [qiime2_moving_pictures_tutorial.ipynb](qiime2_moving_pictures_tutorial.ipynb) 之後回來對照著看。

---

## 0. 這份資料在講什麼故事

Moving Pictures 資料集來自 2 位受試者、4 個身體部位（gut 腸道、tongue 舌頭、left palm 左手掌、right palm 右手掌）、
5 個時間點的採樣，**第一個時間點緊接在使用抗生素之後**。這個設計本身就是在問三個生物學問題：

1. 不同身體部位的微生物社群本來就長得不一樣，差多少？（body-site 效應）
2. 兩個人的微生物社群本來就不一樣，差多少？（subject 個體差異）
3. 抗生素會怎麼打亂微生物社群，之後多久會恢復？（時間序列 + 抗生素擾動）

後面每個分析步驟的圖表，都可以回頭對照這三個問題來解讀，而不是只看「這個模組有沒有跑成功」。

---

## 1. Alpha diversity（單一樣本內的多樣性）怎麼解讀

| 指標 | 量的是什麼 | 白話解釋 |
|---|---|---|
| Observed Features | 樣本裡有幾種不同的 ASV/OTU | 「這個樣本裡有幾種菌」，最直覺但沒考慮豐度分布 |
| Shannon 指數 | 豐富度 + 均勻度的綜合指標 | 種類多、且各種類數量平均，指數才會高；某幾種獨大則指數會被拉低 |
| Faith's PD | 考慮親緣關係的豐富度 | 兩個樣本 Observed Features 一樣，但如果 A 樣本的菌親緣關係差很多（演化距離遠），Faith's PD 會比 B 高 |
| Evenness（Pielou's） | 純粹的均勻度，不管有幾種 | 只回答「數量分布平不平均」，不管總共有幾種 |

**在這份資料上該怎麼解讀 `faith-pd-group-significance.qzv` / `evenness-group-significance.qzv`：**
- 依 `body-site` 分組看盒鬚圖：**腸道通常比皮膚/口腔的多樣性更高**，這是人體微生物體研究裡很穩定的現象，
  如果你的結果相反，先懷疑是不是分類/前處理哪裡有問題，而不是急著解讀成新發現
- 依 `subject` 分組看：兩人之間有沒有系統性差異，還是差不多——這關係到「這個資料集能不能代表『人類』的普遍模式，
  還是只反映這兩個人的個體差異」，樣本數只有 2 人時，**這一題的答案通常是後者**，解讀時要保守

---

## 2. Beta diversity / PCoA（樣本之間的相似度）怎麼解讀

**幾種距離指標的差異：**

| 指標 | 考慮豐度嗎 | 考慮親緣關係嗎 |
|---|---|---|
| Jaccard | 否（只看有無） | 否 |
| Bray-Curtis | 是 | 否 |
| unweighted UniFrac | 否（只看有無） | 是 |
| weighted UniFrac | 是 | 是 |

**PCoA 圖（Emperor 3D 圖）怎麼看：**
- 兩個點（樣本）在圖上**距離越近，代表群落組成越相似**
- 用 `body-site` 上色：四個身體部位通常會各自聚成一群，群跟群之間分得越開，代表 body-site 對群落組成的影響越強
  （這也是 `unweighted-unifrac-body-site-group-significance.qzv` 裡 PERMANOVA 檢定在統計上驗證的東西——
  視覺上的分群，用統計方法確認不是偶然）
- 用 `days-since-experiment-start` 當第三軸（`--p-custom-axes`）：可以看到**抗生素使用後的樣本，
  在 PCoA 圖上會先偏離「正常」的群集，隨時間慢慢移回去**——這就是「群落擾動後恢復」的視覺化證據
- **unweighted vs weighted UniFrac 給的圖长得不一樣，是正常的**：unweighted 只看「有沒有這個菌」，
  對稀有菌很敏感，容易放大微小差異；weighted 看「這個菌佔多少比例」，主要由優勢菌主導。
  如果兩者結論一致（都顯示 body-site 分得開），代表這個效應很穩固；如果不一致，要進一步想是不是被少數稀有菌主導

---

## 3. Taxonomic barplot 怎麼解讀

`taxa-bar-plots.qzv` 用 Level 2（phylum，門）檢視最容易上手：

- 人體腸道常見優勢門：**Bacteroidetes、Firmicutes**（兩者合計常佔絕大多數）
- 皮膚常見優勢門：**Actinobacteria、Proteobacteria** 比例通常比腸道高
- 抗生素使用後、隨時間推移，注意**優勢門的相對比例有沒有明顯變化再慢慢回到使用前的樣子**——
  這是判斷「群落有沒有恢復」最直覺的第一步，比看 alpha/beta diversity 數字更直觀，適合當作課堂討論的切入點

> ⚠️ 這份教學用的分類器是用過時的 Greengenes 13_8 訓練的「suboptimal」分類器（教學文件裡已經強調過），
> **Phylum 層級的判斷通常還算穩定，但物種/屬層級的判斷不建議直接採信**，正式研究要換用最新的分類資料庫重新訓練分類器。

---

## 4. ANCOM-BC 差異豐度檢定怎麼解讀

`da-barplot-subject.qzv` / `l6-da-barplot-subject.qzv` 呈現的是「相對於參考組，這個 feature 是被 enriched（增加）還是 depleted（減少）」：

- **參考組是誰很重要**：預設用 `subject-1` 當參考，圖上「enriched」代表在 `subject-2` 身上比在 `subject-1` 身上多，
  「depleted」則相反。換一個參考組，enriched/depleted 的標籤會整個反過來，但生物學結論不變——
  一定要先確認自己看的是誰跟誰比較，再下結論
- **這是相對豐度的比較，不是絕對量的比較**：微生物體資料是「compositional data」（成分資料），
  一個 taxon 比例變高，可能是它真的變多了，也可能是別的 taxon 變少了把它「相對地」襯托出來，
  ANCOM-BC 這類方法就是為了處理這個統計陷阱而設計的，但解讀時還是要記得這個限制，
  不要直接跟外面世界（例如「腸道菌總數變多了」）畫上等號
- **ASV 層級 vs Genus（屬）層級結果數量不同是預期行為**：Genus 層級把很多 ASV 合併計算，
  統計檢定力（power）通常比較高，容易看到更多顯著結果；ASV 層級解析度更細，但每個 feature 的樣本數少，
  容易因為統計power不足而看起來「沒有顯著差異」——不是方法錯了，是解析度跟統計檢定力的取捨

---

## 5. 常見解讀誤區小結

| 誤區 | 為什麼是誤區 |
|---|---|
| 「這個 p 值顯著，所以生物學上一定很重要」 | 樣本數小（本資料集只有 2 位受試者）時，統計顯著不代表效應量大或能推廣到其他人 |
| 「分類器判斷到種（species）層級，我就直接引用」 | 這份教學用的是過時、縮小版的 Greengenes 分類器，物種層級判斷不可靠，見第 3 節 |
| 「enriched 就是「變多了」，depleted 就是「變少了」」 | 這是相對於參考組的相對豐度比較，不是絕對數量變化，見第 4 節 |
| 「unweighted 和 weighted UniFrac 結果不一樣，代表分析錯了」 | 兩者本來就在回答不同問題（有無 vs 比例），結果不同是正常的，要一起看才完整 |
