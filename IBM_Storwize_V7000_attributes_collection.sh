#!/bin/bash
#Createt by Artsiom Dziavitski
#https://goo.gl/0UvFOl
#https://drive.google.com/folderview?id=0B3BCpTmQPhq5fk9HcW1aeDBaamIwcFZNU3VOd3ZqOU5WVFRpbTFFXzhNamt1WGZvYkdKVjg&usp=sharing


#readonly set v7k_addr=$1
#readonly v7k_login=$2
v7k_addr=""
v7k_login=""
readonly script_dir=`dirname "$BASH_SOURCE"`
v7k_enc_id="0"

function func_first_connect(){
	local ffc_addr=$1
	local ffc_lgn=$2
	if [ ! -f "$ffc_lgn"_"$ffc_addr".key ]
		then {
		ssh-keygen -b 2048 -t rsa -f "$script_dir"/"$ffc_lgn"_"$ffc_addr".key -q -N ""
		chmod 600 "$script_dir"/"$ffc_lgn"_"$ffc_addr".key
		chmod 600 "$script_dir"/"$ffc_lgn"_"$ffc_addr".key.pub
		if [ -f "$ffc_lgn"_"$ffc_addr".key ]
			then {
			echo "Temp key-file created"
			scp "$script_dir"/"$ffc_lgn"_"$ffc_addr".key.pub ""$ffc_lgn@$ffc_addr:/tmp/
			ssh $ffc_lgn@$ffc_addr << EOF
			chcurrentuser -keyfile /tmp/"$ffc_lgn"_"$ffc_addr".key.pub
EOF
			}
			else {
			echo "Key file not created"
			exit 1
			}		
			fi
		}
		fi
}

function func_get_enc(){
	local fge_addr=$1
	local fge_lgn=$2
#	local fge_pss=$3
	#local fge_fname=.fge_buf
	local fge_top=""
	local fge_counter="1"
	ssh $fge_lgn@$fge_addr -i "$script_dir"/"$fge_lgn"_"$fge_addr".key > $script_dir/.enc_buf_$fge_addr << EOF
		lsenclosure
EOF
	fge_top=`cat  "$script_dir"/.enc_buf_"$fge_addr"|wc -l`
	rm -f 
    while read line
    do
       if [ $fge_counter -eq 1 ]
       then {
             echo ""
          }
       else {
             echo $line | awk '{print $1}' >>  "$script_dir"/.enc_ids_"$fge_addr"
             }
       fi
       let "fge_counter += 1"
    done < $script_dir/.enc_buf_$fge_addr

	
	#rm $script_dir/.enc_buf
}

function func_get_enc_drives() {
	local fged_addr=$1
	local fged_lgn=$2
	local fged_encid=$3
	local fged_fname=.fged_buf
	local fged_counter=1
	
	function fged_lsdrive() {
		local fl_addr=$1
		local fl_lgn=$2
		local fl_encid=$3
		ssh "$fl_lgn"@"$fl_addr" -i "$script_dir"/"$fl_lgn"_"$fl_addr".key > "$script_dir"/.drives_buf_"$fl_addr"_"$fl_encid" << EOF
		lsdrive -filtervalue enclosure_id=$fl_encid
EOF
	}
	function fged_drive(){
		local fd_addr=$1
		local fd_lgn=$2
		local fd_driveid=$3
		local fd_encid=$4
		ssh "$fd_lgn"@"$fd_addr" -i "$script_dir"/"$fd_lgn"_"$fd_addr".key > "$script_dir"/.drives_buf_"$fd_addr"_"$fd_encid"_"$fd_driveid" << EOF
		lsdrive $fd_driveid
EOF

	}
	fged_lsdrive $fged_addr $fged_lgn $fged_encid
	fged_top=`cat "$script_dir"/.drives_buf_"$fged_addr"_"$fged_encid"|wc -l`
	while read drive
	do
		if [ $fged_counter -eq 1 ]
		then {
				echo ""
		}
		else {
				#echo "time to rock"
				drive_id=`echo "$drive" | awk '{print $1}'`
				#echo $fged_addr $fged_lgn $drive_id $fged_encid
				fged_drive $fged_addr $fged_lgn $drive_id $fged_encid
		}
		fi
		let "fged_counter += 1"
	done < "$script_dir"/.drives_buf_"$fged_addr"_"$fged_encid"
}

function func_report(){
	local fr_addr=$1
	local fr_lgn=$2
	local fr_repfile="$script_dir"/report_"$fr_addr".html
	local fr_counter_enc="1"
	local fr_top_enc=`cat  "$script_dir"/.enc_buf_"$fr_addr"|wc -l`
	####create HTML File
#	echo "<html>" > $fr_repfile
#	echo "<head>" >>
cat > $fr_repfile <<- EOF 
<html>
<head>
    <title>V7000 Hardware configuration</title>
</head>
  <style>
   p {
    text-indent: 40px; 
	line-height: 0.5em;
   }
  </style>
<body>
	<br>
	<br>
	<br>
	<p><b><span style="margin-left:2em"> V7000 Hardware configuration</span><br></b></p>
EOF


	while read fr_enc
		do
		
		if [ $fr_counter_enc -eq 1 ]
       then {
             echo ""
          }
       else {
				fr_eid=`echo "$fr_enc" | awk '{print $1}'`
				fr_mach=`echo "$fr_enc" | awk '{print $7}'`
				fr_serial=`echo "$fr_enc" | awk '{print $8}'`
				
				cat >> $fr_repfile <<- EOF
				<br>
				<font size="3"><p><b><span style="margin-left:2em"> Enclosure ID</span><span style="margin-left:4em">Machine</span><span style="margin-left:4em">Serial Number</span><br></b></p></font>
				<font size="3"><p><b><span style="margin-left:5em">$fr_eid</span><span style="margin-left:6em">$fr_mach</span><span style="margin-left:5em">$fr_serial</span><br></b></p></font>
EOF
					local fr_dfiles="$script_dir"/.drives_buf_"$fr_addr"_"$fr_eid"_*
					local fr_dfile_counter=1
					for fr_dfile in $fr_dfiles
					do
						fr_dparam1=`cat $fr_dfile |grep slot_id | awk '{print $2}'`
						fr_dparam2=`cat $fr_dfile |grep FRU_part_number | awk '{print $2}'`
						fr_dparam3=`cat $fr_dfile |grep firmware_level | awk '{print $2}'`
						echo "$fr_dparam1	$fr_dparam2	$fr_dparam3" >> "$script_dir"/.drives_"$fr_addr"_"$fr_eid"
						if [ "$fr_dfile_counter" -eq `ls -a ./.drives_buf_"$fr_addr"_"$fr_eid"_* |wc -l` ]
						then {
							cat "$script_dir"/.drives_"$fr_addr"_"$fr_eid" | sort -n >> "$script_dir"/.drives_"$fr_addr"_"$fr_eid"_
						}
						fi
						let "fr_dfile_counter += 1"
						if [ -f "$script_dir"/.drives_"$fr_addr"_"$fr_eid"_ ]
						then {
							cat >> $fr_repfile <<- EOF
							<br>
							<font size="2"><p><b><span style="margin-left:5em">Disk Slot</span><span style="margin-left:3em">FRU</span><span style="margin-left:3em">Firmware</span><br></b></p></font>
EOF
							while read disk
							do
							cat >> $fr_repfile <<- EOF
							<font size="2"><p><b><span style="margin-left:7em">`echo $disk | awk '{print $1}'`</span><span style="margin-left:3em">`echo $disk | awk '{print $2}'`</span><span style="margin-left:3em">`echo $disk | awk '{print $3}'`</span><br></b></p></font>
EOF
							done <"$script_dir"/.drives_"$fr_addr"_"$fr_eid"_
						}
					fi
					done
				}
				
       fi
       let "fr_counter_enc += 1"
		done <"$script_dir"/.enc_buf_"$fr_addr"
		fr_counter_enc=1

cat >> $fr_repfile <<- EOF
</body>
</html>
EOF

}

if [ -z $v7k_addr ]
then {
	read -p "Enter IP or hostname of V7000: " v7k_addr
	v7k_addr=${v7k_addr:-localhost}
	echo "v7k_addr: $v7k_addr"
	if [ -z $v7k_addr ] || [ $v7k_addr == "localhost" ]
	then {
		echo "Wrong address. v7k_addr: " $v7k_addr
		exit 1
	}
	fi
}
else {
	echo "v7k_addr: $v7k_addr"
}
fi
echo $v7k_login
if [ -z $v7k_login ]
then {
	read -p "Enter user name of V7000: " v7k_login
	v7k_login=${v7k_login:-dev_test}
	echo "v7k_login: $v7k_login"
	if [ -z $v7k_login ] || [ $v7k_login == "superuser" ]
	then {
		echo "Wrong login! Do not try to login by superuser! Create new user on V7000, script use dev_test user by default"
		exit 1
	}
	fi
}
fi
func_first_connect $v7k_addr $v7k_login
func_get_enc $v7k_addr $v7k_login  2> /dev/null
	
while read enc_id
do
	func_get_enc_drives $v7k_addr $v7k_login $enc_id  2> /dev/null
done <  "$script_dir"/.enc_ids_"$v7k_addr"
func_report $v7k_addr $v7k_login
rm -f .*_"$v7k_addr"*

if [ -f "$script_dir"/report_"$v7k_addr".html ]
then {
	echo "Report file created."
	echo ""$script_dir"/report_"$v7k_addr".html"
}
else {
	echo "Report file not created."
	echo "Check IP address and credentials."
	}
fi


exit