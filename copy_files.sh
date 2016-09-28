#!/usr/bin/sh

target=${1%/}
files="grub.cfg
grub.d
multiboot.6U4YzT
themes"

# check arg
if [ ! "$target" ]; then
    echo "no target given (e.g. /mnt/boot/grub/)"
    exit
fi

# check target exist
if [ ! -d "$target" ]; then
    echo "target does not exist"
    exit
fi

echo "copying from $PWD to $target..."

# copy files
for file in $files; do
    echo -e "\t$PWD/$file -> $target/$file"
    yes | cp -rf $PWD/$file $target/$file
done

echo "done"
