java http2file 10.36.252.78 80 /sql/?sql=execute+hj_location?root=root /data/hotelpayments/XMLFILES/location.xml
java http2file 10.36.252.78 80 /sql/?sql=execute+hj_property?root=root /data/hotelpayments/XMLFILES/property.xml
java http2file 10.36.252.78 80 /sql/?sql=execute+hj_propertycode?root=root /data/hotelpayments/XMLFILES/propertycode.xml
java http2file 10.36.252.78 80 /sql/?sql=execute+hj_booking?root=root /data/hotelpayments/XMLFILES/booking.xml
java -mx256m http2file 10.36.252.78 80 /sql/?sql=execute+hj_bookingaccom?root=root /data/hotelpayments/XMLFILES/bookingaccom.xml

