#!/usr/bin/env bash
set -euo pipefail

target_dir="${1:-}"

if [ -z "$target_dir" ]; then
  echo "사용법: $0 <대상_폴더>" >&2
  exit 1
fi

if [ ! -d "$target_dir" ]; then
  echo "대상 폴더를 찾을 수 없습니다: $target_dir" >&2
  exit 1
fi

positions=()
while IFS= read -r file; do
  value="$(awk '
    BEGIN { fm=0 }
    /^---[[:space:]]*$/ { fm++; next }
    fm==1 && $1=="sidebar_position:" { print $2; exit }
  ' "$file")"

  if [[ "$value" =~ ^[0-9]+$ ]]; then
    positions+=("$value")
  fi
done < <(find "$target_dir" -mindepth 1 -maxdepth 1 -type f \( -name "*.md" -o -name "*.mdx" \) | sort)

if [ "${#positions[@]}" -eq 0 ]; then
  echo "기존 sidebar_position이 없습니다."
  echo "추천 sidebar_position: 1"
  exit 0
fi

uniq_sorted="$(printf "%s\n" "${positions[@]}" | sort -n | uniq)"
max=0
display=""
while IFS= read -r n; do
  [ -z "$n" ] && continue
  display="${display}${n} "
  if [ "$n" -gt "$max" ]; then
    max="$n"
  fi
done <<< "$uniq_sorted"

recommended=$((max + 1))

echo "기존 sidebar_position: ${display}"
echo "추천 sidebar_position: $recommended"
