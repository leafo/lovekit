
all:
	moonc main.moon lovekit

test: all
	love .

watch:
	moonc -w main.moon lovekit