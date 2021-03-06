#!/bin/bash

# -a: Add listed folders
# -b: Backup listed folders to current dir
# -B: Backup listed folders to new location
# -h: Display help/usage message
# -r: Remove listed folders
# -s: Set source location
# -u: Update listed folders
# -U: Update listed folders, backing up to new location

SOURCE=""
ADDON_DIR=""
ERROR_COUNT=0

displayHelpMessage () {
  printf "%s\n%s\n\n" "WoW AddOn Utility" "Allows manual addition, removal, back-up, and updating of WoW AddOn programs"
  printf "%s\n\n" "Syntax: addons.sh {-a|-b|-B|-h|-r|-s|-u|-U} [FILE_PATHS...]"
  printf "%s\n\n" "Usage:"
  printf "%-5s%s\n%-5s%s\n" "a" "Import new add-on directories and files." "" "Takes at least one add-on directory as an argument."
  printf "%-5s%s\n%-5s%s\n" "b" "Back-up existing add-ons to the default add-on directory." "" "Takes at least one add-on directory as an argument."
  printf "%-5s%s\n%-5s%s\n" "B" "Back-up existing add-ons to a custom add-on directory." "" "Takes a destination file path and at least one add-on directory as an argument."
  printf "%-5s%s\n" "h" "Display helpful information about the WoW AddOn Utility"
  printf "%-5s%s\n%-5s%s\n" "r" "Remove existing add-ons from the add-on directory." "" "Takes at least one add-on directory as an argument."
  printf "%-5s%s\n%-5s%s\n%-5s%s\n" "u" "Update existing add-ons in the add-on directory." "" "Performs a '-b' backup, and overwrites existing add-on." "" "Takes at least one add-on directory as an argument."
  printf "%-5s%s\n%-5s%s\n%-5s%s\n\n" "U" "Update existing add-ons in the add-on directory." "" "Performs a '-B' backup, and overwrites existing add-on." "" "Takes a destination file path and at least one add-on directory as an argument."
  printf "%s\n\n" "Initial Set-Up:"
  printf "%s\n\n" "To begin using this utility script, default source and destination locations must be added to the 'SOURCE' and 'ADDON_DIR' global variables respectively. No other set-up is required at this time."
}

checkConfirmValidation () {
  if [[ "$1" =~ ^(y(es)?|Y(es)?|n(o)?|N(o)?)$ ]]; then
    return 0
  else
    return 1
  fi
}

addFile () {
  local FILE="$1"
  SOURCE_FILE="$SOURCE/$FILE"
  DEST_FILE="$ADDON_DIR/$FILE"

  if [ "$MODE" = "a" ] && [ ! -d $DEST_FILE ]; then
    `cp -R $SOURCE_FILE $DEST_FILE 2>/dev/null`
    local ADD_RESP="$?"
  elif [[ "$MODE" =~ (u|U) ]]; then
    `rm -rf $DEST_FILE && cp -R $SOURCE_FILE $DEST_FILE 2>/dev/null`
    local ADD_RESP="$?"
  else
    ERROR_COUNT=$(($ERROR_COUNT+1))
    printf "%s\n" "File exists: $DEST_FILE already exists. Use the u or U flag to overwrite files."
    return 1
  fi

  if [ "$ADD_RESP" -eq 0 ] && [[ "$MODE" =~ (u|U) ]]; then
    printf "%s\n" "$SOURCE_FILE successfully updated."
    return 0
  elif [ "$ADD_RESP" -eq 0 ]; then
    printf "%s\n" "$SOURCE_FILE successfully added."
    return 0
  elif [ "$ADD_RESP" -eq 1 ] && [[ "$MODE" =~ (u|U) ]]; then
    ERROR_COUNT=$(($ERROR_COUNT+1))
    printf "%s\n%s\n" "Update failed: $FILE could not be updated." "Check that the addon exists and has correct permissions, and that the source and destination are set correctly."
    return 1
  else
    ERROR_COUNT=$(($ERROR_COUNT+1))
    printf "%s\n%s\n" "Import failed: $FILE could not be added." "Check that the addon exists and has correct permissions, and that the source and destination are set correctly."
    return 1
  fi
}

backupFile () {
  local FILE="$1"
  local BACKUP_DEST="${2:-$ADDON_DIR}"

  BACKUP_DEST="${BACKUP_DEST%/}"

  DATE="`date +"%Y%m%d"`"
  SOURCE_FILE="$ADDON_DIR/$FILE"
  BACKUP_FILE="$BACKUP_DEST/${FILE}_${DATE}.bkup"

  `cp -R $SOURCE_FILE $BACKUP_FILE 2>/dev/null`

  if [ "$?" -eq "0" ]; then
    printf "%s\n" "Back-up successful. New backup located at $BACKUP_FILE."
    return 0
  else
    ERROR_COUNT=$(($ERROR_COUNT+1))
    if [ "$MODE" = "b" ]; then
      printf "%s\n%s\n" "Backup failed: $FILE could not be backed-up." "Check that the addon exists and has correct permissions, and that the source and destination are set correctly."
    elif [ "$MODE" = "B" ]; then
      printf "%s\n%s\n" "Backup failed: $FILE could not be backed-up." "Check the addon and its permissions, and the chosen destination."
    fi
    return 1
  fi
}

removeFile () {
  if [ -d "$1" ]; then
    `rm -rf "$1" 2>/dev/null`
    printf "%s\n" "$1 was successfully removed."
    return 0
  else
    printf "%s\n" "Add-on does not exist: $1 does not exist and could not be deleted."
    return 1
  fi
}

updateFile () {
  local FILE="$1"
  local BACKUP_DEST="${2:-$ADDON_DIR}"

  backupFile "$FILE" "$BACKUP_DEST"
  local BACKUP_RESP="$?"

  if [ "$BACKUP_RESP" -eq 1 ] && [ "$MODE" = "u" ]; then
    printf "%s\n%s\n" "Back-up failed: $FILE was not backed up and will not be updated." "Check to make sure the file exists and has correct permissions, and that the source and destination are set correctly."
  elif [ "$BACKUP_RESP" -eq 1 ] && [ "$MODE" = "U" ]; then
    printf "%s\n%s\n" "Back-up failed: $FILE was not backed up and will not be updated." "Check the addon and its permissions, and the chosen destination."
  else
    addFile "$FILE"
  fi
}

exitWithErrorBasedStatus () {
   if [ "$1" -eq 0 ]; then exit 0; else exit 1; fi
}

MODES=()

while getopts ":abB:hrs:uU:" opt; do
  case "$opt" in
    a)
      MODES+=("a")
      ;;
    b)
      MODES+=("b")
      ;;
    B)
      MODES+=("B")
      BACKUP_DEST="$OPTARG"
      ;;
    h)
      displayHelpMessage | less
      exit 0
      ;;
    r)
      MODES+=("r")
      ;;
    s)
      SOURCE="$OPTARG"
      ;;
    u)
      MODES+=("u")
      ;;
    U)
      MODES+=("U")
      BACKUP_DEST="$OPTARG"
      ;;
    \?)
      printf "%s\n" "Invalid option -$OPTARG: Use the -h flag to learn more about accepted options." >&2
      exit 1
      ;;
    :)
      printf "%s\n" "Missing argument: Use the -h flag to learn more about the -$OPTARG option." >&2
      exit 1
      ;;
  esac
done
shift $(($OPTIND - 1))

if [ "$#" -eq 0 ]; then
  printf "%s\n" "Missing argument: Use the -h flag to learn about required arguments." >&2
  exit 1
else
  for FILE in "${@}"; do
    FILES+=($FILE)
  done
fi

if [ "${#MODES[@]}" -gt 1 ]; then
  printf "%s\n" "Mode conflict: Only one operation mode can be chosen. Use the -h flag to learn more about mode options." >&2
  exit 1
elif [ "${#MODES[@]}" -eq 0 ]; then
  MODE="a"
else
  MODE="${MODES[0]}"
fi

case $MODE in
  a)
    for FILE in "${FILES[@]}"; do
      addFile "$FILE"
    done
    exitWithErrorBasedStatus $ERROR_COUNT
    ;;
  b)
    for FILE in "${FILES[@]}"; do
      backupFile "$FILE"
    done
    exitWithErrorBasedStatus $ERROR_COUNT
    ;;
  B)
    for FILE in "${FILES[@]}"; do
      backupFile "$FILE" "$BACKUP_DEST"
    done
    exitWithErrorBasedStatus $ERROR_COUNT
    ;;
  r)
    printf "%s\n" "The following add-ons were selected for deletion:"
    for FILE in "${FILES[@]}"; do
      printf "%s\n" "$FILE"
    done
    printf "%s %s\n" "Are you sure you want to remove these add-ons?" "Y / N"
    read CONFIRM

    checkConfirmValidation "$CONFIRM"
    CONFIRM_STATUS="$?"

    while [ "$CONFIRM_STATUS" = 1 ]; do
      printf "%s\n" "Choose yes (Y/y) to proceed with removal or no (N/n) to cancel removal."
      read CONFIRM
      checkConfirmValidation $CONFIRM
      CONFIRM_STATUS="$?"
    done

    if [[ "$CONFIRM" =~ ^(y(es)?|Y(es)?)$ ]]; then
      for FILE in "${FILES[@]}"; do
        REMOVED_FILE="$ADDON_DIR/$FILE"

        removeFile "$REMOVED_FILE"
        if [ "$?" -eq 0]; then ERROR_COUNT+=1; fi
      done
      exitWithErrorBasedStatus $ERROR_COUNT
    elif [[ "$CONFIRM" =~ ^(n(o)?|N(no)$) ]]; then
      printf "%s\n" "Add-on removal has been cancelled."
      exit 1
    fi
    ;;
  u)
    for FILE in "${FILES[@]}"; do
      updateFile "$FILE"
    done
    exitWithErrorBasedStatus $ERROR_COUNT
    ;;
  U)
    for FILE in "${FILES[@]}"; do
      updateFile "${FILES[@]}" "$BACKUP_DEST"
    done
    exitWithErrorBasedStatus $ERROR_COUNT
    ;;
esac
