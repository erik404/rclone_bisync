# Rclone Bisync

## Overview

This script offers a solution for bidirectional file synchronization between a local directory and a remote destination using Rclone. Using Rclone's experimental bisync functionality, it facilitates synchronization, ensuring data consistency between the local and remote locations.

## Features

- **Dry Run Mode**: The script automatically conducts a dryrun before synchronization to detect any potential issues.
- **Resync Support**: Automatically handles recoverable errors by retrying with the `--resync` flag.
- **Error Logging**: Logs errors encountered during synchronization for later inspection.

## Usage

### Prerequisites

- [Rclone](https://rclone.org/) must be installed on your system.
- [Zenity](https://help.gnome.org/users/zenity/stable/) must be installed on your system.
### Running the Script

1. Clone or download the script to your local machine.
2. Make the script executable:
    ```bash
    chmod +x rclone_bisync.sh
    ```
3. Run the script with the desired options:

    ```bash
    ./rclone_bisync.sh --local "/path/to/local/directory" --remote "remote:directory"
    ```

### Command-line Options

- `--local`: Specifies the local directory to sync with the remote destination.
- `--remote`: Specifies the remote destination where files will be synced.

### Example

    ./rclone_bisync.sh --local "/media/user/Proton/" --remote "proton:"

### Automatic Synchronization with Cronjobs

This script can be integrated with cronjobs to automate the synchronization process at regular intervals.

## Error Handling and File Management

- In case of synchronization errors, an error message will be displayed on the screen using Zenity.
- Additionally, an error log will be created at `/tmp/rclone_sync_error.log`. This log can be referenced for troubleshooting and analysis.
- To prevent the synchronization process from restarting prematurely, a lock file will be created at `/tmp/rclone_sync.lock`. This file ensures that only one instance of the synchronization script runs at a time, avoiding potential conflicts and data corruption.

## Knowns issues

- The syncing process is slow possibly to the precautionary dry-run before each actual sync to maintain data integrity.
- Rclone's bisync feature encounters difficulty when both the local and remote paths contain no content. If all content is deleted and a sync operation is initiated, Rclone may encounter issues and attempt to resync all data. **Solution**: Ensure that there is always at least one file present in either the local or remote path to prevent synchronization issues with Rclone's bisync feature.
- Use at own risk!


# 

PROTON PLEASE BUILD A LINUX TOOL FOR YOUR PROTON DRIVE KTHNX
