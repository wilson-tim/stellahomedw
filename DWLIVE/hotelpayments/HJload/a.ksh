 export CLASSPATH=/oracle/jre/1.1.8:/oracle/product/8.1.7/jlib:/oracle/product/8.1.7/rdbms/jlib/xsu12.jar:/oracle/product/8.1.7/lib/xmlparserv2.jar:/oracle/product/8.1.7/lib/xmlcomp.jar:/oracle/product/8.1.7/lib/xmlplsql.jar:/home/dw/DWLIVE/hotelpayments/HJload/classes12.jar:/home/dw/DWLIVE/hotelpayments/HJload
export PATH=/usr/java131/bin:/usr/local/bin:/usr/bin:/etc:/usr/sbin:/usr/ucb:$HOME/bin:/usr/bin/X11:/sbin:.
. /home/dw/bin/set_oracle_variables.ksh

java OracleXML putXML -user "iacs/iacs" -conn "jdbc:oracle:thin:@dwlive_en1:1521:dwl"  -commitBatch 10 -rowTag LOCATION -dateFormat "dd/MM/yyyy" -fileName /data/hotelpayments/XMLFILES/location.xml  temp_xml_location 
