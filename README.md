# Backup and Restore

A simple backup and restore systems for managing a directory versions.

## Overview
It consists of two systems, backup and restore. All files are directly found inside *main directory* which should also contains source and backup directory.

Please note that two systems **do not work** concurrently.
#### 1. Backup
Backup is done using a shell script `backupd.sh`, it takes 4 arguments in this order:
1. `source_dir`: directory to be tracked and backed up.
2. `backup_dir`: directory to store backups.
3. `interval_secs`: interval between each check for changes
4. `max_backups`: max number of backups to have (older backups will be deleted to retain max number).

`source_dir` is checked every `interval_secs`, make a new backup if changes were made to it inside `backup_dir`.

#### 2. Restore
Restore is done using shell script `restore.sh`, it takes two arguments in this order:
1. `source_dir`: directory to be restored.
2. `backup_dir`: directory containing backups.

When restore is used, by default the newest backup is restored, putting its content inside `source_dir`.

Please note that restore **stops** backup process and vice versa.

## Prerequisites
User may need to install `make` command: `sudo apt install make`, to be able to run Makefile.

## Instructions
All of commands required to run backup or restore have been grouped inside Makefile, making it very easy to use.
#### For Backup
Simply inside main directory (which contains all working files like Makefile but also source and backup directory), run `make` or `make backup`.

This should start tracking source directory, create an initial backup and create backups if any changes were made to it inside backup directory.

If backup directory was not found, it will be created.

#### For Restore
Inside main directory, run `make restore`.

This should stop backup system, restore newest backup version and gives user a menu to choose from different backups (sorted from oldest to newest).

Enter `1` to select previous version, Enter `2` to select next version and finally `3` to exit.

#### For Clearing
Inside main directory, use `man clear` to clear all working files, backups and stop backup or restore.