

all::
	moonc main.moon lovekit examples

watch:: all
	moonc -w main.moon lovekit examples

test:
	busted -p _spec.moon$


lint:
	moonc -l lovekit
