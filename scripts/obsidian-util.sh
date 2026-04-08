#!/usr/bin/env bash
set -euo pipefail

VAULT="${HOME}/Vault"
DAILY_FOLDER="daily"

usage() {
  cat <<'EOF'
Usage: obsidian-util [OPTIONS] COMMAND

Options:
  --vault PATH          Vault root path (default: ~/Vault)
  --daily-folder NAME   Daily notes subfolder (default: daily)
  -h, --help            Show this help

Commands:
  daily journal "text"  Add a timestamped journal entry to today's daily note
  daily task "text"     Add a task to today's daily note
  daily note "text"     Add a note to today's daily note
  daily show            Print today's daily note to stdout
  daily open            Open today's daily note in nvim
  search "query"        Search vault notes for a query
EOF
  exit "${1:-0}"
}

# Parse global flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --vault)
      VAULT="$2"
      shift 2
      ;;
    --daily-folder)
      DAILY_FOLDER="$2"
      shift 2
      ;;
    -h|--help)
      usage 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage 1
      ;;
    *)
      break
      ;;
  esac
done

# Expand ~ in vault path
VAULT="${VAULT/#\~/$HOME}"

# Require a command
if [[ $# -lt 1 ]]; then
  echo "Error: No command specified" >&2
  usage 1
fi

# Ensure today's daily note exists, print path
ensure_daily() {
  local today
  today="$(date +%Y-%m-%d)"
  local now
  now="$(date +%H:%M)"
  local dir="${VAULT}/${DAILY_FOLDER}"
  local file="${dir}/${today}.md"

  mkdir -p "$dir"

  if [[ ! -f "$file" ]]; then
    cat > "$file" <<TMPL
# ${today}

## Tasks

## Notes

## Journal

- **${now}**: Note created
TMPL
  fi

  echo "$file"
}

# Append an entry under a ## heading in a file
# Usage: append_to_section <file> <section> <entry>
append_to_section() {
  local file="$1"
  local section="$2"
  local entry="$3"

  # Find the line number of the section heading
  local section_line
  section_line="$(grep -n "^## ${section}$" "$file" | head -1 | cut -d: -f1)"

  if [[ -z "$section_line" ]]; then
    # Section doesn't exist — append it
    printf '\n## %s\n\n%s\n' "$section" "$entry" >> "$file"
    return
  fi

  # Find the next ## heading after this section (if any)
  local next_section_line
  next_section_line="$(tail -n +"$((section_line + 1))" "$file" | grep -n '^## ' | head -1 | cut -d: -f1)" || true

  local insert_at
  if [[ -n "$next_section_line" ]]; then
    # Insert before the blank line preceding the next heading
    insert_at=$((section_line + next_section_line - 1))
    # Walk backwards over blank lines to find the real insertion point
    while [[ $insert_at -gt $((section_line + 1)) ]] && sed -n "$((insert_at - 1))p" "$file" | grep -q '^$'; do
      insert_at=$((insert_at - 1))
    done
  else
    # No next section — find last non-blank line after the heading
    local total_lines
    total_lines="$(wc -l < "$file")"
    insert_at=$((total_lines + 1))
    while [[ $insert_at -gt $((section_line + 1)) ]] && sed -n "$((insert_at - 1))p" "$file" | grep -q '^$'; do
      insert_at=$((insert_at - 1))
    done
  fi

  # Check if this is the first item (nothing between heading and insert point)
  local has_content=false
  for ((i = section_line + 1; i < insert_at; i++)); do
    if ! sed -n "${i}p" "$file" | grep -q '^$'; then
      has_content=true
      break
    fi
  done

  # Build the replacement file
  local tmpfile
  tmpfile="$(mktemp)"
  head -n "$((insert_at - 1))" "$file" > "$tmpfile"
  if [[ "$has_content" == false ]]; then
    echo >> "$tmpfile"
  fi
  echo "$entry" >> "$tmpfile"
  # Ensure a blank line before the next section heading
  local total_lines
  total_lines="$(wc -l < "$file")"
  if [[ -n "$next_section_line" ]] && [[ $insert_at -le $total_lines ]]; then
    local next_line
    next_line="$(sed -n "${insert_at}p" "$file")"
    if [[ -n "$next_line" ]]; then
      echo >> "$tmpfile"
    fi
  fi
  tail -n +"$insert_at" "$file" >> "$tmpfile"
  mv "$tmpfile" "$file"
}

cmd_daily_journal() {
  local text="$1"
  local now
  now="$(date +%H:%M)"
  local file
  file="$(ensure_daily)"

  append_to_section "$file" "Journal" "- **${now}**: ${text}"
  echo "[${now}] Journal added to ${file}"
}

cmd_daily_task() {
  local text="$1"
  local file
  file="$(ensure_daily)"

  append_to_section "$file" "Tasks" "- [ ] ${text}"
  echo "Task added to ${file}"
}

cmd_daily_note() {
  local text="$1"
  local file
  file="$(ensure_daily)"

  append_to_section "$file" "Notes" "- ${text}"
  echo "Note added to ${file}"
}

# Route commands
case "$1" in
  daily)
    shift
    if [[ $# -lt 1 ]]; then
      echo "Error: daily requires a subcommand (journal, task, note)" >&2
      exit 1
    fi
    case "$1" in
      journal)
        shift
        if [[ $# -lt 1 ]]; then
          echo "Error: daily journal requires text argument" >&2
          exit 1
        fi
        cmd_daily_journal "$1"
        ;;
      task)
        shift
        if [[ $# -lt 1 ]]; then
          echo "Error: daily task requires text argument" >&2
          exit 1
        fi
        cmd_daily_task "$1"
        ;;
      note)
        shift
        if [[ $# -lt 1 ]]; then
          echo "Error: daily note requires text argument" >&2
          exit 1
        fi
        cmd_daily_note "$1"
        ;;
      show)
        file="$(ensure_daily)"
        cat "$file"
        ;;
      open)
        file="$(ensure_daily)"
        nvim "$file"
        ;;
      *)
        echo "Unknown daily subcommand: $1" >&2
        exit 1
        ;;
    esac
    ;;
  search)
    shift
    if [[ $# -lt 1 ]]; then
      echo "Error: search requires a query argument" >&2
      exit 1
    fi
    grep -rl --include="*.md" "$1" "$VAULT" | while read -r f; do
      rel="${f#"$VAULT"/}"
      echo "=== $rel ==="
      grep -n "$1" "$f"
      echo
    done
    ;;
  *)
    echo "Unknown command: $1" >&2
    usage 1
    ;;
esac
