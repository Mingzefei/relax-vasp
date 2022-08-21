#!/bin/bash
#--------------------------------------------------
# @File : sigma.sh
# @Time : 2022/03/07 22:57:20
# @Auth : Ming 
# @Vers : 1.0
# @Desc : to know whether entropy T*S is less than 1 mev
# @Usag : only sigma.sh (eq to sigma.sh ./) or sigma.sh bu_opt1 bu_opt2 ...
#--------------------------------------------------

# here set the PATH and LANG
# PATH=
# LANG=zh_CN.UTF-8
# export PATH

if [ $# = 0 ]; then

	aveenergy=$(echo "scale=5;$(grep "entropy T\*S" OUTCAR | tail -n 1 |  awk '{print $5}')/$(sed -n 7p POSCAR | tr -d "\r"  |  awk '{ for(i=1;i<=NF;i++) sum+=$i; print sum}')" | bc)
	absaveenergy=${aveenergy#-}
	sigma=$(grep SIGMA INCAR)

	if [ `echo "$absaveenergy < 0.001" | bc` -eq 1 ]; then
		echo -n "./ sigma is okay; for average T*S ${absaveenergy} is < 0.001 eV, this" 
		echo "$sigma"
	else
		echo -n "./ sigma is BAD; for average T*S $absaveenergy  is > 0.001 eV,try to decrease sigma! This"
		echo "$sigma"
	fi	

else
	for i in $@
	do 
		cd ${i}

		aveenergy=$(echo "scale=5;$(grep "entropy T\*S" OUTCAR | tail -n 1 |  awk '{print $5}')/$(sed -n 7p POSCAR | tr -d "\r"  |  awk '{ for(i=1;i<=NF;i++) sum+=$i; print sum}')" | bc)
		absaveenergy=${aveenergy#-}
		sigma=$(grep SIGMA INCAR)

		if [ `echo "$absaveenergy < 0.001" | bc` -eq 1 ]; then
			echo -n "${i} sigma is okay; for average T*S ${absaveenergy} is < 0.001 eV, this" 
			echo "$sigma"
		else
			echo -n "${i} sigma is BAD; for average T*S $absaveenergy  is > 0.001 eV,try to decrease sigma! This"
			echo "$sigma"
		fi	

		cd ..
	done
fi
exit 0
