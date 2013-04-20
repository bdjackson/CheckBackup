#!/bin/bash
# ==============================================================================
# = Script to check the backup status of the movies in the itunes directory
# ==============================================================================

# ------------------------------------------------------------------------------
# relevant directory names
LOCAL_MOVIES_DIR="${HOME}/Music/iTunes/iTunes Music/Movies"
BACKUP_MOVIES_DIR="/Volumes/Drobo/Media/Movies"

echo "Local movie directory:  ${LOCAL_MOVIES_DIR}"
echo "Backup movie directory: ${BACKUP_MOVIES_DIR}"

# ------------------------------------------------------------------------------
# Check all the files in LOCAL_MOVIES_DIR, and see if they exist in
# BACKUP_MOVIES_DIR
MISSING_FILES=()
for FULL_ITUNES_FILE in "${LOCAL_MOVIES_DIR}"/*
do
  ITUNES_FILE=$(echo $FULL_ITUNES_FILE | sed "s,${LOCAL_MOVIES_DIR}/\(.*\),\1,g")
  echo "Checking for file: $ITUNES_FILE"

  if [ ! -f "${BACKUP_MOVIES_DIR}/${ITUNES_FILE}" ]
  then
    echo "   File not found on backup: ${ITUNES_FILE}"
    MISSING_FILES+=("${ITUNES_FILE}")
  fi
done
echo ''

# ------------------------------------------------------------------------------
# Print the missing files
echo '-------------------------------------------------------------------------'
echo '- Files missing from backup                                             -'
echo '-------------------------------------------------------------------------'
for ((i = 0; i < ${#MISSING_FILES[@]}; i++))
do
    echo "${MISSING_FILES[$i]}"
done
echo ''

if [[ ${#MISSING_FILES[@]} > 0 ]]
then
  # ----------------------------------------------------------------------------
  # Should we back up the missing files
  echo '-----------------------------------------------------------------------'
  DO_BACKUP=false
  while true
  do
    read -p "Copy to backup drive [y/n]: " yn
    case $yn in
      [Yy]* ) DO_BACKUP=true
              break
              ;;
      [Nn]* ) DO_BACKUP=false
              break
              ;;
      * )     echo "Please answer yes or no"
              ;;
    esac
  done
  echo ''

  # Backup if the user wants to
  if $DO_BACKUP
  then
    echo "Backing up files!"
    for ((i = 0; i < ${#MISSING_FILES[@]}; i++))
    do
        echo "  Backing up ${MISSING_FILES[$i]}"
        cp "${LOCAL_MOVIES_DIR}/${MISSING_FILES[$i]}" \
          "${BACKUP_MOVIES_DIR}/${MISSING_FILES[$i]}"
    done
  else
    echo "Not copying -- files are still not backed up!"
  fi
  echo ''
fi
