# Convenience for testing locally

VERSION=$(strip $(shell cat VERSION))
ARCHIVE_NAME=usb_fel_loaders-$(VERSION)
ARCHIVE=$(ARCHIVE_NAME).tar.gz

all: $(ARCHIVE)

pine64: builder/configs/pine64_defconfig release/launch.sh
	cd builder && ./build.sh pine64_defconfig
	mkdir -p release/boards/pine64
	cp builder/o/pine64/images/u-boot-sunxi-with-spl.bin release/boards/pine64/u-boot-loader.bin

release/launch.sh: scripts/launch.sh
	mkdir -p release
	cp $< $@

$(ARCHIVE): pine64
	tar --transform 's,^release,$(ARCHIVE_NAME),' -czf $@ release

clean:
	rm -rf builder/o release $(ARCHIVE)

.PHONY: all clean pine64 
