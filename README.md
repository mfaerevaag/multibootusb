Multiboot USB Drive
===================

Write up of my install process.

Arch Wiki: [Multiboot USB Drive](https://wiki.archlinux.org/index.php/Multiboot_USB_drive#Hybrid_UEFI_GPT_.2B_BIOS_GPT.2FMBR_boot)

GRUB configs based of [aguslr/multibootusb](https://github.com/aguslr/multibootusb) and [thias/glim](https://github.com/thias/glim)

Theme based of [Generator/Grub2-themes](https://github.com/Generator/Grub2-themes)

## 1. Partition disk

Table:
 - A BIOS boot partition (type EF02) 1MB
 - An EFI System partition (type EF00 with a FAT32 filesystem) 50MB
 - Your data partition (use a filesystem supported by GRUB) rest

```
Model: Kingston DataTraveler 150 (scsi)
Disk /dev/sdb: 32.3GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name                 Flags
 1      1049kB  2097kB  1049kB               BIOS boot partition  bios_grub
 2      2097kB  12.9GB  12.9GB  fat32        EFI System           boot, esp
 3      12.9GB  32.3GB  19.4GB  ext4         Linux filesystem
```

## 2. Create "Hybrid MBR Partition Table"
```
$ gdisk /dev/sdX

Command (? for help): r
Recovery/transformation command (? for help): h
Type from one to three GPT partition numbers, separated by spaces, to be added to the hybrid MBR, in sequence: 1 2 3
Place EFI GPT (0xEE) partition first in MBR (good for GRUB)? (Y/N): N

Creating entry for GPT partition #1 (MBR partition #2)
Enter an MBR hex code (default EF):
Set the bootable flag? (Y/N): N

Creating entry for GPT partition #2 (MBR partition #3)
Enter an MBR hex code (default EF):
Set the bootable flag? (Y/N): N

Creating entry for GPT partition #3 (MBR partition #4)
Enter an MBR hex code (default 83):
Set the bootable flag? (Y/N): Y

Recovery/transformation command (? for help): x
Expert command (? for help): h
Expert command (? for help): w

Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
PARTITIONS!!

Do you want to proceed? (Y/N): Y
```

## 3. Format filesystem
```
$ mkfs.msdos -F 32 /dev/sdX2
$ mkfs.ext4 /dev/sdX3
```

## 4. Mount
Using `/mnt/efi` and `/mnt/data` as mount points.

```
$ mount /dev/sdX2 /mnt/efi
$ mount /dev/sdX3 /mnt/data
```

## 5. GRUB Install
Install for EFI:

`$ grub-install --target=x86_64-efi --efi-directory=/mnt/efi --boot-directory=/mnt/data/boot --removable --recheck`

Install for BIOS:

`$ grub-install --target=i386-pc --boot-directory=/mnt/data/boot --recheck /dev/sdX`

As additional fallback, install for MBR-bootable data partition:

`$ grub-install --target=i386-pc --boot-directory=/mnt/data/boot --recheck /dev/sdX3`

EDIT last command:
```
Installing for i386-pc platform.
grub-install: warning: File system `ext2' doesn't support embedding.
grub-install: warning: Embedding is not possible.  GRUB can only be installed in this setup by using blocklists.  However, blocklists are UNRELIABLE and their use is discouraged..
grub-install: error: will not proceed with blocklists.
```

"Fixed" with `--force`...

## 6. GRUB Configure

cp `grub.cfg`, `multiboot.6U4YzT` and `themes` to `/boot/grub/`

cp `grub.d/` entries to `/boot/grub/grub.d/` and corresponding ISOs to `/boot/iso/`
