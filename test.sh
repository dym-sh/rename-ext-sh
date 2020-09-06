#!/bin/bash

echo "\$\@: '$@'"

echo `getopts 'ext-only':`

for ARG in "$@"; do
  case "$ARG" in
    "--ext-only")
      echo 'ext-only'
      shift
      ;;
  esac
done

echo "\$\@: '$@'"
