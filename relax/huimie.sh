#!/bin/bash
#--------------------------------------------------
# @File : huimie.sh
# @Time : 2022/03/07 17:54:10
# @Auth : Ming 
# @Vers : 1.0
# @Desc : delete WAVECAR CHG 
# @Usag : only huimie.sh(WAVECAR CHG) or huimie.sh file_1(file) bu_opt2(dir, WAVECAR CHG) ...
#--------------------------------------------------

# here set the PATH and LANG
# PATH=
# LANG=zh_CN.UTF-8
# export PATH

huimie_files='WAVECAR CHG'

if [ $# = 0 ]; then
    rm `echo $huimie_files`
    if [ $? = 0 ]; then 
        echo "rm $huimie_files"
    fi
else
    for i in $*
    do
        if [ -f ${i} ]; then
            rm  -i ${i}
            # rm ${i}
        elif [ -d ${i} ];then
            rm `echo ${i}/$huimie_files`
            if [ $? = 0 ]; then
                echo "rm ${i}/$huimie_files"
            fi
        else
            echo "no file or dir named ${i}"
        fi
    done
fi
