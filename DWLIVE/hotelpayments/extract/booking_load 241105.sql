-- This sql calls procedures from pkg_booking_load for loading Accommodation bookings into datawarehouse IACS schema

set serveroutput on size 1000000

Declare

v_ret   number;

Begin

      iacs.pkg_booking_load.booking_load;

      v_ret := iacs.pkg_booking_load.f_del_hotel_pay_cont_old;

      v_ret := iacs.pkg_booking_load.f_del_hotel_pay_cont_no_ext;

      v_ret := iacs.pkg_booking_load.f_force_recalc_invalid_accrual;

      v_ret := iacs.pkg_booking_load.f_force_recalc_eldest;

      v_ret := iacs.pkg_booking_load.f_force_recalc_all;

End;

/
exit    
