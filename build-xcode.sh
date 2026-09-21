#!/bin/bash
# Configure and build MiniOB as an Xcode project (macOS / Apple Silicon).
#
# Usage:
#   ./build_xcode.sh          # configure + build Debug
#   ./build_xcode.sh open     # configure + build, then open in Xcode
#
# The generated project is at build_xcode/minidb.xcodeproj. Every CMake target
# (observer, obclient, clog_dump, unit tests) gets its own Xcode scheme, so you
# can select a scheme in Xcode and hit Run.
#
# Third-party dependencies must be prepared first with:
#   bash .vscode/setup-deps.sh
set -euo pipefail

TOPDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$TOPDIR/build_xcode"
PREFIX="${THIRD_PARTY_INSTALL_PREFIX:-$TOPDIR/deps/3rd/usr/local}"
CMAKE="${CMAKE:-/opt/homebrew/bin/cmake}"

# Make sure CMake uses the Xcode toolchain and SDK.
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

"$CMAKE" -S "$TOPDIR" -B "$BUILD_DIR" -G Xcode \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_C_COMPILER=/usr/bin/clang \
  -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
  -DCMAKE_PREFIX_PATH="$PREFIX;/opt/homebrew" \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  -DFLEX_EXECUTABLE=/opt/homebrew/opt/flex/bin/flex \
  -DBISON_EXECUTABLE=/opt/homebrew/opt/bison/bin/bison \
  -DWITH_UNIT_TESTS=ON -DWITH_BENCHMARK=OFF -DWITH_MEMTRACER=OFF -DENABLE_ASAN=ON

"$CMAKE" --build "$BUILD_DIR" --config Debug --parallel 4

if [[ "${1:-}" == "open" ]]; then
  open "$BUILD_DIR/minidb.xcodeproj"
fi
