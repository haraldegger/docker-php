#!/bin/sh
#-------------------------------------------------------------------------#
if [ -z ${DONE_001_PREPARE+x} ]; then
  echo "/srv/bin/001-prepare.sh"
  /srv/bin/001-prepare.sh
  export DONE_001_PREPARE=done
  exit
fi
#-------------------------------------------------------------------------#
if [ -z ${DONE_002_SETUP+x} ]; then
  echo "/srv/bin/002-setup.sh"
  /srv/bin/002-setup.sh
  export DONE_002_SETUP=done
  exit
fi
#-------------------------------------------------------------------------#
echo "/srv/bin/003-run.sh"
/srv/bin/003-run.sh
#-------------------------------------------------------------------------#