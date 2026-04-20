#!/bin/bash
# ============================================================
# Test Cloud AI Provider — MiniMax / OpenRouter / OpenAI
# ============================================================
# Usage:
#   ./scripts/test_cloud_ai.sh minimax YOUR_API_KEY
#   ./scripts/test_cloud_ai.sh openrouter YOUR_API_KEY
#   ./scripts/test_cloud_ai.sh openai YOUR_API_KEY
# ============================================================

PROVIDER="${1:-minimax}"
API_KEY="${2:-}"

if [ -z "$API_KEY" ]; then
    echo "Usage: $0 <provider> <api_key>"
    echo "  Providers: minimax, openrouter, openai, deepseek, anthropic"
    exit 1
fi

case "$PROVIDER" in
    minimax)
        URL="https://api.minimax.chat/v1/chat/completions"
        MODEL="MiniMax-Text-01"
        AUTH="Authorization: Bearer $API_KEY"
        ;;
    openrouter)
        URL="https://openrouter.ai/api/v1/chat/completions"
        MODEL="google/gemini-2.0-flash-exp:free"
        AUTH="Authorization: Bearer $API_KEY"
        ;;
    openai)
        URL="https://api.openai.com/v1/chat/completions"
        MODEL="gpt-4o-mini"
        AUTH="Authorization: Bearer $API_KEY"
        ;;
    deepseek)
        URL="https://api.deepseek.com/v1/chat/completions"
        MODEL="deepseek-chat"
        AUTH="Authorization: Bearer $API_KEY"
        ;;
    anthropic)
        URL="https://api.anthropic.com/v1/messages"
        MODEL="claude-3-5-haiku-latest"
        echo "Testing Anthropic Claude..."
        RESPONSE=$(curl -s "$URL" \
            -H "x-api-key: $API_KEY" \
            -H "anthropic-version: 2023-06-01" \
            -H "Content-Type: application/json" \
            -d "{
                \"model\": \"$MODEL\",
                \"messages\": [{\"role\": \"user\", \"content\": \"Say hello in one sentence.\"}],
                \"max_tokens\": 50
            }")
        echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
        exit 0
        ;;
    *)
        echo "Unknown provider: $PROVIDER"
        exit 1
        ;;
esac

echo "Testing $PROVIDER ($MODEL)..."
echo "URL: $URL"
echo ""

RESPONSE=$(curl -s "$URL" \
    -H "$AUTH" \
    -H "Content-Type: application/json" \
    -d "{
        \"model\": \"$MODEL\",
        \"messages\": [{\"role\": \"user\", \"content\": \"Say hello in one sentence.\"}],
        \"max_tokens\": 50,
        \"temperature\": 0.7
    }")

echo "Response:"
echo "$RESPONSE" | python3 -c "
import sys, json
try:
    data = json.loads(sys.stdin.read())
    if 'choices' in data:
        content = data['choices'][0]['message']['content']
        model = data.get('model', 'unknown')
        print(f'✅ Success!')
        print(f'Model: {model}')
        print(f'Reply: {content}')
    elif 'error' in data:
        error = data['error']
        if isinstance(error, dict):
            print(f'❌ Error: {error.get(\"message\", error)}')
        else:
            print(f'❌ Error: {error}')
    else:
        print(json.dumps(data, indent=2))
except:
    print(sys.stdin.read() if hasattr(sys.stdin, 'read') else 'Failed to parse response')
" 2>/dev/null
