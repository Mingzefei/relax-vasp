#!/bin/bash
#--------------------------------------------------
# @File : cptemplate.sh
# @Time : 2022/03/07 16:24:53
# @Auth : Ming 
# @Vers : 1.0
# @Desc : copy files or dir in ${hgb_path}/relax/template
#--------------------------------------------------

# here set the PATH and LANG
# PATH=
# LANG=zh_CN.UTF-8
# export PATH

temp_path=${hgb_path}/relax/template
copy_path=`pwd`

# show file and dir
echo "file and dir under ${temp_path}"
cd ${temp_path} && ls


# input 
read -p "file or dir to be copyed: " copyfiles


if [ ! -n "$copyfiles" ]; then
	echo "no input"
	cd - > /dev/null
	exit 0
else
	for i in $copyfiles;
	do
		cp -r ${temp_path}/*${i}* ${copy_path}/ 2> /dev/null

		if (($? == 0)); then 
			echo *${i}* " copyed";
		else
			echo *${i}* " failed to copyed";
		fi

	done
	cd - > /dev/null
	exit 0
fi
