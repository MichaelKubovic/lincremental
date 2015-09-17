#!/bin/bash
#incremental backup script
#requires a full backup made with lincremental_initial.sh first

set -eu

. /etc/lincremental/lincremental.cfg
. /usr/local/lincremental/lincremental_functions

#the specific directory to store this backup in
TRG="$TRGBASE/snapshot.0"

if [ ! -d $TRG ] ; then
	$ECHO "Please perform an initial backup using lincremental_initial.sh first"
	exit 1
fi

lock "$LOCK_DIR" "snapshot"

#the directory containing the previous backup that we will increment from
LNK="$TRGBASE/snapshot.1"

#Delete the oldest snapshot, if it exists
OLDEST="$TRGBASE/snapshot.$NUM_DAILY"
if [ -d $OLDEST ] ; then
	$RM -rfv "$OLDEST"
fi

#Shift all the other backups back by one
shiftbackupsback "snapshot" $NUM_DAILY

#The rsync link dest option:
LNKOPT="--link-dest=$LNK"

#the final rsync command
$RSYNC $OPT $LNKOPT $SRC $TRG

#Update the mtime of snapshot.0 to reflect the snapshot time
$TOUCH $TRG
