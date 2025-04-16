# USB FEL Loaders for Allwinner devices

This repository contains a mini-Buildroot for building U-Boot based image
loaders for use on:

- [Trellis](https://protolux.io/projects/trellis)
- Pine64+

## Using the loader

If you only want to use the load, download and untar the latest release from
TBD.

You will also need `sunxi-fel` v1.4.2 or later. See below for installation
instructions or go to [sunxi-tools](https://linux-sunxi.org/Sunxi-tools). The
instructions below expect `sunxi-fel` to be in your `PATH`.

1. Plug the board into your host machine:
   - Trellis: use the device USB-C port
   - Pine64: use the top USB-A port

2. Power-on your board in FEL mode

3. Execute `sunxi-fel <PATH TO UBOOT BIN>`

4. Wait a few seconds and the eMMC of the device should show up as a removable
   storage device. Use `fwup` or `dd` to flash the image and then reset your
   board.

#### Gotchas and Warnings

> ⚠️ **USB Cables and Hubs**: When using the USB FEL Loaders, not all USB cables
> and hubs will work properly. It's recommended to not use any kind of "smart"
> USB Hub or USB-C Docking Station when connecting boards to your machine for
> programming. USB-A to USB-A cables (and if required, a **_basic_** USB-A to
> USB-C adapter) will always work.

> ⚠️ **MacOS Unrecognized Disk Prompt**: When you run the USB FEL Loaders to
> connect a board to a Mac, you may get a prompt that looks like this:
>
> ![Screenshot 2022-11-02 at 11 38 51 AM](https://user-images.githubusercontent.com/61982076/199574378-9868734b-6b12-4af9-9937-ff620e817724.png)
>
> You MUST select the `Ignore` option, if you dismiss this dialog box with any
> other option or key-press the USB device will not be usable, and may become
> unlisted by the OS until you unplug it or reboot your machine.

## Installing sunxi-tools

Here are instructions for installing `sunxi-tools` on different platforms.

### Ubuntu 22.04+

```sh
sudo apt install sunxi-tools
```

### MacOS

This will create a `fel` directory and build `sunxi-tools` and its dependencies
inside it.

```sh
mkdir fel
cd fel
brew install libusb
git clone https://github.com/dgibson/dtc
git clone https://github.com/linux-sunxi/sunxi-tools
make -C dtc libfdt
CFLAGS="-I$PWD/dtc/libfdt -L$PWD/dtc/libfdt" make -C sunxi-tools
```

If that worked without errors, then you can either copy `sunxi-tools/sunxi-fel`
to somewhere in your `$PATH` or use it from that directory.

## Building from source

> NOTE: You may only build this repo on Linux machines with x86_64 or aarch64
> CPUs

```sh
# Build ALL targets
make all

# Build only 1 target
make pine64   

# Clean all target outputs
make clean
```

The resulting loader `u-boot-sunxi-with-spl.bin` file will be located inside
`builder/o/[BOARD_NAME]/output/images`

## Releasing

Update and commit `CHANGELOG.md`.

```sh
export VERSION="vX.Y.Z"
echo $VERSION > VERSION
# Update CHANGELOG.md
git commit -a -m "$VERSION release"
git tag -a $VERSION -m "$VERSION release"

# Make sure that the repository is clean
git clean -fdx
make all

# Push the updates to GitHub
git push --tags
git push
```

Then upload the release `tar.gz` to GitHub releases.
