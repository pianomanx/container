#!/usr/bin/env python3
# Plex analayze all files that are missing analyzation info

from subprocess import call
import os
import requests
import sqlite3
import sys

conn = sqlite3.connect('/config/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db')

c = conn.cursor()
c.execute('Select media_items.metadata_item_id As id, metadata_items.title As title From media_items Inner Join metadata_items On media_items.metadata_item_id = metadata_items.id Where media_items.bitrate Is Null And Not metadata_items.metadata_type = "12"')
items = c.fetchall()
conn.close()

print("To analyze: " + str( len(items) ))

for row in items:
	os.system('LD_LIBRARY_PATH=/usr/lib/plexmediaserver PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/config/Library/Application\ Support /usr/lib/plexmediaserver/Plex\ Media\ Scanner -a -o ' + str(row[0]))
	os.system('sleep 1')
	print(str(row[0]))
