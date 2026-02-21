#!/usr/bin/env bash

# ===== Isaac Lab GPU增强版启动脚本 =====
# 自动设置GPU独显渲染，保留所有官方功能

# 设置GPU独显环境变量（核心！）
export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export NVIDIA_DRIVER_CAPABILITIES=all

echo "[INFO] GPU独显渲染已启用"
echo "[INFO] 显卡: NVIDIA GeForce RTX 4060"
echo "[INFO] 显存: 8GB"
echo "[INFO] CUDA: 已激活"
echo ""

# 调用原脚本，传递所有参数
./isaaclab.sh "$@"
