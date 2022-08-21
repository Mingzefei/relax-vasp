#!/bin/bash
#--------------------------------------------------
# @File : kpoint.sh
# @Time : 2022/03/07 21:54:32
# @Auth : Ming 
# @Vers : 1.0
# @Desc : make KPOINTS 
# @Usag : kpoints.sh G|M 1 2 3 (default G 1 1 1)
#--------------------------------------------------

# here set the PATH and LANG
# PATH=
# LANG=zh_CN.UTF-8
# export PATH


echo K-POINTS > KPOINTS
echo " 0" >> KPOINTS
if [ -z $1 ]||[ ${1:0:1} == "G" ]&&[ -z $2 ]
then
    echo Gamma-Centered >> KPOINTS
    echo " 1 1 1" >> KPOINTS
    echo " 0 0 0" >> KPOINTS
    exit
else
	if [ ${1:0:1} == "M" ] ; then
		echo Monkhorst-Pack >> KPOINTS
		if [ -z $2 ]; then
		    echo " 1 1 1" >> KPOINTS
			echo " 0 0 0" >> KPOINTS
			exit
		fi
	elif [ ${1:0:1} == "G" ]; then
			echo Gamma-Centered >> KPOINTS
	elif [[ $1 =~ ^[0-9]+$ ]]; then
			echo Gamma-Centered >> KPOINTS
			echo " $1 $2 $3" >> KPOINTS
			echo " 0 0 0" >> KPOINTS
			exit
	else
		echo Your input is WRONG. TRY kpoint G 1 1 1
		exit
	fi
	echo " $2 $3 $4" >> KPOINTS
	echo " 0 0 0" >> KPOINTS
fi


