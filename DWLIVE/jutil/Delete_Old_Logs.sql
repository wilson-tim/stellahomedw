CREATE OR REPLACE PROCEDURE Delete_Old_Logs(i_maxcount IN INTEGER,
                                            i_daysago IN INTEGER,
                                            i_path IN VARCHAR2,
                                            i_filename IN VARCHAR2) AS
-- Declare Cursor
CURSOR Cur_Log IS
SELECT ROWID
FROM jutil.application_log al
WHERE trunc(al.event_date) < trunc((SYSDATE - i_daysago));

-- Declare variables
v_count           INTEGER(10) := 0;
v_totcount        INTEGER(10) := 0;

v_output_line     VARCHAR2(100);

v_error           CHAR(1);
v_error_message   CHAR(512);

v_code            NUMBER(5);

v_output_file     utl_file.file_type;


BEGIN
  -- Open output file
  v_output_file := utl_file.fopen(i_path, i_filename, 'W');
  
  -- Log Start time
  v_output_line := 'Delete_Old_Logs Procedure started at '||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss');
  utl_file.put_line(v_output_file,v_output_line);
  
  
  FOR v_loop IN Cur_Log LOOP   -- Cursor Loop
    
    v_error := 'N';
    
    BEGIN  
      -- Delete record from table
      DELETE FROM jutil.application_log al
      WHERE al.ROWID = v_loop.ROWID;
    
      -- Increment Counters
      v_count := v_count + 1;
      v_totcount := v_totcount + 1;
    
      -- Commit at relevant point
      IF v_count = i_maxcount THEN
        COMMIT;
      
        -- Log point reached
        v_output_line := 'Commit point reached.  Deleted a total of '||v_totcount||' records';
        utl_file.put_line(v_output_file,v_output_line);
      
        -- Reset counter
        v_count := 0;
      END IF;     
      
      -- Error Handling
      EXCEPTION 
      WHEN OTHERS THEN
        v_error := 'Y';
        
    END;
    
    -- Log any errors in log file
    IF v_error = 'Y' THEN
      v_code := sqlcode;
      v_error_message := SQLERRM;
      
      v_output_line := 'Error has occurred '||v_code||' '||v_error_message;
      utl_file.put_line(v_output_file,v_output_line);      
    END IF;
    
  END LOOP;                    -- Cursor Loop
  
  -- Commit remainder of deleted records
  COMMIT;
  v_output_line := 'Commit point reached.  Deleted a total of '||v_totcount||' records';
  utl_file.put_line(v_output_file,v_output_line);

  v_output_line := 'Delete_Old_Logs Procedure finished at '||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss');
  utl_file.put_line(v_output_file,v_output_line);
  
  -- Close logging file
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
    dbms_output.put_line('Unknown Error has occurred');
  
END Delete_Old_Logs;
