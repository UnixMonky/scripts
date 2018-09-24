#!/bin/bash

rsync -aAXv / \
   --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/cifs/*","/virtualbox/*","/data/*","/home/matt/Dropbox/*","/home/matt/.cache/*"} \
   /media/matt/touro/archive/
