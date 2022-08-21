#!/bin/bash
#--------------------------------------------------
# @File : cdd1.sh
# @Time : 2022/03/07 09:28:50
# @Auth : Ming 
# @Vers : 1.0
# @Desc : (will get rid of this script) make im file for CHGCAR diff
#--------------------------------------------------

# here set the PATH and LANG
# PATH=
# LANG=zh_CN.UTF-8
# export PATH

#bu---CONTCAR KPOINTS INCAR CHGCAR (here)
#   |
#   ---cdd---AB_CHGCAR (A_CHGCAR B_CHGCAR)
#          |
#          ---(B)onlyLi+---history job.h.m
#	   |          |
#  	   |	      ---im
#	   |          ---bu_scf
#	   ---(A)withoutLi+---//same
# mv to ../

mkdir cdd
cp CHGCAR cdd/AB_CHGCAR
cp CONTCAR cdd/AB_CONTCAR
cp KPOINTS cdd/KPOINTS
cp INCAR cdd/INCAR

cd cdd
mkdir onlyLi+ withoutLi+

cd onlyLi+
mkdir im bu
echo -e "job.h.m\n" | cptemplate.h

cd im
#INCAR: NELECT EDIFF NGX/Y/ZF NSW
#	echo -e "scf_INCAR\n " | cptemplate.h
#	sed -i 's/#NELECT = 402/ NELECT = 2/g' scf_INCAR
#	mv scf_INCAR INCAR
	cp ../../INCAR ./INCAR
	sed -i 's/NELECT = 402/NELECT = 2/g' INCAR
	sed -i 's/NSW    = 500/NSW    = 0/g' INCAR
#KPOINTS
	cp ../../KPOINTS ./KPOINTS
#POTCAR
	potcar.sh Li_sv
#POSCAR
	cp ../../AB_CONTCAR ./
	sed -i '1c Li' AB_CONTCAR
	sed -i '6c Li' AB_CONTCAR
	sed -i '7c 1' AB_CONTCAR
	sed -i '9,104d' AB_CONTCAR
	mv AB_CONTCAR POSCAR

cd ..
echo "scf_onlyLi+" >> history
#qsub job.h.m

cd ../withoutLi+
mkdir im bu
echo -e "job.h.m\n" | cptemplate.h

cd im
  #INCAR: NELECT EDIFF NGX/Y/ZF NSW
#         echo -e "scf_INCAR\n " | cptemplate.h
#         sed -i 's/#NELECT = 402/ NELECT = 2/g' scf_INCAR
#         mv scf_INCAR INCAR
	  cp ../../INCAR ./INCAR
	  sed -i 's/ NELECT/#NELECT/g' INCAR
	  sed -i 's/NSW    = 500/NSW    = 0/g' INCAR
  #KPOINTS
          cp ../../KPOINTS ./KPOINTS
  #POTCAR
          potcar.sh Sn_d Cl C H N
  #POSCAR
          cp ../../AB_CONTCAR ./
          sed -i '1c Sn Cl C H N' AB_CONTCAR
          sed -i '6c Sn Cl C H N' AB_CONTCAR
          sed -i '7c 8 24 8 48 8' AB_CONTCAR
          sed -i '105d' AB_CONTCAR
          mv AB_CONTCAR POSCAR
  
cd ..
echo "scf_withoutLi+" >> history
#qsub job.h.m

cd ../..
mv cdd ../

cd ../cdd/onlyLi+
	qsub job.h.m
cd ../withoutLi+
	qsub job.h.m
cd ..
#pwd

