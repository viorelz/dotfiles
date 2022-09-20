#!/bin/bash

find . -mindepth 1 -maxdepth 1 -type f -name 'bash*' | while read -r BFILE; do
  F2REPLACE=$(basename "${BFILE}")
  F2REPLACE=".${F2REPLACE}"
  # echo "$HOME/${F2REPLACE} will be replaced!"
  if [ -f "$HOME/${F2REPLACE}" ]; then
    echo "$HOME/${F2REPLACE} will be replaced!"
  fi
done

