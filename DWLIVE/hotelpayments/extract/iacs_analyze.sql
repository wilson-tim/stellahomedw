/* to be run as iacs user */
analyze table iacs.booking compute statistics;
analyze table iacs.booking_accom compute statistics;
analyze table iacs.booking_accom_invoice compute statistics;
analyze table iacs.booking_accom_extras compute statistics;
analyze table iacs.invoice compute statistics;
analyze table iacs.invoice_extras compute statistics;
analyze table iacs.hotel_payment_control compute statistics;
analyze table iacs.country_office_correlation compute statistics;
analyze table iacs.property compute statistics;
analyze table iacs.otop_property compute statistics;
analyze table iacs.location compute statistics;
exit;

