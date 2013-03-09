#!/bin/bash

LOCAL_TV_SHOW_DIR=${HOME}/Music/iTunes/iTunes\ Music/TV\ Shows
# BACKUP_TV_SHOW_DIR=/Volumes/Seagate\ Data/Big\ Drive\ backup/Media/TV\ Shows
BACKUP_TV_SHOW_DIR=/Volumes/Data/Media/TV\ Shows

echo ${LOCAL_TV_SHOW_DIR}
echo ${BACKUP_TV_SHOW_DIR}

MISSING_FILES=()

for SHOW_DIR in "$LOCAL_TV_SHOW_DIR"/*
do
  SHOW_TITLE=`echo $SHOW_DIR | sed "s,${LOCAL_TV_SHOW_DIR}/\(.*\),\1,g"`
  echo "Checking the show: ${SHOW_TITLE}"

  for FULL_ITUNES_FILE in "${SHOW_DIR}"/*
  do
    ITUNES_FILE=`echo $FULL_ITUNES_FILE | sed "s,${SHOW_DIR}/\(.*\),\1,g"`
    if [ "${ITUNES_FILE}" == "*" ]
    then
      continue
    fi

    FOUND_FILE=0
    echo "    Checking for file: $ITUNES_FILE"
  
    for FULL_SEASON_DIR in "${BACKUP_TV_SHOW_DIR}/${SHOW_TITLE}/"/Season\ *
    do
      LOCATION_TO_CHECK=${FULL_SEASON_DIR}/${ITUNES_FILE}
      if [ -f "${LOCATION_TO_CHECK}" ]
      then
        echo "        Found file at location: ${LOCATION_TO_CHECK}"
        FOUND_FILE=1
        break
      fi
    done

    if [ ${FOUND_FILE} == 0 ]
    then
      MISSING_FILES+=("${FULL_ITUNES_FILE}")
    fi
  done
done

echo ''
echo '-------------------------------------------------------------------------'
echo '- Files missing from backup                                             -'
echo '-------------------------------------------------------------------------'
for ((i = 0; i < ${#MISSING_FILES[@]}; i++))
do
    echo "${MISSING_FILES[$i]}"
done
