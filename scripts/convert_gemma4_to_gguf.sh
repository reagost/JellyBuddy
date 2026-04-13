#!/bin/bash
# ============================================================
# Gemma 4 E2B: MLX safetensors → GGUF 转换脚本
# ============================================================
#
# 用途: 将 Google Gemma 4 E2B 模型从 HuggingFace 格式转换为
#       GGUF Q4_K_M 量化格式，供 Android/Windows 的 llama.cpp 使用
#
# 前置条件:
#   - Python 3.10+
#   - Git LFS (用于下载大模型文件)
#   - ~10GB 磁盘空间
#
# 产出:
#   models/gemma-4-e2b-it-q4_k_m.gguf (~2.5GB)
#
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MODELS_DIR="$PROJECT_ROOT/models"
LLAMA_CPP_DIR="$MODELS_DIR/llama.cpp"
MODEL_REPO="google/gemma-4-e2b-it"
MODEL_DIR="$MODELS_DIR/gemma-4-e2b-it-hf"
OUTPUT_FILE="$MODELS_DIR/gemma-4-e2b-it-q4_k_m.gguf"

echo "============================================"
echo "  Gemma 4 E2B → GGUF Q4_K_M 转换"
echo "============================================"
echo ""

# Step 1: Install Python dependencies
echo "[1/5] 安装 Python 依赖..."
pip3 install --quiet --upgrade \
    torch \
    transformers \
    sentencepiece \
    protobuf \
    gguf \
    numpy \
    safetensors

# Step 2: Clone llama.cpp (for convert script)
if [ ! -d "$LLAMA_CPP_DIR" ]; then
    echo "[2/5] 克隆 llama.cpp..."
    git clone --depth 1 https://github.com/ggerganov/llama.cpp.git "$LLAMA_CPP_DIR"
else
    echo "[2/5] llama.cpp 已存在，跳过克隆"
fi

# Step 3: Download Gemma 4 E2B from HuggingFace
if [ ! -d "$MODEL_DIR" ]; then
    echo "[3/5] 下载 Gemma 4 E2B 模型 (需要 HuggingFace 登录)..."
    echo ""
    echo "⚠️  注意: Gemma 4 需要接受 Google 的使用条款"
    echo "   请先访问: https://huggingface.co/$MODEL_REPO"
    echo "   然后运行: huggingface-cli login"
    echo ""

    # Check if logged in
    if ! python3 -c "from huggingface_hub import HfApi; HfApi().whoami()" 2>/dev/null; then
        echo "❌ 未登录 HuggingFace。请先运行:"
        echo "   huggingface-cli login"
        exit 1
    fi

    python3 -c "
from huggingface_hub import snapshot_download
snapshot_download(
    repo_id='$MODEL_REPO',
    local_dir='$MODEL_DIR',
    ignore_patterns=['*.bin', '*.pt'],  # 只下载 safetensors
)
print('✅ 模型下载完成')
"
else
    echo "[3/5] 模型已存在于 $MODEL_DIR"
fi

# Step 4: Convert to GGUF F16
echo "[4/5] 转换为 GGUF 格式..."
GGUF_F16="$MODELS_DIR/gemma-4-e2b-it-f16.gguf"

python3 "$LLAMA_CPP_DIR/convert_hf_to_gguf.py" \
    "$MODEL_DIR" \
    --outfile "$GGUF_F16" \
    --outtype f16

echo "✅ F16 GGUF 生成: $GGUF_F16"

# Step 5: Quantize to Q4_K_M
echo "[5/5] 量化为 Q4_K_M..."

# Build llama-quantize if not exists
if [ ! -f "$LLAMA_CPP_DIR/build/bin/llama-quantize" ]; then
    echo "   编译 llama-quantize..."
    cd "$LLAMA_CPP_DIR"
    cmake -B build -DCMAKE_BUILD_TYPE=Release
    cmake --build build --target llama-quantize -j$(sysctl -n hw.ncpu)
    cd "$PROJECT_ROOT"
fi

"$LLAMA_CPP_DIR/build/bin/llama-quantize" \
    "$GGUF_F16" \
    "$OUTPUT_FILE" \
    Q4_K_M

# Cleanup F16 (large)
rm -f "$GGUF_F16"

echo ""
echo "============================================"
echo "  ✅ 转换完成!"
echo "============================================"
echo ""
echo "  输出文件: $OUTPUT_FILE"
echo "  文件大小: $(du -h "$OUTPUT_FILE" | cut -f1)"
echo ""
echo "  下一步:"
echo "  1. 上传到 ModelScope/HuggingFace 供 App 下载"
echo "  2. 或直接推送到设备测试:"
echo "     adb push $OUTPUT_FILE /sdcard/Android/data/com.example.jelly_buddy/files/models/"
echo ""
