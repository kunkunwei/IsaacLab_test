#!/bin/bash

# 清除 Pylance 和 Python 扩展的缓存

echo "清除 Pylance 缓存..."

# Pylance 缓存位置
PYLANCE_CACHE="$HOME/.vscode/extensions/ms-pylance-*/server"
PYRIGHT_CACHE="$HOME/.vscode/extensions/ms-pyright-*/server"

# 删除缓存目录
if [ -d "$PYLANCE_CACHE" ]; then
    echo "删除 Pylance 缓存: $PYLANCE_CACHE"
    rm -rf "$PYLANCE_CACHE"/.pytype 2>/dev/null
fi

# 删除工作区的 .pytype 目录
if [ -d "$(pwd)/.pytype" ]; then
    echo "删除工作区 .pytype 目录"
    rm -rf .pytype
fi

# 删除 __pycache__
echo "删除 __pycache__ 目录..."
find . -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null

echo "缓存清除完成！"
echo ""
echo "现在请：" 
echo "1. 关闭 VSCode"
echo "2. 重新打开 VSCode"
echo "3. 等待 Pylance 重新索引代码（通常需要 10-30 秒）"
