#!/bin/bash
#--------------------------------------------------
# @File : nebcdd.sh
# @Time : 2022/03/07 10:44:16
# @Auth : Ming 
# @Vers : 1.0
# @Desc : (will get rid of this script) make im file for neb CHGCAR diff
#--------------------------------------------------

# here set the PATH and LANG
# PATH=
# LANG=zh_CN.UTF-8
# export PATH



#!!!!!!must use scf_INCAR!!!!!!

#0x---CONTCAR KPOINTS  CHGCAR (here)
#   |
#   ---cdd_0x---AB_CHGCAR (A_CHGCAR B_CHGCAR)
#          |
#          ---(B)onlyLi+---history job.h.m
#	   |          |
#  	   |	      ---im
#	   |          ---bu_scf
#	   ---(A)withoutLi+---//same
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
cp ../KPOINTS ./

mkdir cdd
cp CHGCAR cdd/AB_CHGCAR
cp CONTCAR cdd/AB_CONTCAR
mv KPOINTS cdd/KPOINTS
#cp INCAR cdd/INCAR

cd cdd
mkdir onlyLi+ withoutLi+
 
cd onlyLi+
echo "------" $(basename `pwd`) "-----"
mkdir im bu
echo -e "job.h.m\n" | cptemplate.h

cd im
#INCAR: NELECT EDIFF NGX/Y/ZF NSW
 	echo -e "scf_INCAR\n " | cptemplate.h
	sed -i 's/#NELECT = 402/ NELECT = 2/g' scf_INCAR
	sed -i 's/EDIFF  = 1.0E-05/EDIFF  = 1.0E-06/g' scf_INCAR
	mv scf_INCAR INCAR
#	cp ../../INCAR ./INCAR
#	sed -i 's/NELECT = 402/NELECT = 2/g' INCAR
#	sed -i 's/NSW    = 500/NSW    = 0/g' INCAR
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
echo "------" $(basename `pwd`) "-----"
mkdir im bu
echo -e "job.h.m\n" | cptemplate.h

cd im
  #INCAR: NELECT EDIFF NGX/Y/ZF NSW
	echo -e "scf_INCAR\n " | cptemplate.h
#	sed -i 's/#NELECT = 402/ NELECT = 2/g' scf_INCAR
	sed -i 's/EDIFF  = 1.0E-05/EDIFF  = 1.0E-06/g' scf_INCAR
	mv scf_INCAR INCAR
#	cp ../../INCAR ./INCAR
#	sed -i 's/ NELECT/#NELECT/g' INCAR
#	sed -i 's/NSW    = 500/NSW    = 0/g' INCAR
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
mv cdd ../cdd_${i}

cd ../cdd_${i}/onlyLi+
qsub job.h.m
cd ../withoutLi+
qsub job.h.m
cd ..

cd ..
done


