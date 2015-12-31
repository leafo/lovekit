
.PHONY: all watch test lint

test: build
	busted -p _spec.moon$

lint: build
	moonc -l lovekit

watch: build
	moonc -w main.moon lovekit examples

build:
	moonc main.moon lovekit examples


