 CREATE OR REPLACE FUNCTION IsEmailValid(p_Email CLIENTS.email%type) RETURN BOOLEAN
IS
    v_Pattern VARCHAR2(100) := '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
BEGIN
    RETURN REGEXP_LIKE(p_Email, v_Pattern);
END;
----------------------------

 CREATE OR REPLACE FUNCTION IsEmployeeExists(p_employeeID EMPLOYEES.employeeID%type) RETURN BOOLEAN
IS
    v_Count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_Count FROM EMPLOYEES WHERE employeeID = p_employeeID;
    RETURN v_Count > 0;
END;
---------------------------

 CREATE OR REPLACE FUNCTION IsReviewExists(p_reviewID REVIEWS.reviewID%type) RETURN BOOLEAN
IS
    v_Count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_Count FROM REVIEWS WHERE reviewID = p_reviewID;
    RETURN v_Count > 0;
END;
--------------------------

 CREATE OR REPLACE FUNCTION IsServiceExists(p_serviceID SERVICES.serviceID%type) RETURN BOOLEAN
IS
    v_Count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_Count FROM SERVICES WHERE serviceID = p_serviceID;
    RETURN v_Count > 0;
END;
---------------------------


