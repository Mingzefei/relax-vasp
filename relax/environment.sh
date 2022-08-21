#!/bin/bash
#--------------------------------------------------
# @File : environment.sh
# @Time : 2022/03/05 22:29:32
# @Auth : Ming 
# @Vers : 1.0
# @Desc : PATH and global_var for relax: hgb_path is the workbench path
#--------------------------------------------------

# here set the PATH and LANG
# PATH=
# LANG=zh_CN.UTF-8
# export PATH

# get hgb_path
# auto_way: `source relax/envirnoment.sh`
# input_way: `source relax/envirnoment.sh path`
if test $# -eq 0
then
    hgb_path=`pwd`
    echo "hgb_path=$hgb_path"
else
    hgb_path="$1"
    echo "hgb_path=$hgb_path"
fi

export hgb_path

# set relax path
export PATH=${PATH}:"${hgb_path}/relax"
export PATH=${PATH}:"${hgb_path}/relax/template"
export PATH=${PATH}:"${hgb_path}/relax/vtst"
export PATH=${PATH}:"${hgb_path}/relax/VASP-script-master"

# set software path
# conda and python
alias huapython="${hgb_path}/software/anaconda3/bin/python"
export PATH=${PATH}:"${hgb_path}/software/anaconda3/bin"
