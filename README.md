#### script-collection
Thats my public collection of scripts for various purposes.

## IBM_Storwize_V7000_attributes_collection.sh
Sctipt to collect info about enclosures, drives and etc of BM Storwize V7000 storage system

## music_to_flash.sh
Script for encoding of audio files to proper bitrate to play with Yatour YT-M06  

## script_template.sh
Thats just template for bash-script writing which I usually use

## clear_system_logs.sh
Simple script to prune logs if you are lazy guy and don't want to tune syslogd. Just edit "vacuum_time" parameter and add script to crontab.

## bruteforce_pass_and_inventory.sh
Script was wroten at 2017 to find all servers in subnet with known passwords and just a little inventory them. 

## mysql_bkp.sh
Simple script to backup MySQL DB.

## app_log_archiver.sh
Parallel archive script. Usable for directories with 100+k small files, when your command | tar czf file.tgz * | brokes in case of bash limitations for length of variable.
