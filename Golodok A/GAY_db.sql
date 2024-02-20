select * from EMPLOYEES;
select * from CLIENTS;
select * from SERVICES;
select * from REGISTRATION;
select * from REVIEWS;

----------------------------------------
--SET serveroutput ON;
--добавление услуги
BEGIN
    GOL_PDB_A.AddService(
        'Окрашивание',
        'окрашивание разной сложности по одной цене',
        200
    );
END;
-------------------------------------

--обновление услуги по id
BEGIN
    UpdateService(
        1,
        'Маникюр',
        'Все виды сложности',
        150.00
    );
END;
-----------------------------------

--удаление услуги по id
begin
    DELETESERVICE(2);
end;
-----------------------------------

--получение списка услуг с сотрудниками
BEGIN
   GOL_PDB_A.GetServiceList();
END;
---------------------------------------

--получение информации об услуге по имени
BEGIN
    GetServiceInfoByName('маникюр');
END;
--------------------------------------

--добавление сотрудника
BEGIN
    AddEmployee(
        'Ирина',
        'Викторович',
        'мастер маникюра',
        '+144554798746',
        'irina@example.com',
        1
    );
END;
------------------------------------------

--обновление сотрудника по id
BEGIN
    GOL_PDB_A.UpdateEmployee(
        1,
        'Полина',
        'Иванова',
        'мастер педикюра',
        '+375445959897',
        'new_email@example.com',
        2
    );
END;

--удаление сотрудника по id
BEGIN
    DeleteEmployee(2);
END;

------------------------------------

--получение списка сотрдуников с услугами
BEGIN
    GetEmployeeList();
END;
---------------------------------------

--получение информации о сотруднике
BEGIN
    GOL_PDB_A.GetStaffInfo(1);
END;
---------------------------------------

--регистрация и добавление клиента в таблицу
BEGIN
    GOL_PDB_A.RegisterClient(
        'Людмила',
        'Иванович',
        '+375291959897',
        'ivan@example.com',
        'ivan');
END;
------------------------------------------

--обновление клиента
BEGIN
    GOL_PDB_A.UpdateClient(
        1,
        'Анастасия',
        'Голодок',
        '+375291234759',
        'asyagol@example.com',
        'nast');
END;
-------------------------------------------

--удаление клиента
begin
    GOL_PDB_A.DELETECLIENT(1);
end;
--------------------------------------------

--авторизация клиента
begin
    GOL_PDB_A.CLIENTLOGIN('asyagol@example.com', 'nast');
end;
-------------------------------------------

--список клиентов
begin
    GOL_PDB_A.GetClientList();
end;
--------------------------------------

--получение информации о клиенте
begin
    GOL_PDB_A.GETCLIENTINFOBYID(1);
end;

-- процедуры для добавления записи
BEGIN
    AddRegistration(
        'asyagol@example.com',
        'pol.ff@example.com',
        '22-12-2023 12:00:00',
        'Дополнительные заметки'
    );
END;
----------------------------------------

--удаление записи
BEGIN
    DeleteRegistration(1);
END;
----------------------------------------
--получение информации о записи
BEGIN
    GetClientRegistrations(1);
END;
----------------------------------------

--добавление отзыва
BEGIN
    GOL_PDB_A.AddReview(1, 3, 'нормально!');
END;
----------------------------------------

--удаление отзыва
BEGIN
    GOL_PDB_A.DeleteReview(1);
END;
----------------------------------------

--получение среднего рейтинга сотрудника
BEGIN
    GetAverageRatingForEmployee('Полина', 'Глушеня');
END;
----------------------------------------

--получение отзывов сотрудника
BEGIN
    DBMS_OUTPUT.PUT_LINE('Отзывы для сотрудника:' );
    GetReviewsForEmployee('Полина', 'Глушеня');
END;
----------------------------------------

--анализа количества проведенных услуг по периодам
BEGIN
    AnalyzeServicesByPeriod(TO_DATE('2023-12-21', 'YYYY-MM-DD'), TO_DATE('2023-12-31', 'YYYY-MM-DD'));
END;

BEGIN
    AnalyzePopularServices();
END;
-----------------------------------------



