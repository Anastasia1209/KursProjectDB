select user from dual;

select * from sys.AUD$;

AUDIT ALL BY CLIENT_SALONE;

CREATE OR REPLACE PROCEDURE LogAuditEvent (
    p_UserName VARCHAR2,
    p_ActionType VARCHAR2,
    p_TableName VARCHAR2,
    p_Details CLOB
)
AS
    v_LogMessage CLOB;
BEGIN
    v_LogMessage := 'Audit Event - User: ' || p_UserName ||
                    ', Action Type: ' || p_ActionType ||
                    ', Table Name: ' || p_TableName ||
                    ', Details: ' || p_Details;

    sys.DBMS_OUTPUT.PUT_LINE(v_LogMessage);
END;

BEGIN
    LogAuditEvent('CLIENT_SALON', 'UPDATE', 'YourTableName', 'Audit details...');
END;