#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

read_measure_property() {
  local file="$1"
  local key="$2"
  if [[ ! -f "$file" ]]; then
    return 0
  fi
  local line
  line="$(grep -E "^${key}=" "$file" 2>/dev/null | tail -n 1 || true)"
  if [[ -n "$line" ]]; then
    printf '%s' "${line#*=}"
  fi
}

MEASURE_PROPERTIES="$ROOT/android/measure.properties"

ANDROID_KEY="${MEASURE_ANDROID_API_KEY:-}"
IOS_KEY="${MEASURE_IOS_API_KEY:-}"
API_URL="${MEASURE_API_URL:-}"

if [[ -z "$ANDROID_KEY" ]]; then
  ANDROID_KEY="$(read_measure_property "$MEASURE_PROPERTIES" "measure.apiKey")"
fi
if [[ -z "$IOS_KEY" ]]; then
  IOS_KEY="$(read_measure_property "$MEASURE_PROPERTIES" "measure.ios.apiKey")"
fi
if [[ -z "$API_URL" ]]; then
  API_URL="$(read_measure_property "$MEASURE_PROPERTIES" "measure.apiUrl")"
fi

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
