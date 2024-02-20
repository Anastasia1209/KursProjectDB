-----PROCEDURES
--SET serveroutput ON;

--���������� ����� ������
CREATE OR REPLACE PROCEDURE AddService(   
    p_name IN SERVICES.name%TYPE,    
    p_description IN SERVICES.description%TYPE,    
    p_price IN SERVICES.price%TYPE
)
IS
BEGIN
    IF
        p_name IS NULL OR LENGTH(TRIM(p_name)) = 0 or
        p_description IS NULL or length(trim(p_description)) = 0 or
        p_price is null THEN
        DBMS_OUTPUT.PUT_LINE('������: ���� �� ����� ���� ������.');
        RETURN;
    END if;

     IF NOT REGEXP_LIKE(p_name, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('������: �������� ������ ������ ��������� ������ �����.');
        RETURN;
    END IF;

    IF NOT REGEXP_LIKE(p_description, '^[[:alpha:],.\- ]+$') THEN
    sys.DBMS_OUTPUT.PUT_LINE('������: ����� ������ ��������� ������ �����, �������, �����, ������ � �������.');
    RETURN;
END IF;

    -- �������� �� ������������ �������� ������
   BEGIN
        IF p_price < 0 THEN
            sys.DBMS_OUTPUT.PUT_LINE('������: ���� �� ����� ���� �������������.');
            RETURN;
        END IF;
    EXCEPTION
        WHEN VALUE_ERROR THEN
            sys.DBMS_OUTPUT.PUT_LINE('������: ���� ������ ���� ������.');
            RETURN;
    END;

    INSERT INTO SERVICES (name, description, price)
    VALUES (TRIM(p_name), TRIM(p_description), p_price);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('������ ��������� �������.');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('������ � ����� id ��� ����������.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ���������� ������: ' || SQLERRM);
        RAISE;
END;
-----------------------------------------

--���������� ������
CREATE OR REPLACE PROCEDURE UpdateService(
    p_serviceID IN SERVICES.serviceID%TYPE,
    p_name IN SERVICES.name%TYPE,
    p_description IN SERVICES.description%TYPE,
    p_price IN SERVICES.price%TYPE
)
IS
BEGIN
    IF p_name IS NULL OR LENGTH(TRIM(p_name)) = 0 THEN
        sys.DBMS_OUTPUT.PUT_LINE('������: �������� ������ �� ����� ���� ������.');
        RETURN;
    END IF;
     IF NOT REGEXP_LIKE(p_name, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('������: �������� ������ ������ ��������� ������ �����.');
        RETURN;
    END IF;
     IF p_description IS NULL  OR LENGTH(TRIM(p_description)) = 0 THEN
        sys.DBMS_OUTPUT.PUT_LINE('������: �������� ������ �� ����� ���� NULL.');
        RETURN;
    END IF;
     IF NOT REGEXP_LIKE(p_description, '^[[:alpha:],.\- ]+$') THEN
    sys.DBMS_OUTPUT.PUT_LINE('������: ����� ������ ��������� ������ �����.');
    RETURN;
END IF;

    -- �������� �� ������������ �������� ������
    IF p_price < 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: ���� �� ����� ���� �������������.');
        RETURN;
    END IF;

    UPDATE SERVICES
    SET name = TRIM(p_name),
        description = TRIM(p_description),
        price = p_price
    WHERE serviceID = p_serviceID;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('������ �������� �������.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ � ID ' || p_ServiceID || ' �� �������.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��������� ������: ' || SQLERRM);
        RAISE;
END;
-----------------------------------------

--�������� ������
CREATE OR REPLACE PROCEDURE DeleteService(    
    p_serviceID IN SERVICES.serviceID%TYPE
)
IS
BEGIN
    -- �������� �� null � ������ ������ ��� p_serviceID
    IF p_serviceID IS NULL OR LENGTH(TRIM(p_serviceID)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������: ID ������ �� ����� ���� ������.');
        RETURN;
    END IF;

    DELETE FROM SERVICES WHERE serviceID = p_serviceID;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ � ID ' || p_serviceID || ' �� �������.');
        ROLLBACK;
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('������ � ID ' || p_serviceID || ' ������� �������.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ �������� ������: ' || SQLERRM);
        RAISE;
END;
-----------------------------------------

--��������� ������ �����
CREATE OR REPLACE PROCEDURE GetServiceList
IS
BEGIN
    FOR service_rec IN (SELECT s.serviceID, s.name AS service_name, s.description, s.price, e.name AS employee_name, e.surname AS employee_surname
                        FROM SERVICES s
                        LEFT JOIN EMPLOYEES e ON s.serviceID = e.serviceID) LOOP
        DBMS_OUTPUT.PUT_LINE('ID ������: ' || service_rec.serviceID ||
                             ', �������� ������: ' || service_rec.service_name ||
                             ', ��������: ' || service_rec.description ||
                             ', ����: ' || service_rec.price ||
                             CASE
                                WHEN service_rec.employee_name IS NOT NULL THEN
                                    ', ���������: ' || service_rec.employee_name || ' ' || service_rec.employee_surname
                                ELSE
                                    ', ��� ��������� ����������� ��� �������������� ������.'
                             END);
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('������ ��������� ������ �����: ' || SQLERRM);
END;
-----------------------------------------

--��������� ���������� �� ������
CREATE OR REPLACE PROCEDURE GetServiceInfoByName(
    p_serviceName IN SERVICES.name%TYPE
)
IS
    v_serviceID SERVICES.serviceID%TYPE;
    v_description SERVICES.description%TYPE;
    v_price SERVICES.price%TYPE;
BEGIN
     IF p_serviceName IS NULL OR LENGTH(TRIM(p_serviceName)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������: �������� ������ �� ����� ���� ������.');
        RETURN;
    END IF;
    -- ��������, ��� ������� ������ ��������� ��������
    IF NOT REGEXP_LIKE(p_serviceName, '^[[:alpha:]]+$') THEN
        DBMS_OUTPUT.PUT_LINE('������: ������� ������ ��������� �������� ��� �������� ������.');
        RETURN;
    END IF;

    SELECT serviceID, description, price
    INTO v_serviceID, v_description, v_price
    FROM SERVICES
    WHERE UPPER(name) = UPPER(TRIM(p_serviceName));

    DBMS_OUTPUT.PUT_LINE('ID ������: ' || v_serviceID);
    DBMS_OUTPUT.PUT_LINE('�������� ������: ' || p_serviceName);
    DBMS_OUTPUT.PUT_LINE('��������: ' || v_description);
    DBMS_OUTPUT.PUT_LINE('����: ' || v_price);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('������ � ������ ' || p_serviceName || ' �� �������.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('������ ��������� ���������� �� ������: ' || SQLERRM);
END;
-------------------------------------------

--���������� ������ ����������
CREATE OR REPLACE PROCEDURE AddEmployee(    
    p_name IN EMPLOYEES.name%TYPE,    
    p_surname IN EMPLOYEES.surname%TYPE,    
    p_positions IN EMPLOYEES.positions%TYPE,
    p_phone IN EMPLOYEES.phone%TYPE,    
    p_email IN EMPLOYEES.email%TYPE,
    p_serviceID IN EMPLOYEES.serviceID%TYPE
)
IS
    v_EmailExists NUMBER;
    v_EmployeeID EMPLOYEES.employeeID%TYPE;
BEGIN
     IF p_name IS NULL OR LENGTH(TRIM(p_name)) = 0 or
        p_surname IS NULL OR LENGTH(TRIM(p_surname)) = 0 or
        p_positions IS NULL OR LENGTH(TRIM(p_positions)) = 0 or
        p_phone IS NULL OR LENGTH(TRIM(p_phone)) = 0 or
        p_email IS NULL OR LENGTH(TRIM(p_email)) = 0 then
        DBMS_OUTPUT.PUT_LINE('������: ���� �� ����� ���� ������.');
        RETURN;
    END IF;

       IF NOT REGEXP_LIKE(p_name, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('������: ��� ���������� ������ ��������� ������ �����.');
        RETURN;
    END IF;
       IF NOT REGEXP_LIKE(p_surname, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('������: ������� ���������� ������ ��������� ������ �����.');
        RETURN;
    END IF;
       IF NOT REGEXP_LIKE(p_positions, '^[[:alpha:],.\- ]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('������: ������������� ���������� ������ ��������� ������ �����.');
        RETURN;
    END IF;

    -- �������� �� ������������ �������� ������
    IF NOT IsEmailValid(p_email) THEN
        DBMS_OUTPUT.PUT_LINE('Error: ������������ email.');
        RETURN;
    END IF;

    -- �������� �� ������������� ������
    IF NOT IsServiceExists(p_serviceID) THEN
        DBMS_OUTPUT.PUT_LINE('Error: ������ � ID ' || p_serviceID || ' �� �������.');
        RETURN;
    END IF;

    -- �������� ������������ email
    SELECT COUNT(*)
    INTO v_EmailExists
    FROM EMPLOYEES
    WHERE email = TRIM(p_email);

    IF v_EmailExists > 0 THEN
        DBMS_OUTPUT.PUT_LINE('������: ��������� � ����� email ��� ����������.');
        RETURN;
    END IF;

    INSERT INTO EMPLOYEES (name, surname, positions, phone, email, serviceID)
    VALUES (TRIM(p_name), TRIM(p_surname), TRIM(p_positions), TRIM(p_phone), TRIM(p_email), p_serviceID);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('��������� �������� �������.');
EXCEPTION    
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('��������� � ����� email ��� ����������.');
    WHEN OTHERS THEN     
        ROLLBACK;       
        DBMS_OUTPUT.PUT_LINE('������ ���������� ����������: ' || SQLERRM);
        RAISE;
END;
-------------------------------------

--���������� ����������
CREATE OR REPLACE PROCEDURE UpdateEmployee(
    p_employeeID IN EMPLOYEES.employeeID%TYPE,
    p_name IN EMPLOYEES.name%TYPE,
    p_surname IN EMPLOYEES.surname%TYPE,
    p_positions IN EMPLOYEES.positions%TYPE,
    p_phone IN EMPLOYEES.phone%TYPE,
    p_email IN EMPLOYEES.email%TYPE,
    p_serviceID IN EMPLOYEES.serviceID%TYPE
)
IS
BEGIN
     IF p_name IS NULL OR LENGTH(TRIM(p_name)) = 0 or
        p_surname IS NULL OR LENGTH(TRIM(p_surname)) = 0 or
        p_positions IS NULL OR LENGTH(TRIM(p_positions)) = 0 or
        p_phone IS NULL OR LENGTH(TRIM(p_phone)) = 0 or
        p_email IS NULL OR LENGTH(TRIM(p_email)) = 0 then
        DBMS_OUTPUT.PUT_LINE('������: ���� �� ����� ���� ������.');
        RETURN;
    END IF;

     IF NOT REGEXP_LIKE(p_name, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('������: ��� ���������� ������ ��������� ������ �����.');
        RETURN;
    END IF;
       IF NOT REGEXP_LIKE(p_surname, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('������: ������� ���������� ������ ��������� ������ �����.');
        RETURN;
    END IF;
       IF NOT REGEXP_LIKE(p_positions, '^[[:alpha:],.\- ]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('������: ������������� ���������� ������ ��������� ������ �����.');
        RETURN;
    END IF;

    -- �������� �� ������������ �������� ������
    IF NOT IsEmailValid(p_email) THEN
        DBMS_OUTPUT.PUT_LINE('Error: ������������ email.');
        RETURN;
    END IF;

    -- �������� ������������� ����������
    IF NOT IsEmployeeExists(p_employeeID) THEN
        DBMS_OUTPUT.PUT_LINE('��������� � ID ' || p_employeeID || ' �� ������.');
        RETURN;
    END IF;

    -- �������� ������������� ������
    IF NOT IsServiceExists(p_serviceID) THEN
        DBMS_OUTPUT.PUT_LINE('������ � ID ' || p_serviceID || ' �� �������.');
        RETURN;
    END IF;

    -- ���������� ������ ����������
    UPDATE EMPLOYEES
    SET name = TRIM(p_name),
        surname = TRIM(p_surname),
        positions = TRIM(p_positions),
        phone = TRIM(p_phone),
        email = TRIM(p_email),
        serviceID = p_serviceID
    WHERE employeeID = p_employeeID;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('��������� ������� �������.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��������� ����������: ' || SQLERRM);
        RAISE;
END;
---------------------------------------

--�������� ����������
CREATE OR REPLACE PROCEDURE DeleteEmployee(
    p_employeeID IN EMPLOYEES.employeeID%TYPE
)
IS
BEGIN
    -- �������� �� null � ������ ������ ��� p_employeeID
    IF p_employeeID IS NULL OR LENGTH(TRIM(p_employeeID)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������: ID ���������� �� ����� ���� ������.');
        RETURN;
    END IF;

    -- �������� ���������� � ��������� �������
    DELETE FROM EMPLOYEES WHERE employeeID = p_employeeID;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('��������� � ID ' || p_employeeID || ' �� ������.');
        ROLLBACK;
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('��������� � ��������� ������ ������� �������.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ �������� ����������: ' || SQLERRM);
        RAISE;
END;
-------------------------------------------


--��������� ������ �����������
CREATE OR REPLACE PROCEDURE GetEmployeeList
IS
BEGIN
    FOR employee_rec IN (SELECT * FROM EMPLOYEES) LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || employee_rec.employeeID || ', ���: ' || employee_rec.name || ', �������: ' || employee_rec.surname || ', �������������: ' || employee_rec.positions || ', �������: ' || employee_rec.phone || ', Email: ' || employee_rec.email);

        -- ������� ������ ��� ��������� ���������� � ��������������� ������
        DECLARE
            v_service_name SERVICES.name%TYPE;
        BEGIN
            SELECT name INTO v_service_name
            FROM SERVICES
            WHERE serviceID = employee_rec.serviceID;

            DBMS_OUTPUT.PUT_LINE('   ������: ' || v_service_name);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('   ������ �� �������.');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('   ������ ��� ��������� ���������� �� ������: ' || SQLERRM);
        END;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('������ ��������� ������ �����������: ' || SQLERRM);
END;
-----------------------------------------

--��������� ���������� � ����������
CREATE OR REPLACE PROCEDURE GetStaffInfo(
    p_employeeID IN EMPLOYEES.employeeID%TYPE
)
IS
    v_name EMPLOYEES.name%TYPE;
    v_surname EMPLOYEES.surname%TYPE;
    v_positions EMPLOYEES.positions%TYPE;
    v_phone EMPLOYEES.phone%TYPE;
    v_email EMPLOYEES.email%TYPE;
    v_service_name SERVICES.name%TYPE;
BEGIN
    IF p_employeeID IS NULL OR LENGTH(TRIM(p_employeeID)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������: ���� �� ����� ���� ������.');
        RETURN;
    END IF;

    SELECT e.name, e.surname, e.positions, e.phone, e.email, s.name AS service_name
    INTO v_name, v_surname, v_positions, v_phone, v_email, v_service_name
    FROM EMPLOYEES e
    LEFT JOIN SERVICES s ON e.serviceID = s.serviceID
    WHERE e.employeeID = p_employeeID;

    DBMS_OUTPUT.PUT_LINE('ID ����������: ' ||  p_employeeID);
    DBMS_OUTPUT.PUT_LINE('���: ' || v_name);
    DBMS_OUTPUT.PUT_LINE('�������: ' || v_surname);
    DBMS_OUTPUT.PUT_LINE('�������������: ' || v_positions);
    DBMS_OUTPUT.PUT_LINE('����� ��������: ' || v_phone);
    DBMS_OUTPUT.PUT_LINE('Email: ' || v_email);

    IF v_service_name IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('������: ' || v_service_name);
    ELSE
        DBMS_OUTPUT.PUT_LINE('� ���������� ��� ����������� ������.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('��������� � ID ' || p_employeeID || ' �� ������.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('������ ��������� ���������� � ����������: ' || SQLERRM);
END;
------------------------------------------------------------------------------

--���������� ������
CREATE OR REPLACE PROCEDURE AddReview(    
    p_employeeID IN REVIEWS.employeeID%TYPE,    
    p_rating IN REVIEWS.rating%TYPE,    
    p_comm IN REVIEWS.comm%TYPE
)
IS
BEGIN
     IF p_employeeID IS NULL OR LENGTH(TRIM(p_employeeID)) = 0  or
        p_rating IS NULL OR LENGTH(TRIM(p_rating)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������: ���� �� ����� ���� ������.');
        RETURN;
    END IF;

    -- �������� ������������� ����������
    IF NOT IsEmployeeExists(p_employeeID) THEN
        DBMS_OUTPUT.PUT_LINE('Error: ��������� �� ������.');
        RETURN;
    END IF;

    INSERT INTO REVIEWS (employeeID, rating, comm)    
    VALUES (p_employeeID, p_rating, TRIM(p_comm));    
    
    COMMIT;   
    DBMS_OUTPUT.PUT_LINE('����� �������� �������.');
EXCEPTION

    WHEN OTHERS THEN        
        ROLLBACK;        
        DBMS_OUTPUT.PUT_LINE('������ ���������� ������: ' || SQLERRM);
        RAISE;
END;
-----------------------------------------

--�������� ������
CREATE OR REPLACE PROCEDURE DeleteReview(
    p_reviewID IN REVIEWS.reviewID%TYPE
)
IS
BEGIN
    -- �������� �� null � ������ ������ ��� p_reviewID
    IF p_reviewID IS NULL OR LENGTH(TRIM(p_reviewID)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������: ID ������ �� ����� ���� ������.');
        RETURN;
    END IF;

    -- �������� ������������� ������
    IF NOT IsReviewExists(p_reviewID) THEN
        DBMS_OUTPUT.PUT_LINE('Error: ����� � ID ' || p_reviewID || ' �� ������.');
        RETURN;
    END IF;

    -- �������� ������
    DELETE FROM REVIEWS WHERE reviewID = p_reviewID;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('����� � ID ' || p_reviewID || ' �� ������.');
        ROLLBACK;
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('����� � ��������� ������ ������� �������.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ �������� ������: ' || SQLERRM);
        RAISE;
END;
------------------------------------------

--��������� �������� �������� ���������� �� �������
CREATE OR REPLACE PROCEDURE GetAverageRatingForEmployee(
    p_employeeName IN EMPLOYEES.name%TYPE,
    p_employeeSurname IN EMPLOYEES.surname%TYPE
)
IS
    v_employeeID EMPLOYEES.employeeID%TYPE;
    v_averageRating NUMBER;
BEGIN
    IF p_employeeName IS NULL OR LENGTH(TRIM(p_employeeName)) = 0  or
        p_employeeSurname IS NULL OR LENGTH(TRIM(p_employeeSurname)) = 0
         THEN
        DBMS_OUTPUT.PUT_LINE('������: ���� �� ����� ���� ������.');
        RETURN;
    END IF;
    IF NOT REGEXP_LIKE(p_employeeName, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('������: ��� ������ ��������� ������ �����.');
        RETURN;
    END IF;

    IF NOT REGEXP_LIKE(p_employeeSurname, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('������: ������� ������ ��������� ������ �����.');
        RETURN;
    END IF;

    -- ����� ���������� �� �����
    SELECT employeeID INTO v_employeeID
    FROM EMPLOYEES
    WHERE UPPER(name) = UPPER(TRIM(p_employeeName))
    AND UPPER(surname) = UPPER(TRIM(p_employeeSurname));

    -- �������� ������������� ����������
    IF v_employeeID IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error: ��������� � ������ ' || p_employeeName || ' �� ������.');
        RETURN;
    END IF;

    -- ���������� �������� ��������
    SELECT AVG(rating) INTO v_averageRating
    FROM REVIEWS
    WHERE employeeID = v_employeeID;

    IF v_averageRating IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('������� ������� ���������� ' || p_employeeName || ': ' || v_averageRating);
    ELSE
        DBMS_OUTPUT.PUT_LINE('��� ������� � ���������� ' || p_employeeName);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('��������� � ������ ' || p_employeeName || ' �� ������.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('������ �������� �������� ��������: ' || SQLERRM);
END;
--------------------------------------------

--��������� ������ ������� �� ����������� ����������
CREATE OR REPLACE PROCEDURE GetReviewsForEmployee(
    p_employeeName IN EMPLOYEES.name%TYPE,
    p_employeeSurname IN EMPLOYEES.surname%TYPE
)
IS
    v_employeeID EMPLOYEES.employeeID%TYPE;
BEGIN
    IF p_employeeName IS NULL OR LENGTH(TRIM(p_employeeName)) = 0  or
        p_employeeSurname IS NULL OR LENGTH(TRIM(p_employeeSurname)) = 0
         THEN
        DBMS_OUTPUT.PUT_LINE('������: ���� �� ����� ���� ������.');
        RETURN;
    END IF;
    IF NOT REGEXP_LIKE(p_employeeName, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('������: ��� ������ ��������� ������ �����.');
        RETURN;
    END IF;

    IF NOT REGEXP_LIKE(p_employeeSurname, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('������: ������� ������ ��������� ������ �����.');
        RETURN;
    END IF;

    -- ����� ���������� �� ����� � �������
    SELECT employeeID INTO v_employeeID
    FROM EMPLOYEES
    WHERE UPPER(name) = UPPER(TRIM(p_employeeName))
      AND UPPER(surname) = UPPER(TRIM(p_employeeSurname));

    -- �������� ������������� ����������
    IF v_employeeID IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error: ��������� ' || p_employeeName || ' ' || p_employeeSurname || ' �� ������.');
        RETURN;
    END IF;

    -- ��������� ������� ��� ����������
   FOR review_rec IN (SELECT *
                   FROM REVIEWS
                   WHERE employeeID = v_employeeID) LOOP
    DBMS_OUTPUT.PUT_LINE('ID ������: ' || review_rec.reviewID || ', ���: ' || p_employeeName || ', �������: ' || p_employeeSurname ||
                         ', �������: ' || review_rec.rating || ', �����: ' || review_rec.comm);
END LOOP;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('��� ������� ��� ���������� ' || p_employeeName || ' ' || p_employeeSurname);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('������ ��������� ������� ��� ���������� ' || p_employeeName || ' ' || p_employeeSurname || ': ' || SQLERRM);
END;
-------------------------------------------------------------------------

--������ �� ������
CREATE OR REPLACE PROCEDURE AddRegistration(
    p_clientEmail IN CLIENTS.email%type,
    p_employeeEmail IN EMPLOYEES.email%type,
    p_dateTime IN REGISTRATION.dateTime%type,
    p_notes IN REGISTRATION.notes%type
)
IS
    v_clientID CLIENTS.clientID%TYPE;
    v_employeeID EMPLOYEES.employeeID%TYPE;
    v_ExistingRegistration NUMBER;
BEGIN
    IF p_clientEmail IS NULL OR LENGTH(TRIM(p_clientEmail)) = 0 or
        p_employeeEmail IS NULL OR LENGTH(TRIM(p_employeeEmail)) = 0 or
        p_dateTime IS NULL OR LENGTH(TRIM(p_dateTime)) = 0 then
        DBMS_OUTPUT.PUT_LINE('������: ���� �� ����� ���� ������.');
        RETURN;
    END IF;
      -- �������� �� ������������ �������� ������
    IF NOT IsEmailValid(p_clientEmail) THEN
        DBMS_OUTPUT.PUT_LINE('Error: ������������ email.');
        RETURN;
    END IF;
    IF NOT IsEmailValid(p_employeeEmail) THEN
        DBMS_OUTPUT.PUT_LINE('Error: ������������ email.');
        RETURN;
    END IF;
    -- �������� ������������� ������������
    SELECT clientID INTO v_clientID
    FROM CLIENTS
    WHERE EMAIL = p_clientEmail;

    IF v_clientID IS NULL THEN
        sys.DBMS_OUTPUT.PUT_LINE('������: ������������ � ������ ' || p_clientEmail || ' �� ������.');
        RETURN;
    END IF;
    -- �������� ������������� ����������
    SELECT employeeID INTO v_employeeID
    FROM EMPLOYEES
    WHERE EMAIL = p_employeeEmail;

    IF v_employeeID IS NULL THEN
        sys.DBMS_OUTPUT.PUT_LINE('������: ��������� � ������ ' || p_employeeEmail || ' �� ������.');
        RETURN;
    END IF;

     -- �������� ������� ������ ����������� � ������� � ��������� ������ �������
    SELECT COUNT(*)
    INTO v_ExistingRegistration
    FROM REGISTRATION
    WHERE EMPLOYEEID = v_employeeID
      AND dateTime BETWEEN p_dateTime - INTERVAL '2' HOUR AND p_dateTime + INTERVAL '2' HOUR;

    IF v_ExistingRegistration > 0 THEN
        sys.DBMS_OUTPUT.PUT_LINE('������: � ���������� ��� ���� ������ ����������� � ��������� ������ �������.');
        RETURN;
    END IF;

     -- �������� �� ������������� ����������� � �������
    IF p_dateTime < SYSTIMESTAMP THEN
        sys.DBMS_OUTPUT.PUT_LINE('������: ����������� � ������� ������� ����������.');
        RETURN;
    END IF;

    INSERT INTO REGISTRATION (CLIENTID, EMPLOYEEID, DATETIME, NOTES)
    VALUES (v_clientID, v_employeeID, p_dateTime, TRIM(p_Notes));

    COMMIT;
    sys.DBMS_OUTPUT.PUT_LINE('����������� ������� ���������.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        sys.DBMS_OUTPUT.PUT_LINE('������ ��� ���������� �����������: ' || SQLERRM);
        RAISE;
END;
------------------------------------------

--�������� ������ �� ������
CREATE OR REPLACE PROCEDURE DeleteRegistration(
    p_registrationID IN REGISTRATION.registrationID%TYPE
)
IS
BEGIN
    -- �������� �� null � ������ ������ ��� p_registrationID
    IF p_registrationID IS NULL OR LENGTH(TRIM(p_registrationID)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������: ID ������ �� ����� ���� ������.');
        RETURN;
    END IF;

    -- �������� ������
    DELETE FROM REGISTRATION WHERE registrationID = p_registrationID;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ � ID ' || p_registrationID || ' �� �������.');
        ROLLBACK;
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('������ ������� �������.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ �������� ������: ' || SQLERRM);
        RAISE;
END;
---------------------------------------------

--��������� ���������� � ������ �������
CREATE OR REPLACE PROCEDURE GetClientRegistrations(    
    p_clientID IN CLIENTS.clientID%TYPE
)
IS
BEGIN

    FOR reg_rec IN (
        SELECT
            R.registrationID,
            R.dateTime,
            C.name AS client_name,
            C.surname AS client_surname,
            E.name AS employee_name,
            E.surname AS employee_surname,
            S.name AS service_name,
            R.notes
        FROM REGISTRATION R
        JOIN CLIENTS C ON R.clientID = C.clientID
        JOIN EMPLOYEES E ON R.employeeID = E.employeeID
        JOIN SERVICES S ON E.serviceID = S.serviceID
        WHERE R.clientID = p_clientID
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('ID ������: ' || reg_rec.registrationID ||
                             ', ������: ' || reg_rec.client_name || ' ' || reg_rec.client_surname ||
                             ', ���������: ' || reg_rec.employee_name || ' ' || reg_rec.employee_surname ||
                             ', ������: ' || reg_rec.service_name ||
                             ', ���� � �����: ' || TO_CHAR(reg_rec.dateTime, 'YYYY-MM-DD HH24:MI:SS') ||
                             ', ����������: ' || reg_rec.notes);
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('������ ��������� ���������� � ������: ' || SQLERRM);
END;
-----------------------------------------------------------------------------------

--��������� ��� ��������� ������ ��������
CREATE OR REPLACE PROCEDURE GetClientList
IS
BEGIN
    FOR client_rec IN (SELECT * FROM CLIENTS) LOOP
        DBMS_OUTPUT.PUT_LINE('ID �������: ' || client_rec.clientID ||
                             ', ���: ' || client_rec.name ||
                             ', �������: ' || client_rec.surname ||
                             ', �������: ' || client_rec.phone ||
                             ', Email: ' || client_rec.email);
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('������ ��������� ������ ��������: ' || SQLERRM);
END;
-------------------------------------------------------------

--��������� ��� ������� ���������� ����������� ����� �� ��������
CREATE OR REPLACE PROCEDURE AnalyzeServicesByPeriod(
    p_StartDate IN DATE,
    p_EndDate IN DATE
)
IS
BEGIN
    FOR service_record IN (
        SELECT s.name AS serviceName, COUNT(*) AS serviceCount
        FROM REGISTRATION r
        JOIN EMPLOYEES e ON r.employeeID = e.employeeID
        JOIN SERVICES s ON e.serviceID = s.serviceID
        WHERE r.dateTime BETWEEN p_StartDate AND p_EndDate
        GROUP BY s.name
    ) LOOP
        EnableDbmsOutput();
        sys.DBMS_OUTPUT.PUT_LINE('���������� ����������� �����: ' || service_record.serviceCount);
    END LOOP;
END;

-------------------------------------------------

--��������� ��� ��������� ���������� �����
CREATE OR REPLACE PROCEDURE AnalyzePopularServices
IS
BEGIN
    FOR service_rec IN (
        SELECT s.name AS ServiceName,
               COUNT(*) AS TotalRegistrations
        FROM REGISTRATION r
        JOIN EMPLOYEES e ON r.employeeID = e.employeeID
        JOIN SERVICES s ON e.serviceID = s.serviceID
        GROUP BY s.name
        ORDER BY TotalRegistrations DESC
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('������: ' || service_rec.ServiceName || ', ����� ���������� �������: ' || service_rec.TotalRegistrations);
    END LOOP;
END;
------------------------------------------------------------------------

--��������� ��� ����������� ������������ � ���������� ��� � ������� ��������
CREATE OR REPLACE PROCEDURE RegisterClient(
    p_name IN VARCHAR2,
    p_surname IN VARCHAR2,
    p_phone IN VARCHAR2,
    p_email IN VARCHAR2,
    p_password IN VARCHAR2
)
IS
    v_ClientID CLIENTS.clientID%TYPE;
    v_PasswordExists NUMBER;
BEGIN
    ENABLEDBMSOUTPUT();
    IF p_name IS NULL OR LENGTH(TRIM(p_name)) = 0 or
        p_surname IS NULL OR LENGTH(TRIM(p_surname)) = 0 or
        p_phone IS NULL OR LENGTH(TRIM(p_phone)) = 0 or
        p_email IS NULL OR LENGTH(TRIM(p_email)) = 0 or
        p_password IS NULL OR LENGTH(TRIM(p_password)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������: ���� �� ����� ���� ������.');
        RETURN;
    END IF;

    IF NOT REGEXP_LIKE(p_name, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('������: ��� ������������ ������ ��������� ������ �����.');
        RETURN;
    END IF;

    IF NOT REGEXP_LIKE(p_surname, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('������: ������� ������������ ������ ��������� ������ �����.');
        RETURN;
    END IF;

    -- �������� �� ������������ �������� ������
    IF NOT IsEmailValid(p_email) THEN
        DBMS_OUTPUT.PUT_LINE('Error: ������������ email.');
        RETURN;
    END IF;

    -- �������� �� ������������� ������
    SELECT COUNT(*) INTO v_PasswordExists FROM CLIENTS WHERE PASSWORD = p_password;

    IF v_PasswordExists > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: ������ ��� ����������. �������� ������ ������.');
        RETURN;
    END IF;

    -- ������� ����� ������������ � ��������� email
    BEGIN
        SELECT CLIENTID INTO v_ClientID FROM CLIENTS WHERE EMAIL = p_email;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_ClientID := NULL; -- ���� ������ �� �������, ������������� ���������� � NULL
    END;

    -- ���� ������������ � ����� email ��� ����������, ������ ��������� �� ������
    IF v_ClientID IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error: ������������ � ����� email ��� ����������.');
    ELSE
        -- ���������� ������ ������������ � ������� CLIENTS
        BEGIN
            INSERT INTO CLIENTS (name, surname, phone, email, password)
            VALUES (p_name, p_surname, p_phone, p_email, p_password);
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('������������ ��������������� �������.');
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('Error: ������������ � ����� email ��� ����������.');
        END;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ����������� ������������: ' || SQLERRM);
        RAISE;
END RegisterClient;
----------------------------------------------

--��������� ���������� �������
CREATE OR REPLACE PROCEDURE UpdateClient(
    p_clientID IN CLIENTS.clientID%TYPE,
    p_name IN CLIENTS.name%TYPE,
    p_surname IN CLIENTS.surname%TYPE,
    p_phone IN CLIENTS.phone%TYPE,
    p_email IN CLIENTS.email%TYPE,
    p_password IN CLIENTS.password%TYPE
)
IS
    v_client_exists NUMBER;
BEGIN
    -- �������� �� null � ������ ������ ��� p_clientID
    IF p_clientID IS NULL OR LENGTH(TRIM(p_clientID)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������: ID ������� �� ����� ���� ������.');
        RETURN;
    END IF;

    -- �������� �� null � ������ ������ ��� ��������� �����
    IF p_name IS NULL OR LENGTH(TRIM(p_name)) = 0 or
        p_surname IS NULL OR LENGTH(TRIM(p_surname)) = 0 or
        p_phone IS NULL OR LENGTH(TRIM(p_phone)) = 0 or
        p_email IS NULL OR LENGTH(TRIM(p_email)) = 0 or
        p_password IS NULL OR LENGTH(TRIM(p_password)) = 0 then
        DBMS_OUTPUT.PUT_LINE('������: ���� �� ����� ���� ������.');
        RETURN;
    END IF;

    -- �������� �� ������������ �������� ������
    IF NOT IsEmailValid(p_email) THEN
        DBMS_OUTPUT.PUT_LINE('Error: ������������ email.');
        RETURN;
    END IF;

  -- �������� ������������� �������
    SELECT COUNT(*) INTO v_client_exists
    FROM CLIENTS
    WHERE clientID = p_clientID;

    IF v_client_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ � ID ' || p_clientID || ' �� ������.');
        RETURN;
    END IF;
    -- ���������� ������ �������
    UPDATE CLIENTS
    SET name = TRIM(p_name),
        surname = TRIM(p_surname),
        phone = TRIM(p_phone),
        email = TRIM(p_email),
        password = TRIM(p_password)
    WHERE clientID = p_clientID;

    -- ���������� ��������� ������� � ������� REGISTRATION
    UPDATE REGISTRATION
    SET clientID = p_clientID
    WHERE clientID = p_clientID;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('������ ������� �������.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��������� �������: ' || SQLERRM);
        RAISE;
END;
------------------------------------------

--��������� �������� �������
CREATE OR REPLACE PROCEDURE DeleteClient(
    p_clientID IN CLIENTS.clientID%TYPE
)
IS
BEGIN
    -- �������� �� null � ������ ������ ��� p_clientID
    IF p_clientID IS NULL OR LENGTH(TRIM(p_clientID)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������: ID ������� �� ����� ���� ������.');
        RETURN;
    END IF;

    -- �������� ������� � ��������� �������
    DELETE FROM CLIENTS WHERE clientID = p_clientID;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������ � ID ' || p_clientID || ' �� ������.');
        ROLLBACK;
    ELSE
        -- �������� ��������� ������� � ������� REGISTRATION
        DELETE FROM REGISTRATION WHERE clientID = p_clientID;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('������ � ��������� ������ ������� �������.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ �������� �������: ' || SQLERRM);
        RAISE;
END;
-------------------------------------------------

--��������� ����������� �������
CREATE OR REPLACE PROCEDURE ClientLogin(
    p_email IN CLIENTS.email%TYPE,
    p_password IN CLIENTS.password%TYPE
)
IS
    v_clientID CLIENTS.clientID%TYPE;
BEGIN
    -- �������� �� ������ ����
    IF p_email IS NULL OR LENGTH(TRIM(p_email)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������: Email �� ����� ���� ������.');
        RETURN;
    END IF;

    IF p_password IS NULL OR LENGTH(TRIM(p_password)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������: ������ �� ����� ���� ������.');
        RETURN;
    END IF;
        -- �������� �� ������������ �������� ������
    IF NOT IsEmailValid(p_email) THEN
        DBMS_OUTPUT.PUT_LINE('Error: ������������ email.');
        RETURN;
    END IF;


    -- ����� ������� �� email � ������
    SELECT clientID INTO v_clientID
    FROM CLIENTS
    WHERE email = p_email AND password = p_password;

    -- ��������, ������ �� ������
    IF v_clientID IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('������ � email ' || p_email || ' ������� �����������. ID: ' || v_clientID);
    ELSE
        DBMS_OUTPUT.PUT_LINE('������: �������� email ��� ������.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('������: ������ � email ' || p_email || ' �� ������. ��������� email � ������');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('������ ����������� �������: ' || SQLERRM);
END;
------------------------------------------------

--��������� ���������� � �������
CREATE OR REPLACE PROCEDURE GetClientInfoByID(
    p_clientID IN CLIENTS.clientID%TYPE
)
IS
    v_name CLIENTS.name%TYPE;
    v_surname CLIENTS.surname%TYPE;
    v_phone CLIENTS.phone%TYPE;
    v_email CLIENTS.email%TYPE;
BEGIN
    -- �������� �� null � ������ ������ ��� p_clientID
    IF p_clientID IS NULL OR LENGTH(TRIM(p_clientID)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������: ID ������� �� ����� ���� ������.');
        RETURN;
    END IF;

    -- ����� ���������� � ������� �� ID
    SELECT name, surname, phone, email
    INTO v_name, v_surname, v_phone, v_email
    FROM CLIENTS
    WHERE clientID = p_clientID;

    -- ��������, ������ �� ������
    IF v_name IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('���������� � ������� � ID ' || p_clientID || ':');
        DBMS_OUTPUT.PUT_LINE('���: ' || v_name);
        DBMS_OUTPUT.PUT_LINE('�������: ' || v_surname);
        DBMS_OUTPUT.PUT_LINE('�������: ' || v_phone);
        DBMS_OUTPUT.PUT_LINE('Email: ' || v_email);
    ELSE
        DBMS_OUTPUT.PUT_LINE('������: ������ � ID ' || p_clientID || ' �� ������.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('������: ������ � ID ' || p_clientID || ' �� ������.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('������ ��������� ���������� � �������: ' || SQLERRM);
END;

