-- This sql calls procedures from pkg_xml_to_iacs_reference_load
set serveroutput on size 1000000

Declare

Begin


-- Call Reference tables load
        iacs.pkg_xml_to_iacs_reference_load.location_load;
        iacs. pkg_xml_to_iacs_reference_load.property_load;
        iacs.pkg_xml_to_iacs_reference_load.otop_property_load;
        iacs.pkg_xml_to_iacs_reference_load.clear_ref_temp_tables; -- clear temp tables 

-- Call Booking tables load
       iacs.pkg_xml_to_iacs_booking_load.booking_load;
      iacs.pkg_xml_to_iacs_booking_load.bookingaccom_load;
       iacs.pkg_xml_to_iacs_booking_load.clear_bkg_temp_tables;  -- clear temp tables 

End;

/
exit    
