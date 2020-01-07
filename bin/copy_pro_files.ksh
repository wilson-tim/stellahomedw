#!/bin/ksh
cd /home/dw/DWLIVE/
#for name in `ls *_pro_*`
#do
#  echo $name
#  cp $name provider_store
#  compress provider_store/$name
#done
tar cf provider_store/`date +"%Y%m%d"`.tar *_pro_*
compress provider_store/`date +"%Y%m%d"`.tar
