CREATE OR REPLACE PACKAGE p_Email_Role IS 

  -- Author  : JDURNFORD
  -- Created : 23/12/2005 10:28:01
  -- Purpose : Send Emails to users based on entries in Security_Role and Security_User Tables

  PROCEDURE Email_Role (p_SecurityRole  IN  security_role.user_role%TYPE,
                        p_Subject       IN  VARCHAR2,
                        p_Message       IN  VARCHAR2);
  
END  p_Email_Role;
/
CREATE OR REPLACE PACKAGE BODY p_Email_Role IS 

  PROCEDURE Email_Role (p_SecurityRole  IN  security_role.user_role%TYPE,
                        p_Subject       IN  VARCHAR2,
                        p_Message       IN  VARCHAR2) IS
  
  CURSOR Cursor_AllUsers (c_Role IN security_role.user_role%TYPE) IS
  SELECT su.email_address_list 
  FROM security_user su,
       security_user_role sur,
       security_role sr
  WHERE sur.user_role = c_Role
  AND   sur.user_name = su.user_name
  AND   su.email_disabled_ind != 'Y'
  AND   sr.user_role = sur.user_role
  AND   sr.email_disabled_ind != 'Y';
  
  BEGIN
    FOR v_email IN Cursor_AllUsers(p_SecurityRole) LOOP
    
      p_Common.Debug_Message('Sending Email to '||v_email.email_address_list);      
      App_Util.send_email('smtp',
                          p_SecurityRole,
                          v_email.email_address_list,
                          p_Subject,
                          p_Message);
    END LOOP;
    
  END Email_Role;
  
BEGIN 
  -- Initialization
  NULL;
END p_Email_Role;
/
