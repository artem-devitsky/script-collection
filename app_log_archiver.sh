#!/bin/bash
#Created by Artsiom Dziavitski
#Just place script to directory that 1 level uper then directory with logs
#Environment block
service_name=""

param_key1=$1
param_kay1_val=$2
param_key2=$3
param_kay2_val=$4
extr_date_start=$5
extr_date_end=$6
param_check_return=""
search_pttrn_in="in_*"
search_pttrn_out="out_*"

script_dir=`dirname "$BASH_SOURCE"` 
wrk_dir=$script_dir"/some_dir" #Edit log directory name if needed
filebuf_size="5000"


######################################################################################

############################==Function block==########################################

function param_check () {
local pc_pkey1=$1
local pc_pkey1_val=$2
local pc_pkey2=$3
local pc_pkey2_val=$4
local pc_excode=""

#Function return 2 digital execution code. 
#First digit is job type (1 - is archivation, 2 - is extraction), second digit is file type (1 - in, 2 - out, 3 - all)


if [ "$pc_pkey1" == "-J" ] || [ "$pc_pkey1" == "-j" ]   # condition1 OR condition2
then {
	if [ "$pc_pkey1_val" == "a" ]
	then {
		echo "Job type is archivation"
		pc_excode="10"
			if [ "$pc_pkey2" == "-T" ] || [ "$pc_pkey2" == "-t" ]
			then {
					if [ "$pc_pkey2_val" == "in" ]
						then {
							pc_excode=$(($pc_excode+1))
#							echo "archivation type is IN_Log, execution code: $pc_excode"			
						}
						elif [ "$pc_pkey2_val" == "out" ]
						then {
							pc_excode=$(($pc_excode+2))
#							echo "archivation type is OUT_Log, execution code: $pc_excode"
						}
						elif [ "$pc_pkey2_val" == "all" ]
						then {
							pc_excode=$(($pc_excode+3))
#							echo "archivation type is IN_Log and OUT_Log, execution code: $pc_excode"
						}
						else {
							echo "Entered unsupported value of -T parameter. Please use in for IN_Log, out for Out_Log and all for both type of files"
							exit 2
						}
					fi;
					}
			else {
				echo "Please, use key -T for define a type of log for compress"	
				exit 2
			}
			fi;
	}
	elif [ "$pc_pkey1_val" == "x" ]
	then {
		echo "Job type is extraction"
		pc_excode="20"		
			if [ "$pc_pkey2" == "-T" ] || [ "$pc_pkey2" == "-t" ]
			then {
					if [ "$pc_pkey2_val" == "in" ]
						then {
							pc_excode=$(($pc_excode+1))
							echo "extraction type is IN_Log, execution code: $pc_excode"
						}
						elif [ "$pc_pkey2_val" == "out" ]
						then {
							pc_excode=$(($pc_excode+2))
							echo "extraction type is OUT_Log, execution code: $pc_excode"
						}
						elif [ "$pc_pkey2_val" == "all" ]
						then {
							pc_excode=$(($pc_excode+3))
							echo "extraction type is IN_Log and OUT_Log, execution code: $pc_excode"
						}
						else {
							echo "Entered unsupported value of -T parameter. Please use in for IN_Log, out for Out_Log and all for both type of files"
							exit 2
						}
					fi;
					}
			else {
				echo "Please, use value a for archive or x for extraction"	
				exit 2
			}
			fi;
			
	}
	else {
			echo "Please, use key -T for define a type of log for compress"	
			exit 2
	}
	fi;
	}
elif [ "$pc_pkey1" == "-T" ] || [ "$pc_pkey1" == "-t" ] 
then {
		echo "-T on wrong place. Please use -J before -T. like: ./scriptname.sh -J a -T all"
	}
else {
		echo "Place for HELP here"
}
fi

return $pc_excode
}

#Usage
#param_check $param_key1 $param_kay1_val $param_key2 $param_kay2_val
#param_check_return=$?
#echo "parameter param_check_return is $param_check_return"
#######

function compression_processor () {
local cp_servicename=$1
local cp_searchpttrn=$2
local cp_workdate=$3
local cp_inout=$4
local cp_work_dir=$5
local cp_filebuf_size=$6
local cp_stopdate=`date --date "$cp_workdate +1 day" +%F`
local cp_arcfile=`date --date="$cp_workdate" +%Y%m%d`
local cp_arcfile="$cp_work_dir""/arch/""$cp_arcfile""-""$cp_servicename""_some_dir_$cp_inout.tar"
local cp_file=""
local cp_delay=`shuf -i 2-20 -n 1`
local cp_filebufer=1

until [ ${#cp_filebufer} -eq 0 ]
do
		cp_filebufer=`find $cp_work_dir -maxdepth 1 -iname "$cp_searchpttrn" -type f -newermt $cp_workdate ! -newermt $cp_stopdate 2>/dev/null | head -n $cp_filebuf_size `
	if [ ! -f $cp_arcfile ]
	then {
				if [ ${#cp_filebufer} -gt 0 ]
				then {
						echo "create tar of $cp_workdate"
						tar cf $cp_arcfile $cp_filebufer --remove-files
				}
				fi
		}
		elif [ -f $cp_arcfile ]
		then {
				if [ ${#cp_filebufer} -gt 0 ]
				then {
						echo "append to tar $cp_workdate next $cp_filebuf_size files"
						tar rf  $cp_arcfile $cp_filebufer --remove-files
				}
				fi
		}
		fi
done


		if [ -f $cp_arcfile.gz ]
		then {
				echo "File $cp_arcfile.gz exist. Please rename or move old file"
				}
		elif [ -f $cp_arcfile ]
				then {
						gzip -v $cp_arcfile
				}
				fi
}

#Usage
#compression_processor $flc_service_name $search_pttrn_out $flc_work_date $in_out $wrk_dir $filebuf_size &
######



function file_list_compression () {
flc_wrk_dir=$1
flc_file_type=$2
flc_service_name=$3
oldest_file=`ls -t $flc_wrk_dir | grep -E '^[^d]' | tail -n 1`
oldest_file_date=`stat -c %y $flc_wrk_dir/$oldest_file | awk '{print $1}'`
flc_search_pttrn_in="in_*"
flc_search_pttrn_out="out_*"
filebuf_size="5000" #nubmer of files
flc_ptrn_in="$flc_wrk_dir/in_"
flc_ptrn_out="$flc_wrk_dir/out_"
flc_work_date=$oldest_file_date
flc_target_date=`date --date "today" +%F`
flc_arc_dir="$flc_wrk_dir/arch"


if [ -z "$oldest_file_date" ]
	then {
	echo "Blank oldest_file_date value"
	exit 2
	}
fi
   
	if [ ! -d $flc_arc_dir ];
	then {
				mkdir $flc_arc_dir
				}
		fi

		until [ "$flc_work_date" = "$flc_target_date" ]
		do
				if [ "$flc_file_type" == "in" ]
						then {
								in_out="in"
								compression_processor $flc_service_name $flc_search_pttrn_in $flc_work_date $in_out $flc_wrk_dir $filebuf_size &
						}
				elif [ "$flc_file_type" == "out" ]
						then {
								in_out="out"
								compression_processor $flc_service_name $flc_search_pttrn_out $flc_work_date $in_out $flc_wrk_dir $filebuf_size &
						}
				elif [ "$flc_file_type" == "all" ]
						then {
								in_out="in"
								compression_processor $flc_service_name $flc_search_pttrn_in $flc_work_date $in_out $flc_wrk_dir $filebuf_size &
								########################################################################################################
								in_out="out"
								compression_processor $flc_service_name $flc_search_pttrn_out $flc_work_date $in_out $flc_wrk_dir $filebuf_size &
						}
				else {
						echo "Incorrect file type"
						exit 2
						}
				fi

				flc_work_date=`date --date "$flc_work_date +1 day" +%F`
		done
wait
}

#Usage
#file_list_compression $wrk_dir $file_type $service_name
######

function extraction_processor () {
local ep_service_name=$1
local ep_file_type=$2
local ep_work_dir=$3
local ep_arc_date_start=$4
local ep_arc_date_end=$5


if [ "$ep_arc_date_end" -gt "$ep_arc_date_start" ]
then {
	echo "if_gt"
	echo "ep_arc_date_start  is $ep_arc_date_start"
	echo "ep_arc_date_end  is $ep_arc_date_end "
	
	until [ "$ep_arc_date_start" -gt "$ep_arc_date_end" ]
	do {
		local ep_arc_dir="$ep_work_dir""/arch/extracted/""$ep_arc_date_start"
		local ep_arc_file="$ep_work_dir""/arch/""$ep_arc_date_start""-""$ep_service_name""_some_dir_$ep_file_type"".tar.gz"

		echo "until_gt"
		if [ ! -d $ep_work_dir ];
		then {
			mkdir -p $ep_work_dir
		}
		fi
		if [ ! -d $ep_arc_dir ];
                then {
					mkdir -p $ep_arc_dir
                }
                fi
		echo "ep_arc_date_end is $ep_arc_date_end  ep_arc_date_start is $ep_arc_date_start"
		echo "arc $ep_arc_file  will be extracted to $ep_arc_dir"
		if [ -f $ep_arc_file ]
		then {
			echo "$ep_arc_file exist"
						
			tar -C "$ep_arc_dir" -xzf "$ep_arc_file"
		}
		else {
			echo "$ep_arc_file not exist"
		}
		fi
		ep_arc_date_start=`date --date "$ep_arc_date_start +1 day" +%Y%m%d`
	}
	done
}
	elif [ "$ep_arc_date_end" -eq "$ep_arc_date_start" ]
	then {
		if [ ! -d $ep_work_dir ];
		then {
			mkdir -p $ep_work_dir
		}
		fi

	if [ ! -d $ep_arc_dir ];
	then {
		mkdir -p $ep_arc_dir
	}
	fi
	echo "arc $ep_arc_file  will be extracted to $ep_arc_dir"
		if [ -f $ep_arc_file ]
		then {
			echo "$ep_arc_file exist"
			tar -C "$ep_arc_dir" -xzf "$ep_arc_file"
		}
		else {
			echo "$ep_arc_file not exist"
			}
		fi
}
else {
	echo "ep_arc_date_end less ep_arc_date_start"
}
fi
}

#Usage
#extraction_processor $service_name $file_type $wrk_dir $date_start $date_end
######

####################################################################################################
##################################################Begin#############################################
start=`date +%s`
echo "Work started at $start"

param_check $param_key1 $param_kay1_val $param_key2 $param_kay2_val
param_check_return=$?
echo "parameter param_check_return is $param_check_return"

#First digit is job type (1 - is archivation, 2 - extraction), second digit is file type (1 - in, 2 - out, 3 - all)
if [[ $param_check_return -ge 11 && $param_check_return -le 13 ]]
then {
	echo "start file_list_compression in archivation mode"
	if [ $param_check_return -eq 11 ]
	then {
		echo "archivation of IN_Log"
		file_type="in"
		echo " wrk_dir is : $wrk_dir "
		echo " file_type is : $file_type "
		echo " service_name is : $service_name "
		file_list_compression $wrk_dir $file_type $service_name
	}
	elif [ $param_check_return -eq 12 ]
	then {
		echo "archivation of OUT_Log"
		file_type="out"
		file_list_compression $wrk_dir $file_type $service_name
	}
	elif [ $param_check_return -eq 13 ]
	then {
		echo "archivation of IN_Log and OUT_Log"
		file_type="out"
		file_list_compression $wrk_dir $file_type $service_name
###############################################################
		file_type="in"
		file_list_compression $wrk_dir $file_type $service_name
	}
	fi;
	}
elif [[ $param_check_return -ge 21 && $param_check_return -le 23 ]]
then {
	
	if [ -z $extr_date_start ]
	then {
		echo "no date for arch"
	}
	elif [ -n $extr_date_start ] && [ -z $extr_date_end ] 
	then {
		echo "end date will be same date as start date"
		extr_date_end=$extr_date_start
	}
	elif [ -n $extr_date_start ] || [ -n $extr_date_end ]
	then {
		echo "end date will be $extr_date_end date, start date is $extr_date_start"
		echo "all ok"
	}
	fi
	echo "start file_list_compression in extraction mode"
	if [ $param_check_return -eq 21 ]
	then {
		echo "extraction of IN_Log"
		echo "---------------debug main--------------"
		echo "extr_date_start  is $extr_date_start"
		echo "extr_date_end  is $extr_date_end "
		echo "wrk_dir is $wrk_dir"
		echo "file_type is $file_type"
		echo "service_name is $service_name"
		echo "---------------------------------------"
		file_type="in"
		extraction_processor $service_name $file_type $wrk_dir $extr_date_start $extr_date_end 
	}
	elif [ $param_check_return -eq 22 ]
	then {
		echo "---------------debug main--------------"
		echo "extr_date_start  is $extr_date_start"
		echo "extr_date_end  is $extr_date_end "
		echo "wrk_dir is $wrk_dir"
		echo "file_type is $file_type"
		echo "service_name is $service_name"
		echo "---------------------------------------"
		file_type="out"
		echo "extraction of OUT_Log"
		extraction_processor $service_name $file_type $wrk_dir $extr_date_start $extr_date_end
	}
	elif [ $param_check_return -eq 23 ]
	then {
		echo "---------------debug main--------------"
		echo "extr_date_start  is $extr_date_start"
		echo "extr_date_end  is $extr_date_end "
		echo "wrk_dir is $wrk_dir"
		echo "file_type is $file_type"
		echo "service_name is $service_name"
		echo "---------------------------------------"

		echo "extraction of IN_Log and OUT_Log"
		file_type="in"
		extraction_processor $service_name $file_type $wrk_dir $extr_date_start $extr_date_end
		############################################
		file_type="out"
		extraction_processor $service_name $file_type $wrk_dir $extr_date_start $extr_date_end
	}
	fi;
}
fi

end=`date +%s`
runtime=$((end-start))
echo "execution time: $runtime"
exit 0

##################################################End###################################################################
########################################################################################################################


