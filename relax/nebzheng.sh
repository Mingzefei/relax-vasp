#!/bin/bash
#--------------------------------------------------
# @File : nebzheng.sh
# @Time : 2022/03/08 09:26:50
# @Auth : Ming 
# @Vers : 1.0
# @Desc : zhengli for neb(CONTCAR neb.dat notes history movie vtst_history)(energy)(trans)
# @Usag : nebzheng.sh $image_num
#--------------------------------------------------

# here set the PATH and LANG
# PATH=
# LANG=zh_CN.UTF-8
# export PATH


relax_path=${hgb_path}/relax

if [ $# = 0 ]; then 
    echo "usage : nebzheng.sh image_num(IMAGES, like 12)"
    exit 1
elif [ "$1" -gt 0 ] 2>/dev/null; then
	image_num=$1
	echo "will zheng" $(seq -w 01 $image_num)

	# files will be saved in nebzheng_files
	if [ -d "./nebzheng_files" ]; then
		echo -e  "nebzheng_files has been here, renamed $(date +"%Y-%m-%d-%H:%M")_nebzheng_files_old"
		mv ./nebzheng_files ./$(date +"%Y-%m-%d-%H:%M")_nebzheng_files_old
	fi
	echo -e "mkdir nebzheng_files\n"
	mkdir ./nebzheng_files

	# cp CONTCAR
	echo -e "cp CONTCAR\n"
	for i in $(seq -w 00 $((${image_num}+1)) )
	do
		cp ${i}/CONTCAR ./nebzheng_files/${i}_CONTCAR
	done

	# neb.dat
	echo "do nebbarrier.pl to get neb.dat"
	${relax_path}/vtst/nebbarrier.pl > /dev/null
	mv neb.dat ./nebzheng_files/

	# notes or history(old version)
	echo "cp notes and history"
	cp *notes* ./nebzheng_files/ 
	cp *history* ./nebzheng_files/

	# nebmovie.pl 1
	echo "do nebmovie.pl 1 to get contcar movie"
	${relax_path}/vtst/nebmovie.pl 1 > /dev/null
	mv movie.xyz ./nebzheng_files/

	# nebvtst.py
	echo "do nebvtst.py to get vtst_history"
	${relax_path}/vtst/nebvtst.py ${image_num} >> vtst_history
	mv vtst_history ./nebzheng_files/

	echo ''

	# energy ini fin
	${relax_path}/energy.sh ini fin

	# trans
	read -p "need trans nebzheng_files to the door? [y/n]" input
	case $input in
		[yY][eE][sS]|[yY])
			${relax_path}/trans.sh nebzheng_files
			echo "done";;
		[nN][oO]|[nN])
			echo "No";;

		*)
			echo "Invalid input"
			exit 1
	esac	
else
	echo "usage : zheng.sh bu_1 bu_2 ..."
    exit 1
fi



