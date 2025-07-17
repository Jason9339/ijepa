#!/bin/bash
#
# 檢查檔案系統可存取性
#
#SBATCH --job-name=check_fs
#SBATCH --partition=edr1-al9_short
#SBATCH --time=0:05:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --error=check_fs.%J.err
#SBATCH --output=check_fs.%J.out

echo "================================================================"
echo "檢查檔案系統可存取性"
echo "作業ID: $SLURM_JOB_ID"
echo "節點: $SLURM_NODELIST"
echo "================================================================"

echo "當前使用者: $USER"
echo "家目錄: $HOME"
echo "工作目錄: $PWD"
echo "提交目錄: $SLURM_SUBMIT_DIR"

echo ""
echo "檢查家目錄存取性..."
if [ -d "$HOME" ]; then
    echo "✓ 家目錄存在: $HOME"
    if [ -w "$HOME" ]; then
        echo "✓ 家目錄可寫入"
        # 測試創建測試檔案
        test_file="$HOME/slurm_test_$(date +%s).tmp"
        if touch "$test_file" 2>/dev/null; then
            echo "✓ 可以在家目錄創建檔案"
            rm -f "$test_file"
        else
            echo "✗ 無法在家目錄創建檔案"
        fi
    else
        echo "✗ 家目錄無寫入權限"
    fi
else
    echo "✗ 家目錄不存在或無法存取"
fi

echo ""
echo "檢查 /ceph/sharedfs/ 存取性..."
if [ -d "/ceph/sharedfs" ]; then
    echo "✓ /ceph/sharedfs 目錄存在"
    user_ceph_dir="/ceph/sharedfs/$USER"
    if [ -d "$user_ceph_dir" ]; then
        echo "✓ 使用者ceph目錄存在: $user_ceph_dir"
    else
        echo "? 使用者ceph目錄不存在，嘗試創建..."
        if mkdir -p "$user_ceph_dir" 2>/dev/null; then
            echo "✓ 成功創建: $user_ceph_dir"
            rmdir "$user_ceph_dir" 2>/dev/null
        else
            echo "✗ 無法創建使用者ceph目錄"
        fi
    fi
else
    echo "✗ /ceph/sharedfs 目錄不存在"
fi

echo ""
echo "建議使用的資料路徑："
if [ -w "$HOME" ]; then
    echo "推薦: $HOME/ijepa_test_data (家目錄)"
fi
if [ -d "/ceph/sharedfs" ]; then
    echo "備選: /ceph/sharedfs/$USER/test_data (並行檔案系統)"
fi

echo "================================================================" 