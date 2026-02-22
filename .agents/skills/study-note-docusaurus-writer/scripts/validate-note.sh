#!/usr/bin/env bash
set -euo pipefail

target_file="${1:-}"

if [ -z "$target_file" ]; then
  echo "사용법: $0 <검증할_문서_경로>" >&2
  exit 1
fi

if [ ! -f "$target_file" ]; then
  echo "파일을 찾을 수 없습니다: $target_file" >&2
  exit 1
fi

frontmatter="$(awk '
  BEGIN { fm=0 }
  /^---[[:space:]]*$/ { fm++; next }
  fm==1 { print }
  fm==2 { exit }
' "$target_file")"

errors=0

check_frontmatter_key() {
  local key="$1"
  if ! printf "%s\n" "$frontmatter" | grep -Eq "^${key}:[[:space:]]*.*$"; then
    echo "누락: frontmatter ${key}"
    errors=1
  fi
}

check_frontmatter_key "title"
check_frontmatter_key "description"
check_frontmatter_key "sidebar_position"

if ! printf "%s\n" "$frontmatter" | grep -Eq "^tags:[[:space:]]*$"; then
  echo "누락: frontmatter tags"
  errors=1
fi

if ! awk '
  BEGIN { fm=0; in_tags=0; ok=0 }
  /^---[[:space:]]*$/ { fm++; next }
  fm==1 {
    if ($0 ~ /^tags:[[:space:]]*$/) { in_tags=1; next }
    if (in_tags && $0 ~ /^[[:space:]]*-[[:space:]]+/) { ok=1; next }
    if (in_tags && $0 !~ /^[[:space:]]*$/ && $0 !~ /^[[:space:]]*-[[:space:]]+/) { in_tags=0 }
  }
  END { exit(ok ? 0 : 1) }
' "$target_file"; then
  echo "누락: tags 항목 리스트(- ...)"
  errors=1
fi

if ! grep -Eq '^## Wrap Up[[:space:]]*$' "$target_file"; then
  echo "누락: ## Wrap Up"
  errors=1
fi

if ! grep -Eq '^### Summary[[:space:]]*$' "$target_file"; then
  echo "누락: ### Summary"
  errors=1
fi

if ! grep -Eq '^### Reference[[:space:]]*$' "$target_file"; then
  echo "누락: ### Reference"
  errors=1
fi

if ! awk '
  BEGIN { ref=0; ok=0 }
  /^### Reference[[:space:]]*$/ { ref=1; next }
  ref==1 {
    if ($0 ~ /^[[:space:]]*-[[:space:]]+/) { ok=1; exit }
    if ($0 !~ /^[[:space:]]*$/ && $0 !~ /^[[:space:]]*-[[:space:]]+/) { exit }
  }
  END { exit(ok ? 0 : 1) }
' "$target_file"; then
  echo "누락: Reference 하위 목록(- ...)"
  errors=1
fi

if [ "$errors" -ne 0 ]; then
  exit 1
fi

echo "검증 통과: 기본 구조가 요구사항과 일치합니다."
