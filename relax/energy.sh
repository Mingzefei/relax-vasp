#!/bin/bash
#--------------------------------------------------
# @File : energy.sh
# @Time : 2022/03/07 17:08:33
# @Auth : Ming 
# @Vers : 1.0
# @Desc : get final energy from OUTCAR to check whethe reach convergence
#--------------------------------------------------

# here set the PATH and LANG
# PATH=
# LANG=zh_CN.UTF-8
# export PATH


if [ -e OUTCAR ]; then
    tac OUTCAR | grep -m 1 "energy  with"
elif [ "$1" != "" ]; then
    for i in $@
    do
        for j in `find $i -name OUTCAR | sort`
        do
            echo "$j " `tac $j | grep -m 1 "energy  with"`
        done
    done
else
    for i in `find ./ -name OUTCAR | sort`
    do
        echo "$i" `tac $i | grep -m 1 "energy  with"`
    done
fi