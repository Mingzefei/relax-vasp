# To use it: ./potcar.sh C H O 

repo=/scratch/work/project/open-18-25/tianshuai/paw_PBE
# check whether POTCAR is exist already
if [ -f POTCAR ] ; then
mv -f POTCAR old-POTCAR
echo "warning: POTCAR is exist already. I rename it to old-POTCAR"
fi

# Main loop

for i in $*
do
 if [ -f $repo/$i/POTCAR ] ; then
  cat $repo/$i/POTCAR >> POTCAR
  echo "yes,I have found PORCAR about $i"
 elif [ -f $repo/$i/POTCAR.Z ] ; then 
  zcat $repo/$i/POTCAR.Z >> POTCAR
 elif [ -f $repo/$i/POTCAR.gz ] ; then
  gunzip -c $repo/$i/POTCAR.gz >> POTCAR
 else 
  echo "sorry,I have serched in $repo/$i/ , but failed finding POTCAR about $i"
 fi
done
