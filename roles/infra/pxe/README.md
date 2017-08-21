# How to prepare the repo for PXE

- /var/lib/tftpboot/repo
- /var/lib/tftpboot/repo/images
- /var/lib/tftpboot/repo/ks
- /var/lib/tftpboot/repo/iso
- /var/lib/tftpboot/repo/utils

> Note.
> This repo is exported through http server, like `Alias /pxe /var/lib/tftpboot/repo`.
> So you can access files through `http://<ip>/pxe/` url.

## Prepare `/var/lib/tftpboot/repo/iso`

You can directly put any Operating System ISO files into the `iso` directory.

## Prepare `/var/lib/tftpboot/repo/images`

The `images` directory has many subdirectories. Each subdirectory holds all the inner contents of an ISO file.

eg 1.

```bash
mkdir /var/lib/tftpboot/repo/images/centos-6.8-x64

mount -o loop CentOS-6.8-x86_64-minimal.iso /mnt
cp -a /mnt/* /var/lib/tftpboot/repo/images/centos-6.8-x64
umount /mnt
```

eg 2.

```
mkdir /var/lib/tftpboot/repo/images/ubuntu12.04-x64

mount -o loop Ubuntu-12.04-minimal.iso /mnt
cp -a /mnt/* /var/lib/tftpboot/repo/images/ubuntu-12.04-x64
umount /mnt
```

## Prepare `/var/lib/tftpboot/repo/ks`

You can put all `.ks` files or `.seed` files in this directory

`.ks` files are for CentOS/RHEL OS.
`.seed` files are for Debian/Ubuntu OS.

> Warning Note.
> In `.ks` files, there might be need to refer to files or directories in `images` and/or `utils` directory.

## Prepare `utils`

1. The most useful utility is `MegaCli`.

[Download megacli](https://docs.broadcom.com/docs-and-downloads/raid-controllers/raid-controllers-common-files/8-07-14_MegaCLI.zip)


```bash
rpm -qlp MegaCli-8.07.14-1.noarch.rpm
/opt/MegaRAID/MegaCli/MegaCli
/opt/MegaRAID/MegaCli/MegaCli64
/opt/MegaRAID/MegaCli/libstorelibir-2.so.14.07-0

# cp /opt/MegaRAID/MegaCli /var/lib/tftpboot/
```