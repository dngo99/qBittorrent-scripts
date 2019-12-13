#!/bin/bash
# Triggers a Jellyfin library refresh via API

set -e
set -u
set -o pipefail

# Jellyfin API key
API_KEY=""
# Jellyfin domain, no trailing slash "/"
JELLYFIN=""

echo $(curl -v --silent -d "" -H "X-MediaBrowser-Token: $API_KEY" -X POST -i "https://$JELLYFIN/library/refresh" 2>/dev/null | grep HTTP | perl -ne 'print "update-jellyfin.bash:  $_"')
