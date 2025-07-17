#!/bin/bash
#
# I-JEPA 快速測試 - 智能資源選擇腳本
#

echo "================================================================"
echo "I-JEPA 智能測試腳本"
echo "自動檢查可用資源並提交最合適的測試作業"
echo "================================================================"

# 檢查SLURM是否可用
if ! command -v sinfo &> /dev/null; then
    echo "錯誤：SLURM系統不可用"
    exit 1
fi

echo "檢查GPU資源可用性..."

# 檢查A100資源
A100_IDLE=$(sinfo -p a100_short-al9 -h -o "%T" 2>/dev/null | grep -c "idle")
A100_MIX=$(sinfo -p a100_short-al9 -h -o "%T" 2>/dev/null | grep -c "mix")
A100_AVAILABLE=$((A100_IDLE + A100_MIX))

# 檢查V100資源
V100_IDLE=$(sinfo -p v100-al9_short -h -o "%T" 2>/dev/null | grep -c "idle")
V100_MIX=$(sinfo -p v100-al9_short -h -o "%T" 2>/dev/null | grep -c "mix")  
V100_AVAILABLE=$((V100_IDLE + V100_MIX))

# 檢查L40S資源
L40S_IDLE=$(sinfo -p l40s-al9_short -h -o "%T" 2>/dev/null | grep -c "idle")
L40S_MIX=$(sinfo -p l40s-al9_short -h -o "%T" 2>/dev/null | grep -c "mix")
L40S_AVAILABLE=$((L40S_IDLE + L40S_MIX))

# 檢查CPU資源
CPU_IDLE=$(sinfo -p edr1-al9_short -h -o "%T" 2>/dev/null | grep -c "idle")
CPU_MIX=$(sinfo -p edr1-al9_short -h -o "%T" 2>/dev/null | grep -c "mix")
CPU_AVAILABLE=$((CPU_IDLE + CPU_MIX))

echo "資源狀況："
echo "  A100 GPU (a100_short-al9): $A100_AVAILABLE 節點可用"
echo "  V100 GPU (v100-al9_short): $V100_AVAILABLE 節點可用"
echo "  L40S GPU (l40s-al9_short): $L40S_AVAILABLE 節點可用"
echo "  CPU (edr1-al9_short): $CPU_AVAILABLE 節點可用"

echo ""
echo "================================================================"

# 智能選擇最佳資源
if [ $A100_AVAILABLE -gt 0 ]; then
    echo "✓ 發現可用的A100 GPU資源"
    echo "建議使用A100版本（最快速度）"
    echo ""
    read -p "是否提交A100 GPU測試？(y/n): " choice
    if [[ $choice == "y" || $choice == "Y" ]]; then
        echo "提交A100 GPU測試作業..."
        sbatch slurm_test_ijepa_a100.sh
        if [ $? -eq 0 ]; then
            echo "✓ A100測試作業已提交！"
            echo "使用 'squeue -u $USER' 查看作業狀態"
        else
            echo "✗ 作業提交失敗"
        fi
        exit 0
    fi
elif [ $V100_AVAILABLE -gt 0 ]; then
    echo "✓ 發現可用的V100 GPU資源"
    echo "建議使用V100版本（良好速度）"
    echo ""
    read -p "是否提交V100 GPU測試？(y/n): " choice
    if [[ $choice == "y" || $choice == "Y" ]]; then
        echo "提交V100 GPU測試作業..."
        sbatch slurm_test_ijepa.sh
        if [ $? -eq 0 ]; then
            echo "✓ V100測試作業已提交！"
            echo "使用 'squeue -u $USER' 查看作業狀態"
        else
            echo "✗ 作業提交失敗"
        fi
        exit 0
    fi
elif [ $L40S_AVAILABLE -gt 0 ]; then
    echo "✓ 發現可用的L40S GPU資源"
    echo "注意：L40S需要修改腳本分區設定"
    echo "建議改用V100或等待其他GPU可用"
elif [ $CPU_AVAILABLE -gt 0 ]; then
    echo "只有CPU資源可用"
    echo "CPU版本執行時間較長（30-90分鐘）"
    echo ""
    read -p "是否提交CPU測試？(y/n): " choice
    if [[ $choice == "y" || $choice == "Y" ]]; then
        echo "提交CPU測試作業..."
        sbatch slurm_test_ijepa_cpu.sh
        if [ $? -eq 0 ]; then
            echo "✓ CPU測試作業已提交！"
            echo "使用 'squeue -u $USER' 查看作業狀態"
        else
            echo "✗ 作業提交失敗"
        fi
        exit 0
    fi
else
    echo "⚠ 目前沒有可用的計算資源"
    echo "所有節點都在使用中或維護狀態"
fi

echo ""
echo "================================================================"
echo "手動選擇選項："
echo "1. sbatch slurm_test_ijepa_a100.sh   # A100 GPU版本"
echo "2. sbatch slurm_test_ijepa.sh        # V100 GPU版本"
echo "3. sbatch slurm_test_ijepa_cpu.sh    # CPU版本"
echo ""
echo "查看詳細資源狀況："
echo "sinfo -p a100_short-al9,v100-al9_short,l40s-al9_short,edr1-al9_short"
echo ""
echo "查看作業佇列："
echo "squeue -u $USER"
echo "================================================================" 