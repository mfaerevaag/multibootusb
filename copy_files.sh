#!/usr/bin/sh

# multiboot usb drive
# by Markus Færevaag
# github.com/mfaerevaag/multibootusb

# use absolute path to cp to sirucumcent
# aliases which can stop from overwriting
cp=/usr/bin/cp

# files to copy
files="grub.cfg
multiboot.6U4YzT
grub.d
themes"

# error func
function err
{
    echo "$1"
    exit 1
}

# parse args
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    err "usage: $0 [--force] PATH_TO_GRUB_DIR"
fi

for arg in $@; do
    if [ "$arg" == "--force" ] || [ "$arg" == "-f" ]; then
        force=true
    else
        target=${arg%/} # remove trailing slash
    fi
done

# check args
if [ ! "$target" ]; then # check target given
    err "no target given (e.g. /mnt/boot/grub/)"
elif [ ! -d "$target" ]; then # check target exist
    err "target does not exist"
elif [ ! -f "$target/grubenv" ]; then # check sane target
    err "not a grub folder"
fi

echo "copying from $PWD to $target..."

# copy files
for file in $files; do
    echo -ne " * $PWD/$file -> $target/$file"

    if [ -e "$PWD/$file" ]; then
        if [ "$force" ]; then
            echo " [FORCE]"
            /usr/bin/cp -rf $PWD/$file $target/
        else
            # read yes or no
            read -p " [y/N] " yn
            case $yn in
                [Yy]* ) ;;
                "" ) ;;
                [Nn]* ) continue;;
                * ) continue;;
            esac

            /usr/bin/cp -rf $PWD/$file $target/
        fi
    else
        err "$PWD/$file not found"
    fi
done

echo "done"
