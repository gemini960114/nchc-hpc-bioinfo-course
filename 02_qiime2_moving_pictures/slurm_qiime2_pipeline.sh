#!/usr/bin/sh
#SBATCH -A MST109178                        # 計畫代號
#SBATCH -J qiime2_pipeline                  # Job 名稱
#SBATCH -p ngs53G                           # Partition：ngs53G
#SBATCH -c 8                                # 核心數，需對應 ngs53G 的固定搭配
#SBATCH --mem=53g                           # 記憶體，需對應 ngs53G 的固定搭配
#SBATCH -o logs/out_%j.log                  # 標準輸出（%j 會自動代入 job ID）
#SBATCH -e logs/err_%j.log                  # 標準錯誤輸出
#SBATCH --mail-user=0203126@niar.org.tw
#SBATCH --mail-type=BEGIN,END

# 只負責資源設定與環境啟用，實際分析邏輯都在 run_qiime2_pipeline.sh 裡

# compute node 對外網路需透過 login node 的 proxy 才能連線（見除錯記錄）
export http_proxy=http://lgn304-v304:53128
export https_proxy=http://lgn304-v304:53128

source /work/c00cjz00/Miniconda/bin/activate rachis-qiime2-2026.7

bash /work/c00cjz00/notebook/run_qiime2_pipeline.sh
