# This is bad_mkt.ksh]
#!/usr/bin/ksh
#
typeset -l today
today_d=`date +%Y%b%d`
today=${today_d}
export load_path="/home/dw/DWLIVE/load/otop/"
export data_path="/data/tourops/"
export log_path="/home/dw/DWLIVE/logs/otop/"
#
cat ${load_path}otop_ls_season.lst|while read season
do
  echo
  (( k=0 ))

  cat ${load_path}otop_l_mkt.lst|while read abbrev
  do
    if [[ ${abbrev} != mem ]] then 
      if [[ -f  ${log_path}o_${abbrev}_bad${today}.${season} ]] then
        if [[ k -eq 0 ]] then
          echo These are the bad market files for ${season} with record numbers
        fi
        wc -l ${log_path}o_${abbrev}_bad${today}.${season}
        (( k=k+1 ))
      fi
    fi
  done
if [[ k -eq 0 ]] then
  echo There are no bad market files for ${season} 
fi
#
done
