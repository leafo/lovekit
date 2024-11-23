#!/bin/bash

# adapted from http://love2d.org/wiki/Game_Distribution

set -e
set -o pipefail

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	echo "Usage: $0 [game_name] [target_dir]"
	echo
	echo "Options:"
	echo "  --help, -h         Show this help message and exit"
	echo
	echo "Arguments:"
	echo "  game_name          Name of the game to package (default: 'game')"
	echo "  target_dir         Directory to place output files (default: current directory)"
	exit 0
fi

GAME_NAME=game
TARGET_DIR="."

if [ -n "$1" ]; then
	GAME_NAME=$1
fi

if [ -n "$2" ]; then
	TARGET_DIR=$2
	# Create target directory if it doesn't exist
	mkdir -p "$TARGET_DIR"
fi

GAME_ZIP="${GAME_NAME}.love"
# LOVEKIT_SRC=https://leafo@github.com/leafo/lovekit.git
LOVEKIT_SRC=/home/leafo/srv/git/lovekit.git
LOVE_BIN_WIN="/home/leafo/Downloads/love-0.10.2-win32.zip"
LOVE_BIN_OSX="/home/leafo/Downloads/love-0.10.2-macosx-x64.zip"
MOON_SRC_DIR=/home/leafo/code/moon/moonscript

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
mkdir -p $TMP/release
REL=$(cd $TMP/release && pwd)
LOVEKIT=$TMP/lovekit

log "Preparing $GAME_NAME"
log "Working in $TMP"
log "Output will be placed in $TARGET_DIR"
echo

if [ ! -d "$LOVEKIT" ]; then
	log "Cloning lovekit"
	git clone $LOVEKIT_SRC $LOVEKIT
fi

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
log "Compiling all moon -> lua"
(
	cd $REL
	moonc .
	find . -name "*.moon" -exec rm {} +
)

echo
log "Packing $TARGET_DIR/$GAME_ZIP"
(
	cd $REL
	zip "$GAME_ZIP" $(find .) &> /dev/null
)
mv "$REL/$GAME_ZIP" "$TARGET_DIR"

# create win32 exe
if [ -n "$LOVE_BIN_WIN" ]; then
	log "Creating Windows build..."
	if [ ! -f "$LOVE_BIN_WIN" ]; then
		err "Windows binaries not found, skipping Windows build"
		err "Tried: $LOVE_BIN_WIN"
	else
		mkdir -p $TMP/bin
		(
			cd $TMP/bin
			unzip $LOVE_BIN_WIN &> /dev/null
			mv "$(ls | head -n 1)" "$GAME_NAME"
			cd "$GAME_NAME"
			rm *.txt
			mv love.exe "$GAME_NAME.exe"
		)
		cat "$TARGET_DIR/$GAME_ZIP" >> "$TMP/bin/$GAME_NAME/$GAME_NAME.exe"
		(
			cd $TMP/bin
			zip -r "$GAME_NAME-win32.zip" $(ls) &> /dev/null
			log "Packed $(ls *.zip)"
		)
		mv $TMP/bin/*.zip "$TARGET_DIR"
	fi
fi

if [ -n "$LOVE_BIN_OSX" ]; then
	log "Creating OSX build..."
	if [ ! -f "$LOVE_BIN_OSX" ]; then
		err "OSX binaries not found, skipping OSX build"
		err "Tried: $LOVE_BIN_OSX"
	else
		mkdir -p $TMP/osx
		(
			cd $TMP/osx
			unzip $LOVE_BIN_OSX &> /dev/null
		)
		cp "$TARGET_DIR/$GAME_ZIP" "$TMP/osx/love.app/Contents/Resources/"
		(
			cd $TMP/osx
			cat love.app/Contents/Info.plist | sed 's/>LÖVE</>'$GAME_NAME'</' | sed 's/>org.love2d.love</>net.leafo.'$GAME_NAME'</' | sed '74,101d' | tee love.app/Contents/Info.plist &> /dev/null
			mv love.app "${GAME_NAME}.app"
			zip -r "$GAME_NAME-osx" $(ls) &> /dev/null
			log "Packed $(ls *.zip)"
		)
		mv $TMP/osx/*.zip "$TARGET_DIR"
	fi
fi

rm -rf $TMP

# vim: set noexpandtab ts=2 :
