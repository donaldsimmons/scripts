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
      # copy from source to addon_dir
      ;;
    b)
      MODES+=("b")
      # copy from addon_dir to addon/file_name.orig
      ;;
    B)
      MODES+=("B")
      BACKUP_DEST="$OPTARG"
      # copy from to dest/file_name.orig
      ;;
    h)
      displayHelpMessage
      exit 0
      ;;
    r)
      MODES+=("r")
      # generate warning message/wait for response
      # rm from addon_dir
      ;;
    s)
      SOURCE="$OPTARG"
      ;;
    u)
      MODES+=("u")
      # copy matching addons from addon_dir to addon/file_name.orig
      # copy matching addons from source to addon folder
      ;;
    U)
      MODES+=("U")
      BACKUP_DEST="$OPTARG"
      # copy matching addons from addon_dir to dest/file_name.orig
      # copy matching addons from source to addon folder
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
fi

if [ "${#MODES[@]}" -gt 1 ]; then
  printf "%s\n" "Mode conflict: Only one operation mode can be chosen. Use the -h flag to learn more about mode options." >&2
  exit 1
else
  MODE="${MODES[0]}"
fi
