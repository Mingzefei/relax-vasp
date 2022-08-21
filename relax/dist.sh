#!/bin/bash
#--------------------------------------------------
# @File : dist.sh
# @Time : 2022/03/07 16:48:34
# @Auth : Ming 
# @Vers : 1.0
# @Desc : dist from POSCAR_A to POSCAR_B
# @Usag : dist.sh POSCAR CONTCAR or only dist.sh (POSCAR and CONTCAR) or dist.sh bu_opt1(dir) bu_opt2(dir) ...
#--------------------------------------------------

# here set the PATH and LANG
# PATH=
# LANG=zh_CN.UTF-8
# export PATH

which_dist=${hgb_path}/relax/vtst/dist.pl


if [ $# = 2 ] && [ -f ${1} ] && [ -f ${2} ]; then
	POSCAR_A=$1
	POSCAR_B=$2
	dist=$($which_dist $POSCAR_A $POSCAR_B)
	echo "distance from $POSCAR_A to $POSCAR_B : $dist A"
elif [ $# = 0 ]; then
	POSCAR_A=POSCAR
	POSCAR_B=CONTCAR
	dist=$($which_dist $POSCAR_A $POSCAR_B)
	echo "distance from POSCAR to POSCAR : $dist A"
else
	for i in $*
	do
		POSCAR_A=./${i}/POSCAR
		POSCAR_B=./${i}/CONTCAR
		dist=$($which_dist $POSCAR_A $POSCAR_B)
		echo -e "${i} : distance from POSCAR to CONTCAR : $dist A"
	done
fi
