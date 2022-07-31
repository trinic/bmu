#!/bin/bash --
#
# Created 7/19/2022 by Ian Smith
# Last Edit 7/26/2022 by Ian Smith
# Back Me Up! is a bash shell script for copying files to a backup drive and
# sorting them into destination directories based on extensions.
#
# Detailed explanations of the script can be found in bmu_manual.rtf.
#
# Settings should be changed in the bmu.conf file, not here!
#
. ./bmu.conf  # config file must be in the same dir as script.

if [ ! -w $LOGFILE ]
then
  echo Log not found. Creating new log file...
  touch $LOGFILE
  echo "$(date +%F_%H%M%S): New log created.">>$LOGFILE
fi

LOGSIZE=$(du $LOGFILE|cut -f 1)
if [ $LOGSIZE -ge $LOGMAX ]
then
  echo $(date +%F_%H%M%S): Log size is $LOGSIZE - Limit reached.
  mv $LOGFILE ${LOGFILE/%.log}_$(date +%F_%H%M%S).log
  touch $LOGFILE
  echo "$(date +%F_%H%M%S): New log created.">>$LOGFILE
fi

exec > >(tee -a $LOGFILE) 2>&1

echo "$(date +%F_%H%M%S): Backup process started."
NOEXCLUDES=1  # 1 (False) by default, meaning at least one Exclude is present
ALLEXCLUDES=""  # We need to assemble all the excludes, so create a placeholder

if [ $NODOWNLD == 1 ]; then ALLEXCLUDES+=$( echo '-not -path "./Downloads/*" ' ); fi
if [ $NODOTDIRS == 1 ]; then ALLEXCLUDES+=$( echo '-not -path "*/.*" ' ) ; fi
if [ -n "$ADDTLEXCLUDES" ]
  then
  for i in "${ADDTLEXCLUDES[@]}"
  do
	    ALLEXCLUDES+="-not -path \"$i\" ";
  done
fi
if [ -z "$ALLEXCLUDES" ]; then NOEXCLUDES=0; else echo Final excludes are \
  ${ALLEXCLUDES}; fi

function bmu () {
  case $NOEXCLUDES in
    1)
      DEST=$( echo "${2}" )
      FMT=$( echo "\".*\.("${1}")+$\"" )
      if [ -d "$DEST" ]
      then
        echo Searching for files using regex "$FMT":
        COMBOCMD=$( echo find ~/ -type f -regextype posix-extended -iregex \
          ${FMT} ${ALLEXCLUDES} -prune -print -exec cp -p -u {} \'"$DEST"\' \\\; )
        eval $COMBOCMD
      else
        if [ ${2} == 0 ]
          then echo Backup of "${3}" disabled in bmu.conf.
        else echo "${DEST}" is unreachable!
        fi
      fi;;
    0)
      DEST=$( echo "${2}" )
      FMT=$( echo "\".*\.("${1}")+$\"" )
      if [ -d "$DEST" ]
      then
        COMBOCMD=$( echo find ~/ -type f -regextype posix-extended -iregex \
          ${FMT} -prune -print; )
        eval $COMBOCMD
      else
        if [ ${2} == 0 ]
          then echo Backup of "${3}" disabled in bmu.conf.
        else echo "${DEST}" is unreachable!
        fi
      fi;;
  esac
}

if [ $DOCS == 1 ]; then bmu "$DOCFMT" "$DOCDEST" DOCS; fi
if [ $PDFS == 1 ]; then bmu "$PDFFMT" "$PDFDEST" DOCS; fi
if [ $PICS == 1 ]; then bmu "$PICFMT" "$PICDEST" DOCS; fi
if [ $TDP == 1 ]; then bmu "$TDPFMT" "$TDPDEST" DOCS; fi
if [ $PROGS == 1 ]; then bmu "$PROGFMT" "$PROGDEST" DOCS; fi

echo Backup completed at $(date +%F_%H%M%S).
