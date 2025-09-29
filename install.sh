#!/bin/bash
###############################################################################
# File: install.sh
# Purpose: Hard copy (overwrite) all dot bash config files from this repository
#          into the user's $HOME directory.
# Usage:   ./install.sh
# Notes:   REPLACES existing .bash* files in $HOME with repository versions.
#          Prefer Makefile symlinks if you want to track changes.
# Safe?:   Performs an automatic backup (move) of existing real .bash* files
#          (excluding any matching *history*) into a timestamped directory.
# Backup:  Destination: ${BACKUP_DIR:-$HOME/.dotfiles_backup}/YYYYmmdd_HHMMSS
#          Env:
#            SKIP_BACKUP=1     skip backup phase
#            BACKUP_DIR=/path  override backup root
# Environment:
#   HOME - Destination for the copied files.
# Exit codes:
#   0 - success
#   >0 - unexpected failure during copy
###############################################################################
set -euo pipefail

# --- Backup existing .bash* files (if any) ---------------------------------
ts="$(date +%Y%m%d_%H%M%S)"
backup_root="${BACKUP_DIR:-$HOME/.dotfiles_backup}"
backup_dir="${backup_root}/${ts}"
if [ "${SKIP_BACKUP:-0}" != "1" ]; then
  mkdir -p "$backup_dir"
  moved_any=0
  while IFS= read -r existing; do
    case "$existing" in *history*) continue ;; esac
    if [ ! -L "$existing" ]; then
      mv "$existing" "$backup_dir/" && moved_any=1
    fi
  done < <(find "$HOME" -maxdepth 1 -type f -name '.bash*')
  if [ $moved_any -eq 1 ]; then
    echo "Backup created at $backup_dir"
  else
    rmdir "$backup_dir" 2>/dev/null || true
    echo "No existing real .bash* files to backup"
  fi
else
  echo "SKIP_BACKUP=1 set; skipping backup"
fi

find . -mindepth 1 -maxdepth 1 -type f -name '.bash*' | while read -r BFILE; do
  F2REPLACE=$(basename "${BFILE}")
  if [ -f "$HOME/${F2REPLACE}" ]; then
    echo "$HOME/${F2REPLACE} will be replaced!"
  fi
  cp "${F2REPLACE}" "$HOME/${F2REPLACE}"
done

echo "All .bash* files have been copied to $HOME."
if [ -d "$backup_root" ]; then
  echo "Backups stored under: $backup_root"
fi
