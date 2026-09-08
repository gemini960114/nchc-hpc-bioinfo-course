#!/usr/bin/sh
# ==============================================================================
# SLURM 排程派送腳本 - slurm_qc.sh (台灣杉三號 T3-C4 生醫節點專用)
# 規範：僅負責 #SBATCH 資源宣告與呼叫邏輯腳本 run_qc.sh
# ==============================================================================
#SBATCH -A MST109178             # 計畫代號 (國網帳務扣款來源)
#SBATCH -J fastqc_multiqc        # 工作名稱 (顯示於 squeue)
#SBATCH -p ngs53G                # 佇列分區：8 核 / 53GB 規格
#SBATCH -c 8                     # 要求核心數 (必須與 ngs53G 一致)
#SBATCH --mem=53g                # 要求記憶體 (必須與 ngs53G 一致)
#SBATCH -o logs/qc_%j.out        # 標準輸出日誌 (%j 會代換為 Job ID)
#SBATCH -e logs/qc_%j.err        # 標準錯誤日誌
#SBATCH --mail-type=BEGIN,END,FAIL

# 1. 確保工作區與日誌目錄存在
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "${SCRIPT_DIR}"
mkdir -p logs

echo "=== [SLURM 批次作業開始執行] ==="
echo "工作 ID: ${SLURM_JOB_ID}"
echo "計算節點: $(hostname)"
echo "開始時間: $(date)"

# 2. 呼叫純邏輯腳本執行運算
bash "${SCRIPT_DIR}/run_qc.sh" "${SCRIPT_DIR}"

echo "=== [SLURM 批次作業執行結束] ==="
echo "結束時間: $(date)"
