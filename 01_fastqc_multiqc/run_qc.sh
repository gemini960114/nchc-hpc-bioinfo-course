#!/usr/bin/env bash
# ==============================================================================
# 生醫資料品質管控 (QC) 邏輯腳本 - run_qc.sh
# 目的：對指定目錄下的雙端定序 (PE) fastq.gz 執行 FastQC，並透過 MultiQC 彙總
# 規範：純 Bash 邏輯、不含 #SBATCH、使用 set -euo pipefail 防呆
# ==============================================================================
set -euo pipefail

# 1. 目錄設定（預設為當前目錄，亦可由外部傳入參數 $1）
WORKDIR="${1:-$(pwd)}"
DATA_DIR="${WORKDIR}/data"
FASTQC_OUT="${WORKDIR}/fastqc_out"
MULTIQC_OUT="${WORKDIR}/multiqc_out"

echo "=== [1/4] 初始化工作目錄 ==="
echo "工作目錄: ${WORKDIR}"
echo "定序資料目錄: ${DATA_DIR}"
mkdir -p "${FASTQC_OUT}" "${MULTIQC_OUT}"

# 2. 載入台灣杉三號生醫專用模組（若為 interactive 登入環境）
if command -v module &> /dev/null; then
    module load biology 2>/dev/null || true
    module load FastQC/0.11.9 2>/dev/null || true
    module load MultiQC/1.18 2>/dev/null || true
fi

# 若 module 未載入成功，fallback 到主機系統預設安裝絕對路徑
FASTQC_BIN="$(command -v fastqc || echo "/opt/ohpc/Taiwania3/pkg/biology/FastQC/FastQC_v0.11.9/fastqc")"
MULTIQC_BIN="$(command -v multiqc || echo "/opt/ohpc/Taiwania3/pkg/biology/MultiQC/MultiQC_v1.18/bin/multiqc")"

# 3. 檢查輸入檔案
shopt -s nullglob
FASTQ_FILES=("${DATA_DIR}"/*.fastq.gz "${DATA_DIR}"/*.fq.gz)
if [ ${#FASTQ_FILES[@]} -eq 0 ]; then
    echo "❌ 錯誤：在 ${DATA_DIR} 中找不到任何 *.fastq.gz 或 *.fq.gz 定序檔案！"
    echo "請確認 raw data 是否已放置於 ${DATA_DIR} 目錄下。"
    exit 1
fi
echo "找到 ${#FASTQ_FILES[@]} 個定序檔案待分析。"

# 4. 執行 FastQC（使用 8 執行緒加速）
echo "=== [2/4] 執行 FastQC 平行品質分析 ==="
"${FASTQC_BIN}" \
  -t 8 \
  --outdir "${FASTQC_OUT}" \
  "${FASTQ_FILES[@]}"

# 5. 執行 MultiQC 彙整
echo "=== [3/4] 執行 MultiQC 整合總覽報告 ==="
"${MULTIQC_BIN}" \
  "${FASTQC_OUT}" \
  --outdir "${MULTIQC_OUT}" \
  --filename multiqc_report.html \
  --force

echo "=== [4/4] QC 分析全部完成！==="
echo "✅ FastQC 個別報告目錄：${FASTQC_OUT}"
echo "✅ MultiQC 整合報告：${MULTIQC_OUT}/multiqc_report.html"
