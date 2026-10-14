#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

ANDROID_KEY="${MEASURE_ANDROID_API_KEY:-}"
IOS_KEY="${MEASURE_IOS_API_KEY:-}"
API_URL="${MEASURE_API_URL:-}"

if [[ -n "$ANDROID_KEY" ]]; then
  if [[ -z "$API_URL" ]]; then
    echo "::error::MEASURE_API_URL must be set when MEASURE_ANDROID_API_KEY is set"
    exit 1
  fi
  cat >"$ROOT/android/measure.properties" <<EOF
measure.apiKey=$ANDROID_KEY
measure.apiUrl=$API_URL
EOF
  echo "Wrote android/measure.properties"
else
  echo "MEASURE_ANDROID_API_KEY not set; skipping android/measure.properties"
fi

if [[ -n "$IOS_KEY" ]]; then
  if [[ -z "$API_URL" ]]; then
    echo "::error::MEASURE_API_URL must be set when MEASURE_IOS_API_KEY is set"
    exit 1
  fi
  cat >"$ROOT/ios/Flutter/MeasureSecrets.xcconfig" <<EOF
MEASURE_API_KEY=$IOS_KEY
MEASURE_API_URL=$API_URL
EOF
  echo "Wrote ios/Flutter/MeasureSecrets.xcconfig"
else
  echo "MEASURE_IOS_API_KEY not set; skipping ios/Flutter/MeasureSecrets.xcconfig"
fi
