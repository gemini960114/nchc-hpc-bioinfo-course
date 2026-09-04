#!/usr/bin/env bash
# HUMAnN3 (via Singularity) demo pipeline
# 對應 03_Singularity_HUMAnN3_教學.md / 03_humann3_demo.ipynb 的完整流程
set -euo pipefail

WORKDIR="/work/c00cjz00/notebook/class/03_singularity_humann3"
SIF="${WORKDIR}/containers/humann_latest.sif"
DB="${WORKDIR}/db"
OUT="${WORKDIR}/demo_out"
DEMO_FASTQ="/usr/local/lib/python3.6/dist-packages/humann/tests/data/demo.fastq"

mkdir -p "${WORKDIR}/containers" "${DB}" "${OUT}"
cd "${WORKDIR}"

SINGULARITY_BIND="--bind /work/c00cjz00:/work/c00cjz00"

echo "=== [1/4] 確認 / 建立 Singularity image ==="
if [ ! -f "${SIF}" ]; then
  echo "找不到 ${SIF}，開始從 Docker Hub 拉取..."
  singularity pull --force "${SIF}" docker://biobakery/humann:latest
else
  echo "已存在，略過下載：${SIF}"
fi

echo "=== [2/4] 確認容器可正常執行 ==="
singularity exec ${SINGULARITY_BIND} "${SIF}" humann --version

echo "=== [3/4] 下載 DEMO 資料庫（chocophlan + uniref，已存在則略過） ==="
if [ ! -d "${DB}/chocophlan" ]; then
  singularity exec ${SINGULARITY_BIND} "${SIF}" \
    humann_databases --download chocophlan DEMO "${DB}" --update-config no
else
  echo "已存在，略過下載：${DB}/chocophlan"
fi

if [ ! -d "${DB}/uniref" ]; then
  singularity exec ${SINGULARITY_BIND} "${SIF}" \
    humann_databases --download uniref DEMO_diamond "${DB}" --update-config no
else
  echo "已存在，略過下載：${DB}/uniref"
fi

echo "=== [4/4] 執行 HUMAnN3 分析 ==="
# --bypass-prescreen：跳過需要下載 ~40GB MetaPhlAn 資料庫的物種篩選步驟，
# 直接對（DEMO 版）ChocoPhlAn 全庫比對。正式研究資料集請移除這個參數，
# 並改成先在 login node 用 `metaphlan --install` 把完整資料庫裝好、重複使用。
singularity exec ${SINGULARITY_BIND} "${SIF}" \
  humann --input "${DEMO_FASTQ}" \
  --output "${OUT}" \
  --nucleotide-database "${DB}/chocophlan" \
  --protein-database "${DB}/uniref" \
  --bypass-prescreen \
  --threads "${SLURM_CPUS_PER_TASK:-4}"

echo "=== 全部完成，結果在 ${OUT} ==="
ls -la "${OUT}"
