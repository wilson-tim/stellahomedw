#
cp /home/dw/DWLIVE/load/speake/spk_flag.bkp /home/dw/DWLIVE/load/speake/spk_flag.txt
#
ftp -nvi << EOF
       open dwlive
       user dw dwevil
       lcd /data/tourops
       mget /data/tourops/s*.txt
       mget /data/tourops/act*.txt
       bye
       EOF

