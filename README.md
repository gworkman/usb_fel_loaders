# USB FEL Loaders for Allwinner devices

This repository contains a mini-Buildroot for building U-Boot based image
loaders for use on:

- [Trellis](https://protolux.io/projects/trellis)
- Pine64+

## Using the loader

To use the loader, clone this repository and run the `launch.sh` script. The
script will automatically download the necessary board firmware from GitHub if
it's not already present locally.

### Prerequisites

You will need `sunxi-fel` v1.4.2 or later. See below for installation
instructions or go to [sunxi-tools](https://linux-sunxi.org/Sunxi-tools). The
instructions below expect `sunxi-fel` to be in your `PATH`.

### Instructions

1. **Clone the repository**:
   ```sh
   git clone https://github.com/gworkman/usb_fel_loaders
   cd usb_fel_loaders
   ```

2. **Run the launch script** for your specific board:
   ```sh
   chmod +x launch.sh

   # to upload to a target:
   ./launch.sh TARGET

   # to list targets:
   ./launch.sh
   ```

3. **Connect your board**: Follow the on-screen prompts to place your board in
   FEL mode and connect it to your machine.
   - **Trellis**: Use the device USB-C port.
   - **Pine64**: Use the top USB-A port.

4. **Flash your image**: Once the loader is running, the device's eMMC will
   appear as a removable USB storage device. Use `fwup`, `dd`, or Etcher to
   flash your image.

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

First, install some dependencies with Homebrew:

```sh
brew install libusb dtc
```

Then change to a work directory of your choice to clone and build `sunxi-tools`:

```sh
git clone https://github.com/linux-sunxi/sunxi-tools
CFLAGS="-I$(brew --prefix dtc)/include" LDFLAGS="-L$(brew --prefix dtc)/lib" make -C sunxi-tools
```

If that worked without errors, then copy `sunxi-tools/sunxi-fel` to somewhere in
your `$PATH`.

## Building from source

> NOTE: Building requires a Linux machine (x86_64 or aarch64).

```sh
# Build ALL targets
make all

# Build only 1 target
make pine64   

# Clean all target outputs
make clean
```

The resulting loader binaries will be located in the `release/` directory:

- `release/pine64.bin`
- `release/trellis.bin`

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

Then create a GitHub Release for the tag and upload the `.bin` files from the
`release/` directory as individual assets.
