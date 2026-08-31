#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
#
# SPDX-License-Identifier: ISC

set -Eeuo pipefail

readonly release_url="https://github.com/arcangelo7/portfolio/releases/latest/download/portfolio-web-latest.zip"
readonly project_dir="/root/portfolio"
readonly build_dir="$project_dir/build"
readonly web_dir="$build_dir/web"

mkdir -p "$build_dir"
temporary_dir=$(mktemp -d "$build_dir/.web-deploy.XXXXXX")
readonly temporary_dir
readonly archive="$temporary_dir/portfolio-web-latest.zip"
readonly staged_web_dir="$temporary_dir/web"
readonly previous_web_dir="$temporary_dir/previous-web"

cleanup() {
  rm -rf "$temporary_dir"
}

rollback() {
  local status=$?

  if [[ -d "$previous_web_dir" && ! -e "$web_dir" ]]; then
    mv "$previous_web_dir" "$web_dir"
  fi

  exit "$status"
}

trap cleanup EXIT

curl --fail --location --silent --show-error "$release_url" --output "$archive"
mkdir "$staged_web_dir"
unzip -q "$archive" -d "$staged_web_dir"

test -f "$staged_web_dir/index.html"
test -f "$staged_web_dir/flutter_bootstrap.js"
test -f "$staged_web_dir/main.dart.js"
grep -Fq '<base href="/">' "$staged_web_dir/index.html"

trap rollback ERR

if [[ -e "$web_dir" ]]; then
  mv "$web_dir" "$previous_web_dir"
fi

mv "$staged_web_dir" "$web_dir"

trap - ERR
