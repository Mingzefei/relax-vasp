#!/bin/bash
#--------------------------------------------------
# @File : cdd2.sh
# @Time : 2022/03/07 09:28:50
# @Auth : Ming 
# @Vers : 1.0
# @Desc : (will get rid of this script) process file for CHGCAR diff after cdd1.sh and computed
#--------------------------------------------------

# here set the PATH and LANG
# PATH=
# LANG=zh_CN.UTF-8
# export PATH

#after cdd1.h
#useage: cdd2.h cdd[dir] 

#cdd---AB_CHGCAR (A_CHGCAR B_CHGCAR)
#    |
#    ---withoutLi+---im history
#    |             |     
#    |             ---bu (bu_scf)---A_CHGCAR
#    |  
#    ---onlyLi+---//same
#    ---CHGDIFF.vasp

cd $1

cd withoutLi+
mv bu bu_scf
record.h bu_scf >> history
cp bu_scf/CHGCAR ../A_CHGCAR
cd ..

cd onlyLi+
mv bu bu_scf
record.h bu_scf >> history
cp bu_scf/CHGCAR ../B_CHGCAR
cd ..

echo -e "314\n AB_CHGCAR A_CHGCAR B_CHGCAR\n" | vaspkit 
trans.h CHGDIFF.vasp

cd ..
