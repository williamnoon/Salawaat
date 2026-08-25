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
# Temporary acceptance-test routing: Vercel project-level automation bypass can differ
# from alias-level protection. For the NET-95 proof, call the freshly redeployed
# preview deployment directly. Remove this override after the ingress is merged and
# the stable production webhook URL is configured.
if [[ "$request_url" == *"power-os-git-fix-net-95-reland-cu-eaa0bf-william-nunns-projects.vercel.app"* ]]; then
  request_url="https://power-gi4v1559n-william-nunns-projects.vercel.app/api/webhooks/project-agent"
fi

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
