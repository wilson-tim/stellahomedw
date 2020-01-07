# This is files.ksh]
#!/usr/bin/ksh
#
typeset -l today
today_d=`date +%Y%b%d`
today=${today_d}
export load_path="/home/dw/DWLIVE/load/otop/"
export log_path="/home/dw/DWLIVE/logs/dmis/"
export data_path="/data/tourops/"
#
echo THIS IS THE POS GROUP FOR $1
cat ${load_path}otop_l_pos.lst|while read abbrev
do
wc -l ${data_path}o_${abbrev}${today}.${1}*
done
echo
echo THIS IS THE AHI GROUP FOR $1
cat ${load_path}otop_l_ahi.lst|while read abbrev
do
wc -l ${data_path}o_${abbrev}${today}.${1}*
done
echo
echo THIS IS THE GEN GROUP FOR $1
cat ${load_path}otop_l_gen.lst|while read abbrev
do
wc -l ${data_path}o_${abbrev}${today}.${1}*
done
echo
echo  Below, TRS, ACC, INT, GSH groups -  are in the Generic Gemini Group INV
echo
echo THIS IS THE TRS GROUP FOR $1
cat ${load_path}otop_l_trs.lst|while read abbrev
do
wc -l ${data_path}o_${abbrev}${today}.${1}*
done
echo
echo THIS IS THE ACC GROUP FOR $1
cat ${load_path}otop_l_acc.lst|while read abbrev
do
wc -l ${data_path}o_${abbrev}${today}.${1}*
done
echo
echo THIS IS THE INT GROUP FOR $1
cat ${load_path}otop_l_int.lst|while read abbrev
do
wc -l ${data_path}o_${abbrev}${today}.${1}*
done
echo
echo THIS IS THE SHR GROUP FOR $1
cat ${load_path}otop_l_shr.lst|while read abbrev
do 
wc -l ${data_path}o_${abbrev}${today}.${1}*
done
echo
echo THIS IS THE GSH GROUP FOR $1
cat ${load_path}otop_l_gsh.lst|while read abbrev
do
wc -l ${data_path}o_${abbrev}${today}.${1}*
done
echo
echo THIS IS THE MKT GROUP FOR $1
cat ${load_path}otop_l_mkt.lst|while read abbrev
do
wc -l ${data_path}o_${abbrev}${today}.${1}*
done
echo
echo THIS IS THE SHD GROUP FOR $1
cat ${load_path}otop_l_shd.lst|while read abbrev
do
wc -l ${data_path}o_${abbrev}${today}.${1}*
done
