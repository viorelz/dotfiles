#!/bin/bash

find . -mindepth 1 -maxdepth 1 -type f -name '.bash*' | while read -r BFILE; do
  F2REPLACE=$(basename "${BFILE}")
  # echo "$HOME/${F2REPLACE} will be replaced!"
  if [ -f "$HOME/${F2REPLACE}" ]; then
    echo "$HOME/${F2REPLACE} will be replaced!"
  fi
  cp "${F2REPLACE}" "$HOME/${F2REPLACE}"
done
