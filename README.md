# KiteOS Bootstrap

## Synopsis

KiteOS Bootstrap handles all the setup for a new Arch system following the partitioning
of disks. It handles fstab, hostname, hosts, user creation, pacman hooks, and
other things.

If you're following the [Arch Install Guide](https://wiki.archlinux.org/index.php/Installation_guide),
these scripts take over starting at the section titled "Installation".

## How to Use

1. Boot the Arch bootstrap ISO
2. Partition your disks using fstab
3. Mount your partitions using `/mnt` as the root
4. Install git `pacman -S git`
5. Clone the bootstrap files `git clone https://github.com/lfkeitel/KiteOS /KiteOS`
6. Run the bootstrap script `/KiteOS/bootstrap.sh`
7. Reboot and login as you your new user
8. Run the second setup script `/KiteOS/setup_packages.sh`. DO NOT run as root,
it will prompt for a sudo password when needed.
9. Reboot

## Assumptions

**Please read these carefully**

**If your system differs from this list, do NOT use these scripts**

These scripts assume the system will be:

- using EFI boot mode
- booted using Systemd
- in the America/Chicago timezone
- localed for US English
- using Network Manager
- setup with my personal configs exactly

## Is KiteOS a distribution?

No. It's a set of scripts to automate the setup of a new Arch install.

## Is this compatible with other distributions?

No. It's only for Arch.

## What do these scripts NOT do?

They don't partition your storage in any way. That is something left to the user
to decide how it needs to be done.

## Why the name KiteOS?

It's a play on my last name `Keitel`. They first syllable kinds sounds like `kite`.

## License

MIT
