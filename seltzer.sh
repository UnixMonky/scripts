#!/bin/bash


if [[ -z $1 ]]; then
    echo "No argument supplied. exiting..."
    exit
fi
CMD=$1

case $CMD in
    "up")
        cd ~/git/devilbox      
        cp seltzer.env .env;
        [[ ! $(mount | grep /data/www/seltzer/htdocs) ]] && sudo mount --bind /home/matt/git/seltzer /data/www/seltzer/htdocs ;
        docker-compose up -d bind httpd php mysql ;;
    "start")
        cd ~/git/devilbox      
        cp seltzer.env .env;
        [[ ! $(mount | grep /data/www/seltzer/htdocs) ]] && sudo mount --bind /home/matt/git/seltzer /data/www/seltzer/htdocs ;
        docker-compose start bind httpd php mysql ;;
    "stop" | "down")
        cd ~/git/devilbox      
        docker-compose ${CMD} ;
        [[ $(mount | grep /data/www/seltzer/htdocs) ]] && sudo umount /data/www/seltzer/htdocs ;;
esac
