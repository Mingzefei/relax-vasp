#!/bin/bash
#--------------------------------------------------
# @File : tar.sh
# @Time : 2022/03/08 10:08:07
# @Auth : Ming 
# @Vers : 1.0
# @Desc : tar all str*(files and dir) and split them
# @Usag : nohup tar.sh file1 dir2 ... &
#--------------------------------------------------

# here set the PATH and LANG
# PATH=
# LANG=zh_CN.UTF-8
# export PATH


i=$*
echo "those files and dir to tar: "
ls $i
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

read -r -p "name: " name
mkdir $name
cp -r ${i} $name

echo "tar-ing"
tar -zcvf ${name}.tar.gz $name >> tar_history
rm tar_history
rm -r ${name}

read -r -p "files size is $(du -sh ${name}.tar.gz), need split? [Y/n]" split
case $split in 
	[yY][eE][sE]|[yY])
		echo -e "OK, split\n"
		cat ${name}.tar.gz | split -b 2G - "${name}.tar.gz."
		;;
	*)
		echo -e "no\n"
		exit 1 ;;
esac


