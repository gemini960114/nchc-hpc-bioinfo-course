#!/usr/bin/env bash
# QIIME 2 Moving Pictures tutorial pipeline
# 對應 qiime2_moving_pictures_tutorial.ipynb 的完整流程（DADA2 版本）
set -euo pipefail

WORKDIR="/work/$USER/notebook/qiime2-moving-pictures-tutorial-slurm"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "=== [0/10] 確認 QIIME 2 安裝 ==="
qiime info

echo "=== [1/10] Sample metadata ==="
wget -N -O 'sample-metadata.tsv' \
  'https://moving-pictures-tutorial.readthedocs.io/en/2026.7/data/moving-pictures/sample-metadata.tsv'

qiime metadata tabulate \
  --m-input-file sample-metadata.tsv \
  --o-visualization sample-metadata-viz.qzv

echo "=== [2/10] Obtaining and importing data ==="
wget -N -O 'emp-single-end-sequences.zip' \
  'https://moving-pictures-tutorial.readthedocs.io/en/2026.7/data/moving-pictures/emp-single-end-sequences.zip'

unzip -o -d emp-single-end-sequences emp-single-end-sequences.zip

qiime tools import \
  --type 'EMPSingleEndSequences' \
  --input-path emp-single-end-sequences \
  --output-path emp-single-end-sequences.qza

echo "=== [3/10] Demultiplexing sequences ==="
qiime demux emp-single \
  --i-seqs emp-single-end-sequences.qza \
  --m-barcodes-file sample-metadata.tsv \
  --m-barcodes-column barcode-sequence \
  --o-per-sample-sequences demux.qza \
  --o-error-correction-details demux-details.qza

qiime demux summarize \
  --i-data demux.qza \
  --o-visualization demux.qzv

echo "=== [4/10] DADA2 denoise ==="
qiime dada2 denoise-single \
  --i-demultiplexed-seqs demux.qza \
  --p-trim-left 0 \
  --p-trunc-len 120 \
  --o-representative-sequences rep-seqs.qza \
  --o-table table.qza \
  --o-denoising-stats denoising-stats.qza \
  --o-base-transition-stats base-transition-stats.qza

qiime metadata tabulate \
  --m-input-file denoising-stats.qza \
  --o-visualization denoising-stats.qzv

echo "=== [5/10] FeatureTable and FeatureData summaries ==="
qiime feature-table summarize \
  --i-table table.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-summary table.qzv \
  --o-feature-frequencies feature-frequencies.qza \
  --o-sample-frequencies sample-frequencies.qza

qiime feature-table tabulate-seqs \
  --i-data rep-seqs.qza \
  --o-visualization rep-seqs.qzv

echo "=== [6/10] Phylogenetic tree ==="
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seqs.qza \
  --o-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza

echo "=== [7/10] Alpha and beta diversity analysis ==="
# --output-dir 若目錄已存在會直接報錯拒絕執行，先清掉舊結果讓腳本可重複執行
rm -rf diversity-core-metrics-phylogenetic
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table table.qza \
  --p-sampling-depth 1103 \
  --m-metadata-file sample-metadata.tsv \
  --output-dir diversity-core-metrics-phylogenetic

qiime diversity alpha-group-significance \
  --i-alpha-diversity diversity-core-metrics-phylogenetic/faith_pd_vector.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization faith-pd-group-significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity diversity-core-metrics-phylogenetic/evenness_vector.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization evenness-group-significance.qzv

qiime diversity beta-group-significance \
  --i-distance-matrix diversity-core-metrics-phylogenetic/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file sample-metadata.tsv \
  --m-metadata-column body-site \
  --p-pairwise \
  --o-visualization unweighted-unifrac-body-site-group-significance.qzv

qiime diversity beta-group-significance \
  --i-distance-matrix diversity-core-metrics-phylogenetic/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file sample-metadata.tsv \
  --m-metadata-column subject \
  --p-pairwise \
  --o-visualization unweighted-unifrac-subject-group-significance.qzv

qiime emperor plot \
  --i-pcoa diversity-core-metrics-phylogenetic/unweighted_unifrac_pcoa_results.qza \
  --m-metadata-file sample-metadata.tsv \
  --p-custom-axes days-since-experiment-start \
  --o-visualization unweighted-unifrac-emperor-days-since-experiment-start.qzv

qiime emperor plot \
  --i-pcoa diversity-core-metrics-phylogenetic/bray_curtis_pcoa_results.qza \
  --m-metadata-file sample-metadata.tsv \
  --p-custom-axes days-since-experiment-start \
  --o-visualization bray-curtis-emperor-days-since-experiment-start.qzv

echo "=== [8/10] Alpha rarefaction plotting ==="
qiime diversity alpha-rarefaction \
  --i-table table.qza \
  --i-phylogeny rooted-tree.qza \
  --p-max-depth 4000 \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization alpha-rarefaction.qzv

echo "=== [9/10] Taxonomic analysis ==="
wget -N -O 'reference-sequences.qza' \
  'https://moving-pictures-tutorial.readthedocs.io/en/2026.7/data/moving-pictures/reference-sequences.qza'
wget -N -O 'reference-taxonomy.qza' \
  'https://moving-pictures-tutorial.readthedocs.io/en/2026.7/data/moving-pictures/reference-taxonomy.qza'

qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads reference-sequences.qza \
  --i-reference-taxonomy reference-taxonomy.qza \
  --o-classifier suboptimal-16S-rRNA-classifier.qza

qiime feature-classifier classify-sklearn \
  --i-classifier suboptimal-16S-rRNA-classifier.qza \
  --i-reads rep-seqs.qza \
  --o-classification taxonomy.qza

qiime metadata tabulate \
  --m-input-file taxonomy.qza \
  --o-visualization taxonomy.qzv

qiime taxa barplot \
  --i-table table.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization taxa-bar-plots.qzv

echo "=== [10/10] Differential abundance testing with ANCOM-BC ==="
qiime feature-table filter-samples \
  --i-table table.qza \
  --m-metadata-file sample-metadata.tsv \
  --p-where '[body-site]="gut"' \
  --o-filtered-table gut-table.qza

qiime composition ancombc \
  --i-table gut-table.qza \
  --m-metadata-file sample-metadata.tsv \
  --p-formula subject \
  --o-differentials ancombc-subject.qza

qiime composition da-barplot \
  --i-data ancombc-subject.qza \
  --o-visualization da-barplot-subject.qzv

qiime taxa collapse \
  --i-table gut-table.qza \
  --i-taxonomy taxonomy.qza \
  --p-level 6 \
  --o-collapsed-table gut-table-l6.qza

qiime composition ancombc \
  --i-table gut-table-l6.qza \
  --m-metadata-file sample-metadata.tsv \
  --p-formula subject \
  --o-differentials l6-ancombc-subject.qza

qiime composition da-barplot \
  --i-data l6-ancombc-subject.qza \
  --o-visualization l6-da-barplot-subject.qzv

echo "=== 全部完成，結果在 ${WORKDIR} ==="
