#!/bin/bash

## rename-ext-sh
# > changes file-extension based on mime-type
# - adds rename-date suffix to ensure uniquness of the filename
# - optimizes images while at it

## example
# rename-ext /Data/Pictures/_unsorted/**/*

## requires
# - `cargo install sd` – better sed
# - pngquant – to compress PNGs
# - jpegoptim – to compress JPEGs


ALL_EXTS='gif|jpe?g|a?png|web(p|m)|svg|eps|tga|tiff?|psd|ico|xcf|eot|otf|ttf|epub|doc|xls|swf|pdf|flac|opus|ogg|m4a|wav|mpe?g|mp\d|mov|mkv|avif?|asf|3gp|html?|sh|py|php'

OPTIONS=''

calc_reduction()
{
  SIZE_PRE="$1"
  SIZE_POST="$2"
  RESULT=''

  if [ $SIZE_PRE -gt $SIZE_POST ]; then
    PERECENT=` echo "scale=2; 100 - (100 * $SIZE_POST / $SIZE_PRE)" | bc `
    RESULT="$(( $SIZE_PRE / 1000 ))-$(( ( $SIZE_PRE - $SIZE_POST ) / 1000 )) kb \
($PERECENT%)
"
  fi

  echo "$RESULT"
}

rename_ext()
{
  NAME="$1"
  EXT="$2"
  NOTE="$3"
  TARGET=''
  if [[ "$OPTIONS" =~ 'only-ext' ]]; then
    NAME_NO_EXT=` echo "$NAME" \
           | sd -f i "(\.+($ALL_EXTS))$" '' \
           `
    TARGET="$NAME_NO_EXT.$EXT"
  else
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

  if [ "$NAME" != "$TARGET" ]; then
    echo "$FILENAME"

    if [[ "$OPTIONS" =~ 'test-run' ]]; then
      [ -f "$FILENAME" ] \
        && echo "replacing existing '$TARGET'"
      echo " >> $TARGET"
    else
      if [[ ! "$OPTIONS" =~ 'only-ext' ]]; then
        chmod -x "$FILENAME"

        SIZE_PRE=` stat "$FILENAME" -c '%s' `
        if [ "$EXT" == 'jpg' ];then
          jpegoptim "$FILENAME" -qsftp
        elif [ "$EXT" == 'png' ];then
          pngquant "$FILENAME" --output "$FILENAME" \
            --quality=100 --force --skip-if-larger --speed 1
        fi
        SIZE_POST=` stat "$FILENAME" -c '%s' `

        NOTE=` calc_reduction "$SIZE_PRE" "$SIZE_POST" `
      fi

      if [ ! -f "$TARGET" ]; then
        mv "$NAME" "$TARGET"
        echo "$NOTE >> $TARGET"
      else
        if [[ "$PARAMS" =~ 'force-replace' ]]; then
          echo "replacing existing '$TARGET'"
          mv "$NAME" "$TARGET"
          echo "$NOTE >> $TARGET"
        else
          echo "File '$TARGET' already exist, use '--force-replace' to overwrite"
        fi
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

  filetype=` file -b --mime-type "$FILENAME" `
  case "$filetype" in

  # pixel-based
  "image/gif") rename_ext "$FILENAME" "gif" ;;
  "image/jpeg") rename_ext "$FILENAME" "jpg" ;;
  "image/png") rename_ext "$FILENAME" "png" ;;
  "image/webp") rename_ext "$FILENAME" "webp" ;;

  # vector-based
  "image/svg+xml") rename_ext "$FILENAME" "svg" ;;
  "image/x-eps") rename_ext "$FILENAME" "eps" ;;

  # some less common image formats
  "image/x-tga") rename_ext "$FILENAME" "tga" ;;
  "image/tiff") rename_ext "$FILENAME" "tiff" ;;
  "image/vnd.adobe.photoshop") rename_ext "$FILENAME" "psd" ;;
  "image/vnd.microsoft.icon") rename_ext "$FILENAME" "ico" ;;
  "image/x-xcf") rename_ext "$FILENAME" "xcf" ;;

  # fonts
  "application/vnd.ms-fontobject") rename_ext "$FILENAME" "eot" ;;
  "application/vnd.ms-opentype") rename_ext "$FILENAME" "otf" ;;
  "font/sfnt") rename_ext "$FILENAME" "ttf" ;;

  # documents
  "application/epub+zip") rename_ext "$FILENAME" "epub" ;;
  "application/msword") rename_ext "$FILENAME" "doc" ;;
  "application/vnd.ms-excel") rename_ext "$FILENAME" "xls" ;;
  "application/x-shockwave-flash") rename_ext "$FILENAME" "swf" ;;
  # "application/pdf") rename_ext "$FILENAME" "pdf" ;; # can be .ai

  # audio
  "audio/flac") rename_ext "$FILENAME" "flac" ;;
  "audio/mpeg") rename_ext "$FILENAME" "mp3" ;;
  "audio/ogg") rename_ext "$FILENAME" "ogg" ;;
  "audio/x-m4a") rename_ext "$FILENAME" "m4a" ;;
  "audio/x-wav") rename_ext "$FILENAME" "wav" ;;

  # video
  "video/av1") rename_ext "$FILENAME" "avi" ;;
  "video/MP2T") rename_ext "$FILENAME" "mp2" ;;
  "video/mp4") rename_ext "$FILENAME" "mp4" ;;
  "video/x-m4v") rename_ext "$FILENAME" "mp4" ;;
  "video/quicktime") rename_ext "$FILENAME" "mov" ;;
  "video/webm") rename_ext "$FILENAME" "webm" ;;
  "video/x-matroska") rename_ext "$FILENAME" "mkv" ;;
  "video/x-ms-asf") rename_ext "$FILENAME" "asf" ;;
  "video/3gpp") rename_ext "$FILENAME" "3gp" ;;

  # text
  # "text/html") rename_ext "$FILENAME" "html" ;; # can be .htm, .htc, .mht, ...
  # "text/x-shellscript") rename_ext "$FILENAME" "sh" ;; # can have no .<ext>
  # "text/x-python") rename_ext "$FILENAME" "py" ;; # can be .py3, have no .<ext>

  # any
  "application/octet-stream") ;; # can be anything

  # special
  "inode/directory") ;; # literally a folder

  *) echo "!!  $FILENAME : $filetype" ;;

  esac

done

# if [[ "@#" -eq 1 ]]; then
#   if [[ `file -b --mime-type "$1"` == "inode/directory" ]]; then
#     find "$1"
#   fi
# fi
