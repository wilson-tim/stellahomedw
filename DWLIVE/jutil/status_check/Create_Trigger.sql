CREATE OR REPLACE TRIGGER t_application_status_aiu
  AFTER INSERT OR UPDATE ON application_status  
  FOR EACH ROW 
DECLARE 
  -- local variables here
BEGIN 

  INSERT INTO application_status_history
  (
  application_key,
  checked_at_datetime,
  application_status_code,
  application_message
  )
  VALUES
  (
  :NEW.application_key,
  :NEW.last_checked_at_datetime,
  :NEW.application_status_code,
  :NEW.application_message
  );
    
END t_application_status_biu;
