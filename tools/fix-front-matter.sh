#!/usr/bin/env sh
set -eu

SOURCE_DIR="${1:-source}"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Source directory not found: $SOURCE_DIR" >&2
  exit 1
fi

find "$SOURCE_DIR" -type f -name '*.md' | while IFS= read -r file; do
  first_line=''
  IFS= read -r first_line < "$file" || true

  if [ "$first_line" = "---" ]; then
    continue
  fi

  title=$(awk '
    /^#[[:space:]]+/ {
      sub(/^#[[:space:]]+/, "")
      print
      exit
    }
  ' "$file")

  if [ -z "$title" ]; then
    title=$(basename "$file" .md)
  fi

  title=$(printf '%s' "$title" | sed 's/\\/\\\\/g; s/"/\\"/g')
  date_value=$(date -r "$file" '+%Y-%m-%d %H:%M:%S')
  tmp_file=$(mktemp)

  {
    printf '%s\n' '---'
    printf 'title: "%s"\n' "$title"
    printf 'date: %s\n' "$date_value"
    printf '%s\n' 'tags:'
    printf '%s\n' '  - note'
    printf '%s\n\n' '---'
    cat "$file"
  } > "$tmp_file"

  mv "$tmp_file" "$file"
  echo "Added front-matter: $file"
done

echo "Front-matter check complete."
