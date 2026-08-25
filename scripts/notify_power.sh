#!/usr/bin/env bash
set -euo pipefail

: "${PROJECT_AGENT_WEBHOOK_URL:?PROJECT_AGENT_WEBHOOK_URL is required}"
: "${PROJECT_AGENT_WEBHOOK_SECRET:?PROJECT_AGENT_WEBHOOK_SECRET is required}"

EVENT="${1:-tests-passed}"
SUMMARY="${2:-Salawaat staging CI passed}"
ATTENTION="${3:-none}"

payload=$(cat <<JSON
{"project":"Salawaat","event":"${EVENT}","summary":"${SUMMARY}","attention":"${ATTENTION}","creator":{"name":"Habib Akil"},"actor":{"name":"GitHub Actions","kind":"system"},"repo":"williamnoon/Salawaat","branch":"${GITHUB_REF_NAME:-staging}","commit":"${GITHUB_SHA:-unknown}","sourceUrl":"${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY:-williamnoon/Salawaat}/actions/runs/${GITHUB_RUN_ID:-unknown}","reversible":true}
JSON
)

signature=$(printf '%s' "$payload" | openssl dgst -sha256 -hmac "$PROJECT_AGENT_WEBHOOK_SECRET" -hex | sed 's/^.* //')

request_url="$PROJECT_AGENT_WEBHOOK_URL"
if [[ -n "${VERCEL_AUTOMATION_BYPASS_SECRET:-}" ]]; then
  separator='?'
  [[ "$request_url" == *'?'* ]] && separator='&'
  request_url="${request_url}${separator}x-vercel-protection-bypass=${VERCEL_AUTOMATION_BYPASS_SECRET}"
fi

response=$(curl \
  --fail-with-body \
  --silent \
  --show-error \
  -X POST "$request_url" \
  -H 'content-type: application/json' \
  -H "x-project-agent-signature: sha256=${signature}" \
  --data "$payload")
printf '%s\n' "$response"

if [[ "$response" != *'"ok":true'* ]]; then
  echo "Power webhook did not confirm ok=true" >&2
  exit 1
fi
