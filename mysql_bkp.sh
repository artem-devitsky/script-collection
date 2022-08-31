#!/usr/bin/bash

#Created by Artsiom Dziavitski
#DB backup script 2017.01.04
#################APP_SERVER################

#Env block#
curr_date="$(date '+%Y%m%d_%H-%M')"
dump_dir="/bkp/db"
dump_name="db_""$curr_date"".sql.gz"
db_name="$1"
db_user="$2"
db_pass="$3"
script_dir="$(pwd)"
scr_lock_file="$script_dir""/db_backup.lock"
###########

#Func block#
function func_check_start { 

if [ -f "$scr_lock_file" ]
then {
        echo "Backup software allrady started or lockfile has not been deleted in case of broken prewius backup process."
        echo "Delete ""$scr_lock_file"" If prewius backup process was broken."
        exit 4
        }
else {
        touch "$scr_lock_file"
        if [ $? -eq 0 ]
        then
                echo "Successfully created lockfile"
        else
                echo "Could not create lockfile" >&2
fi
        echo "started at $curr_date" > "$scr_lock_file"
        }
fi
}

function func_del_lock { 
if [ -f "$scr_lock_file" ]
then {
        rm -f "$scr_lock_file"
}
fi
}

function func_create_backup { 
touch "$dump_dir/$dump_name"
if [ $? -eq 0 ]
	then
		echo "Successfully created test file"
		rm -f "$dump_dir/$dump_name"
	else
		echo "Could not create test file" >&2
		exit 5
fi
	
/usr/bin/mysql -u "$db_user" -p"$db_pass" -e 'use "$db_name"'
if [ $? -eq 0 ]
	then
		echo "Successfully created db backup"
	else
		echo "Could not create db backup" >&2
		exit 6
fi
/usr/bin/mysqldump --opt -u "$db_user" -p"$db_pass" "$db_name"  | gzip -9 > "$dump_dir/$dump_name"
}

############

####BEGIN####
case $1 in 
start)
func_check_start
func_create_backup
func_del_lock
;;
*)
        echo "Usage $0:"
        echo "Allowed keys: start"
        echo "start key starts a backup"
;;
esac

#####END#####
