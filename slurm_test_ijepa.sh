#!/bin/bash
#
# I-JEPA 快速測試 - SLURM 作業腳本
#
#SBATCH --job-name=ijepa_test          # 顯示在squeue中的作業名稱
#SBATCH --partition=v100-al9_short     # 使用V100 GPU短時間分區
#SBATCH --gres=gpu:1                   # 請求1個GPU
#SBATCH --time=6:00:00                 # 最大執行時間 6小時
#SBATCH --ntasks=1                     # 單一任務
#SBATCH --cpus-per-task=8              # 每個任務8個CPU核心
#SBATCH --mem=32G                      # 記憶體需求
#SBATCH --error=ijepa_test.%J.err      # 錯誤日誌檔案
#SBATCH --output=ijepa_test.%J.out     # 輸出日誌檔案

echo "================================================================"
echo "I-JEPA 測試作業開始"
echo "作業ID: $SLURM_JOB_ID"
echo "節點: $SLURM_NODELIST"
echo "工作目錄: $SLURM_SUBMIT_DIR"
echo "================================================================"

# 載入必要模組
module load anaconda3/2024.10-1
module load cuda/12.6.0
module load gcc/13.1.0

# 確保我們在正確的目錄
cd $SLURM_SUBMIT_DIR

# 檢查依賴
echo "檢查Python環境和依賴..."
python3 --version
python3 -c "import torch; print(f'PyTorch版本: {torch.__version__}')"
python3 -c "import torch; print(f'CUDA可用: {torch.cuda.is_available()}')"
python3 -c "import torch; print(f'GPU數量: {torch.cuda.device_count()}')" 

# 建立日誌目錄
mkdir -p $SLURM_SUBMIT_DIR/test_logs

echo "================================================================"
echo "創建測試資料..."
echo "================================================================"

# 創建測試資料
srun python3 create_test_data.py

if [ $? -ne 0 ]; then
    echo "錯誤：測試資料創建失敗"
    exit 1
fi

echo "================================================================"
echo "開始I-JEPA訓練測試..."
echo "配置: 1個epoch, batch_size=4, vit_tiny模型"
echo "================================================================"

# 執行I-JEPA測試
srun python3 main.py --fname configs/test_config.yaml --devices cuda:0

exit_code=$?

echo "================================================================"
echo "測試完成"
echo "退出代碼: $exit_code"

if [ $exit_code -eq 0 ]; then
    echo "✓ I-JEPA測試成功完成！"
    echo "日誌檔案位於: $SLURM_SUBMIT_DIR/test_logs/"
    echo "SLURM輸出檔案: ijepa_test.$SLURM_JOB_ID.out"
else
    echo "✗ I-JEPA測試失敗"
    echo "請檢查錯誤日誌: ijepa_test.$SLURM_JOB_ID.err"
fi

echo "================================================================"

# 清理詢問（可選）
echo "如需清理測試資料，請手動執行："
echo "rm -rf /ceph/sharedfs/$USER/test_data"
echo "rm -rf $SLURM_SUBMIT_DIR/test_logs" 