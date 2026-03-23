#!/usr/bin/env bash
# Send a message to Telegram via Bot API (for heartbeat use — no polling)
# Usage: ./send_telegram.sh "Your message here"

set -euo pipefail

BOT_TOKEN="{{bot_token}}"
CHAT_ID="{{chat_id}}"

MESSAGE="${1:?Usage: $0 \"message text\"}"

# Use jq for safe JSON construction (handles special chars, newlines, etc.)
PAYLOAD=$(jq -n --arg chat_id "$CHAT_ID" --arg text "$MESSAGE" \
  '{chat_id: $chat_id, text: $text, parse_mode: "Markdown"}')

RESPONSE=$(curl -s -X POST \
  "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

# Check for errors
OK=$(echo "$RESPONSE" | jq -r '.ok')
if [ "$OK" != "true" ]; then
  echo "ERROR: Telegram API returned error:" >&2
  echo "$RESPONSE" | jq . >&2
  exit 1
fi

echo "Message sent successfully."
