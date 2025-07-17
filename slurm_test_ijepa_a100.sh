#!/bin/bash

#SBATCH --job-name="ijepa-test-a100"
#SBATCH --partition=a100_short-al9
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gres=gpu:1 
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=6:00:00
#SBATCH -o slurm-logs/%j.out
#SBATCH -e slurm-logs/%j.err

# 執行測試腳本
bash run.sh
