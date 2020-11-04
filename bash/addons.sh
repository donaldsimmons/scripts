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
BACKUP_DIR=""

displayHelpMessage () {
  printf "%s\n%s\n\n" "WoW AddOn Utility" "Allows manual addition, removal, back-up, and updating of WoW AddOn programs"
  printf "%s\n" "Syntax: addons.sh {-a|-b|-B|-h|-r|-s|-u|-U} [FILE_PATHS...]"
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
      displayHelpMessage
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
      SOURCE_FILE="$SOURCE/$FILE"
      DEST_FILE="$ADDON_DIR/$FILE"

      `cp -R $SOURCE_FILE $DEST_FILE 2>/dev/null`
      if [ "$?" -eq 0 ]; then
        printf "%s\n" "$SOURCE_FILE added successfully"
      else
        printf "%s\n" "$FILE could not be added. Check that the addon exists and has correct permissions, and that the source and destination are set correctly."
      fi
    done
    ;;
  b)
    for FILE in "${FILES[@]}"; do
      DATE="`date +"%Y%m%d"`"
      SOURCE_FILE="$ADDON_DIR/$FILE"
      BACKUP_FILE="$ADDON_DIR/${FILE}_${DATE}.orig"

      `cp -R $SOURCE_FILE $BACKUP_FILE 2>/dev/null`
      if [ "$?" -eq "0" ]; then
        printf "%s\n" "Back-up successful. New backup located at $BACKUP_FILE."
      else
        printf "%s\n" "$FILE could not be backed-up. Check that the addon exists and has correct permissions, and that the source and destination are set correctly."
      fi
    done
    ;;
  B)
    # copy from to dest/file_name.orig
    ;;
  r)
    # generate warning message/wait for response
    # rm from addon_dir
    ;;
  u)
    # copy matching addons from addon_dir to addon/file_name.orig
    # copy matching addons from source to addon folder
    ;;
  U)
    # copy matching addons from addon_dir to dest/file_name.orig
    # copy matching addons from source to addon folder
    ;;
esac
