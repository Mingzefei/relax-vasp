#!/bin/bash
#--------------------------------------------------
# @File : dos.sh
# @Time : 2022/03/07 09:28:50
# @Auth : Ming 
# @Vers : 1.0
# @Desc : (will get rid of this script) make im file for dos
#--------------------------------------------------

# here set the PATH and LANG
# PATH=
# LANG=zh_CN.UTF-8
# export PATH

#file---bu_opt---CONTCAR CHGCAR POTCAR
#     |(here)
#     ---im---INCAR (dos_INCAR) POSCAR(CONTCAR) KPOINTS CHGCAR POTCAR
#     |	
#     ---job.h.m
#     ---bu

mkdir bu

read -r -p "where can I get CONTCAR and CHGCAR?[dir]: " bu_opt
cp bu_opt/CONTCAR im/POSCAR
cp bu_opt/CHGCAR im/
cp bu_opt/POTCAR im/

cd im
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

echo -e "dos" >> history


#qsub job.h.m

