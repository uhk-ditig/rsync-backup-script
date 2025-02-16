# Rsync Backup Script

For more information on the script, see the article on the [Rsync Backup Script](https://www.ditig.com/rsync-backup-script).

## Script File

Find the script here: [rsync-backup-script.sh](https://github.com/uhk-ditig/rsync-backup-script/blob/main/rsync-backup-script.sh).


## Step-by-Step Explanation of the Script

### Preliminaries

1. **Set strict error handling:**  
   The set -euo pipefail ensures:
   * `-e`: The script exits if any command returns a non-zero exit code.
   * `-u`: Exiting with an error if an undefined variable is used.
   * `-o pipefail`: The script fails if any command in a pipeline fails.

1. **Define script metadata:**  
   __ScriptVersion="1.2" defines the version of the script.

1. **Define a usage function:**  
   The usage function describes how to run the script and explains the options:
   * `-h|help`: Ensures the backup destination is mounted.
   * `-v|version`: Displays the script version.


### Set Key Variables

* `backuppath`: The directory to back up (`$HOME`).
* `mountpoint`: The backup destination (`/media/user/backup`).
* `date`: Current date in `YYYY-MM-DD` format.
* `time`: Current time in `HH:MM:SS` format.


### Main Logic

1. **Check if the backup destination is mounted:**  
   The script uses `mountpoint -q $mountpoint` to verify if the backup destination is mounted.
   * If mounted:  
     Proceed with the backup process.
   * If not mounted:  
     Display an error message:  
     `"$mountpoint is not mounted"`, styled in bold, and exit with code 6.

1. **Clean up old logs:**  
   Check if any backup log files exist at the destination (`backup*.txt`).
   * If none are found: Print `"No backup file(s) found!"`.
   * If found: Prompt for confirmation (`y` to delete, `n` to cancel) and delete selected logs.

1. **Perform the backup using rsync:**  
   The script uses rsync with the following options:
   * `-a`: Archive mode (preserves symbolic links, permissions, etc.).
   * `-v`: Verbose output.
   * `-r`: Recursively sync directories.
   * `--delete`: Remove files from the destination that no longer exist in the source.
   * `--progress`: Show progress for each file.
   * `--stats`: Display transfer statistics.
   * `--itemize-changes`: List changes made during the sync.
   * `--exclude '.cache/'`: Exclude the .cache/ directory.
   * Output from `rsync` is piped to `tee`, saving a log file named `backup-log_<date>-<time>.txt` at the backup destination.

1. **Display a success message:**  
   Use styled and formatted text (`\033` sequences) to indicate success.
   Specify the synced source (`$backuppath`) and destination (`$mountpoint`).

1. **Print the latest file written to the backup destination:**  
   Use `find` to locate the most recently written file and display its timestamp.

1. **Wait, clear screen, and exit:**
   * Pause for 15 seconds (`sleep 15`).
   * Clear the terminal (`clear`).
   * Exit with code `0` to signal success.


### Error Handling

If the backup destination (`$mountpoint`) is not mounted:

* Print an error message in bold: `"$mountpoint is not mounted"`.
* Exit with error code `6` (No such device or address).
