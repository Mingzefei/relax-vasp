#!/bin/bash
#--------------------------------------------------
# @File : trans.sh
# @Time : 2022/03/08 10:09:46
# @Auth : Ming 
# @Vers : 1.0
# @Desc : trans file or dir to the door
# @Usag : trans.sh file_1 dir_2 ...
#--------------------------------------------------

# here set the PATH and LANG
# PATH=
# LANG=zh_CN.UTF-8
# export PATH



door_path=${hgb_path}/door

if [ $# = 0 ]; then
	echo "no input files"
	echo 'usage : trans.sh file_1 dir_2 ...'
	exit 0
else
	for i in $@
	do
		if [ -e ${i} ]; then
			echo "will copy ${i}"
			read -p "name it(prefix):" name

			# check file or dir in door before cp
			if [ -e ${door_path}/${name}_${i} ]; then
				echo "${name}_${i} exist! renamed $(date +"%Y-%m-%d-%H:%M")_${name}_${i}_old"
				mv ${door_path}/${name}_${i} ${door_path}/$(date +"%Y-%m-%d-%H:%M")_${name}_${i}_old
			fi
			cp -r ./${i} ${door_path}/${name}_${i}
			if (($? == 0)); then 
				echo "${name}_${i} copyed to the door";
			else
				echo "${name}_${i} failed to copy";
			fi
		fi

	done
fi


