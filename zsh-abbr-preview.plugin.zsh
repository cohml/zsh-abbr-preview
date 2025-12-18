#!/usr/bin/env zsh

# License: MIT

# Configuration
: ${ZSH_ABBR_PREVIEW_PREFIX:="→ "}

typeset -g _ABBR_PREVIEW_LAST=""

# Helper: find and return expansion for a matching abbreviation
_abbr_preview_find_expansion() {
  local text="${1}"
  local abbreviation quoted

  # Try suffixes of decreasing length (last N characters)
  local max_len=${#text}
  (( max_len > 50 )) && max_len=50
  for (( len = max_len; len >= 1; len-- )); do
    abbreviation="${text: -$len}"
    quoted="\"${abbreviation}\""

    # Check regular abbreviations
    if (( "${+ABBR_REGULAR_SESSION_ABBREVIATIONS[${quoted}]}" )); then
      echo "${(Q)ABBR_REGULAR_SESSION_ABBREVIATIONS[${quoted}]}"
      return 0
    elif (( "${+ABBR_REGULAR_USER_ABBREVIATIONS[${quoted}]}" )); then
      echo "${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[${quoted}]}"
      return 0
    fi
  done

  return 1
}

# Check for abbreviation and show preview
_abbr_preview_show() {
  # Require zsh-abbr functions
  (( "${+functions[_abbr_regular_expansion]}" )) || return
  (( "${+functions[_abbr_global_expansion]}" )) || return

  # Get text up to cursor
  local before_cursor="${BUFFER[1,${CURSOR}]}"

  local expansion=""

  # Check if regular abbreviation would expand
  local full_expansion="$(_abbr_regular_expansion "${before_cursor}")"

  if [[ -n "${full_expansion}" && "${full_expansion}" != "${before_cursor}" ]]; then
    # Find which abbreviation matched by trying suffixes
    expansion="$(_abbr_preview_find_expansion "${before_cursor}")"
  fi

  # If no regular expansion, try global abbreviations
  if [[ -z "${expansion}" ]]; then
    local -a words
    if (( "${+functions[ABBR_SPLIT_FN]}" )); then
      ABBR_SPLIT_FN "${before_cursor}"
      words=( "${REPLY}" )
    else
      words=( "${(z)before_cursor}" )
    fi

    local max_words=5
    (( max_words > ${#words} )) && max_words=${#words}

    local abbreviation
    for (( word_count = max_words; word_count >= 1; word_count-- )); do
      local start_idx=$(( ${#words} - word_count + 1 ))
      abbreviation="${(j: :)words[${start_idx},-1]}"

      [[ -z "${abbreviation}" ]] && continue

      expansion="$(_abbr_global_expansion "${abbreviation}" 1)"
      [[ -n "${expansion}" ]] && break

      expansion="$(_abbr_global_expansion "${abbreviation}" 0)"
      [[ -n "${expansion}" ]] && break
    done
  fi

  # Display preview
  if [[ -n "${expansion}" ]]; then
    local preview_msg="${ZSH_ABBR_PREVIEW_PREFIX}${expansion}"
    if [[ "${preview_msg}" != "${_ABBR_PREVIEW_LAST}" ]]; then
      zle -M "${preview_msg}"
      _ABBR_PREVIEW_LAST="${preview_msg}"
    fi
  elif [[ -n "${_ABBR_PREVIEW_LAST}" ]]; then
    zle -M ""
    _ABBR_PREVIEW_LAST=""
  fi
}

# Save original widget
typeset -g _ABBR_PREVIEW_ORIG_WIDGET=""

if (( "${+widgets[zle-line-pre-redraw]}" )); then
  case "${widgets[zle-line-pre-redraw]}" in
    user:*) _ABBR_PREVIEW_ORIG_WIDGET="${widgets[zle-line-pre-redraw]#user:}" ;;
    builtin) _ABBR_PREVIEW_ORIG_WIDGET=".zle-line-pre-redraw" ;;
  esac
fi

# Widget wrapper
_abbr_preview_widget() {
  [[ -n "${_ABBR_PREVIEW_ORIG_WIDGET}" ]] && "${_ABBR_PREVIEW_ORIG_WIDGET}"
  _abbr_preview_show
}

# Register widget
zle -N zle-line-pre-redraw _abbr_preview_widget
