#!/bin/bash

API_KEY="AQ.Ab8RN6LazCKwxBmzBWdnwseIUznuCUfomAPBLpy0aCbfv031eg"
PROJECT_ID="18072097460985571906"
ENDPOINT="https://stitch.googleapis.com/mcp"

# Initialize
INIT_RESP=$(curl -s -N "$ENDPOINT" \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"codebuddy","version":"1.0"}},"id":0}')

echo "Init: $INIT_RESP"

# Send tools/list request
TOOLS_RESP=$(curl -s -N "$ENDPOINT" \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/list","params":{},"id":1}')

echo "Tools: $TOOLS_RESP" | head -c 2000
