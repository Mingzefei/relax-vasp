#!/bin/bash
#--------------------------------------------------
# @File : zheng.sh
# @Time : 2022/03/08 10:25:11
# @Auth : Ming 
# @Vers : 1.0
# @Desc : zhengli for normal(bu/{CHGCAR,CONTCAR,POSCAR} history|notes)(energy)(trans)
# @Usag : zheng.sh bu_1 bu_2 ...
#--------------------------------------------------

# here set the PATH and LANG
# PATH=
# LANG=zh_CN.UTF-8
# export PATH

relax_path=${hgb_path}/relax

if [ $# = 0 ]; then 
    echo "usage : zheng.sh bu_1 bu_2 ..."
    exit 1
else
    for i in $@
    do
        if [ -e ${i} ]; then
            if [ -d "./${i}_zheng_files" ]; then
                echo -e "${i}_zheng_files exit! renamed $(date +"%Y-%m-%d-%H:%M")_${i}_zheng_files_old"
                mv ./${i}_zheng_files ./$(date +"%Y-%m-%d-%H:%M")_${i}_zheng_files_old
            fi
            echo -e "mkdir ${i}_zheng_files\n"
            mkdir ./${i}_zheng_files

            # cp bu/{CHGCAR,CONTCAR,POSCAR} history|notes
            echo -e "cp bu/{CHGCAR,CONTCAR,POSCAR} and history|notes\n"
            cp bu/{CHGCAR,CONTCAR,POSCAR} ./${i}_zheng_files/
            cp *history* ./${i}_zheng_files/
            cp *notes* ./${i}_zheng_files/

            # energy
            ${relax_path}/energy.sh ${i}

            # trans
            read -p "need trans ${i}_zheng_files to the door? [y/n]" input
            case $input in
                [yY][eE][sS]|[yY])
                    ${relax_path}/trans.sh ${i}_zheng_files
                    echo "done";;
                [nN][oO]|[nN])
                    echo "No";;

                *)
                    echo "Invalid input"
                    exit 1
            esac

        else
            echo "!!!  cannot find ${i}  !!!\n"
        
        fi
    done
fi
