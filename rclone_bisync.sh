#!/bin/bash

# Default values
LOCKFILE="/tmp/rclone_bisync.lock"
LOGFILE="/tmp/rclone_bisync.log"
DRYRUN_OUTPUT="/tmp/rclone_bisync_dryrun.log"
ERROR_FILE="/tmp/rclone_bisync_error.log"

LOCAL_PATH=""
REMOTE_PATH=""

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --local)
            LOCAL_PATH="$2"
            shift # past argument
            shift # past value
            ;;
        --remote)
            REMOTE_PATH="$2"
            shift # past argument
            shift # past value
            ;;
        *)  # unknown option
            echo "Unknown option: $key"
            exit 1
            ;;
    esac
done

# Check if LOCAL_PATH is empty
if [ -z "$LOCAL_PATH" ]; then
    echo "Error: --local argument is required."
    exit 1
fi

# Check if REMOTE_PATH is empty
if [ -z "$REMOTE_PATH" ]; then
    echo "Error: --remote argument is required."
    exit 1
fi

# Delete logs
delete_logs() {
	rm -f "$LOGFILE"
	rm -f "$ERROR_FILE"
	rm -f "$DRYRUN_OUTPUT"
}

# Check if the lock file exists and exit
if [ -e "$LOCKFILE" ]; then
    exit 1
else
	# Delete the logs from the previous sync
	delete_logs
    # Create the lock file
    touch "$LOCKFILE"
	# Boolean for resync
	resync=false
    # Run the rclone bisync command with dry-run and capture output
    rclone bisync "$LOCAL_PATH" "$REMOTE_PATH" --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only -MvP --drive-skip-gdocs --fix-case --force --dry-run 2>&1 | tee "$DRYRUN_OUTPUT"
	# Rclone might fail with a recoverable error, this happens when there was never an initial sync, or when the paths have no content (possible rclone bug perhaps?)
	if grep -q "Bisync aborted. Must run --resync to recover" "$DRYRUN_OUTPUT"; then
		echo "RECOVERING WIT RESYNC FLAG"
	    # Run the rclone bisync command with dry-run and --resync and capture the output
		rm -f "$DRYRUN_OUTPUT"
		resync=true
    	rclone bisync "$LOCAL_PATH" "$REMOTE_PATH" --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only -MvP --drive-skip-gdocs --fix-case --force --resync --dry-run 2>&1 | tee "$DRYRUN_OUTPUT"
	fi
	
    # Check if "Bisync successful" is in the dry-run output
    if ! grep -q "Bisync successful" "$DRYRUN_OUTPUT"; then
	     # Log the error if dry-run did not contain "Bisync successful"
        rm -f "$LOCKFILE"
		touch "$ERROR_FILE"
        cat "$DRYRUN_OUTPUT" > "$ERROR_FILE"
        exit 1
	fi
	
	# Run the actual bisync command
	if $resync; then
		rclone bisync "$LOCAL_PATH" "$REMOTE_PATH" --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only -MvP --drive-skip-gdocs --fix-case --force --resync --max-lock 10 2>&1 | tee "$LOGFILE"
	else
		rclone bisync "$LOCAL_PATH" "$REMOTE_PATH" --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only -MvP --drive-skip-gdocs --fix-case --force --max-lock 10 2>&1 | tee "$LOGFILE"
	fi

	if ! grep -q "Bisync successful" "$LOGFILE"; then
		rm -f "$LOCKFILE"
		touch "$ERROR_FILE"
		cat "$LOGFILE" > "$ERROR_FILE"
		exit 1
	fi    
	
	rm -f "$LOCKFILE"
fi
