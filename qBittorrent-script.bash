#!/bin/bash

SRC="$2"
API_KEY=""
DST=""

LOG_PATH="$(pwd)/qBittorrent-script.log"

#echo "%L: "$1 >> $LOG_PATH
#echo "%F: "$2 >> $LOG_PATH
#echo "%R: "$3 >> $LOG_PATH
#echo "%D: "$4 >> $LOG_PATH

if [ "$1" != "Anime" ]; then
	exit 0
fi

sleep 120s
./process-anime.bash -v "$SRC" "$DST" >> $LOG_PATH
if [ -d "$SRC" ]; then
	rmdir "$SRC" >> $LOG_PATH
fi
curl -X POST "https://jf.pyras.duckdns.org/emby/Library/Refresh?api_key=$API_KEY" -d "" -i | grep HTTP | perl -ne 'print "Jellyfin:  $_"'>> $LOG_PATH
exit 0
