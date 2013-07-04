

all::
	moonc lovekit

watch:: all
	moonc -w main.moon lovekit

test: all
	love .
