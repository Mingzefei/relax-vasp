#!/bin/bash
#--------------------------------------------------
# @File : record.sh
# @Time : 2022/03/07 22:13:57
# @Auth : Ming 
# @Vers : 1.0
# @Desc : get info about reached, energy, dist, sigma
# @Usag : record.sh bu_opt (>> notes)
#--------------------------------------------------

# here set the PATH and LANG
# PATH=
# LANG=zh_CN.UTF-8
# export PATH

relax_path=${hgb_path}/relax

if [ $# = 0 ]; then 
    ${relax_path}/reached.sh ./
    ${relax_path}/energy.sh ./
    ${relax_path}/dist.sh ./
    ${relax_path}/sigma.sh ./
else
    for i in $@
    do
        if [ -d ${i} ]; then
            ${relax_path}/reached.sh ${i}
            ${relax_path}/energy.sh ${i}
            ${relax_path}/dist.sh ${i}
            ${relax_path}/sigma.sh ${i}
        else
            echo "${i} is not a dir"
        fi
    done
fi

echo -e $(date "+%Y-%m-%d %H:%M:%S") '\n' 


