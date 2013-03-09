#!/bin/bash

LOCAL_MOVIES_DIR=${HOME}/Music/iTunes/iTunes\ Music/Movies
# BACKUP_MOVIES_DIR=/Volumes/Seagate\ Data/Big\ Drive\ backup/Media/Movies
BACKUP_MOVIES_DIR=/Volumes/Data/Media/Movies

echo ${LOCAL_MOVIES_DIR}
echo ${BACKUP_MOVIES_DIR}

MISSING_FILES=()

for FULL_ITUNES_FILE in "${LOCAL_MOVIES_DIR}"/*
do
  ITUNES_FILE=`echo $FULL_ITUNES_FILE | sed "s,${LOCAL_MOVIES_DIR}/\(.*\),\1,g"`
  echo "Checking for file: $ITUNES_FILE"

  if [ ! -f "${BACKUP_MOVIES_DIR}/${ITUNES_FILE}" ]
  then
    echo "   File not found on backup: ${ITUNES_FILE}"
    MISSING_FILES+=("${ITUNES_FILE}")
  fi
done

echo ''
echo '-------------------------------------------------------------------------'
echo '- Files missing from backup                                             -'
echo '-------------------------------------------------------------------------'
for ((i = 0; i < ${#MISSING_FILES[@]}; i++))
do
    echo "${MISSING_FILES[$i]}"
done
