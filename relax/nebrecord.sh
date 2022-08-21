#!/bin/bash
#--------------------------------------------------
# @File : nebrecord.sh
# @Time : 2022/03/07 22:13:19
# @Auth : Ming 
# @Vers : 1.0
# @Desc : get info about reached, energy, dist, sigma, nebefs for neb
# @Usag : nebrecord.sh $image_num
#--------------------------------------------------

# here set the PATH and LANG
# PATH=
# LANG=zh_CN.UTF-8
# export PATH

relax_path=${hgb_path}/relax

if [ $# = 0 ]; then 
    echo "usage : nebrecord.sh image_num(IMAGES, like 12)"
    exit 1
elif [ "$1" -gt 0 ] 2>/dev/null; then
    for i in `seq -w 1 ${1}`
    do
        if [ -d ${i} ]; then
            echo "${i} record:"
            ${relax_path}/reached.sh ${i}
            ${relax_path}/energy.sh ${i}
            ${relax_path}/dist.sh ${i}
            ${relax_path}/sigma.sh ${i}
            echo '-----------'
        else
            echo "${i} is not a dir"
        fi
    done
    ${relax_path}/vtst/nebefs.pl
    echo -e $(date "+%Y-%m-%d %H:%M:%S") "\n"
    exit 0
else
    echo "usage : nebrecord.sh image_num(IMAGES, like 12)"
    exit 1 
fi



