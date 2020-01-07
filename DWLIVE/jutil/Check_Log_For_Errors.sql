CREATE OR REPLACE PROCEDURE Check_Log_For_Errors (i_path IN VARCHAR2,      -- Path for utl_file
                                                  i_filename IN VARCHAR2,  -- Filename for utl_file
                                                  i_separator IN INTEGER)  -- Ascii value for separator within output file
                                                  IS
                                                   
/****************************************************************
Author       : John Durnford 
Created Date : 18/06/2003
Application  : Extract data from jutil.application_log table where
               the event_level or event_type is one of a predefined
               list and send output to a CSV file
Updates      :
*****************************************************************/

v_output_file           utl_file.file_type;
v_output_line           VARCHAR2(750);

CURSOR   Cur_App_Errors IS
SELECT   al.application_key,
         al.run_id,
         al.log_sequence,
         al.event_period,
         al.event_summary,
         al.event_detail
FROM     application_log al
WHERE   (al.event_level IN ('FATAL','WARNING','ERROR')
OR       al.event_type IN ('ERROR','GENERROR'))
AND      trunc(al.event_date) = trunc(SYSDATE)
ORDER BY al.application_key,
         al.event_date;        
                                                   
BEGIN 
  v_output_file := utl_file.fopen(i_path, i_filename, 'W');

  v_output_line := '"Application Key"'||chr(i_separator);
  v_output_line := v_output_line||'"Run Id"'||chr(i_separator);
  v_output_line := v_output_line||'"Log Sequence"'||chr(i_separator);        
  v_output_line := v_output_line||'"Event Period"'||chr(i_separator);        
  v_output_line := v_output_line||'"Event Summary"'||chr(i_separator);        
  v_output_line := v_output_line||'"Event Detail"';        
  utl_file.put_line(v_output_file,v_output_line);
  
  FOR v_err_row IN Cur_App_Errors LOOP
  
    v_output_line := '"'||rtrim(ltrim(v_err_row.application_key))||'"'||chr(i_separator);
    v_output_line := v_output_line||'"'||rtrim(ltrim(v_err_row.run_id))||'"'||chr(i_separator);
    v_output_line := v_output_line||'"'||rtrim(ltrim(v_err_row.log_sequence))||'"'||chr(i_separator);        
    v_output_line := v_output_line||'"'||rtrim(ltrim(v_err_row.event_period))||'"'||chr(i_separator);        
    v_output_line := v_output_line||'"'||rtrim(ltrim(v_err_row.event_summary))||'"'||chr(i_separator);        
    v_output_line := v_output_line||'"'||rtrim(ltrim(v_err_row.event_detail))||'"';          
    utl_file.put_line(v_output_file,v_output_line);
        
    
  END LOOP;  
  
  utl_file.fclose(v_output_file);
  
  EXCEPTION

  -- Handle an errors created by use of utl_file
  WHEN UTL_FILE.INVALID_PATH THEN
    dbms_output.put_line('Error caused due to invalid path spefication'); 
  WHEN UTL_FILE.INVALID_MODE THEN
    dbms_output.put_line('Error caused due to invalid mode');
  WHEN UTL_FILE.INVALID_FILEHANDLE THEN
    dbms_output.put_line('Error caused due to invalid file handle');
  WHEN UTL_FILE.INVALID_OPERATION THEN
    dbms_output.put_line('Error caused due to invalid operation');
  WHEN UTL_FILE.READ_ERROR THEN
    dbms_output.put_line('Error caused due to read error');
  WHEN UTL_FILE.WRITE_ERROR THEN
    dbms_output.put_line('Error caused due to write error');
  WHEN OTHERS THEN
    dbms_output.put_line('Unknown error has occurred');
  
END Check_Log_for_Errors;