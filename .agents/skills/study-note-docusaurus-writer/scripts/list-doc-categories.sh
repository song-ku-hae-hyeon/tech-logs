#!/usr/bin/env bash
set -euo pipefail

docs_root="${1:-docs}"

if [ ! -d "$docs_root" ]; then
  echo "docs 디렉터리를 찾을 수 없습니다: $docs_root" >&2
  exit 1
fi

echo "1depth 카테고리:"
while IFS= read -r top_dir; do
  top_name="$(basename "$top_dir")"
  echo "- $top_name"

  subdirs="$(find "$top_dir" -mindepth 1 -maxdepth 1 -type d ! -name "img" | sort || true)"
  if [ -z "$subdirs" ]; then
    echo "  - (하위 카테고리 없음)"
    continue
  fi

  while IFS= read -r sub_dir; do
    [ -z "$sub_dir" ] && continue
    echo "  - $(basename "$sub_dir")"
  done <<< "$subdirs"
done < <(find "$docs_root" -mindepth 1 -maxdepth 1 -type d | sort)
