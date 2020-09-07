#!/bin/bash

## rename-ext-sh
# > changes file-extension based on mime-type

## also
# - removes `*?|^:"<>` characters from the file-name
# - reducing multiple spaces, dots, and underscores
# - adds rename-date suffix to ensure uniquness of the filename
# - strips exec-flag from non-executive types (usual leftover from FAT/NTFS)
# - optimizes images while at it (shows reduction size in `kb` and `%`)

## example
# rename-ext /Data/Pictures/_unsorted/**/*

## requires
# - `cargo install sd` – better sed
# - pngquant – to compress PNGs
# - jpegoptim – to compress JPEGs


ALL_EXTS='gif|jpe?g|a?png|web(p|m)|svg|eps|tga|tiff?|psd|ico|xcf|eot|otf|ttf|epub|doc|xls|swf|pdf|flac|opus|ogg|m4a|wav|mpe?g|mp\d|mov|mkv|avif?|asf|3gp|html?|sh|py|php'

OPTIONS=''
NR='1'

calc_reduction()
{
  SIZE_PRE="$1"
  SIZE_POST="$2"
  PERECENT=` echo "scale=2; 100 - (100 * $SIZE_POST / $SIZE_PRE)" | bc `
  RESULT="$(( $SIZE_PRE / 1000 ))-$(( ( $SIZE_PRE - $SIZE_POST ) / 1000 )) kb \
($PERECENT%)
"
  echo "$RESULT"
}

rename_ext()
{
  NAME="$1"
  EXT="$2"
  NOTE=''
  TARGET=''
  if [[ "$OPTIONS" =~ 'only-ext' ]]; then
    NAME_NO_EXT=` echo "$NAME" \
           | sd -f i "(\.+($ALL_EXTS))$" '' \
           `
    TARGET="$NAME_NO_EXT.$EXT"
  else
    if [[ ! "$OPTIONS" =~ 'test-run' ]]; then
      chmod -x "$FILENAME"

      SIZE_PRE=` stat "$FILENAME" -c '%s' `

      [ "$EXT" = 'jpg' ] \
        && jpegoptim "$FILENAME" -qsftp
      [ "$EXT" = 'png' ] \
        && pngquant "$FILENAME" --output "$FILENAME" \
             --quality=100 --force --skip-if-larger --speed 1

      SIZE_POST=` stat "$FILENAME" -c '%s' `

      [ $SIZE_PRE -gt $SIZE_POST ] \
        && NOTE=` calc_reduction "$SIZE_PRE" "$SIZE_POST" `
    fi
    DATE=` date -r "$NAME" -u "+%Y%m%d%H%M%S" `
    TCLEAN=` echo "$NAME" \
           | sd '[\\\?\*\|^:"<>]+' '_' \
           | sd '_\d{12,}\.' '.' \
           | sd -f i "(\.+($ALL_EXTS))+$" '' \
           `
    TARGET=` echo "${TCLEAN}_$DATE.$EXT" \
       | sd '([\s\.,_]){3,}' '$1' \
       `
  fi

  [ "$NAME" = "$TARGET" ] \
    && return

  echo "$NR:"
  NR="$(($NR+1))"
  echo "$FILENAME"

  if [[ "$OPTIONS" =~ 'test-run' ]]; then
    if [ -f "$TARGET" ]; then
      if [[ "$PARAMS" =~ 'force-replace' ]]; then
        echo " >> replacing existing file >> "
      else
        echo " !! file already exist !! "
      fi
    fi
    echo "$TARGET"
  else
    if [ ! -f "$TARGET" ]; then
      echo " >> $NOTE >> "
      echo "$TARGET"
      mv "$NAME" "$TARGET"
    else
      if [[ "$PARAMS" =~ 'force-replace' ]]; then
        echo " >> $NOTE ## replacing existing file >> "
        echo "$TARGET"
        mv "$NAME" "$TARGET"
      else
        echo ' !! File already exist, use `--force-replace` to overwrite !! '
        echo "$TARGET"
      fi
    fi
  fi

}

for PARAM in "$@"; do
  if [ "$PARAM" == '--only-ext' ]; then
    OPTIONS="$OPTIONS;only-ext"
  elif [ "$PARAM" == '--test-run' ]; then
    OPTIONS="$OPTIONS;test-run"
  elif [ "$PARAM" == '--force-replace' ]; then
    OPTIONS="$OPTIONS;force-replace"
  fi
done
echo "OPTIONS: '$OPTIONS'"


for FILENAME in "$@"; do

  [ ! -f "$FILENAME" ] \
    && continue

  FILE_TYPE=` file -b --mime-type "$FILENAME" `
  case "$FILE_TYPE" in

  # pixel-based
  'image/gif') rename_ext "$FILENAME" 'gif' ;;
  'image/jpeg') rename_ext "$FILENAME" 'jpg' ;;
  'image/png') rename_ext "$FILENAME" 'png' ;;
  'image/webp') rename_ext "$FILENAME" 'webp' ;;

  # vector-based
  'image/svg+xml') rename_ext "$FILENAME" 'svg' ;;
  'image/x-eps') rename_ext "$FILENAME" 'eps' ;;

  # some less common image formats
  'image/tiff') rename_ext "$FILENAME" 'tiff' ;;
  'image/vnd.adobe.photoshop') rename_ext "$FILENAME" 'psd' ;;
  'image/vnd.microsoft.icon') rename_ext "$FILENAME" 'ico' ;;
  'image/x-tga') rename_ext "$FILENAME" 'tga' ;;
  'image/x-xcf') rename_ext "$FILENAME" 'xcf' ;;

  # fonts
  'application/vnd.ms-fontobject') rename_ext "$FILENAME" 'eot' ;;
  'application/vnd.ms-opentype') rename_ext "$FILENAME" 'otf' ;;
  'font/sfnt') rename_ext "$FILENAME" 'ttf' ;;

  # documents
  'application/epub+zip') rename_ext "$FILENAME" 'epub' ;;
  'application/msword') rename_ext "$FILENAME" 'doc' ;;
  'application/pdf') ;; # can be .ai
  'application/vnd.ms-excel') rename_ext "$FILENAME" 'xls' ;;
  'application/x-shockwave-flash') rename_ext "$FILENAME" 'swf' ;;

  # audio
  'audio/flac') rename_ext "$FILENAME" 'flac' ;;
  'audio/mpeg') rename_ext "$FILENAME" 'mp3' ;;
  'audio/ogg') rename_ext "$FILENAME" 'ogg' ;;
  'audio/x-m4a') rename_ext "$FILENAME" 'm4a' ;;
  'audio/x-wav') rename_ext "$FILENAME" 'wav' ;;

  # video
  'video/3gpp') rename_ext "$FILENAME" '3gp' ;;
  'video/av1') rename_ext "$FILENAME" 'avi' ;;
  'video/MP2T') rename_ext "$FILENAME" 'mp2' ;;
  'video/mp4') rename_ext "$FILENAME" 'mp4' ;;
  'video/quicktime') rename_ext "$FILENAME" 'mov' ;;
  'video/webm') rename_ext "$FILENAME" 'webm' ;;
  'video/x-m4v') rename_ext "$FILENAME" 'mp4' ;;
  'video/x-matroska') rename_ext "$FILENAME" 'mkv' ;;
  'video/x-ms-asf') rename_ext "$FILENAME" 'asf' ;;

  # text
  'application/json') ;; # can be any other language
  'text/html') ;; # can be .htm, .htc, .mht, ...
  'text/plain') ;; # can be any file with not enough text
  'text/x-python') ;; # can be .py3, have no .ext
  'text/x-shellscript') ;; # can be .zsh, have no .ext

  # special
  'application/octet-stream') ;; # can be anything
  'inode/directory') ;; # a folder
  'inode/x-empty') ;; # zero-size

  # default
  *) echo "??  $FILENAME : $FILE_TYPE" ;;

  esac

done

# if [[ "@#" -eq 1 ]]; then
#   if [[ `file -b --mime-type "$1"` == "inode/directory" ]]; then
#     find "$1"
#   fi
# fi
