#!/bin/bash
#--------------------------------------------------
# @File : nebsave.sh
# @Time : 2022/03/08 09:03:52
# @Auth : Ming 
# @Vers : 1.0
# @Desc : save nebjob's result: POSCAR CONTCAR OUTCAR OSZICAR
# @Usag : nebsave.sh $image_num 
#--------------------------------------------------

# here set the PATH and LANG
# PATH=
# LANG=zh_CN.UTF-8
# export PATH


if [ $# = 0 ]; then 
    echo "usage : nebsave.sh image_num(IMAGES, like 12)"
    exit 1
elif [ "$1" -gt 0 ] 2>/dev/null; then
	image_num=${1}
	echo "will save" $(seq -w 01 ${image_num})
	read -p "name old files (prefix):" name
	for i in $(seq -w 01 ${image_num})
	do
		cd ${i}

		cp POSCAR ${name}_POSCAR
		cp CONTCAR ${name}_CONTCAR
		cp OUTCAR ${name}_OUTCAR
		cp OSZICAR ${name}_OSZICAR
		
		echo "-----${i}-----"
		ls *
		cd ..
	done

	echo "nebvtst.py ${image_num} >> ${name}_vtst_history"
	nebvtst.py ${image_num} >> ${name}_vtst_history

	read -p "need copy CONTCAR to POSCAR? [y/n]" input
	case $input in 
		[yY][eE][sS]]|[yY])
			echo "copying"
			for i in $(seq -w 01 ${image_num})
			do
				cp ${i}/CONTCAR ${i}/POSCAR
			done
			echo "done";;
		[nN][oO]|[nN])
			echo "No";;
		*)
			echo "Invalid input"
			exit 1
	esac

fi



