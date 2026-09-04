# 國網中心 GP1 生醫核心設施 — 台灣杉三號（T3）生醫專用節點 使用手冊

> 本文件整理自國網中心官方說明頁面，聚焦在**實際操作會用到的資訊**：登入、儲存、模組、排程送工作、常用查詢指令。
> 完整原始說明、費率細節、法規條款請以官方頁面為準。

---

## 1. 服務與計畫

- 計畫代號：**MST109178**（計畫建立者：林沿妊）
- 若尚未加入 GP1 核心設施 iService 服務計畫，需先申請加入，才能使用生醫專用計算環境。
- 查詢自己是否已加入計畫、剩餘額度：

  ```bash
  wallet
  ```

  正常會看到：
  ```
  PROJECT_ID: MST109178, PROJECT_NAME: 國家生醫數位資料與分析運算雲端服務平台, SU_BALANCE: xxxxxx
  ```

- 帳號密碼：iService 會員中心 → 會員資訊 → 主機帳號資訊 查詢/修改。
- 客服：生醫小組 電話 03-5776085#370、email `bio.nchc@niar.org.tw`

---

## 2. 登入與資料上傳

- **生醫專用節點**主機位置：`t3-c4.nchc.org.tw`（或 `203.145.216.54`）
- ⚠️ **不要用台灣杉一號**計算，會產生額外費用。
- ⚠️ **不要在登入節點（login node）上直接跑計算**（CPU/GPU），會影響其他人與排程系統，計算一律透過 SLURM 送到 compute node。
- ⚠️ **Compute node 預設連不到外部網路**（`wget`/`curl` 會 `Connection timed out`，實測 `cpn3859`、`cpn3852` 皆如此），只有 login node 能直接連外網。若 SLURM job 裡需要下載資料或連外部服務，要在 job script 裡設定 proxy：

  ```bash
  export http_proxy=http://lgn304-v304:53128
  export https_proxy=http://lgn304-v304:53128
  ```

- 登入需要密碼 + OTP（二階段驗證），登入時會問：

  ```
  Please select the 2FA login method.
  1. Mobile APP OTP
  2. Mobile APP PUSH
  3. Email OTP
  ```

### 2.1 用 Antigravity IDE Remote SSH 連線（`~/.ssh/config` 設定）

Antigravity IDE（VS Code 相容分支）內建 Remote SSH 功能，跟終端機一樣讀取本機的 `~/.ssh/config`
（Windows 路徑為 `C:\Users\<帳號>\.ssh\config`）。這台機器**必須走密碼 + OTP 的互動式驗證**，
不能用金鑰登入，設定檔要明確關掉金鑰驗證，強制走互動式流程：

```ssh-config
Host t3-c4
  HostName t3-c4.nchc.org.tw
  User <你的帳號>

  # 直接進入 OTP / MFA 驗證流程
  PubkeyAuthentication no
  KbdInteractiveAuthentication yes
  PreferredAuthentications keyboard-interactive,password

  # 維持及偵測連線狀態
  ServerAliveInterval 30
  ServerAliveCountMax 3

  # 如果目前網路確實需要，再保留
  IPQoS none
```

> **跟一般雲端 VM（例如晶創雲）的 SSH config 寫法不一樣**：晶創雲那類 VM 通常用
> `IdentityFile ~/.ssh/xxx.pem` 走金鑰登入；這台機器（GP1 生醫節點）走的是機構帳號 + OTP，
> 一定要把 `PubkeyAuthentication` 關掉、`PreferredAuthentications` 指定成
> `keyboard-interactive,password`，不然 SSH 客戶端會先嘗試金鑰驗證失敗才 fallback，
> 連線體驗會變慢甚至卡住。
>
> `User` 請換成自己的帳號。注意 ssh config **不會展開環境變數**，這一格不能寫 `$USER`，
> 必須直接填入自己的帳號名稱（文件其他地方的 `/work/$USER` 在 shell 裡才會自動代換）。

設定好之後：

- **終端機**：直接 `ssh t3-c4` 就能連，不用每次打完整主機名稱
- **Antigravity IDE**：Remote SSH 面板會列出 `t3-c4` 這個 Host，點選即可連線
- 不管哪種方式連線，都還是會跳出上面提到的 2FA 選單，正常輸入密碼 + OTP 即可，
  `~/.ssh/config` 只是省去每次打完整參數的麻煩，不會跳過 OTP 驗證

- 上傳資料建議走 `t3-c4.nchc.org.tw`，用 SFTP/SCP/rsync：

  ```bash
  sftp youruserid@t3-c4.nchc.org.tw
  ```

---

## 3. 儲存空間

| 空間 | 容量 | 說明 |
|---|---|---|
| `/home/$USER` | 100G | 固定額度 |
| `/staging/biology/$USER` | 5T（將合併到 work） | |
| `/work/$USER` | 1.5TB + 5TB = 6.5TB | 國科會計畫帳號預設 /work 免費額度已從 100GB 提高到 1500GB，需自行到 HFS 申購介面調高額度 |
| `/staging/reserve/PI_folder` | 需另外付費申請 | |
| 巨量資料儲存服務（GP1-4） | 需另外付費申請，目前無空間上限 | 長期保存用 |

**查詢用量：**

```bash
# 查 work / home
/usr/lpp/mmfs/bin/mmlsquota -u $USER --block-size auto fs01 fs02   # fs01=/work, fs02=/home

# 查 /staging/biology
/usr/lpp/mmfs/bin/mmlsquota -u $USER --block-size auto 5Kstaging:biology

# 查 /staging/reserve/$Fileset
/usr/lpp/mmfs/bin/mmlsquota -j $Fileset --block-size auto 5Kstaging

# 或用整合指令看 work 空間額度
hfs-quota
```

**重要政策：**
- `/work`、`/staging/biology` 是**短期暫存空間**，本核心設施**不做備份**，毀損/誤刪無法復原、不負賠償責任 —— 重要資料要自己搬到巨量資料儲存服務。
- 調整 HFS 免費額度時**不要超過 1500GB**，超過部分依國網公告收費（每 GB 每月 4 元，1TB/月 = 4000 元）。
- 目錄預設權限 700（僅自己可讀寫），要分享給同實驗室的人需自行用 `setfacl` 設定（見第 8 節）。

---

## 4. 計算節點與費率

| 節點種類 | 節點數量 | 單節點核心數 | 記憶體 | 國科會計畫費率 | 一般學界費率 |
|---|---|---|---|---|---|
| CPU 節點 | 45 | 56 | 384G | 0.08 元/核心小時 | 0.24 元/核心小時 |
| GPU 節點（V100） | 2 | 8 GPU | 768G | 10 元/GPU小時 | 25 元/GPU小時 |
| 2TB 大記憶體節點 | 1 | 36 | 2TB | 0.56 元/核心小時 | 1.68 元/核心小時 |
| 4TB 大記憶體節點 | 1 | 72 | 4TB | 0.56 元/核心小時 | 1.68 元/核心小時 |
| 6TB 大記憶體節點 | 2 | 112 | 6TB | 0.56 元/核心小時 | 1.68 元/核心小時 |

GPU、大記憶體節點費率較高，排程 partition 請謹慎選擇，不要浪費資源。

---

## 5. 模組系統（Module）

軟體實際安裝路徑：

```
/opt/ohpc/Taiwania3/pkg/biology/<軟體名稱>/<版本>
```

常用指令：

```bash
module load biology        # 一定要先載入 biology 才能看到底下的軟體模組
module avail                # 列出所有可用模組

module load R/4.3.3
module load BWA/0.7.17

module unload gcc/12.3.0
module list                 # 目前已載入的模組
module show R/4.3.3         # 顯示模組細節
```

### 自行安裝 R package

```bash
module load biology R/4.2.1
R
```

```r
.libPaths()
# 預設只有系統路徑，安裝套件時系統會問是否改用個人路徑，選 yes 即可：
install.packages('ggplot2')
# 之後 .libPaths() 就會多一個個人路徑，且優先載入
```

若要指定用非優先路徑的套件版本：

```r
library(ggplot2, lib.loc = "/work/opt/ohpc/Taiwania3/pkg/biology/R/R-4.2.1/library")
```

---

## 6. SLURM 排程系統

### 6.1 Partition（Queue）對照表（節錄常用）

| Partition | 記憶體(`--mem`) | 核心數(`-c`) | 時間限制 | 個人 Job 上限 | 節點 |
|---|---|---|---|---|---|
| ngsTest | 7G | 1 | 10 分鐘 | 2 | CPU |
| ngs7G | 7G | 1 | 48hr | 1000 | CPU |
| ngs13G | 13G | 2 | 48hr | 500 | CPU |
| ngs26G | 26G | 4 | 96hr | 250 | CPU |
| ngs53G | 53G | 8 | 96hr | 120 | CPU |
| ngs92G | 92G | 14 | unlimit | 80 | CPU |
| ngs186G | 175G | 28 | unlimit | 40 | CPU |
| ngs372G | 350G | 56 | unlimit | 20 | CPU |
| ngs1gpu | 90G | 6 CPU / 1 GPU | unlimit | 4 | GPU |
| ngs2gpu | 180G | 12 CPU / 2 GPU | unlimit | 2 | GPU |
| ngs4gpu | 360G | 24 CPU / 4 GPU | unlimit | 1 | GPU |
| ngs8gpu | 720G | 48 CPU / 8 GPU | unlimit | 1 | GPU |
| ngs1gput/2gput/4gput/8gput | 同上 | 同上 | 24~48hr（有時限版） | 較多 | GPU |
| ngs512G ~ ngs6T_112 | 500G ~ 6000G | 9 ~ 112 | unlimit | 1~8 | 大記憶體節點 |

> 完整表格請見原始說明頁；重點是 **`--mem` 與 `-c`（或 GPU 數）必須符合該 partition 的固定搭配**，設錯工作送不出去。

### 6.2 送工作：Job Script

**CPU 範例：**

```bash
#!/usr/bin/sh
#SBATCH -A MST109178        # 計畫代號
#SBATCH -J Job_name
#SBATCH -p ngs53G           # partition
#SBATCH -c 8                # 核心數，需對應 partition
#SBATCH --mem=53g           # 記憶體，需對應 partition
#SBATCH -o out.log
#SBATCH -e err.log
#SBATCH --mail-user=XXXX@niar.org.tw
#SBATCH --mail-type=BEGIN,END

module load biology
module load BWA/0.7.17
bwa mem ...
```

**GPU 範例：**

```bash
#!/usr/bin/sh
#SBATCH -A MST109178
#SBATCH -J Job_name
#SBATCH -p ngs1gpu
#SBATCH -c 6
#SBATCH --mem=90g
#SBATCH --gres=gpu:1
#SBATCH -o out.log
#SBATCH -e err.log
#SBATCH --mail-user=XXXX@niar.org.tw
#SBATCH --mail-type=BEGIN,END

nvidia-smi
```

送出：

```bash
sbatch jobscript.sh
# Submitted batch job 84684
```

**不寫 script，直接帶參數送出：**

```bash
sbatch -A MST109178 -J Job_name -p ngs48G -c 14 --mem=46g \
  -o out.log -e err.log \
  --mail-user=XXXX@niar.org.tw --mail-type=BEGIN,END job.sh
```

**單行指令用 `--wrap`：**

```bash
sbatch -A MST109178 -J Job_name -p ngs48G -c 14 --mem=46g \
  -o out.log -e err.log \
  --wrap="ls /opt/ohpc/Taiwania3/pkg/biology"
```

**引入外部變數：**

```bash
A=5
b='test'
sbatch --export=A=$A,b=$b job.sh
```

**Array Job：**

```bash
#SBATCH --array=1-10
echo $SLURM_ARRAY_TASK_ID
```

### 6.3 查看 / 刪除工作

```bash
squeue -u $USER                    # 列出自己送出的工作
scontrol show job <job_ID>         # 單一工作詳細資訊
scancel -i <job_ID>                # 刪除工作（互動確認）
```

### 6.4 查詢資源使用狀況

```bash
# 工作記憶體使用量（看 *.batch 那行的 MaxRSS）
sacct -j $jobid -o JobID,JobName,Partition,User,NCPUS,AllocNodes,maxrss,Start,End,Elapsed,State

# 歷史工作
sacct --starttime YYYY-MM-DD -u $USER -o JobID,JobName,Partition,State,ExitCode

# 各 partition 排隊/使用狀況
qstat -ngs

# 節點狀態
sinfo -s | grep ngs

# 各 partition QoS 限制
sacctmgr show qos -o format=name,MinTRES%28,MaxTRES%28,MaxJobsPU | grep ngs
scontrol show partition ngs12G

# 節點細節（核心/記憶體/GPU 使用狀況）
ngsnodes
```

> **NRQ 機制提醒：** 台灣杉三號有 Non-Reserved Queue 設計，GP1 專用資源閒置時會釋出給其他人用；
> GP1 使用者送工作時會優先取回資源，其他人的工作可能被中斷。`ngsnodes` 的 Partition Used 欄位若出現非 `ngs` 開頭的 partition，代表目前還有餘裕可用，不是資源被占滿。

---

## 7. 桌面 / 圖形環境（跑 GUI 程式用，不要拿來計算）

| 平台 | 工具 |
|---|---|
| Windows / Mac | ThinLinc（https://www.cendio.com/thinlinc/download/） |
| Windows | MobaXterm（登入時記得勾選 X11 Forwarding） |
| Mac | XQuartz + `ssh -Y username@t3-c4.nchc.org.tw` |

進入圖形環境後可執行的 GUI 程式範例：

```
/opt/ohpc/Taiwania3/pkg/biology/IGV/IGV_v2.10.3/igv.sh
/opt/ohpc/Taiwania3/pkg/biology/RSTUDIO/rstudio_v2021.09.0-351/bin/rstudio
```

---

## 8. 資料權限分享（`/staging/reserve/$Fileset`）

```bash
# 分享讀取權限給 someone
setfacl -R -m u:someone:r-X,g::---,o::--- /staging/reserve/$Fileset

# 設定繼承權限（未來新檔案自動套用）
setfacl -d -m u:someone:r-X,g::---,o::--- /staging/reserve/$Fileset

# 若要給寫入權限，把 r-X 換成 rwX

# 確認設定
getfacl /staging/reserve/$Fileset

# 移除某人權限（兩行都要下）
setfacl -x u:someone /staging/reserve/$Fileset
setfacl -d -x u:someone /staging/reserve/$Fileset
```

若 someone 要能存取分享資料夾，中間所有上層資料夾也要有 `x` 權限，可用迴圈批次設定：

```bash
folder="/path/to/folder"
someone="username"
while [ "$folder" != "/" ]; do
    setfacl -m u:${someone}:x "$folder"
    folder=$(dirname "$folder")
done
```

---

## 9. 檔案加密

**高速計算儲存空間：**

```bash
# 壓縮並加密
tar -czvf - your_file_or_dir | openssl aes-256-cbc -pbkdf2 -salt -k password -e -out /path/to/file.tar.gz

# 解密並解壓縮
openssl aes-256-cbc -pbkdf2 -salt -k password -d -in /path/to/file.tar.gz | tar xzf -
```

**巨量資料儲存空間：** 用 IBM Aspera（`ascp` 或 Aspera Desktop Client）做 Client-Side Encryption。

---

## 10. 常用軟體備忘

**SRAtoolkit（第一次使用需設定）：**

```bash
/opt/ohpc/Taiwania3/pkg/biology/SRAToolkit/sratoolkit_v2.11.1/bin/vdb-config --interactive
# 進入界面後按 s 儲存、按 x 離開
```

**執行 R script（放進 SLURM job script 裡跑，不要在 login node 跑）：**

```bash
/work/opt/ohpc/Taiwania3/pkg/biology/R/R_v4.1.0/bin/Rscript myRcode.r
```

若缺套件，寄信 `bio.nchc@niar.org.tw` 請中心協助安裝。

**IGV：** 需搭配圖形環境（ThinLinc / MobaXterm+X11 / XQuartz）：

```bash
/opt/ohpc/Taiwania3/pkg/biology/IGV/IGV_v2.10.3/igv.sh
```

**RAPIDS（GPU + Jupyter Notebook）：**

```bash
# 1. Server 端：申請一個 GPU 互動節點
salloc -A MST109178 -p ngs1gpu -c 6 --mem=90g --gres=gpu:1 -J Rapids_Job srun --pty bash
# 記下配到的 node 名稱（如 gpn3002）與 jobid

# 2. 設定環境變數並載入 singularity
export SINGULARITYENV_TINI_SUBREAPER=1
ml singularity

# 3. 啟動 RAPIDS container（會印出 jupyter 使用的 port，例如 8888）
singularity run --nv \
  /work/opt/ohpc/Taiwania3/pkg/biology/Rapids/rapids_cuda11.0/rapidsai_21.10-cuda11.0-runtime-ubuntu18.04.sif
```

```bash
# 4. 客戶端：建立 SSH tunnel
ssh -NfL {localport}:{nodename}:{port} {username}@t3-c4.nchc.org.tw
# 範例
ssh -NfL 10002:gpn3002:8888 u00cwh00@t3-c4.nchc.org.tw
```

瀏覽器打開 `localhost:10002`，範例 notebook 在 `/rapids/notebooks/`（可先 cp 到自己家目錄再改）。

> **用完務必釋放 GPU 資源，避免浪費與額外收費：**
> ```bash
> scancel -i $jobid
> ```

**其他：** Parabricks、AlphaFold v2、Google Drive/雲端資料同步（Rclone）等，請參考對應的專屬使用說明連結（見原始頁面）。

---

## 11. 重點注意事項彙整（容易忽略的規則）

- ❌ 不要用台灣杉一號跑計算（會產生額外費用）
- ❌ 不要在登入節點（login node）直接跑計算 —— 一律 SLURM 送到 compute node
- ❌ 不要用 mamba 幫 QIIME2 之類已有官方 conda yml 的工具安裝（另見 [Qiime2_VSCode_Jupyter_教學.md](Qiime2_VSCode_Jupyter_教學.md)，此為 QIIME2 官方建議，與本機無關但同樣適用）
- ⚠️ `/work`、`/staging/biology` **沒有備份**，重要資料要自行搬到巨量資料儲存服務
- ⚠️ HFS 免費額度調整**不要超過 1500GB**，超過會被收費
- ⚠️ GPU / 大記憶體節點費率高，用完（尤其是 `salloc` 互動式 session）要記得 `scancel` 釋放資源
- ⚠️ 分享資料前先確認 `setfacl` 權限設定正確，本核心設施不代管資料外洩/遺失風險
