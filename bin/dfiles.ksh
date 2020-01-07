# This is dfiles.ksh
#!/usr/bin/ksh
#
export load_path="/home/dw/DWLIVE/load/otop/"
export data_path="/data/dmis/"
#
echo
echo THESE ARE THE LATEST DMIS FILES FOR $1
wc -l ${data_path}d_*.${1}
echo
