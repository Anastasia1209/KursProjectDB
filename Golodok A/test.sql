CREATE OR REPLACE PROCEDURE EnableDbmsOutput
IS
BEGIN
    sys.DBMS_OUTPUT.ENABLE(1000000);
END EnableDbmsOutput;



CREATE OR REPLACE PROCEDURE RegisterClientTEST
is
    v_name CLIENTS.name%TYPE;
    v_surname CLIENTS.surname%TYPE;
    v_phone CLIENTS.phone%TYPE;
    v_email CLIENTS.email%TYPE;
    v_password CLIENTS.email%TYPE;

         v_count NUMBER := 100000;

BEGIN
    for i in 1..v_count loop
        --генерация чисел
        v_name := 'Имя';
        v_surname := 'Фамилия';
        v_phone := 'Номер' || i;
        v_email := 'Email' || i || '@example.com' ;--
        v_password := 'Пароль' || i;

    GOL_PDB_A.REGISTERCLIENT(
        p_Name => v_Name,
        p_surname => v_surname,
        p_phone => v_phone,
        p_email => v_email,
        p_password => v_password
        );
  end loop;
    end;
begin
    RegisterClientTEST();
end;

select count (*) from CLIENTS;
select * from CLIENTS;