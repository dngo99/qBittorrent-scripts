#!/bin/bash
# Managers other post download scripts for qBittorrent

set -e
set -u
set -o pipefail

CATEGORY="$1"
SOURCE="$2"
DESTINATION="$3"
LOG="$(pwd)/qBittorrent-scripts.log"

sleep 120s

case $CATEGORY in 
    "Anime" | "anime")
        ./process-anime.bash "$SOURCE" "$DESTINATION" >> $LOG
        ./update-jellyfin.bash >> $LOG
        ;;
    "Movie" | "movie")
        ;;
    *)
        ;;
esac
exit 0
