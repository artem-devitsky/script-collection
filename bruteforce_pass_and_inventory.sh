#!/usr/bin/env bash
#Created by Artsiom Dziavitski
#################APP_SERVER################

#Env block#
readonly v_SUBNET_LIST=(`cat ./subnets.txt`)

###########

#Func block#
function f_get_hosts_net_info () {
local last_bit=0
local end_bit=254
local host_availability=0
local hc_host=""
local host_key=""
local host_key_check=""
local SSHPASS=""
local ssh_ok=""

cat /dev/null > ./known_hosts.txt

for subnet in ${v_SUBNET_LIST[@]}
do
	echo this is net: $subnet
	while [ $last_bit -le $end_bit ]
	do
		let "last_bit++"
		hc_host=`echo $subnet | sed s'/\(.*\)\(.\)$/\1'$last_bit'/g'`
		host_availability=`ping -c 1 "$hc_host" |grep received | awk '{print $4;}'`
		if [ ! -z "${host_availability}" ]
		then {
			if [[ "$host_availability" -eq "1" ]]
			then {
				host_key=`ssh-keyscan -t rsa $hc_host 2>/dev/null`
				if [ ! -z "${host_key}" ]
				then {
					host_key_check=`cat ~/.ssh/known_hosts|grep "${host_key}"|wc -l`
					if [[ "$host_key_check" -eq "1" ]]
					then {
						echo "key of ${hc_host} in known_hosts"
						rm -f "./results/host_$hc_host.txt"
						while read -r line
						do
							if [ ! -f "./results/host_$hc_host.txt" ]
							then {
								ssh_ok=0
								ssh_ok=`(SSHPASS=$line sshpass -v -e ssh -l root $hc_host ifconfig) 2>/dev/null | grep $hc_host |wc -l`
								if [ $ssh_ok -eq "1" ]
								then {
									echo "host $hc_host password found in file."
									touch "./results/host_$hc_host.txt"
									echo "HOSTNAME=`(SSHPASS=$line sshpass -v -e ssh -l root $hc_host hostname) 2>/dev/null`" >> "./results/host_$hc_host.txt"
									echo "IP_ADDRESS=$hc_host" >> "./results/host_$hc_host.txt"
									echo "USERNAME=root" >> "./results/host_$hc_host.txt"
									echo "PASSWORD=$line" >> "./results/host_$hc_host.txt"
									(SSHPASS=$line sshpass -v -e ssh -l root $hc_host find /abs -maxdepth 2 -name *.properties  | grep -v java |grep -v jre ) 2>/dev/null >> "./results/host_"$hc_host"_prop.txt"
									(SSHPASS=$line sshpass -v -e ssh -l root $hc_host find /abs -maxdepth 2 -name tnsnames.ora  | grep -v java |grep -v jre ) 2>/dev/null >> "./results/host_"$hc_host"_tns.txt"

								}
								fi
							}
							fi
						done < ./root_passwd
					}
					else {
						echo "key of ${hc_host} not in known_hosts"
						ssh-keyscan -t rsa $hc_host 2>/dev/null >> ~/.ssh/known_hosts
						while read -r line
						do
							if [ ! -f "./results/host_$hc_host.txt" ]
							then {
								ssh_ok=0
								ssh_ok=`(SSHPASS=$line sshpass -v -e ssh -l root $hc_host ifconfig) 2>/dev/null | grep $hc_host |wc -l`
								if [ $ssh_ok -eq "1" ]
								then {
									echo "host $hc_host password found in file."
									touch "./results/host_$hc_host.txt"
									echo "HOSTNAME=`(SSHPASS=$line sshpass -v -e ssh -l root $hc_host hostname) 2>/dev/null`" >> "./results/host_$hc_host.txt"
									echo "IP_ADDRESS=$hc_host" >> "./results/host_$hc_host.txt"
									echo "USERNAME=root" >> "./results/host_$hc_host.txt"
									echo "PASSWORD=$line" >> "./results/host_$hc_host.txt"
									(SSHPASS=$line sshpass -v -e ssh -l root $hc_host find /abs -maxdepth 2 -name *.properties  | grep -v java |grep -v jre ) 2>/dev/null >> "./results/host_"$hc_host"_prop.txt"
									(SSHPASS=$line sshpass -v -e ssh -l root $hc_host find /abs -maxdepth 2 -name tnsnames.ora  | grep -v java |grep -v jre ) 2>/dev/null >> "./results/host_"$hc_host"_tns.txt"

								}
								fi
							}
							fi
						done < ./root_passwd						
					}
					fi
				host_key=""
				}
				fi
				}
			fi
		}
		fi
	done
last_bit=0
done
}

function f_get_info () {
local host_addrs=(`ls -a ./results/ | column -t -s "_"| awk '{print $2}' | grep -v ".txt" | sort -n |uniq`)
local tns_files=""
local tns_file=""
local tnss=""
local tns=""
local prop_files=""
local prop_file=""
local file_size=0
local props=""
local prop=""
local inst_name=""
local user=""
local pass=""
local wrk_dir=""

for host_addr in ${host_addrs[@]}
do
	echo "$host_addr"
	file_size=(`stat "./results/host_"$host_addr"_tns.txt" |grep Size | awk '{print $2}'`)
	if [ $file_size -gt "0" ]
	then {
		prop_files=(`cat "./results/host_"$host_addr"_prop.txt"`)
		tns_files=(`cat "./results/host_"$host_addr"_tns.txt"`)
		user=`cat "./results/host_"$host_addr".txt"|grep USERNAME | column -t -s "=" | awk '{print $2}'`
		pass=`cat "./results/host_"$host_addr".txt"|grep PASSWORD | column -t -s "=" | awk '{print $2}'`
		for prop_file in ${prop_files[@]}
		do
			echo $prop_file
			inst_name=`echo $prop_file| column -t -s "/" | awk {'print $3'} | column -t -s "." | awk {'print $1'}`
			echo "======================================================================="
			echo "Settings of instance: $inst_name"
			props=`(SSHPASS=$pass sshpass -v -e ssh -l $user $host_addr cat $prop_file|grep -v "#" ) 2>/dev/null`
			for prop in ${props[@]}
			do
				wrk_dir=`echo $prop_file| column -t -s "/"|awk '{print "/"$1"/"$2"/"}'`
				if [ `echo $prop|grep AD.CONTEXT|wc -l` -ge "1" ]
				then {
					echo "$prop"
				}
				
				elif [ `echo $prop|grep AD.USERNAME|wc -l` -ge "1" ]
				then {
					echo "$prop"
				}
				elif [ `echo $prop|grep AD.PASSWORD|wc -l` -ge "1" ]
				then {
					echo "$prop"
				}
				elif [ `echo $prop|grep AD.IP=|wc -l` -ge "1" ]
				then {
					echo "$prop"
				}
				elif [ `echo $prop|grep AD.PORT|wc -l` -ge "1" ]
				then {
					echo "$prop"
				}				
				elif [ `echo $prop|grep AD.USER_GROUP=|wc -l` -ge "1" ]
				then {
					echo "$prop"
				}				
				elif [ `echo $prop|grep AD.ADM_GROUP=|wc -l` -ge "1" ]
				then {
					echo "$prop"
				}
				elif [ `echo $prop|grep IB.LDAP.IP|wc -l` -ge "1" ]
				then {
					echo "$prop"
				}
				elif [ `echo $prop|grep IB.LDAP.PORT|wc -l` -ge "1" ]
				then {
					echo "$prop"
				}
				elif [ `echo $prop|grep IB.LDAP.USER|wc -l` -ge "1" ]
				then {
					echo "$prop"
				}
				elif [ `echo $prop|grep IB.LDAP.PASSWORD|wc -l` -ge "1" ]
				then {
					echo "$prop"
				}
				elif [ `echo $prop|grep POS.LDAP.IP|wc -l` -ge "1" ]
				then {
					echo "$prop"
				}
				elif [ `echo $prop|grep POS.LDAP.PORT|wc -l` -ge "1" ]
				then {
					echo "$prop"
				}
				elif [ `echo $prop|grep POS.LDAP.USER|wc -l` -ge "1" ]
				then {
					echo "$prop"
				}
				elif [ `echo $prop|grep POS.LDAP.PASSWORD|wc -l` -ge "1" ]
				then {
					echo "$prop"
				}				
				elif [ `echo $prop|grep SERVER_NAME|wc -l` -ge "1" ]
				then {
					echo "$prop"
					
				}
				elif [ `echo $prop|grep USERNAME|wc -l` -ge "1" ]
				then {
					echo "$prop"
				}
				elif [ `echo $prop|grep DEFAULT_URL|wc -l` -ge "1" ]
				then {
					
					for tns_file in ${tns_files[@]}
					do
						if [ `echo $tns_file|grep $wrk_dir|wc -l` -eq "1" ]
						then {
							echo "$prop"
							echo "$tns_file"
						tns=`(SSHPASS=$pass sshpass -v -e ssh -l $user $host_addr cat $tns_file|column -t -s "()"|grep SERVICE_NAME|sed 's/ //g'|sort -n| uniq ) 2>/dev/null`
						echo "$tns"
						tns=`(SSHPASS=$pass sshpass -v -e ssh -l $user $host_addr cat $tns_file|column -t -s "()"|grep HOST|awk '{print $6$7$8}'|sort -n|uniq ) 2>/dev/null`
						echo "$tns"
						}
						fi
					done
					
					
				}
				elif [ `echo $prop|grep DEFAULT_USER|wc -l` -ge "1" ]
				then {
					echo "$prop"
				}				
				elif [ `echo $prop|grep DEFAULT_PASSWORD|wc -l` -ge "1" ]
				then {
					echo "$prop"
				}				
				elif [ `echo $prop|grep ETALON|wc -l` -ge "1" ]
				then {
					echo "$prop"
				}
				
				fi
			done			
		done
		}
	fi
done
}

############

####BEGIN####

case $1 in

start)
#f_get_hosts_net_info
f_get_info
;;
*)
echo "Usage $0:"
echo "Allowed keys: start and clean"
;;
esac

#####END#####
exit 0
