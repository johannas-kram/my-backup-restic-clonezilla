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
  * Cloud (pcloud)
* File Backups will be created fully automatically, every 2 hours, using restic
* All Backups will be stored extremely storage efficient, using restic's:
  * Compression
  * Deduplication via Content defined chunking
* System Backups will be created manually, using clonezilla
* All backups will be encrypted, using rectic's encryption

### Optional
* browse backups via virtual file system, using fuse mount
* Simplification of system backup creation

## Prerequisites
* Windows (since all is done with powershell and cmd scripts)
* Ensure that the name of your home directory equals your username
* An external HDD/SSD for local backup storage
* pcloud - An powerful and robust cloud storage
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

### Optional

#### Simplified system image backups
To highly simplify the creation of system backup images and a later restore:
* Download [custom clonezilla](-todo-upload-file-and-link-it-here) iso file
* Create bootable usb stick based on this iso \
  or copy the iso file to a mmultiboot stick, created with [Ventoy](https://www.ventoy.net/en/index.html).
* Go into the `optional` and run the script `prepare-custom-clonezilla.ps1` via `rightclick` -> `run with powershell` (not as administrator)
