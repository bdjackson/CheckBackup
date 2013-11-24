#!/bin/bash
# ==============================================================================
# = Script to check the backup status of the movies in the itunes directory
# ==============================================================================

# ------------------------------------------------------------------------------
# relevant directory names
LOCAL_MOVIES_DIR="${HOME}/Music/iTunes/iTunes Music/Movies"
BACKUP_MOVIES_DIR="/Volumes/Drobo/Media/Movies"

function check_copy_file {
  while true
  do
    read -p "Do you really want to replace $2 with $1? " response
    case $response in
      [Yy]* ) do_copy=true
              break
              ;;
      [Nn]* ) do_copy=false
              break
              ;;
      * )     echo "Please respond with yes or no"
              ;;
    esac
  done

  if $do_copy
  then
    cp "$1" "$2"
  fi
}

# ------------------------------------------------------------------------------
echo "Local movie directory:  ${LOCAL_MOVIES_DIR}"
echo "Backup movie directory: ${BACKUP_MOVIES_DIR}"
echo ""

if [[ $(ls "${LOCAL_MOVIES_DIR}") == "" ]] ; then
  echo "No movies to check!"
  exit
fi

# ------------------------------------------------------------------------------
# - Check all the files in LOCAL_MOVIES_DIR, and see if they exist in 
# - BACKUP_MOVIES_DIR
# ------------------------------------------------------------------------------
ALL_FILES=()
MISSING_FILES=()
for FULL_ITUNES_FILE in "${LOCAL_MOVIES_DIR}"/*
do
  ITUNES_FILE=$(echo $FULL_ITUNES_FILE | sed "s,${LOCAL_MOVIES_DIR}/\(.*\),\1,g")
  echo "Checking for file: $ITUNES_FILE"

  ALL_FILES+=("${ITUNES_FILE}")

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

# ------------------------------------------------------------------------------
# - Back up missing files if the user wants
# ------------------------------------------------------------------------------
if [[ ${#MISSING_FILES[@]} > 0 ]]
then
  echo '-------------------------------------------------------------------------'
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

  # Backup if the user wants to
  if $DO_BACKUP
  then
    echo "Backing up files!"
    echo ""

    for ((i = 0; i < ${#MISSING_FILES[@]}; i++))
    do
      echo "Backing up ${MISSING_FILES[$i]}"
      cp "${LOCAL_MOVIES_DIR}/${MISSING_FILES[$i]}" "${BACKUP_MOVIES_DIR}/${MISSING_FILES[$i]}"
    done
  else
    echo "Not copying -- files are still not backed up!"
  fi
  echo ''
fi

# ------------------------------------------------------------------------------
# - Do diff of files on local wrt files on backup
# ------------------------------------------------------------------------------
if [[ ${#ALL_FILES[@]} > 0 ]]
then
  echo '-------------------------------------------------------------------------'
  DO_DIFF=false
  while true
  do
    read -p "Do deep check [y/n]: " yn
    case $yn in
      [Yy]* ) DO_DIFF=true
              break
              ;;
      [Nn]* ) DO_DIFF=false
              break
              ;;
      * )     echo "Please answer yes or no."
              ;;
    esac
  done
  echo ''

  # Backup if the user wants to
  if $DO_DIFF
  then
    echo "Deep check of files!"
    for ((i = 0; i < ${#ALL_FILES[@]}; i++))
    do
      LOCAL_FILE=${LOCAL_MOVIES_DIR}/${ALL_FILES[$i]}
      BACKUP_FILE=${BACKUP_MOVIES_DIR}/${ALL_FILES[$i]}

      echo ''
      echo '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -'
      echo "Doing diff of ${ALL_FILES[$i]}"
      if diff "${LOCAL_FILE}" "${BACKUP_FILE}" >/dev/null
      then
        # Files are the same!!!
        echo "Local and backup copies match"
      else
        # Oh no! Files differ!
        echo "WARNING: Local and backup copies differ"
        echo "Local file size:  $(du -h "${LOCAL_FILE}"  | awk '{print $1}')"
        echo "Backup file size: $(du -h "${BACKUP_FILE}" | awk '{print $1}')"

        # What version do we keep?
        while true
        do
          read -p "Which version to keep? [(l)ocal, (b)ackup, (w)ait]: " ver
          case $ver in
            [Ll]* ) ver="l"
                    echo "Copying local file to backup"
                    check_copy_file "${LOCAL_FILE}" "${BACKUP_FILE}"
                    break
                    ;;
            [Bb]* ) ver="b"
                    echo "Copying backup file to local"
                    check_copy_file "${BACKUP_FILE}" "${LOCAL_FILE}"
                    break
                    ;;
            [Ww]* ) ver="w"
                    break
                    ;;
            * )     echo "Please provide valid answer."
                    ;;
          esac
        done
      fi
    done
  else
    echo "Not doing diff -- Files could be different"
  fi
  echo ''
fi
