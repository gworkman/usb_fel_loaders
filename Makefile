# Makefile for usb_fel_loaders

VERSION=$(strip $(shell cat VERSION))

all: release/pine64.bin release/trellis.bin release/launch.sh

release/pine64.bin: builder/configs/pine64_defconfig
	cd builder && ./build.sh pine64_defconfig
	mkdir -p release
	cp builder/o/pine64/images/u-boot-sunxi-with-spl.bin $@

release/trellis.bin: builder/configs/trellis_defconfig
	cd builder && ./build.sh trellis_defconfig
	mkdir -p release
	cp builder/o/trellis/images/u-boot-sunxi-with-spl.bin $@

release/launch.sh: scripts/launch.sh
	mkdir -p release
	cp $< $@
	chmod +x $@

clean:
	rm -rf builder/o release

.PHONY: all clean
