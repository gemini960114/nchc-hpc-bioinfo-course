import { defineConfig } from 'vitepress'

export default defineConfig({
  title: "HPC 生物資訊分析課程",
  description: "國網中心台灣杉三號 GP1 生醫節點：用 QIIME2、HUMAnN3、FastQC/MultiQC、SLURM、Jupyter 跑一次完整的生物資訊分析",
  base: '/nchc-hpc-bioinfo-course/',
  ignoreDeadLinks: true, // 教學文件裡連到 .ipynb/.sh 等非 markdown 檔案的相對連結，檔案在 repo 裡真實存在，
                          // 但靜態站台不會打包這些檔案；.ipynb 已在 sidebar 用 GitHub blob 連結涵蓋，其餘視為已知限制

  themeConfig: {
    nav: [
      { text: '首頁', link: '/' },
      { text: '今日課程 (2026-09-08)', link: '/course_20260908' },
      { text: '課程規劃案', link: '/課程規劃案_生醫HPC_QIIME2_Jupyter培訓課程' },
      { text: 'GitHub', link: 'https://github.com/gemini960114/nchc-hpc-bioinfo-course' }
    ],

    sidebar: [
      {
        text: '📚 課程總覽',
        items: [
          { text: '課程資料夾說明', link: '/README' },
          { text: '課程規劃案（逐時段教案）', link: '/課程規劃案_生醫HPC_QIIME2_Jupyter培訓課程' },
          {
            text: '🎯 2026-09-08 實戰課程講義',
            link: '/course_20260908',
            collapsed: false,
            items: [
              { text: '單元一：IDE 介面導覽', link: '/course_20260908#unit-1' },
              { text: '單元二：SSH Config 與 Proxy', link: '/course_20260908#unit-2' },
              { text: '單元三：必備 Extensions 安裝', link: '/course_20260908#unit-3' },
              { text: '單元四：Jupyter 與 ipykernel', link: '/course_20260908#unit-4' },
              { text: '單元五：SLURM 排程語法', link: '/course_20260908#unit-5' },
              { text: '單元六：AI Agent 輔助實戰', link: '/course_20260908#unit-6' },
              { text: '單元七：補充講義索引', link: '/course_20260908#unit-7' }
            ]
          }
        ]
      },
      {
        text: '🧰 Module 0｜環境與背景知識',
        items: [
          { text: '快速上手（懶人包）', link: '/00_environment_setup/快速上手' },
          { text: 'VS Code + Jupyter 安裝', link: '/00_environment_setup/Jupyter_Notebook_Tutorial' },
          { text: 'Miniconda + QIIME2 環境建置', link: '/00_environment_setup/conda_miniconda_qiime2_install' },
          { text: 'QIIME2 × VS Code × Jupyter', link: '/00_environment_setup/Qiime2_VSCode_Jupyter_教學' },
          { text: 'TWCC 台灣杉三號使用手冊', link: '/00_environment_setup/TWCC_Taiwania3_GP1生醫節點_使用手冊' }
        ]
      },
      {
        text: '🧪 Module 1｜FastQC + MultiQC',
        items: [
          { text: '定序品質管控教學', link: '/01_fastqc_multiqc/01_FastQC_MultiQC_教學' },
          { text: '在 GitHub 看 notebook ↗', link: 'https://github.com/gemini960114/nchc-hpc-bioinfo-course/blob/main/01_fastqc_multiqc/01_fastqc_multiqc_demo.ipynb' }
        ]
      },
      {
        text: '🧬 Module 2（主線）｜QIIME2 Moving Pictures',
        items: [
          { text: 'SLURM 腳本撰寫教學', link: '/02_qiime2_moving_pictures/SLURM_腳本撰寫教學_QIIME2實作範例' },
          { text: '結果解讀指南', link: '/02_qiime2_moving_pictures/QIIME2_結果解讀指南' },
          { text: '在 GitHub 看 notebook ↗', link: 'https://github.com/gemini960114/nchc-hpc-bioinfo-course/blob/main/02_qiime2_moving_pictures/qiime2_moving_pictures_tutorial.ipynb' }
        ]
      },
      {
        text: '📦 Module 3｜Singularity + HUMAnN3',
        items: [
          { text: '容器化生資工具教學', link: '/03_singularity_humann3/03_Singularity_HUMAnN3_教學' },
          { text: '結果解讀指南', link: '/03_singularity_humann3/HUMAnN3_結果解讀指南' },
          { text: '在 GitHub 看 notebook ↗', link: 'https://github.com/gemini960114/nchc-hpc-bioinfo-course/blob/main/03_singularity_humann3/03_humann3_demo.ipynb' }
        ]
      }
    ],

    search: {
      provider: 'local'
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/gemini960114/nchc-hpc-bioinfo-course' }
    ],

    footer: {
      message: '課程內容以實際操作 NCHC 台灣杉三號 GP1 生醫節點驗證過的結果為準，平台版本/費率請以官方公告為主。',
      copyright: 'Copyright © 2026 NCHC HPC Bioinfo Course'
    }
  }
})
