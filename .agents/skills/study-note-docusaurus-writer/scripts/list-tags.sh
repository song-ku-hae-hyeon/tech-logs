#!/usr/bin/env bash
set -euo pipefail

tags_file="${1:-docs/tags.yml}"

if [ ! -f "$tags_file" ]; then
  echo "tags 파일을 찾을 수 없습니다: $tags_file" >&2
  exit 1
fi

awk '
  /^[a-zA-Z0-9-]+:[[:space:]]*$/ {
    if (key != "") {
      printf("- %s | permalink: %s | label: %s\n", key, permalink, label)
    }
    key = substr($1, 1, length($1) - 1)
    permalink = ""
    label = ""
    next
  }
  /^[[:space:]]+permalink:[[:space:]]*/ {
    permalink = $2
    gsub(/"/, "", permalink)
    next
  }
  /^[[:space:]]+label:[[:space:]]*/ {
    $1 = ""
    label = $0
    sub(/^[[:space:]]+/, "", label)
    gsub(/"/, "", label)
    next
  }
  END {
    if (key != "") {
      printf("- %s | permalink: %s | label: %s\n", key, permalink, label)
    }
  }
' "$tags_file"
