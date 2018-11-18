#!/bin/bash

## Mount the Drives
function mount_drive {
  mkdir -p $2
  mount_smbfs $1 $2 
}

drives_to_unmount=`df | awk '/username@server/ { print $6 }'`

if [ "$drives_to_unmount" != "" ]; then
  echo "Unmounting existing drives on punedc02: \n$drives_to_unmount"
  umount $drives_to_unmount
fi

mount_drive //username@server/share /Users/userprofile/sharepoint

# Write Flag
echo "`date '+%Y%m%d'`" > ~/Documents/Sync/_lastsync.txt

# Do Copy
rsync -ruv --log-file="/Users/userprofile/sharepoint/Sync/`date '+%Y%m%d'`.log" ~/Documents/ ~/sharepoint/



