#!/bin/bash

# ERROR HANDLING
# e - script stops on error (return != 0)
# u - error if undefined variable
# o pipefail - script fails if one of piped command fails
# x - output each line (debug)
set -euo pipefail

__ScriptVersion="1.2"

#===  FUNCTION  ================================================================
#         NAME:  Backup ~/
#  DESCRIPTION:  Backs up the user home directory to backup mountpoint.
#===============================================================================
function usage ()
{
    echo "Usage :  $0 [options] [--]
    Options:
    -h|help       Make sure backup destination is mounted.
    -v|version    Display script version"

}    # ----------  end of function usage  ----------


# Variables
#
# source directory to back up
backuppath="/home/user"

# back up destination location
# Arch
#mountpoint="/run/media/user/bckp"
# Ubuntu
mountpoint="/media/user/bckp"

# Current date in YYYY-MM-DD
date=$(date +%Y-%m-%d)

# Current time in HH:MM:SS
time=$(date +%T)

# Check if back up disk is mounted
if mountpoint -q $mountpoint
then


# Clean up previous log(s)
if [ ! -f $mountpoint/backup*.txt ]; then
    echo "No backup file(s) found!"
    else
    echo -e "Confirm deletion: press y\nCancel deletion: press n"
    rm -i $mountpoint/backup*.txt
fi

# Rsync Back Up
#
rsync \
  -avr \
  --delete \
  --progress \
  --stats \
  --itemize-changes \
  --exclude '.cache/' \
  $backuppath \
  $mountpoint \
  2>&1 | tee $mountpoint/backup-log_$date-$time.txt # writing log
  
  # Confirmation message
  #
  # echo -e - escaped strings will be interpreted
  # \033 - beginning/ending of the style
  # m - end of the sequence
  # [0m - resets all attributes, e.g. colors, formatting, etc.
  # \n - newline
  #
  # Sequence integers:
  #
  # 0 - Normal Style
  # 1 - Bold
  # 4 - Underlined
  echo -e "\n\n  \033[4mSUCCESS\033[0m\n\n  \033[1m$backuppath\033[0m\n    has been synced to\n  \033[1m$mountpoint\033[0m\n\n"
  
  # Print latest file to back up drive (manual plausability check)
  echo -e "Latest file written to back up drive:"
  find $mountpoint -type f -printf '%TY-%Tm-%Td %TH:%TM: %Tz %p\n'| sort -n | tail -n1
  
  # Wait for 15 seconds
  sleep 15

  # Clear the screen
  clear
  
  # Success exit code
  exit 0

# If $mountpoint is not mounted
else
   echo -e "\033[1m$mountpoint\033[0m is not mounted"   
   # Print error exit code -  No such device or address
  exit 6
fi
