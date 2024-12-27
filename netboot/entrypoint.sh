#!/usr/bin/env sh

TFTPBOOT=${TFTPBOOT:-/tftpboot}

DIRECTORIES="pxelinux.cfg grub grub2 boot ztp.cfg poap.cfg host-config bootloader-universe bootloader-universe/pxegrub2"
for directory in $DIRECTORIES; do
  directory=$TFTPBOOT/$directory
  if [ ! -d $directory ]; then
    mkdir -p -m 0755 $directory
  fi
done

# copy syslinux
SYSLINUX_FILES="/usr/share/syslinux/chain.c32 /usr/share/syslinux/ldlinux.c32 /usr/share/syslinux/libcom32.c32 /usr/share/syslinux/mboot.c32 /usr/share/syslinux/menu.c32 /usr/share/syslinux/memdisk /usr/share/syslinux/pxelinux.0"
for file in $SYSLINUX_FILES; do
  cp $file $TFTPBOOT/$(basename $file)
done

# The symlink from grub2/boot to boot is needed for UEFI HTTP boot
if [ ! -L $TFTPBOOT/grub2/boot ]; then
    ln -s ../boot $TFTPBOOT/grub2/boot
fi

# Default grub.cfg
if [ ! -f $TFTPBOOT/grub2/grub.cfg ]; then
    cat <<EOF > $TFTPBOOT/grub2/grub.cfg
echo ""
echo "The system will attempt to chainload from first HDD"
echo "in 10 minutes..."
echo ""
sleep 600
set root=(hd0,0)
chainloader +1
EOF
fi

# build grubx64.efi
ELF_LIB_DIR=/usr/lib/grub/x86_64-efi
GRUB_MODULES="all_video boot btrfs cat chain configfile echo efifwsetup efinet ext2 fat font gettext gfxmenu gfxterm gfxterm_background gzio halt hfsplus iso9660 jpeg keystatus loadenv linux lsefi lsefimmap lsefisystab lssal memdisk minicmd normal part_apple part_msdos part_gpt password_pbkdf2 png reboot search search_fs_uuid search_fs_file search_label sleep test true video zfs zfscrypt zfsinfo lvm mdraid09 mdraid1x raid5rec raid6rec tftp regexp"

if ! /bin/grep -q regexp ${TFTPBOOT}/grub2/grubx64.efi; then
    /usr/bin/grub-mkimage -O x86_64-efi -d ${ELF_LIB_DIR} -o ${TFTPBOOT}/grub2/grubx64.efi -p '' ${GRUB_MODULES}
fi

[ ! -L $TFTPBOOT/grub2/shim.efi ] && ln -s grubx64.efi ${TFTPBOOT}/grub2/shim.efi
[ ! -L $TFTPBOOT/grub2/shimx64.efi ] && ln -s grubx64.efi ${TFTPBOOT}/grub2/shimx64.efi

exec "$@"
