SHELL := /bin/bash -O globstar
LOVE2D_URL_WINDOWS := https://github.com/love2d/love/releases/download/11.4/love-11.4-win32.zip
LOVE2D_URL_MACOS := https://github.com/love2d/love/releases/download/11.4/love-11.4-macos.zip
VERSION := $(shell git tag --list | tail -n 1)
RELEASE_NAME := 7drl-$(VERSION)
RELEASE_NAME_ALL_PLATFORMS := $(RELEASE_NAME)-allplatforms
RELEASE_NAME_WINDOWS := $(RELEASE_NAME)-windows

.DELETE_ON_ERROR:

.PHONY: run
run: build
	cd build/ && love .

.PHONY: build
build:
	rm -rf build/
	mkdir -p build/
	cp -r assets/ build/
	cd src/ && cp --parents **/*.lua ../build/

.PHONY: dist
dist: clean build
	mkdir -p dist/
	mkdir dist/$(RELEASE_NAME)-allplatforms/
	cd build &&\
zip -9 --no-dir-entries -r ../dist/$(RELEASE_NAME_ALL_PLATFORMS)/$(RELEASE_NAME).love .
	cp README.md LICENSE.txt dist/$(RELEASE_NAME)-allplatforms
	cd dist/ &&\
zip -9 -r $(RELEASE_NAME)-allplatforms.zip $(RELEASE_NAME_ALL_PLATFORMS)

	wget $(LOVE2D_URL_WINDOWS) -O dist/love2d-windows.zip
	cd dist/ && unzip love2d-windows.zip
	mkdir dist/$(RELEASE_NAME_WINDOWS)/
	cp dist/love*/*.dll dist/$(RELEASE_NAME_WINDOWS)/
	cp dist/love*/license.txt \
dist/$(RELEASE_NAME_WINDOWS)/love2d-license.txt
	cp README.md LICENSE.txt dist/$(RELEASE_NAME_WINDOWS)/
	cat dist/love*/love.exe dist/$(RELEASE_NAME_ALL_PLATFORMS)/$(RELEASE_NAME).love > \
dist/$(RELEASE_NAME_WINDOWS)/$(RELEASE_NAME).exe
	cd dist/ &&\
zip -9 -r $(RELEASE_NAME_WINDOWS).zip $(RELEASE_NAME_WINDOWS)

.PHONY: clean
clean:
	rm -rf build/ dist/
