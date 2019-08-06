#!/bin/bash
: ${WATCHER_DEBUG:=false}
mkdir -p /srv/opencvImages
echo "Watching $1 on $(hostname)"

observe () {
  echo $1 received
}

inotifywait -m $1 -e close_write -e moved_to |
  while read path action file; do
    echo "The file '$file' appeared in directory '$path' via '$action'"
    FILE_TYPE=$( file -b $path$file|cut -f1 -d, )
    if [[ $FILE_TYPE == "JPEG image data" ]]; then
      observe $path$file
      mv $path$file /srv/opencvImages/
    else
      echo -n "file type was '$FILE_TYPE', "
      echo -n "$file Not JPEG, "
      if [[ $WATCHER_DEBUG == true ]]; then
        echo "retaining in tmp for further inspection. "
      else
        echo -n "throwing away. "
        rm -v $path$file
      fi
    fi
  done
