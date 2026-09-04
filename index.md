---
layout: home

hero:
  name: "HPC 生物資訊分析課程"
  text: "在國網中心台灣杉三號上跑一次完整的生物資訊分析"
  tagline: "以 GP1 生醫核心設施為基礎，從環境安裝、Jupyter 互動探索到 SLURM 自動化生產，實際跑通 QIIME2 16S 分析與 HUMAnN3 宏基因體功能分析"
  actions:
    - theme: brand
      text: 查看課程規劃案
      link: /課程規劃案_生醫HPC_QIIME2_Jupyter培訓課程
    - theme: alt
      text: 快速上手（懶人包）
      link: /00_environment_setup/快速上手
    - theme: alt
      text: 在 GitHub 上檢視
      link: https://github.com/gemini960114/nchc-hpc-bioinfo-cours

features:
  - icon: 🧰
    title: Module 0｜環境與背景知識
    details: Antigravity IDE + Jupyter 擴充套件、Miniconda + QIIME2 環境建置、kernel 選單與 %%bash PATH 常見坑、台灣杉三號平台使用手冊。
    link: /00_environment_setup/快速上手
    linkText: 開始環境設定
  - icon: 🧪
    title: Module 1｜FastQC + MultiQC
    details: 用模擬 FASTQ 資料練習判讀定序品質報告，養成「分析前先看資料品質」的習慣，作為進入正式分析前的第一課。
    link: /01_fastqc_multiqc/01_FastQC_MultiQC_教學
    linkText: 開始 QC 練習
  - icon: 🧬
    title: Module 2（主線）｜QIIME2 Moving Pictures
    details: 16S 微生物體分析完整 10 章流程，從匯入序列到 ANCOM-BC 差異豐度檢定，Notebook 互動版 + SLURM 生產版皆已實測跑通。
    link: /02_qiime2_moving_pictures/SLURM_腳本撰寫教學_QIIME2實作範例
    linkText: 進入主線範例
  - icon: 📦
    title: Module 3｜Singularity + HUMAnN3
    details: 把 Docker Hub 容器轉成 Singularity，跑宏基因體功能性分析，沿用 QIIME2 模組建立的 SLURM 分離式架構。
    link: /03_singularity_humann3/03_Singularity_HUMAnN3_教學
    linkText: 探索容器化分析
  - icon: 📖
    title: 結果怎麼解讀
    details: 不只教怎麼跑指令，也教跑完之後這些數字/圖表在生物學上代表什麼——QIIME2 與 HUMAnN3 各有一份解讀指南。
    link: /02_qiime2_moving_pictures/QIIME2_結果解讀指南
    linkText: 看解讀指南
  - icon: 🐛
    title: 真實除錯案例集
    details: 7 個在這台機器上實際踩過、驗證過解法的真實案例——kernel 選單、PATH 問題、compute node 連外網、資料庫下載陷阱。
    link: /課程規劃案_生醫HPC_QIIME2_Jupyter培訓課程
    linkText: 查看案例對照表
---
