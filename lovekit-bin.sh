#!/bin/sh

# adapted from http://love2d.org/wiki/Game_Distribution

set -e
set -o pipefail

GAME_NAME=game
if [ -n "$1" ]; then
	GAME_NAME=$1
fi

GAME_ZIP="${GAME_NAME}.love"

# LOVEKIT_SRC=https://leafo@github.com/leafo/lovekit.git
LOVEKIT_SRC=/srv/git/lovekit.git

LOVE_BIN_WIN="/home/leafo/Downloads/love-0.9.0-win32.zip"
# LOVE_BIN_OSX="/home/leafo/Downloads/love-0.8.0-macosx-ub.zip"

MOON_SRC_DIR=/home/leafo/code/lua/moonscript

function log {
	echo "$(tput setaf 4)>>$(tput sgr0) " $@
}

function err {
	echo "$(tput bold)$(tput setaf 1)>>$(tput sgr0) " $@
}

if [ -z "$(git status 2> /dev/null)" ]; then
	err "Must run in a git repository"
	exit 1
fi

function copyall {
	mkdir -p $2
	tar -c $1 | tar -C $2 -x
}

TMP=$(mktemp -d)

# TMP=tmp
# [ -d "$TMP" ] && rm -rf "$TMP"

mkdir -p $TMP/release

REL=$(cd $TMP/release && pwd)
LOVEKIT=$TMP/lovekit

log "Preparing $GAME_NAME"
log "Working in $TMP"
echo

[ ! -d "$LOVEKIT" ] && git clone $LOVEKIT_SRC $LOVEKIT

copyall "$(git ls-files | grep -v '\.xcf$')" $REL
(cd $LOVEKIT && copyall "$(git ls-files | grep ^lovekit)" $REL)

if [ -n "$MOON_SRC_DIR" ]; then
	echo
	log "Copying moon"
	(
		cd $MOON_SRC_DIR
		bin/splat.moon moon > "$REL/moon.lua"
	)
fi

echo
log "Building"
(
	cd $REL
	moonc .
	rm $(find . | grep \.moon$)
)


echo
log "Packing $GAME_ZIP"

(
	cd $REL
	zip "$GAME_ZIP" $(find .) &> /dev/null
)

mv "$REL/$GAME_ZIP" .


# create win32 exe
if [ -n "$LOVE_BIN_WIN" ]; then
	log "Creating Windows build"
	mkdir -p $TMP/bin
	(
		cd $TMP/bin
		unzip $LOVE_BIN_WIN &> /dev/null
		mv "$(ls | head -n 1)" "$GAME_NAME"
		cd "$GAME_NAME"
		rm *.txt
		mv love.exe "$GAME_NAME.exe"
	)

	cat $GAME_ZIP >> "$TMP/bin/$GAME_NAME/$GAME_NAME.exe"
	(
		cd $TMP/bin
		zip -r "$GAME_NAME-win32.zip" $(ls) &> /dev/null
		log "Packed $(ls *.zip)"
	)

	mv $TMP/bin/*.zip .
fi

if [ -n "$LOVE_BIN_OSX" ]; then
	log "Creating OSX build"
	mkdir -p $TMP/osx

	(
		cd $TMP/osx
		unzip $LOVE_BIN_OSX &> /dev/null
	)

	cp "$GAME_ZIP" "$TMP/osx/love.app/Contents/Resources/"

	(
		cd $TMP/osx
		cat love.app/Contents/Info.plist | sed 's/>LÖVE</>'$GAME_NAME'</' | sed 's/>org.love2d.love</>net.leafo.'$GAME_NAME'</' | sed '74,101d' | tee love.app/Contents/Info.plist &> /dev/null
		mv love.app "${GAME_NAME}.app"

		zip -r "$GAME_NAME-osx" $(ls) &> /dev/null
		log "Packed $(ls *.zip)"
	)

	mv $TMP/osx/*.zip .
fi

rm -rf $TMP

