#!/usr/bin/env bash
# Builds the Crewbo IDE for this machine (M8-01): VSCodium's build scripts at
# the commit in VSCODIUM_REF, with Crewbo's product.json merged over theirs,
# Crewbo's app icons from the brand assets at CREWBO_REF, updates switched
# off, and the Crewbo extension built in.
#
#   CREWBO_VSIX=/path/to/crewbo-<version>.vsix ./build.sh
#
# Output: build/vscodium/VSCode-<os>-<arch>/ (VSCodium's folder name).
# Needs VSCodium's build dependencies:
# https://github.com/VSCodium/vscodium/blob/master/docs/howto-build.md
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
work="$here/build"
vsix=${CREWBO_VSIX:?set CREWBO_VSIX to the Crewbo extension .vsix}
vscodium_ref=$(cat "$here/VSCODIUM_REF")
crewbo_ref=$(cat "$here/CREWBO_REF")

mkdir -p "$work"
if [[ ! -d "$work/vscodium/.git" ]]; then
  git clone -q https://github.com/VSCodium/vscodium.git "$work/vscodium"
fi
cd "$work/vscodium"
git fetch -q origin "$vscodium_ref"
git checkout -q --force "$vscodium_ref"

# Crewbo's identity wins: prepare_vscode.sh merges VSCodium's product.json
# over VS Code's last, so ours goes into it.
jq -s '.[0] * .[1]' product.json "$here/product.json" > product.json.crewbo
mv product.json.crewbo product.json

# App icons from Crewbo's brand assets, unchanged.
brand="https://raw.githubusercontent.com/crewbo/crewbo/${crewbo_ref}/docs/brand/assets/png"
icons="$work/icons"
mkdir -p "$icons"
for size in 256 512 1024; do
  curl -fsSL "$brand/app-icon-${size}.png" -o "$icons/app-icon-${size}.png"
done
cp "$icons/app-icon-512.png" src/stable/resources/linux/code.png
magick "$icons/app-icon-256.png" -define icon:auto-resize=256,128,64,48,32,16 src/stable/resources/win32/code.ico
# ponytail: macOS keeps VSCodium's code.icns until M8-02 builds on macOS
# (iconutil there turns the 1024 px icon into an .icns).

export APP_NAME="CrewboIDE"
export BINARY_NAME="crewbo-ide"
export ORG_NAME="Crewbo"
export ASSETS_REPOSITORY="crewbo/ide"
export GH_REPO_PATH="crewbo/ide"
export CI_BUILD="no"
export SHOULD_BUILD="yes"
export SKIP_ASSETS="yes"
export SKIP_BUILD="no"
export SKIP_SOURCE="no"
export VSCODE_LATEST="no"
export VSCODE_QUALITY="stable"
export VSCODE_SKIP_NODE_VERSION_CHECK="yes"
export DISABLE_UPDATE="yes"
export NODE_OPTIONS="--max-old-space-size=8192"
case "$(uname -s)" in
  Darwin) export OS_NAME="osx" ;;
  MINGW* | MSYS* | CYGWIN*) export OS_NAME="windows" ;;
  *) export OS_NAME="linux" ;;
esac
case "$(uname -m)" in
  aarch64 | arm64) export VSCODE_ARCH="arm64" ;;
  *) export VSCODE_ARCH="x64" ;;
esac

rm -rf vscode VSCode-*
# VSCodium's scripts read unset variables; they are sourced, as dev/build.sh does.
set +u
. get_repo.sh
. version.sh
. build.sh
set -u

# The Crewbo extension, built in: a .vsix is a zip whose extension/ folder
# is the extension itself.
out="$work/vscodium/VSCode-${OS_NAME}-${VSCODE_ARCH}"
app="$out/resources/app"
[[ "$OS_NAME" == "osx" ]] && app="$out/Crewbo IDE.app/Contents/Resources/app"
rm -rf "$work/vsix" "$app/extensions/crewbo"
mkdir -p "$work/vsix"
unzip -q "$vsix" -d "$work/vsix"
cp -r "$work/vsix/extension" "$app/extensions/crewbo"
echo "Built $out"
