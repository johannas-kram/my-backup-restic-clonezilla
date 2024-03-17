# My Backup solution, using restic and clonezilla

My personal approach for backups, using restic and clonezilla, free and open-source. \
I am using Windows and i am backuping my system and my files. \
If the approach matches your needs and you are fullfilling the prerequisites, feel free to use the approach and my scripts, too.

## Features

### Main
* All Backups will be created with free and open-source tools
* Data structures of backups allow to restore, even if the creating tool isn't available anymore
* Backups are stored:
  * locally (external HDD/SSD)
  * Cloud ([pcloud](https://www.pcloud.com/); synced using [rclone](https://rclone.org/))
* File Backups will be created fully automatically, every 2 hours, using [restic](https://restic.net/)
* All Backups will be stored extremely storage efficient, using restic's:
  * Compression
  * Deduplication via [Content defined chunking](https://restic.net/blog/2015-09-12/restic-foundation1-cdc/)
* System Backups will be created manually, using [clonezilla](https://clonezilla.org/)
* All backups will be encrypted, using rectic's encryption

### Optional Features
* Browse backups and copy back single files and directories, via virtual file system, using fuse mount
* Simplification of system backup creation

## Prerequisites
* Windows (since all is done with powershell and cmd scripts)
* Ensure that the name of your home directory equals your username
* An external HDD/SSD for local backup storage
* An [pcloud](https://www.pcloud.com/) account - An powerful and robust cloud storage
  * pcloud offers life-time abos (e.g. 2TB for 400€)
  * You will need an [pcloud app](https://docs.pcloud.com/my_apps/) with following properties \
    * Access: Specified folder only
    * Redirect Uris: Must contain: `http://localhost:53682/`
    * Allow implicit-grant: Allow
  * You will need `client_id` and `client_secret` for your [pcloud app](https://docs.pcloud.com/my_apps/), \
    so make sure to save it at a secure place (protected against loss, protected against leakage)
* Enabled powershell script execution
  * Open powershell as administrator
  * type:
    ```powershell
    Set-Executionpolicy RemoteSigned -Scope CurrentUser
    ```
  * Press enter
  * type `y` (or `J` on if german) and press enter again
  * Close powershell
* Git installed
* Bootable USB Stick with [Clonezilla](https://clonezilla.org/) \
  Recommendation:
  * Use [Ventoy](https://www.ventoy.net/en/index.html) to create a multi boot stick
  * Copy a [clonezilla iso](https://clonezilla.org/downloads/download.php?branch=stable) file on the stick \
    Ensure to use `iso` file, not `zip`.

## Setup
### Basic Setup
* Clone this repository or download it as zip file
* If downloaded as zip file: Extract it
* Execute the script `init.ps1` via `rightclick` -> `run with powershell` (not as administrator) and follow the instructions

**Caution!** \
After setup, your local path of this directory must not change at any time. \
Example: If you clone this repo or extract the zip under `C:\Users\banana\backup-restic-clonezilla`,
after basic setup the path must always keep beeing `C:\Users\banana\backup-restic-clonezilla`.

### Optional Setup

#### Simplified system image backups (Recommended)
To highly simplify the creation of system backup images and a later restore:
* Download [custom clonezilla](-todo-upload-file-and-link-it-here) iso file
* Create bootable usb stick based on this iso \
  or copy the iso file to a mmultiboot stick, created with [Ventoy](https://www.ventoy.net/en/index.html).
* Go into the `optional` and run the script `prepare-custom-clonezilla.ps1` via `rightclick` -> `run with powershell` (not as administrator)

## How to

### Create files backup
Files Backups (called `snapshots` in restic) are created automatically, so you don't need to run it manually,
but if you want to do so, \
simply run the script `files-backup.ps1` via `rightclick` -> `run with powershell` (not as administrator)

### System Backup
* Create an image of your system disk.
  * Restart your pc and boot from your USB Stick which holds clonezilla
  * Boot into clonezilla
  * Default clonezilla iso: Follow the instructions of clonezilla \
    [See this helping video tutorial](https://www.youtube.com/watch?v=ci2VyorBjyQ&pp=ygUKY2xvbmV6aWxsYQ%3D%3D) \
    Important settings/options
    * Use expert mode
    * simply accept all defaults, except for compression
    * select z0 (no compression)
  * Custom clonezilla iso (See [Setup->Optional](#optional-setup)): Simply select entry `Backup - Create system image and reboot`
* Trigger restic, to create a snapshot of the system image.
  * When system image is created and computer is restarted, logon like usally.
    restic will create a snapshot of this image automatically and removes the image afterwards, \
    since it's only required to exist in the restic backup repository. \
    See [Background / Internals](#background-internals) for details

## Background / Internals
### restic
This section explains what [restic](https://restic.net/) is and how it works.

Instead of simply creating a copy of all files, restic chunks all files, using content defined chunking,
and only copies chunks, that aren't already stored in backup repository. \
Since cut points for chunking are only dependent of the 64 bytes of each chunk, changes (also length changes) only affect a single chunk. \
Additionally resic compresses and encrypts all chunks. \
So, restic is extremely storage efficient and it's secure.

Terminology:
* Backups are called `snapshot`
* The directory, where all snapshots are stored is called `repository`

Nice and detailed talk about rectic (2016, CCC Cologne): https://media.ccc.de/v/c4.openchaos.2016.01.restic

### Clonezilla
This section explains what [Clonezilla](https://clonezilla.org/) is and how it works.

Clonezilla is a live system (it runs as a operating system), bootable from a usb stick. \
It can be used to clone disk drives directly or to create disk or partition images.
Later it can be used to restore disks or partitions based on images, created before.

Terminology:
* Backups are called `images`

### rclone
This section explains what [rclone](https://rclone.org/) is and how it works.

rclone is a versataile tool work with remote files and directories as they were local. \
It supports **a lot** of types of remote storages. \
A key feature is rclone's simplicity. \
Examples:
* To copy a file from a local device to pcloud: `rclone copy D:\banana.png pcloud:images\`
* Listing all files into the `images` directory in pcloud: `rclone ls pcloud:images`

Once connected and authorized during configuration, all commands can be used without further authorization.

### pcloud
This section explains what [pcloud](https://www.pcloud.com/) is and how it works.

pcloud is a powerful cloud storage. \
pcloud offers a life-time abo with 2TB for 400€, which is really great for backups.

### resticification of system images
Clonezilla always creates full backups (differential and incremental backups aren't supported). \
Keeping multiple versions of system backups would be take a lot of space in your backup locations. \
The solution is following:
* You will create un-compressed system images using clonezilla
* A schedule created on [Basic Setup](#basic-setup) will automatically create a restic snapshot of the image,
  i call it `system backup image resticification` \
  * This will compress the image
  * Newer images wont take the same space additionally, since only different chunks will be stored in the next snapshot.
* After `resticification` the actual system image will be deleted to relaese space.


### Consistency and protecting, using filesystem snapshots
Shadowcopies ([VSS](https://en.wikipedia.org/wiki/Shadow_Copy)),
will be used to keep consistency and secure your backups.
* To keep consistency, files backups are created, using shadowcopies. \
  The shadowcopy is created on the partition, where your files are, so they are always consistent in the respective restic snapshot.
* To prevent syncing corrupted backups into your pcloud storage, a read-only shadowcopy of your local backup device is used. \
  This is done as follows:
  * Create read-only shadowcopy
  * Check if restic backup repository is ok free of errors. \
    This fails and the next step will be skipped, if there are any errors
    (caused by disk errors or ransomware attacks for example)
  * Syncing to pcloud. \
    Only the restic backup repository is synced.
  * Remove shadowcopy

### Cleanup
A cleanup script, executed daily automatically, will delete old snapshots, based on following rules:
* files backup:
  * Keep all snapshots of the same day
  * keep most recent daily snapshot of the last 7 days
  * keep most recent weekly snapshot of the last 4 weeks
  * keep most recent monthly snapshot of the last 15 months
  * In case of not already covered by the rules above: keep always at least 3 snapshots.
* system backup: keep all snapshot of the last 5 weeks \
  (Recommendation: Do a system backup, weekly)

### Syncing to pcloud using rclone
Backup, Restore and Cleanup, always are done in your local backup device only. \
After changing tasks (init, backup, cleanup), the restic repository is synced to pcloud, using [rclone](https://rclone.org/).

## License
[WTFPL License](LICENSE.txt)

## Version
v1.0.0 - 2024-03-17
