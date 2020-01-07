# This is mkt.ksh]
#!/usr/bin/ksh
#
typeset -l today
today_d=`date +%Y%b%d`
today=${today_d}
export load_path="/home/dw/DWLIVE/load/otop/"
export data_path="/data/tourops/"
#
cat ${load_path}otop_ls_season.lst|while read season
do
echo
echo This is mkt for ${season}
cat ${load_path}otop_l_mkt.lst|while read abbrev
do
wc -l ${data_path}o_${abbrev}${today}.${season}*
done
done
