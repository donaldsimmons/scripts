#!/bin/bash

displayHelp () {
  printf "%s\n%s\n\n" "Unpack Extraction Utility" "Extract files from a variety of different compressed or packaged file types"
  printf "%s\n" "Syntax: unpack.sh [FILE_PATHS...]"
}

while getopts ":h" opt; do
  case "$opt" in
    h)
      displayHelp
      exit 0
      ;;
    \?)
      printf "%s\n" "Invalid argument: -$OPTARG is invalid. Use -h to learn about the correct syntax."
      exit 1
      ;;
  esac
done

if [ "$#" -eq 0 ]; then
  displayHelp
  exit 1
fi

for FILE in "$@"; do
  case "$FILE" in
    *.gz)
      `gunzip "$FILE"`;;
    *.bz2)
      `bunzip2 "$FILE"`;;
    *.dmg)
      `hdiutil mount "$FILE"`;;
    *.tar)
      `tar -xvf "$FILE"`;;
    *.tgz | *.tar.gz)
      `tar -zxvf "$FILE"`;;
    *.tar.xz)
      `tar -Jxvf "$FILE"`;;
    *.tbz2 | *.tar.bz2)
      `tar -jxvf "$FILE"`;;
    *.xz)
      `unxz -v "$FILE"`;;
    *.zip)
      `unzip "$FILE"`;;
    *.*)
      EXT="${FILE#*.*}"
      ! printf "%s\n" "Invalid extension: .$EXT extraction is not supported at this time."
      ;;
    *)
      ! printf "%s\n" "No extension: $FILE does not have a recognized file extension."
  esac

  if [ "$?" -eq 0 ]; then
    printf "%s\n" "$FILE was successfully unpacked."
  fi
done
