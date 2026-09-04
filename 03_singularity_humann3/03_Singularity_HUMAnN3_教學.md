# 範例 2 教學：Singularity 容器 + HUMAnN3 功能性宏基因體分析

對應 notebook：[03_humann3_demo.ipynb](03_humann3_demo.ipynb)
對應腳本：[run_humann3_pipeline.sh](run_humann3_pipeline.sh) / [slurm_humann3_pipeline.sh](slurm_humann3_pipeline.sh)

---

## 0. 這個範例怎麼跟 Jupyter Kernel / conda / SLURM 串起來

先講結論，避免你邊看邊猜：

- **Notebook 要選哪個 kernel？** 隨便一個能跑 `%%bash` 的 Python kernel 都可以（例如 [class 課程 Module 0](../README.md#module-0環境與背景知識先備教材沿用-class-外層既有文件)
  裝過的 base Python3 kernel，或你自己註冊的任何 kernel），**不需要**像 QIIME2 範例那樣特地建一個 conda 環境。
  這正是容器化工具的優點之一：HUMAnN3 需要的一整包 Python/Perl/DIAMOND/Bowtie2 依賴，全部封裝在
  `humann_latest.sif` 這個檔案裡，跟你 notebook 用哪個 kernel 完全無關，kernel 只負責幫你執行
  `%%bash` cell 去呼叫 `singularity exec`。
- **需要 conda 環境嗎？** 不需要。這是本範例跟 QIIME2 範例（[conda_miniconda_qiime2_install.md](../../conda_miniconda_qiime2_install.md)）
  最大的差異：QIIME2 是「裝進 conda 環境，環境本身要註冊成 kernel」；HUMAnN3 是「整包工具封裝進容器，
  容器本身不需要跟 kernel 綁定」。
- **跟 SLURM 怎麼接？** 完全比照 QIIME2 範例已經驗證過的架構
  （[SLURM_腳本撰寫教學_QIIME2實作範例.md](../../SLURM_腳本撰寫教學_QIIME2實作範例.md)）：
  notebook 裡的 `%%bash` cell 用來**互動測試**（confirm 容器裝得對、小指令跑得動），
  真正跑分析則交給 `run_humann3_pipeline.sh`（邏輯腳本）+ `slurm_humann3_pipeline.sh`（SLURM 派送腳本）
  這組分離式架構，用 `sbatch` 送到 compute node 執行。

先備知識若還沒看過，建議照 [class/README.md 的 Module 0](../README.md) 順序看完 Jupyter + SLURM 基礎，再回來看這篇。

---

## 1. 為什麼需要容器（Container）

[HUMAnN3](https://huttenhower.sph.harvard.edu/humann/) 是宏基因體功能性分析工具（從 shotgun metagenomics
資料推論微生物社群的基因/代謝路徑豐度），依賴一長串 Python/Perl 套件、DIAMOND、Bowtie2、MetaPhlAn 等外部工具，
版本組合非常挑剔。**與其自己在 conda 裡兜出一套相容的環境，直接用官方維護好的容器最省事、最不容易出錯。**

- 官方在 Docker Hub 發布：[biobakery/humann](https://hub.docker.com/r/biobakery/humann)
- 但這台機器（HPC 共用叢集）**不能直接跑 Docker**（Docker daemon 需要 root 權限，多人共用機器不允許）
- 解法：**Singularity**（也叫 Apptainer）—— HPC 界標準的容器工具，不需要 root 就能執行容器，
  且可以直接把 Docker Hub 上的 image 轉換成 Singularity 的 `.sif` 檔案格式使用

---

## 2. 把 Docker image 轉成 Singularity `.sif`

```bash
singularity pull --force humann_latest.sif docker://biobakery/humann:latest
```

- `singularity pull` 會自動處理「下載 Docker layer → 轉換格式 → 封裝成單一 `.sif` 檔案」整個流程
- `.sif` 是一個**單一檔案**，之後可以直接複製、分享給其他人使用，不需要重新下載
- 這一步需要連外網下載（約 900MB 壓縮），**在 login node 上直接跑沒問題**（本機測試通過）；
  如果要放進 SLURM job 在 compute node 上跑，記得加上 proxy（見
  [TWCC_Taiwania3_GP1生醫節點_使用手冊.md](../../TWCC_Taiwania3_GP1生醫節點_使用手冊.md) 第 2 節）：

  ```bash
  export http_proxy=http://lgn304-v304:53128
  export https_proxy=http://lgn304-v304:53128
  ```

本課程已經把轉好的 image 放在：

```
/work/$USER/notebook/class/03_singularity_humann3/containers/humann_latest.sif
```

---

## 3. Singularity 基本指令

| 指令 | 用途 |
|---|---|
| `singularity exec <image.sif> <command>` | 在容器裡執行「一個指令」，執行完就離開，最常用 |
| `singularity shell <image.sif>` | 進入容器內的互動式 shell，適合除錯 |
| `singularity run <image.sif>` | 執行容器預設定義的入口指令（image 作者事先定義好的行為） |
| `--bind /host/path:/container/path` | **掛載**主機路徑到容器內部，容器預設只看得到少數系統路徑，你的資料在 `/work` 底下的話一定要 bind 才看得到 |

> **常見誤區**：容器預設只能看到 `$HOME` 和少數系統目錄，`/work/...` 底下的資料如果沒有 `--bind`，
> 容器內部會完全看不到、報 "No such file or directory"。這台機器通常會自動 bind 常見路徑，
> 但養成習慣明確寫出 `--bind` 比較保險，尤其換到別的機器時行為可能不同。

範例：

```bash
singularity exec \
  --bind /work/$USER:/work/$USER \
  /work/$USER/notebook/class/03_singularity_humann3/containers/humann_latest.sif \
  humann --version
```

---

## 4. 在 Jupyter Kernel 裡互動測試（快速驗證用）

跟前面 QIIME2、FastQC 範例一樣，在 notebook 的 `%%bash` cell 裡可以直接呼叫 `singularity exec`，
適合**快速確認容器裝得對不對**、單一小指令測試，不適合跑真正吃資源的完整分析
（原因跟之前一樣：login node 是共用資源，重運算要走 SLURM）。

notebook 裡示範的輕量指令：

- `humann --version` — 確認容器內的 HUMAnN3 版本，秒級完成
- `humann_databases --available` — 確認容器內建的資料庫下載選項（順便找出下一節會用到的 `DEMO` 版本）

> 這裡**沒有**用 HUMAnN3 官方內建的 `humann_test` 自我測試指令——實測跑了超過 60 秒沒有結束，
> 具體要跑多久不確定，為了不誤導教學進度，改用第 5 節「DEMO 資料庫 + 官方示範 FASTQ」
> 這個已經實測跑完（1 分 25 秒）的完整流程當作健檢方式，順便直接學到正式分析的操作方式。

---

## 5. 正式分析需要的參考資料庫（為什麼不在課堂上完整下載）

HUMAnN3 真正分析需要兩套參考資料庫：

| 資料庫 | 用途 | 完整版大小 |
|---|---|---|
| ChocoPhlAn（nucleotide database） | 已知物種的 pangenome，核酸層級比對 | 完整版約數 GB～十幾 GB |
| UniRef（protein database） | 未比對上的 reads 改用蛋白質層級比對（translated search） | 完整版動輒 20GB+ |

這兩套資料庫太大，不適合在課堂時間內下載。實測發現 **HUMAnN3 官方兩套資料庫都各自提供了 `DEMO` 迷你版**
（用 `humann_databases --available` 可以查到完整清單），剛好都拿來用，就能做一次「核酸 + 蛋白質層級都真的跑一遍」
的完整 demo，不用犧牲任何一段 pipeline 機制：

```bash
humann_databases --download chocophlan DEMO /path/to/db --update-config no
humann_databases --download uniref DEMO_diamond /path/to/db --update-config no
```

**輸入資料也不用自己生成**：容器內建了官方自己出的示範 FASTQ，路徑固定在

```
/usr/local/lib/python3.6/dist-packages/humann/tests/data/demo.fastq
```

`run_humann3_pipeline.sh` 就是把這三樣（DEMO chocophlan、DEMO uniref、官方 demo.fastq）組合起來：

```bash
humann --input demo.fastq --output out/ \
  --nucleotide-database /path/to/db/chocophlan \
  --protein-database /path/to/db/uniref \
  --bypass-prescreen \
  --threads 4
```

### 5.1 實測踩坑：預設會嘗試下載 39GB 的 MetaPhlAn 資料庫

第一次實測直接照上面「少了 `--bypass-prescreen`」的指令跑，結果卡住報錯：

```
CRITICAL ERROR: Error executing: /usr/local/bin/metaphlan ...
Downloading http://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/mpa_latest
Warning: Unable to download ...
FileNotFoundError: ... metaphlan_databases/mpa_latest
```

原因：HUMAnN3 預設流程第一步是 **prescreen**——先用 **MetaPhlAn** 做物種層級篩選，
決定要拿 ChocoPhlAn 裡哪些物種的 pangenome 來比對。而 MetaPhlAn 需要的物種標記基因資料庫
**完整版接近 40GB**（實測 `metaphlan --install` 印出 `Downloading file of size: 39808.76 MB`），
下載到一半就手動中斷了，這在課堂demo 情境完全不合理。

**解法：加上 `--bypass-prescreen`**，直接跳過 MetaPhlAn 這個物種篩選步驟，改成對整個
（已經是小型 DEMO 版的）ChocoPhlAn 資料庫直接比對。因為我們的 DEMO chocophlan 本來就只有幾個物種、
只有 7.9MB，跳過篩選直接全庫比對完全跑得動，也不需要 MetaPhlAn。

加上這個參數後實測 **1 分 25 秒跑完全部流程**（bowtie2 核酸比對 + diamond 蛋白質比對），
還真的比對到有意義的物種（`Bacteroides dorei`、`Bacteroides vulgatus`），
產出 `demo_genefamilies.tsv`、`demo_pathabundance.tsv`、`demo_pathcoverage.tsv` 三個標準輸出檔案——
這是一次貨真價實跑通的 HUMAnN3 分析，不是空殼展示。

> ⚠️ **DEMO 資料庫是官方縮小版**，涵蓋的物種/蛋白質家族有限，結果不能代表真實研究的定量準確度，
> 但因為輸入是官方自己維護的示範資料、流程機制跟真正分析完全一致，拿來驗證
> 「容器 + pipeline 有沒有裝對、跑得通」非常夠用。
>
> 真正的研究分析：
> - 資料庫要換成完整版（`humann_databases --download chocophlan full ...` + `uniref90_ec_filtered_diamond` 或更完整的版本）
> - **通常還是需要 MetaPhlAn 的物種篩選這一步**（不能一直依賴 `--bypass-prescreen`，
>   否則大型真實資料集直接對全庫比對會非常慢），所以正式分析前必須先妥善規劃：
>   在 login node（有直接外網）先跑一次 `metaphlan --install` 把約 40GB 的資料庫下載安裝好，
>   之後 SLURM job 裡才能重複使用同一份已安裝好的資料庫，不要每次 job 都重新下載
> - 且一定要透過 SLURM 送到適合的 partition 執行（見下一節）

---

## 6. 生產環境：SLURM 派送 HUMAnN3 分析

沿用 QIIME2 那份教學建立的架構（[SLURM_腳本撰寫教學_QIIME2實作範例.md](../../SLURM_腳本撰寫教學_QIIME2實作範例.md)）：
**邏輯腳本（`run_humann3_pipeline.sh`）+ SLURM 派送腳本（`slurm_humann3_pipeline.sh`）分離**。

**Partition 選擇建議**：HUMAnN3 的 DIAMOND translated search 相當吃 CPU 與記憶體，
正式分析（非本課程的 demo 版）建議至少用 `ngs92G`（14 核心 / 92G 記憶體）起跳，
真實資料量大時可以考慮 `ngs186G` 甚至更高，實際依你的資料大小與 `--threads` 設定調整
（partition 對照表見 [TWCC 手冊](../../TWCC_Taiwania3_GP1生醫節點_使用手冊.md) 第 6.1 節）。

送出方式跟 QIIME2 範例完全一樣：

```bash
cd /work/$USER/notebook/class/03_singularity_humann3
sbatch slurm_humann3_pipeline.sh
squeue -u $USER
```

---

## 7. 練習題

1. 執行 `singularity shell containers/humann_latest.sif` 進入容器內部，
   用 `which humann`、`humann --version` 確認執行檔的位置與版本，跟主機上（容器外）的環境有什麼不同？
2. 為什麼 `--bypass-translated-search` 可以讓 demo 變輕量，但正式研究分析不建議一直開著這個選項？
   （提示：想想 reads 比對不上已知物種 pangenome 時，少了蛋白質層級比對會漏掉什麼資訊）
3. 如果要正式下載完整版 ChocoPhlAn + UniRef 資料庫，這個下載步驟該放在 SLURM job 裡跑，
   還是該在 login node 上先下載好？為什麼？（提示：可以對照 QIIME2 章節裡我們對「下載資料該放哪裡」的討論）
4. 嘗試修改 `slurm_humann3_pipeline.sh` 的 partition，改成適合你實際資料量的等級。
