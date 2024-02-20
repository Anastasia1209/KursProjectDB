-----PROCEDURES
--SET serveroutput ON;

--ДОБАВЛЕНИЕ НОВОЙ УСЛУГИ
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
        DBMS_OUTPUT.PUT_LINE('Ошибка: Поле не может быть пустым.');
        RETURN;
    END if;

     IF NOT REGEXP_LIKE(p_name, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Название услуги должно содержать только буквы.');
        RETURN;
    END IF;

    IF NOT REGEXP_LIKE(p_description, '^[[:alpha:],.\- ]+$') THEN
    sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Отзыв должен содержать только буквы, запятые, точки, дефисы и пробелы.');
    RETURN;
END IF;

    -- Проверка на корректность входящих данных
   BEGIN
        IF p_price < 0 THEN
            sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Цена не может быть отрицательной.');
            RETURN;
        END IF;
    EXCEPTION
        WHEN VALUE_ERROR THEN
            sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Цена должна быть числом.');
            RETURN;
    END;

    INSERT INTO SERVICES (name, description, price)
    VALUES (TRIM(p_name), TRIM(p_description), p_price);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Услуга добавлена успешно.');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('Услуга с таким id уже существует.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка добавления услуги: ' || SQLERRM);
        RAISE;
END;
-----------------------------------------

--ОБНОВЛЕНИЕ УСЛУГИ
CREATE OR REPLACE PROCEDURE UpdateService(
    p_serviceID IN SERVICES.serviceID%TYPE,
    p_name IN SERVICES.name%TYPE,
    p_description IN SERVICES.description%TYPE,
    p_price IN SERVICES.price%TYPE
)
IS
BEGIN
    IF p_name IS NULL OR LENGTH(TRIM(p_name)) = 0 THEN
        sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Название услуги не может быть пустым.');
        RETURN;
    END IF;
     IF NOT REGEXP_LIKE(p_name, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Название услуги должно содержать только буквы.');
        RETURN;
    END IF;
     IF p_description IS NULL  OR LENGTH(TRIM(p_description)) = 0 THEN
        sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Описание услуги не может быть NULL.');
        RETURN;
    END IF;
     IF NOT REGEXP_LIKE(p_description, '^[[:alpha:],.\- ]+$') THEN
    sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Отзыв должен содержать только буквы.');
    RETURN;
END IF;

    -- Проверка на корректность входящих данных
    IF p_price < 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Цена не может быть отрицательной.');
        RETURN;
    END IF;

    UPDATE SERVICES
    SET name = TRIM(p_name),
        description = TRIM(p_description),
        price = p_price
    WHERE serviceID = p_serviceID;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Услуга изменена успешно.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Услуга с ID ' || p_ServiceID || ' не найдена.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка изменения услуги: ' || SQLERRM);
        RAISE;
END;
-----------------------------------------

--УДАЛЕНИЕ УСЛУГИ
CREATE OR REPLACE PROCEDURE DeleteService(    
    p_serviceID IN SERVICES.serviceID%TYPE
)
IS
BEGIN
    -- Проверка на null и пустую строку для p_serviceID
    IF p_serviceID IS NULL OR LENGTH(TRIM(p_serviceID)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: ID услуги не может быть пустым.');
        RETURN;
    END IF;

    DELETE FROM SERVICES WHERE serviceID = p_serviceID;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Услуга с ID ' || p_serviceID || ' не найдена.');
        ROLLBACK;
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Услуга с ID ' || p_serviceID || ' удалена успешно.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка удаления услуги: ' || SQLERRM);
        RAISE;
END;
-----------------------------------------

--ПОЛУЧЕНИЕ СПИСКА УСЛУГ
CREATE OR REPLACE PROCEDURE GetServiceList
IS
BEGIN
    FOR service_rec IN (SELECT s.serviceID, s.name AS service_name, s.description, s.price, e.name AS employee_name, e.surname AS employee_surname
                        FROM SERVICES s
                        LEFT JOIN EMPLOYEES e ON s.serviceID = e.serviceID) LOOP
        DBMS_OUTPUT.PUT_LINE('ID услуги: ' || service_rec.serviceID ||
                             ', Название услуги: ' || service_rec.service_name ||
                             ', Описание: ' || service_rec.description ||
                             ', Цена: ' || service_rec.price ||
                             CASE
                                WHEN service_rec.employee_name IS NOT NULL THEN
                                    ', Сотрудник: ' || service_rec.employee_name || ' ' || service_rec.employee_surname
                                ELSE
                                    ', Нет доступных сотрудников для предоставления услуги.'
                             END);
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка получения списка услуг: ' || SQLERRM);
END;
-----------------------------------------

--ПОЛУЧЕНИЕ ИНФОРМАЦИИ ОБ УСЛУГЕ
CREATE OR REPLACE PROCEDURE GetServiceInfoByName(
    p_serviceName IN SERVICES.name%TYPE
)
IS
    v_serviceID SERVICES.serviceID%TYPE;
    v_description SERVICES.description%TYPE;
    v_price SERVICES.price%TYPE;
BEGIN
     IF p_serviceName IS NULL OR LENGTH(TRIM(p_serviceName)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: Название услуги не может быть пустым.');
        RETURN;
    END IF;
    -- Проверка, что введено только буквенное значение
    IF NOT REGEXP_LIKE(p_serviceName, '^[[:alpha:]]+$') THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: Введите только буквенное значение для названия услуги.');
        RETURN;
    END IF;

    SELECT serviceID, description, price
    INTO v_serviceID, v_description, v_price
    FROM SERVICES
    WHERE UPPER(name) = UPPER(TRIM(p_serviceName));

    DBMS_OUTPUT.PUT_LINE('ID услуги: ' || v_serviceID);
    DBMS_OUTPUT.PUT_LINE('Название услуги: ' || p_serviceName);
    DBMS_OUTPUT.PUT_LINE('Описание: ' || v_description);
    DBMS_OUTPUT.PUT_LINE('Цена: ' || v_price);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Услуга с именем ' || p_serviceName || ' не найдена.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка получения информации об услуге: ' || SQLERRM);
END;
-------------------------------------------

--ДОБАВЛЕНИЕ НОВОГО СОТРУДНИКА
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
        DBMS_OUTPUT.PUT_LINE('Ошибка: Поле не может быть пустым.');
        RETURN;
    END IF;

       IF NOT REGEXP_LIKE(p_name, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Имя сотрудника должно содержать только буквы.');
        RETURN;
    END IF;
       IF NOT REGEXP_LIKE(p_surname, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Фамилия сотрудника должна содержать только буквы.');
        RETURN;
    END IF;
       IF NOT REGEXP_LIKE(p_positions, '^[[:alpha:],.\- ]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Специализация сотрудника должна содержать только буквы.');
        RETURN;
    END IF;

    -- Проверка на корректность входящих данных
    IF NOT IsEmailValid(p_email) THEN
        DBMS_OUTPUT.PUT_LINE('Error: Некорректный email.');
        RETURN;
    END IF;

    -- Проверка на существование услуги
    IF NOT IsServiceExists(p_serviceID) THEN
        DBMS_OUTPUT.PUT_LINE('Error: Услуга с ID ' || p_serviceID || ' не найдена.');
        RETURN;
    END IF;

    -- Проверка уникальности email
    SELECT COUNT(*)
    INTO v_EmailExists
    FROM EMPLOYEES
    WHERE email = TRIM(p_email);

    IF v_EmailExists > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: Сотрудник с таким email уже существует.');
        RETURN;
    END IF;

    INSERT INTO EMPLOYEES (name, surname, positions, phone, email, serviceID)
    VALUES (TRIM(p_name), TRIM(p_surname), TRIM(p_positions), TRIM(p_phone), TRIM(p_email), p_serviceID);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Сотрудник добавлен успешно.');
EXCEPTION    
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Сотрудник с таким email уже существует.');
    WHEN OTHERS THEN     
        ROLLBACK;       
        DBMS_OUTPUT.PUT_LINE('Ошибка добавления сотрудника: ' || SQLERRM);
        RAISE;
END;
-------------------------------------

--ОБНОВЛЕНИЕ СОТРУДНИКА
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
        DBMS_OUTPUT.PUT_LINE('Ошибка: Поле не может быть пустым.');
        RETURN;
    END IF;

     IF NOT REGEXP_LIKE(p_name, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Имя сотрудника должно содержать только буквы.');
        RETURN;
    END IF;
       IF NOT REGEXP_LIKE(p_surname, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Фамилия сотрудника должна содержать только буквы.');
        RETURN;
    END IF;
       IF NOT REGEXP_LIKE(p_positions, '^[[:alpha:],.\- ]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Специализация сотрудника должна содержать только буквы.');
        RETURN;
    END IF;

    -- Проверка на корректность входящих данных
    IF NOT IsEmailValid(p_email) THEN
        DBMS_OUTPUT.PUT_LINE('Error: некорректный email.');
        RETURN;
    END IF;

    -- Проверка существования сотрудника
    IF NOT IsEmployeeExists(p_employeeID) THEN
        DBMS_OUTPUT.PUT_LINE('Сотрудник с ID ' || p_employeeID || ' не найден.');
        RETURN;
    END IF;

    -- Проверка существования услуги
    IF NOT IsServiceExists(p_serviceID) THEN
        DBMS_OUTPUT.PUT_LINE('Услуга с ID ' || p_serviceID || ' не найдена.');
        RETURN;
    END IF;

    -- Обновление данных сотрудника
    UPDATE EMPLOYEES
    SET name = TRIM(p_name),
        surname = TRIM(p_surname),
        positions = TRIM(p_positions),
        phone = TRIM(p_phone),
        email = TRIM(p_email),
        serviceID = p_serviceID
    WHERE employeeID = p_employeeID;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Сотрудник изменен успешно.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка изменения сотрудника: ' || SQLERRM);
        RAISE;
END;
---------------------------------------

--УДАЛЕНИЕ СОТРУДНИКА
CREATE OR REPLACE PROCEDURE DeleteEmployee(
    p_employeeID IN EMPLOYEES.employeeID%TYPE
)
IS
BEGIN
    -- Проверка на null и пустую строку для p_employeeID
    IF p_employeeID IS NULL OR LENGTH(TRIM(p_employeeID)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: ID сотрудника не может быть пустым.');
        RETURN;
    END IF;

    -- Удаление сотрудника и связанных записей
    DELETE FROM EMPLOYEES WHERE employeeID = p_employeeID;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Сотрудник с ID ' || p_employeeID || ' не найден.');
        ROLLBACK;
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Сотрудник и связанные записи успешно удалены.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка удаления сотрудника: ' || SQLERRM);
        RAISE;
END;
-------------------------------------------


--ПОЛУЧЕНИЕ СПИСКА СОТРУДНИКОВ
CREATE OR REPLACE PROCEDURE GetEmployeeList
IS
BEGIN
    FOR employee_rec IN (SELECT * FROM EMPLOYEES) LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || employee_rec.employeeID || ', Имя: ' || employee_rec.name || ', Фамилия: ' || employee_rec.surname || ', Специализация: ' || employee_rec.positions || ', Телефон: ' || employee_rec.phone || ', Email: ' || employee_rec.email);

        -- Добавим запрос для получения информации о соответствующей услуге
        DECLARE
            v_service_name SERVICES.name%TYPE;
        BEGIN
            SELECT name INTO v_service_name
            FROM SERVICES
            WHERE serviceID = employee_rec.serviceID;

            DBMS_OUTPUT.PUT_LINE('   Услуга: ' || v_service_name);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('   Услуга не найдена.');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('   Ошибка при получении информации об услуге: ' || SQLERRM);
        END;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка получения списка сотрудников: ' || SQLERRM);
END;
-----------------------------------------

--ПОЛУЧЕНИЕ ИНФОРМАЦИИ О СОТРУДНИКЕ
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
        DBMS_OUTPUT.PUT_LINE('Ошибка: Поле не может быть пустым.');
        RETURN;
    END IF;

    SELECT e.name, e.surname, e.positions, e.phone, e.email, s.name AS service_name
    INTO v_name, v_surname, v_positions, v_phone, v_email, v_service_name
    FROM EMPLOYEES e
    LEFT JOIN SERVICES s ON e.serviceID = s.serviceID
    WHERE e.employeeID = p_employeeID;

    DBMS_OUTPUT.PUT_LINE('ID сотрудника: ' ||  p_employeeID);
    DBMS_OUTPUT.PUT_LINE('Имя: ' || v_name);
    DBMS_OUTPUT.PUT_LINE('Фамилия: ' || v_surname);
    DBMS_OUTPUT.PUT_LINE('Специализация: ' || v_positions);
    DBMS_OUTPUT.PUT_LINE('Номер телефона: ' || v_phone);
    DBMS_OUTPUT.PUT_LINE('Email: ' || v_email);

    IF v_service_name IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Услуга: ' || v_service_name);
    ELSE
        DBMS_OUTPUT.PUT_LINE('У сотрудника нет привязанной услуги.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Сотрудник с ID ' || p_employeeID || ' не найден.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка получения информации о сотруднике: ' || SQLERRM);
END;
------------------------------------------------------------------------------

--ДОБАВЛЕНИЕ ОТЗЫВА
CREATE OR REPLACE PROCEDURE AddReview(    
    p_employeeID IN REVIEWS.employeeID%TYPE,    
    p_rating IN REVIEWS.rating%TYPE,    
    p_comm IN REVIEWS.comm%TYPE
)
IS
BEGIN
     IF p_employeeID IS NULL OR LENGTH(TRIM(p_employeeID)) = 0  or
        p_rating IS NULL OR LENGTH(TRIM(p_rating)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: Поле не может быть пустым.');
        RETURN;
    END IF;

    -- Проверка существования сотрудника
    IF NOT IsEmployeeExists(p_employeeID) THEN
        DBMS_OUTPUT.PUT_LINE('Error: сотрудник не найден.');
        RETURN;
    END IF;

    INSERT INTO REVIEWS (employeeID, rating, comm)    
    VALUES (p_employeeID, p_rating, TRIM(p_comm));    
    
    COMMIT;   
    DBMS_OUTPUT.PUT_LINE('Отзыв добавлен успешно.');
EXCEPTION

    WHEN OTHERS THEN        
        ROLLBACK;        
        DBMS_OUTPUT.PUT_LINE('Ошибка добавления отзыва: ' || SQLERRM);
        RAISE;
END;
-----------------------------------------

--УДАЛЕНИЕ ОТЗЫВА
CREATE OR REPLACE PROCEDURE DeleteReview(
    p_reviewID IN REVIEWS.reviewID%TYPE
)
IS
BEGIN
    -- Проверка на null и пустую строку для p_reviewID
    IF p_reviewID IS NULL OR LENGTH(TRIM(p_reviewID)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: ID отзыва не может быть пустым.');
        RETURN;
    END IF;

    -- Проверка существования отзыва
    IF NOT IsReviewExists(p_reviewID) THEN
        DBMS_OUTPUT.PUT_LINE('Error: Отзыв с ID ' || p_reviewID || ' не найден.');
        RETURN;
    END IF;

    -- Удаление отзыва
    DELETE FROM REVIEWS WHERE reviewID = p_reviewID;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Отзыв с ID ' || p_reviewID || ' не найден.');
        ROLLBACK;
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Отзыв и связанные записи успешно удалены.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка удаления отзыва: ' || SQLERRM);
        RAISE;
END;
------------------------------------------

--ПОЛУЧЕНИЕ СРЕДНЕГО РЕЙТИНГА СОТРУДНИКА ПО ОТЗЫВАМ
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
        DBMS_OUTPUT.PUT_LINE('Ошибка: Поле не может быть пустым.');
        RETURN;
    END IF;
    IF NOT REGEXP_LIKE(p_employeeName, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Имя должно содержать только буквы.');
        RETURN;
    END IF;

    IF NOT REGEXP_LIKE(p_employeeSurname, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Фамилия должна содержать только буквы.');
        RETURN;
    END IF;

    -- Поиск сотрудника по имени
    SELECT employeeID INTO v_employeeID
    FROM EMPLOYEES
    WHERE UPPER(name) = UPPER(TRIM(p_employeeName))
    AND UPPER(surname) = UPPER(TRIM(p_employeeSurname));

    -- Проверка существования сотрудника
    IF v_employeeID IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error: Сотрудник с именем ' || p_employeeName || ' не найден.');
        RETURN;
    END IF;

    -- Вычисление среднего рейтинга
    SELECT AVG(rating) INTO v_averageRating
    FROM REVIEWS
    WHERE employeeID = v_employeeID;

    IF v_averageRating IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Средний рейтинг сотрудника ' || p_employeeName || ': ' || v_averageRating);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Нет отзывов у сотрудника ' || p_employeeName);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Сотрудник с именем ' || p_employeeName || ' не найден.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка подсчета среднего рейтинга: ' || SQLERRM);
END;
--------------------------------------------

--ПОЛУЧЕНИЕ СПИСКА ОТЗЫВОВ НА КОНКРЕТНОГО СОТРУДНИКА
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
        DBMS_OUTPUT.PUT_LINE('Ошибка: Поле не может быть пустым.');
        RETURN;
    END IF;
    IF NOT REGEXP_LIKE(p_employeeName, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Имя должно содержать только буквы.');
        RETURN;
    END IF;

    IF NOT REGEXP_LIKE(p_employeeSurname, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Фамилия должна содержать только буквы.');
        RETURN;
    END IF;

    -- Поиск сотрудника по имени и фамилии
    SELECT employeeID INTO v_employeeID
    FROM EMPLOYEES
    WHERE UPPER(name) = UPPER(TRIM(p_employeeName))
      AND UPPER(surname) = UPPER(TRIM(p_employeeSurname));

    -- Проверка существования сотрудника
    IF v_employeeID IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error: Сотрудник ' || p_employeeName || ' ' || p_employeeSurname || ' не найден.');
        RETURN;
    END IF;

    -- Получение отзывов для сотрудника
   FOR review_rec IN (SELECT *
                   FROM REVIEWS
                   WHERE employeeID = v_employeeID) LOOP
    DBMS_OUTPUT.PUT_LINE('ID отзыва: ' || review_rec.reviewID || ', Имя: ' || p_employeeName || ', Фамилия: ' || p_employeeSurname ||
                         ', Рейтинг: ' || review_rec.rating || ', Отзыв: ' || review_rec.comm);
END LOOP;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Нет отзывов для сотрудника ' || p_employeeName || ' ' || p_employeeSurname);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка получения отзывов для сотрудника ' || p_employeeName || ' ' || p_employeeSurname || ': ' || SQLERRM);
END;
-------------------------------------------------------------------------

--ЗАПИСЬ НА УСЛУГУ
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
        DBMS_OUTPUT.PUT_LINE('Ошибка: Поле не может быть пустым.');
        RETURN;
    END IF;
      -- Проверка на корректность входящих данных
    IF NOT IsEmailValid(p_clientEmail) THEN
        DBMS_OUTPUT.PUT_LINE('Error: Некорректный email.');
        RETURN;
    END IF;
    IF NOT IsEmailValid(p_employeeEmail) THEN
        DBMS_OUTPUT.PUT_LINE('Error: Некорректный email.');
        RETURN;
    END IF;
    -- Проверка существования пользователя
    SELECT clientID INTO v_clientID
    FROM CLIENTS
    WHERE EMAIL = p_clientEmail;

    IF v_clientID IS NULL THEN
        sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Пользователь с именем ' || p_clientEmail || ' не найден.');
        RETURN;
    END IF;
    -- Проверка существования сотрудника
    SELECT employeeID INTO v_employeeID
    FROM EMPLOYEES
    WHERE EMAIL = p_employeeEmail;

    IF v_employeeID IS NULL THEN
        sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Сотрудник с именем ' || p_employeeEmail || ' не найден.');
        RETURN;
    END IF;

     -- Проверка наличия других регистраций у мастера в указанный период времени
    SELECT COUNT(*)
    INTO v_ExistingRegistration
    FROM REGISTRATION
    WHERE EMPLOYEEID = v_employeeID
      AND dateTime BETWEEN p_dateTime - INTERVAL '2' HOUR AND p_dateTime + INTERVAL '2' HOUR;

    IF v_ExistingRegistration > 0 THEN
        sys.DBMS_OUTPUT.PUT_LINE('Ошибка: У сотрудника уже есть другие регистрации в указанный период времени.');
        RETURN;
    END IF;

     -- Проверка на невозможность регистрации в прошлом
    IF p_dateTime < SYSTIMESTAMP THEN
        sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Регистрация в прошлом времени невозможна.');
        RETURN;
    END IF;

    INSERT INTO REGISTRATION (CLIENTID, EMPLOYEEID, DATETIME, NOTES)
    VALUES (v_clientID, v_employeeID, p_dateTime, TRIM(p_Notes));

    COMMIT;
    sys.DBMS_OUTPUT.PUT_LINE('Регистрация успешно добавлена.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        sys.DBMS_OUTPUT.PUT_LINE('Ошибка при добавлении регистрации: ' || SQLERRM);
        RAISE;
END;
------------------------------------------

--УДАЛЕНИЕ ЗАПИСИ НА УСЛУГУ
CREATE OR REPLACE PROCEDURE DeleteRegistration(
    p_registrationID IN REGISTRATION.registrationID%TYPE
)
IS
BEGIN
    -- Проверка на null и пустую строку для p_registrationID
    IF p_registrationID IS NULL OR LENGTH(TRIM(p_registrationID)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: ID записи не может быть пустым.');
        RETURN;
    END IF;

    -- Удаление записи
    DELETE FROM REGISTRATION WHERE registrationID = p_registrationID;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Запись с ID ' || p_registrationID || ' не найдена.');
        ROLLBACK;
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Запись успешно удалена.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка удаления записи: ' || SQLERRM);
        RAISE;
END;
---------------------------------------------

--ПОЛУЧЕНИЕ ИНФОРМАЦИИ О ЗАПИСИ КЛИЕНТА
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
        DBMS_OUTPUT.PUT_LINE('ID записи: ' || reg_rec.registrationID ||
                             ', Клиент: ' || reg_rec.client_name || ' ' || reg_rec.client_surname ||
                             ', Сотрудник: ' || reg_rec.employee_name || ' ' || reg_rec.employee_surname ||
                             ', Услуга: ' || reg_rec.service_name ||
                             ', Дата и время: ' || TO_CHAR(reg_rec.dateTime, 'YYYY-MM-DD HH24:MI:SS') ||
                             ', Примечания: ' || reg_rec.notes);
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка получения информации о записи: ' || SQLERRM);
END;
-----------------------------------------------------------------------------------

--ПРОЦЕДУРА ДЛЯ ПОЛУЧЕНИЯ СПИСКА КЛИЕНТОВ
CREATE OR REPLACE PROCEDURE GetClientList
IS
BEGIN
    FOR client_rec IN (SELECT * FROM CLIENTS) LOOP
        DBMS_OUTPUT.PUT_LINE('ID клиента: ' || client_rec.clientID ||
                             ', Имя: ' || client_rec.name ||
                             ', Фамилия: ' || client_rec.surname ||
                             ', Телефон: ' || client_rec.phone ||
                             ', Email: ' || client_rec.email);
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка получения списка клиентов: ' || SQLERRM);
END;
-------------------------------------------------------------

--Процедура для анализа количества проведенных услуг по периодам
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
        sys.DBMS_OUTPUT.PUT_LINE('Количество проведенных услуг: ' || service_record.serviceCount);
    END LOOP;
END;

-------------------------------------------------

--Процедура для выявления популярных услуг
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
        DBMS_OUTPUT.PUT_LINE('Услуга: ' || service_rec.ServiceName || ', Общее количество записей: ' || service_rec.TotalRegistrations);
    END LOOP;
END;
------------------------------------------------------------------------

--ПРОЦЕДУРА ДЛЯ РЕГИСТРАЦИИ ПОЛЬЗОВАТЕЛЯ И ДОБАВЛЕНИЯ ЕГО В ТАБЛИЦУ КЛИЕНТОВ
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
        DBMS_OUTPUT.PUT_LINE('Ошибка: Поле не может быть пустым.');
        RETURN;
    END IF;

    IF NOT REGEXP_LIKE(p_name, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Имя пользователя должно содержать только буквы.');
        RETURN;
    END IF;

    IF NOT REGEXP_LIKE(p_surname, '^[[:alpha:]]+$') THEN
        sys.DBMS_OUTPUT.PUT_LINE('Ошибка: Фамилия пользователя должна содержать только буквы.');
        RETURN;
    END IF;

    -- Проверка на корректность входящих данных
    IF NOT IsEmailValid(p_email) THEN
        DBMS_OUTPUT.PUT_LINE('Error: Некорректный email.');
        RETURN;
    END IF;

    -- Проверка на существование пароля
    SELECT COUNT(*) INTO v_PasswordExists FROM CLIENTS WHERE PASSWORD = p_password;

    IF v_PasswordExists > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Пароль уже существует. Выберите другой пароль.');
        RETURN;
    END IF;

    -- Попытка найти пользователя с указанным email
    BEGIN
        SELECT CLIENTID INTO v_ClientID FROM CLIENTS WHERE EMAIL = p_email;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_ClientID := NULL; -- Если запись не найдена, устанавливаем переменную в NULL
    END;

    -- Если пользователь с таким email уже существует, выдать сообщение об ошибке
    IF v_ClientID IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error: Пользователь с таким email уже существует.');
    ELSE
        -- Добавление нового пользователя в таблицу CLIENTS
        BEGIN
            INSERT INTO CLIENTS (name, surname, phone, email, password)
            VALUES (p_name, p_surname, p_phone, p_email, p_password);
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Пользователь зарегистрирован успешно.');
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('Error: Пользователь с таким email уже существует.');
        END;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка регистрации пользователя: ' || SQLERRM);
        RAISE;
END RegisterClient;
----------------------------------------------

--ПРОЦЕДУРА ОБНОВЛЕНИЯ КЛИЕНТА
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
    -- Проверка на null и пустую строку для p_clientID
    IF p_clientID IS NULL OR LENGTH(TRIM(p_clientID)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: ID клиента не может быть пустым.');
        RETURN;
    END IF;

    -- Проверка на null и пустую строку для остальных полей
    IF p_name IS NULL OR LENGTH(TRIM(p_name)) = 0 or
        p_surname IS NULL OR LENGTH(TRIM(p_surname)) = 0 or
        p_phone IS NULL OR LENGTH(TRIM(p_phone)) = 0 or
        p_email IS NULL OR LENGTH(TRIM(p_email)) = 0 or
        p_password IS NULL OR LENGTH(TRIM(p_password)) = 0 then
        DBMS_OUTPUT.PUT_LINE('Ошибка: Поле не может быть пустым.');
        RETURN;
    END IF;

    -- Проверка на корректность входящих данных
    IF NOT IsEmailValid(p_email) THEN
        DBMS_OUTPUT.PUT_LINE('Error: некорректный email.');
        RETURN;
    END IF;

  -- Проверка существования клиента
    SELECT COUNT(*) INTO v_client_exists
    FROM CLIENTS
    WHERE clientID = p_clientID;

    IF v_client_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Клиент с ID ' || p_clientID || ' не найден.');
        RETURN;
    END IF;
    -- Обновление данных клиента
    UPDATE CLIENTS
    SET name = TRIM(p_name),
        surname = TRIM(p_surname),
        phone = TRIM(p_phone),
        email = TRIM(p_email),
        password = TRIM(p_password)
    WHERE clientID = p_clientID;

    -- Обновление связанных записей в таблице REGISTRATION
    UPDATE REGISTRATION
    SET clientID = p_clientID
    WHERE clientID = p_clientID;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Клиент изменен успешно.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка изменения клиента: ' || SQLERRM);
        RAISE;
END;
------------------------------------------

--ПРОЦЕДУРА УДАЛЕНИЯ КЛИЕНТА
CREATE OR REPLACE PROCEDURE DeleteClient(
    p_clientID IN CLIENTS.clientID%TYPE
)
IS
BEGIN
    -- Проверка на null и пустую строку для p_clientID
    IF p_clientID IS NULL OR LENGTH(TRIM(p_clientID)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: ID клиента не может быть пустым.');
        RETURN;
    END IF;

    -- Удаление клиента и связанных записей
    DELETE FROM CLIENTS WHERE clientID = p_clientID;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Клиент с ID ' || p_clientID || ' не найден.');
        ROLLBACK;
    ELSE
        -- Удаление связанных записей в таблице REGISTRATION
        DELETE FROM REGISTRATION WHERE clientID = p_clientID;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Клиент и связанные записи успешно удалены.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка удаления клиента: ' || SQLERRM);
        RAISE;
END;
-------------------------------------------------

--ПРОЦЕДУРА АВТОРИЗАЦИИ КЛИЕНТА
CREATE OR REPLACE PROCEDURE ClientLogin(
    p_email IN CLIENTS.email%TYPE,
    p_password IN CLIENTS.password%TYPE
)
IS
    v_clientID CLIENTS.clientID%TYPE;
BEGIN
    -- Проверка на пустые поля
    IF p_email IS NULL OR LENGTH(TRIM(p_email)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: Email не может быть пустым.');
        RETURN;
    END IF;

    IF p_password IS NULL OR LENGTH(TRIM(p_password)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: Пароль не может быть пустым.');
        RETURN;
    END IF;
        -- Проверка на корректность входящих данных
    IF NOT IsEmailValid(p_email) THEN
        DBMS_OUTPUT.PUT_LINE('Error: Некорректный email.');
        RETURN;
    END IF;


    -- Поиск клиента по email и паролю
    SELECT clientID INTO v_clientID
    FROM CLIENTS
    WHERE email = p_email AND password = p_password;

    -- Проверка, найден ли клиент
    IF v_clientID IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Клиент с email ' || p_email || ' успешно авторизован. ID: ' || v_clientID);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Ошибка: Неверный email или пароль.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: Клиент с email ' || p_email || ' не найден. Проверьте email и пароль');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка авторизации клиента: ' || SQLERRM);
END;
------------------------------------------------

--ПОЛУЧЕНИЕ ИНФОРМАЦИИ О КЛИЕНТЕ
CREATE OR REPLACE PROCEDURE GetClientInfoByID(
    p_clientID IN CLIENTS.clientID%TYPE
)
IS
    v_name CLIENTS.name%TYPE;
    v_surname CLIENTS.surname%TYPE;
    v_phone CLIENTS.phone%TYPE;
    v_email CLIENTS.email%TYPE;
BEGIN
    -- Проверка на null и пустую строку для p_clientID
    IF p_clientID IS NULL OR LENGTH(TRIM(p_clientID)) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: ID клиента не может быть пустым.');
        RETURN;
    END IF;

    -- Поиск информации о клиенте по ID
    SELECT name, surname, phone, email
    INTO v_name, v_surname, v_phone, v_email
    FROM CLIENTS
    WHERE clientID = p_clientID;

    -- Проверка, найден ли клиент
    IF v_name IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Информация о клиенте с ID ' || p_clientID || ':');
        DBMS_OUTPUT.PUT_LINE('Имя: ' || v_name);
        DBMS_OUTPUT.PUT_LINE('Фамилия: ' || v_surname);
        DBMS_OUTPUT.PUT_LINE('Телефон: ' || v_phone);
        DBMS_OUTPUT.PUT_LINE('Email: ' || v_email);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Ошибка: Клиент с ID ' || p_clientID || ' не найден.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: Клиент с ID ' || p_clientID || ' не найден.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка получения информации о клиенте: ' || SQLERRM);
END;

