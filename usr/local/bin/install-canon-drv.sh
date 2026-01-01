#!/bin/bash
# script to install canon printer drivers
# this script is run by postinst after a delay.
echo "========================================================="
echo "installing canon printer drivers"
echo "========================================================="
# wait for lock to become available or timeout in seconds
TIMEOUT=60;
LOCK="/var/lib/dpkg/lock-frontend"

# check if lock is available
fuser "${LOCK}"
rc=$?
while [[ $rc -eq 0 && ${TIMEOUT} -gt 0 ]]; do
	echo "install-canon-drv is waiting for the dpkg lock...timeout = ${TIMEOUT} rc = ${rc}"
	# decrement timeout
	TIMEOUT=$((TIMEOUT - 5))
	# get new rc
	sleep 5
	fuser "${LOCK}"
	rc=$?
done;

# check if the time out occured or not
fuser "${LOCK}"
rc=$?
if test $rc -eq 0; then
	# lock not available
	echo "canon drivers not installed...timed out"
	exit 1;
else
	# operation
	echo "Lock acquired ... Installing canon drivers"
	cd /home/robert/canon-drv
	install.sh
fi

echo "========================================================="
echo "installing canon drivers has completed"
echo "========================================================="
exit 0;
