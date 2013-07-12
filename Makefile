

all::
	moonc lovekit

watch:: all
	moonc -w main.moon lovekit

test:
	busted -p _spec.moon$



