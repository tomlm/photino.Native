CC=c++
CFLAGS=-Wall -O2 -std=c++11
DLLFLAGS=-shared -fpic

SRC=./Photino.Native
SRC_SHARED=$(SRC)/Shared
SRC_WIN=$(SRC)/Windows
SRC_MAC=$(SRC)/macOS
SRC_LIN=$(SRC)/Linux

DEST_PATH=./build

DEST_PATH_PROD=$(DEST_PATH)/prod
DEST_PATH_DEV=$(DEST_PATH)/dev
DEST_FILE=Photino.Native

all:
	# "make all is unavailable, use [windows|mac|linux](-dev)."

windows: clean build-windows
mac: clean build-mac
linux: clean build-linux

windows-dev: clean-dev build-windows
mac-dev: clean-dev build-mac-dev
linux-dev: clean-dev install-linux-dependencies build-linux-dev

##
# Cleaning up
##
clean:
	rm -rf $(DEST_PATH_PROD) & mkdir -p $(DEST_PATH_PROD)

clean-dev:
	rm -rf $(DEST_PATH_DEV) & mkdir -p $(DEST_PATH_DEV)

##
# Build for Windows
##
build-windows:
	# "build-windows is not defined"

build-windows-dev:
	# "build-windows-dev is not defined"

##
# Build for macOS
##
pre-build-mac:
	cp $(SRC)/Exports.cpp $(SRC)/Exports.mm

post-build-mac:
	rm -f $(SRC)/Exports.mm

build-mac:
	# "build-mac is not defined"

build-mac-dev:
	make pre-build-mac &&\
	$(CC) $(CFLAGS) $(DLLFLAGS)\
		-framework Cocoa -framework WebKit\
		$(SRC_SHARED)/Structs/*.cpp\
		$(SRC_MAC)/AppDelegate.mm\
		$(SRC_MAC)/PhotinoWebViewUiDelegate.mm\
		$(SRC_MAC)/PhotinoWindowDelegate.mm\
		$(SRC_MAC)/UrlSchemeHandler.mm\
		$(SRC_MAC)/Photino.mm\
		$(SRC)/Exports.mm\
		-o $(DEST_PATH_DEV)/$(DEST_FILE).dylib &&\
	make post-build-mac

##
# Build for Linux
##
install-linux-dependencies:
	sudo apt-get update\
	&& sudo apt-get install\
		libgtk-3-dev\
		libwebkit2gtk-4.0-dev

build-linux:
	# "build-linux is not defined"

build-linux-dev:
	gcc `pkg-config --cflags --libs gtk+-3.0 webkit2gtk-4.0`\
		$(CFLAGS) $(DLLFLAGS)\
		$(SRC_SHARED)/Structs/*.cpp\
		$(SRC_LIN)/Photino.cpp\
		$(SRC)/Exports.cpp\
		-o $(DEST_PATH_DEV)/$(DEST_FILE).so
