#!/bin/bash
#--------------------------------------------------
# @File : cpdoor.sh
# @Time : 2022/03/07 15:41:03
# @Auth : Ming 
# @Vers : 1.0
# @Desc : copy files or dir in ${hgb_path}/door
#--------------------------------------------------

# here set the PATH and LANG
# PATH=
# LANG=zh_CN.UTF-8
# export PATH

door_path=${hgb_path}/door
copy_path=`pwd`

# show file and dir
echo "file and dir under ${door_path}"
cd ${door_path} && ls


# input 
read -p "file or dir to be copyed: " copyfiles


if [ ! -n "$copyfiles" ]; then
	echo "no input"
	cd - > /dev/null
	exit 0
else
	for i in $copyfiles;
	do
		cp -r ${door_path}/*${i}* ${copy_path}/ 2> /dev/null

		if (($? == 0)); then 
			echo *${i}* " copyed";
		else
			echo *${i}* " failed to copyed";
		fi

	done
	cd - > /dev/null
	exit 0
fi

