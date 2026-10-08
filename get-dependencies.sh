#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm sdl2-compat

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini libdecor-mini

echo "Building OpenRealm..."
echo "---------------------------------------------------------------"
REPO="https://github.com/corepunch/open-realm"
if [ "${DEVEL_RELEASE-}" = 1 ]; then
    echo "Making nightly build of OpenRealm..."
    echo "---------------------------------------------------------------"
    VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
    git clone --depth 1 "$REPO" ./open-realm
else
	echo "Making stable build of OpenRealm..."
	VERSION="$(git ls-remote --tags --sort="v:refname" "$REPO" | tail -n1 | sed 's/.*\///; s/\^{}//; s/^v//')"
	git clone --branch v"$VERSION" --single-branch --depth 1 "$REPO" ./open-realm
fi
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin/wc3
mkdir -p ./AppDir/bin/sc2
mkdir -p ./AppDir/bin/wow
cd ./open-realm
make -j$(nproc) BUILD=release FFMPEG=1 GL_BACKEND=gl GLSL=150 openwarcraft3
mv -v ./build/bin/openwarcraft3 ../AppDir/bin
mv -v ./build/lib/* /usr/lib
make clean && make -j$(nproc) BUILD=release FFMPEG=1 GL_BACKEND=gl GLSL=150 openwow
mv -v ./build/bin/openwow ../AppDir/bin
mv -v ./build/lib/* /usr/lib
make clean && make -j$(nproc) BUILD=release FFMPEG=1 GL_BACKEND=gl GLSL=150 opensc2
mv -v ./build/bin/opensc2 ../AppDir/bin
mv -v ./build/lib/* /usr/lib
mv -v ./games/warcraft-3/share/config.cfg ../AppDir/bin/wc3
mv -v ./games/starcraft-2/share/config.cfg ../AppDir/bin/sc2
mv -v ./games/world-of-warcraft/share/config.cfg ../AppDir/bin/wow
