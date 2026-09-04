#!/usr/bin/sh
#SBATCH -A MST109178                        # 計畫代號
#SBATCH -J humann3_demo                     # Job 名稱
#SBATCH -p ngs53G                           # Partition：ngs53G(此為 demo 資料庫規模；正式分析請依教學文件第 6 節改用 ngs92G 以上)
#SBATCH -c 8                                # 核心數，需對應 ngs53G 的固定搭配
#SBATCH --mem=53g                           # 記憶體，需對應 ngs53G 的固定搭配
#SBATCH -o logs/out_%j.log                  # 標準輸出（%j 會自動代入 job ID）
#SBATCH -e logs/err_%j.log                  # 標準錯誤輸出
#SBATCH --mail-user=0203126@niar.org.tw
#SBATCH --mail-type=BEGIN,END

# 只負責資源設定與環境準備，實際分析邏輯都在 run_humann3_pipeline.sh 裡

# compute node 對外網路需透過 login node 的 proxy 才能連線（拉 image / 下載資料庫時需要）
export http_proxy=http://lgn304-v304:53128
export https_proxy=http://lgn304-v304:53128

module load biology 2>/dev/null || true
module load singularity 2>/dev/null || true

bash /work/$USER/notebook/class/03_singularity_humann3/run_humann3_pipeline.sh
