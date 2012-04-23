#!/bin/sh

set -e
set -o pipefail

# include moonscript?
GAME_NAME=game
if [ -n "$1" ]; then
	GAME_NAME=$1
fi

GAME_ZIP=$GAME_NAME.love

# LOVEKIT_SRC=https://leafo@github.com/leafo/lovekit.git
LOVEKIT_SRC=/srv/git/lovekit.git

LOVE_BIN=/home/leafo/Downloads/love-0.8.0-win-x86.zip
MOON_SRC_DIR=/home/leafo/code/lua/moonscript

if [ -z "`git status 2> /dev/null`" ]; then
	echo ">> Must run in a git repository"
	exit 1
fi

function copyall() {
	mkdir -p $2
	tar -c $1 | tar -C $2 -x
}

TMP=`mktemp -d`

# TMP=tmp
# [ -d "$TMP" ] && rm -rf "$TMP"

mkdir -p $TMP/release

REL=`cd $TMP/release && pwd`
LOVEKIT=$TMP/lovekit

echo ">> Preparing $GAME_NAME"
echo ">> Working in $TMP"
echo ""

[ ! -d "$LOVEKIT" ] && git clone $LOVEKIT_SRC $LOVEKIT

copyall "`git ls-files`" $REL
(cd $LOVEKIT && copyall "`git ls-files | grep ^lovekit`" $REL)

if [ -n "$MOON_SRC_DIR" ]; then
	echo ""
	echo ">> Copying moon"
	(
		cd $MOON_SRC_DIR
		bin/splat.moon moon > "$REL/moon.lua"
	)
fi

echo ""
echo ">> Building"
(
	cd $REL
	moonc .
	rm `find . | grep \.moon$`
)


echo ""
echo ">> Packing $GAME_ZIP"

(
	cd $REL
	zip "$GAME_ZIP" `find .` &> /dev/null
)

mv "$REL/$GAME_ZIP" .


# create win32 exe
if [ -n "$LOVE_BIN" ]; then
	echo ">> Creating exe"
	mkdir -p $TMP/bin
	(
		cd $TMP/bin
		unzip $LOVE_BIN &> /dev/null
		mv "`ls | head -n 1`" "$GAME_NAME"
		cd "$GAME_NAME"
		rm *.txt
		mv love.exe "$GAME_NAME.exe"
	)

	cat $GAME_ZIP >> "$TMP/bin/$GAME_NAME/$GAME_NAME.exe"
	(
		cd $TMP/bin
		zip -r "$GAME_NAME-win32.zip" `ls` &> /dev/null
		echo ">> Packing `ls *.zip`"
	)

	mv $TMP/bin/*.zip .
fi

rm -rf $TMP

