#!/bin/bash

set -e

echo "Running Flutter tests with coverage..."

flutter test --coverage

echo "Filtering out auto-generated files from coverage..."

lcov --remove coverage/lcov.info \
  'lib/l10n/app_localizations*.dart' \
  --ignore-errors unused \
  -o coverage/lcov.info

if [ "$1" = "--html" ]; then
  echo "Generating HTML coverage report..."
  genhtml coverage/lcov.info -o coverage/html
  echo "Coverage report generated at coverage/html/index.html"
  
  if command -v open >/dev/null 2>&1; then
    open coverage/html/index.html
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open coverage/html/index.html
  fi
fi

echo "Coverage Summary:"
lcov --summary coverage/lcov.info