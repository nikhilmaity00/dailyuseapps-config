#!/usr/bin/env bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run with sudo (e.g. sudo $0)"
  exit 1
fi

POLICY_DIRS=(
  "/etc/opt/chrome/policies/managed"
  "/etc/chromium/policies/managed"
  "/etc/brave/policies/managed"
  "/etc/opt/edge/policies/managed"
  "/etc/vivaldi/policies/managed"
)

JSON_PAYLOAD='{
  "DefaultSearchProviderEnabled": true,
  "DefaultSearchProviderName": "Google (Web Only)",
  "DefaultSearchProviderSearchURL": "https://www.google.com/search?q={searchTerms}&udm=14",
  "DefaultSearchProviderSuggestURL": "https://www.google.com/complete/search?client=chrome&q={searchTerms}"
}'

for dir in "${POLICY_DIRS[@]}"; do
  mkdir -p "$dir"
  echo "$JSON_PAYLOAD" > "$dir/custom_search.json"
  echo "✓ Applied policy to $dir/custom_search.json"
done

echo "Done! Reload policies in chrome://policy"
