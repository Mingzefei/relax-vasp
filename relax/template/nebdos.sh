#!/bin/bash
#--------------------------------------------------
# @File : nebdos.sh
# @Time : 2022/03/07 10:44:48
# @Auth : Ming 
# @Vers : 1.0
# @Desc : (will get rid of this script) make im file for neb dos
#--------------------------------------------------

# here set the PATH and LANG
# PATH=
# LANG=zh_CN.UTF-8
# export PATH



#0x---CONTCAR KPOINTS  CHGCAR (here)
#   |
#   ---dos_0x---job.h.m  bu
#             |
#             ---im---POSCAR INCAR CHGCAR POTCAR KPOINTS
#mv cdd_0x ../


echo  "these images will run cdd.h:" $*
read -r -p "Sure? [Y/n]" input
case $input in 
	[nN][oO]|[nN])
		echo -e "No, out\n"
		exit 0 ;;
	[yY][eE][sE]|[yY])
		echo -e "OK, running\n";;
	*)
		echo -e "Invalid input, out\n"
		exit 1 ;;
esac


for i in $*
do
echo -e "=======" ${i} "======\n"
cd $i

mkdir dos
mkdir dos/im dos/bu

cp CHGCAR dos/im/
cp CONTCAR dos/im/POSCAR
cp ../POTCAR dos/im/

cd dos/im

#INCAR: ICHARG ISMEAR NELECT 
	echo -e "dos_INCAR\n " | cptemplate.h
	mv dos_INCAR INCAR
#	sed -i 's/ICHARG = 11/ICHARG = 1/g' INCAR
#	sed -i 's/ISMEAR = 0/ISMEAR = -5/g' INCAR
#	sed -i 's/NELECT = 402/#NELECT = 402/g' INCAR

#KPOINTS a*k~45
	kpoint.h 4 4 4
#POTCAR
#POSCAR
cd ..

#echo -e "job.h.m\n" | cptemplate.h
#	sed -i '24 s/#cp/ cp' job.h.m

echo -e "${i}_dos" >> history


echo qsub job.h.m

cd ..
mv dos ../dos_${i}

cd ..
done


