# Miniconda + QIIME2 + Jupyter Kernel 安裝教學

本文件說明如何在 `/work/$USER/Miniconda` 安裝 Miniconda，建立 QIIME2 環境，
並將該環境註冊為 Jupyter Notebook 可選擇的 kernel。

---

## 1. 下載 Miniconda 安裝腳本

```bash
cd /work/$USER
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda_installer.sh
```

若無 `wget`，可改用：

```bash
curl -L -o miniconda_installer.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
```

---

## 2. 安裝到指定路徑

用 `-b`（batch，非互動）+ `-p`（指定安裝路徑）：

```bash
bash miniconda_installer.sh -b -p /work/$USER/Miniconda
```

> 若目錄已存在會報錯，需先 `rm -rf /work/$USER/Miniconda` 再重新安裝，
> 或改用 `-u`（update）安裝到既有目錄。

---

## 3. 啟用 conda

僅在目前這個 shell session 啟用，不寫入 shell 設定檔：

```bash
source /work/$USER/Miniconda/bin/activate
```

（因為此機器已有 `module load miniconda3` 可用，通常**不建議**再對這份自裝的
Miniconda 執行 `conda init`，以免影響到系統既有環境設定。）

確認安裝與 solver 版本：

```bash
conda --version
conda config --show solver
```

新版 Miniconda 預設 solver 為 `libmamba`，速度已經跟 `mamba` 相當，
**不需要另外安裝 mamba**。

---

## 4. 接受 Anaconda 頻道服務條款（Terms of Service）

新版 conda 要求先同意 `pkgs/main`、`pkgs/r` 這兩個官方頻道的服務條款，
否則安裝套件時會出現 `CondaToSNonInteractiveError`：

```bash
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
```

此步驟只需執行一次，之後同帳號、同機器建立任何環境都不會再跳出此錯誤。

---

## 5. 建立 QIIME2 環境

**建議直接使用官方指令搭配 `conda`，不要用 `mamba` 安裝 QIIME2**——
QIIME2 官方明確建議避免用 mamba，因其 solver 有時會裝出版本不相容、
執行時才出錯且難以追查的環境。

```bash
conda env create \
  --name rachis-qiime2-2026.7 \
  --file https://raw.githubusercontent.com/qiime2/distributions/refs/heads/dev/2026.7/qiime2/released/rachis-qiime2-linux-64-conda.yml
```

> 若直接傳網址給 `--file` 失敗，可先下載再指定本機路徑：
> ```bash
> wget https://raw.githubusercontent.com/qiime2/distributions/refs/heads/dev/2026.7/qiime2/released/rachis-qiime2-linux-64-conda.yml
> conda env create --name rachis-qiime2-2026.7 --file rachis-qiime2-linux-64-conda.yml
> ```

此步驟會下載安裝大量套件，需花數分鐘至十幾分鐘，請耐心等候。

環境安裝完成後會位於：

```
/work/$USER/Miniconda/envs/rachis-qiime2-2026.7/
```

---

## 6. 測試安裝

```bash
conda deactivate
conda activate rachis-qiime2-2026.7
qiime info
```

看到 QIIME2 版本資訊即代表安裝成功。

---

## 7. 安裝 ipykernel 並註冊成 Jupyter Kernel

```bash
conda install -y ipykernel
python -m ipykernel install --user --name rachis-qiime2-2026.7 --display-name "QIIME2 (2026.7)"
```

完成後，回到 Jupyter Notebook 右上角選擇 kernel，
即可看到「QIIME2 (2026.7)」，與其他 kernel（如系統 Python、module 版
miniconda3）並存、互不干擾，可直接切換使用。

---

## 常用檢查指令

```bash
conda env list          # 列出所有 conda 環境
jupyter kernelspec list # 列出所有已註冊的 Jupyter kernel
```
