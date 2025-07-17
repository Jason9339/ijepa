#!/bin/bash
set -e  # 發生錯誤時立即停止

echo "================================================================"
echo "I-JEPA 整合測試腳本"
echo "作業ID: $SLURM_JOB_ID"
echo "節點: $SLURM_NODELIST"
echo "家目錄: $HOME"
echo "================================================================"

# 載入必要模組
module load anaconda3/2024.10-1
module load cuda/11.8.0
module load gcc/13.1.0

# 初始化 Conda 指令功能
source $(conda info --base)/etc/profile.d/conda.sh

# 設定環境名稱
ENV_NAME="ijepa-env"

echo "檢查並設置 Conda 環境..."

# 若尚未建立則創建環境與安裝套件
if conda info --envs | grep -q "$ENV_NAME"; then
    echo "✓ 環境 $ENV_NAME 已存在，直接啟用"
    conda activate $ENV_NAME
else
    echo "⚠️ 環境 $ENV_NAME 不存在，開始建立..."
    conda create -n $ENV_NAME python=3.9 -y
    conda activate $ENV_NAME

    echo "🔧 安裝 PyTorch + CUDA..."
    conda install pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia -y

    echo "🔧 安裝其他必要套件..."
    pip install pyyaml numpy pillow opencv-python

    echo "✓ 環境 $ENV_NAME 建立完成"
fi

echo "================================================================"
echo "驗證環境..."
echo "================================================================"

python --version
python -c "import torch; print(f'PyTorch版本: {torch.__version__}')"
python -c "import torch; print(f'CUDA可用: {torch.cuda.is_available()}')"

if python -c "import torch; torch.cuda.is_available()" 2>/dev/null; then
    python -c "import torch; print(f'GPU數量: {torch.cuda.device_count()}')"
    python -c "import torch; print(f'GPU名稱: {torch.cuda.get_device_name(0)}')"
fi

python -c "import yaml, numpy, PIL; print('✓ 所有依賴可用')"

echo "================================================================"
echo "創建測試資料..."
echo "================================================================"

# 創建測試資料
python create_test_data_home.py

if [ $? -ne 0 ]; then
    echo "❌ 錯誤：測試資料創建失敗"
    exit 1
fi

echo "================================================================"
echo "開始 I-JEPA 訓練測試..."
echo "配置: 1 個 epoch, batch_size=4, vit_tiny 模型"
echo "資料來源: 家目錄"
echo "環境: $ENV_NAME"
echo "================================================================"

# 創建訓練日誌資料夾
mkdir -p ./test_logs

# 執行主程式
python main.py --fname configs/test_config_home.yaml --devices cuda:0

exit_code=$?

echo "================================================================"
echo "測試完成"
echo "退出代碼: $exit_code"

if [ $exit_code -eq 0 ]; then
    echo "✓ I-JEPA 測試成功完成！"
    echo "日誌檔案位於: ./test_logs/"
else
    echo "✗ I-JEPA 測試失敗"
    echo "請檢查日誌檔案"
fi

echo "================================================================"
echo "清理說明："
echo "測試資料位於: $HOME/ijepa_test_data/"
echo "清理命令: rm -rf $HOME/ijepa_test_data ./test_logs"
echo "================================================================"
