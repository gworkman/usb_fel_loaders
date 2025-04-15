#!/bin/bash

# configs/xyz_defconfig
config="$1"

echo "Creating $config..."
./create-build.sh configs/$config
if [[ $? != 0 ]]; then
    echo "--> './create-build.sh $config' failed!"
    exit 1
fi

base=$(basename -s _defconfig $config)

echo "Building $base..."

make -C o/$base
if [[ $? != 0 ]]; then
    echo "--> 'Building $base' failed!"
    exit 1
fi
