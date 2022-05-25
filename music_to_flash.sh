#!/usr/bin/env bash
#Created by Artsiom Dziavitski
#Yatour YT-M06 file preparation script
#ffmpeg -i input.mp3 -codec:a libmp3lame -b:a 128k output.mp3
#~/.local/bin/eyeD3 --remove-all-images /run/media/username/46CA-18E1/*/*.mp3

MURANO_DIR="${2}"
WRK_DIR=""
MAX_BITRATE="256"

#func_cdprep (){
#
#}


func_setnum () {
local num="1"
local fname=""
for file in "${WRK_DIR}"/*
do
	echo $num
	ls -al "${file}"
	fname=`basename "${file}"`
	echo "${fname}"
	if [ $num -le "9" ]
		then {
			if [ $(file "${file}"  | sed 's/.*, \(.*\)kbps.*/\1/' | tr -d " ") -gt "${MAX_BITRATE}" ] || ! [[ $yournumber =~ $re ]]
			then {
				if ffmpeg -i "${file}" -codec:a libmp3lame -b:a "${MAX_BITRATE}k" -vsync 2 -vn "${WRK_DIR}"/00"$num"_"${fname}"
					then rm -f "${file}"
					else mv "${file}" "${WRK_DIR}"/00"$num"_"${fname}"
				fi
			}
			else {
				 mv "${file}" "${WRK_DIR}"/00"$num"_"${fname}"
			}
			fi
		}		
	else {
	if [ $(file "${file}"  | sed 's/.*, \(.*\)kbps.*/\1/' | tr -d " ") -gt "${MAX_BITRATE}" ] || ! [[ $yournumber =~ $re ]]
			then {
				if ffmpeg -i "${file}" -codec:a libmp3lame  -b:a "${MAX_BITRATE}k" -vsync 2 -vn "${WRK_DIR}"/0"$num"_"${fname}"
					then rm -f "${file}"
					else mv "${file}" "${WRK_DIR}"/0"$num"_"${fname}"
				fi
			}
			else {
				mv "${file}" "${WRK_DIR}"/0"$num"_"${fname}"
			}
			fi
		}
	fi
	let "num++"
done
local num="1"
}


func_fileprep () {
local file=""
local fname=""
local fname_nodig=""
for file in  "${WRK_DIR}"/*
do
	fname=`basename "${file}"`
	if [[ $fname =~ ^[0-9] ]]
		then {
		fname_nodig="$(echo $fname|cut -d "_" -f 2- |cut -d " " -f 2-)"
		fname_nodig=${fname_nodig// /_}
		mv -v "${WRK_DIR}/${fname}" "${WRK_DIR}/${fname_nodig}" 
		} 
		else {
		fname_nodig=${fname// /_}
		mv -v "${WRK_DIR}/${fname}" "${WRK_DIR}/${fname_nodig}" 
		}
	fi
done
if [ -f *Live*.mp3 ]
then {
rm -v "${WRK_DIR}"/*Live*.mp3
}
fi
}

case $1 in
fileprep)
func_fileprep
func_fileprep
func_fileprep
;;
setnum)
func_setnum
;;
prepare)
cd "${MURANO_DIR}"
for directory in */
do
	WRK_DIR="$(realpath ${directory})"
	echo "Processing $WRK_DIR"
	func_fileprep
	func_fileprep
	func_fileprep
	func_setnum
done
;;
*)
echo "Usage: $0 prepare /path/to/flash_card"
;;
esac
