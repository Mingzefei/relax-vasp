#!/bin/bash
#--------------------------------------------------
# @File : reached.sh
# @Time : 2022/03/07 22:55:38
# @Auth : Ming 
# @Vers : 1.0
# @Desc : to know whether this OUTCAR or $* has reached for ion steps
# @Usag : only reached.sh (eq to reached.sh ./) or reached.sh bu_opt1 bu_opt2 ...
#--------------------------------------------------

# here set the PATH and LANG
# PATH=
# LANG=zh_CN.UTF-8
# export PATH


if [ $# = 0 ]; then
    echo ./ `grep 'reached re' ./OUTCAR`
else
    for i in $@
    do
        echo $i $(grep 'reached re' "$i/OUTCAR" )
    done
fi

