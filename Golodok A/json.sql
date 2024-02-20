CREATE OR REPLACE DIRECTORY UTL_DIR AS 'C:\json';
GRANT READ, WRITE ON DIRECTORY UTL_DIR TO public;

CREATE OR REPLACE PROCEDURE ExportToJSON
IS
    v_file sys.UTL_FILE.FILE_TYPE;
    v_row SERVICES%ROWTYPE;
BEGIN
    v_file := sys.UTL_FILE.FOPEN('UTL_DIR','BEAUTY_SALON_SERVICES.json','W');
    sys.UTL_FILE.PUT_LINE(v_file, '[');
    FOR v_row in (select JSON_OBJECT(
        'serviceID' is serviceID,
        'name' is CAST(name as nvarchar2(100)),
        'description' is CAST(description as nvarchar2(255)),
        'price' is CAST(price as decimal(10,2)),
        'image' is CAST(image as nvarchar2(255))
    ) AS JSON_DATA from SERVICES)

    LOOP
        sys.UTL_FILE.PUT_LINE(v_file ,v_row.JSON_DATA || ',');
    END LOOP;
    sys.UTL_FILE.PUT_LINE(v_file, ']');
    sys.UTL_FILE.FCLOSE(v_file);
    EXCEPTION
        WHEN OTHERS THEN
            sys.DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
    RAISE;
END;

-- execute

BEGIN
    ExportToJSON();
END;

-- create import from json

CREATE OR REPLACE PROCEDURE ImportFromJSON
IS
BEGIN
    FOR json_rec IN (
        SELECT serviceID, name, description, price, image
        FROM JSON_TABLE(BFILENAME('UTL_DIR', 'BEAUTY_SALON_SERVICES.json'), '$[*]' COLUMNS (
            serviceID number PATH '$.serviceID',
            name varchar2(20) PATH '$.name',
            description varchar2(20) PATH '$.description',
            price varchar2(100) PATH '$.price',
            image varchar2(30) PATH '$.image'
        ))
    )
    LOOP
        BEGIN
            INSERT INTO SERVICES (serviceID, name, description, price, image)
            VALUES (json_rec.serviceID, json_rec.name, json_rec.description, json_rec.price, json_rec.image);
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                ROLLBACK;
                sys.DBMS_OUTPUT.PUT_LINE('Service with the id already exists.');
            WHEN OTHERS THEN
                ROLLBACK;
                sys.DBMS_OUTPUT.PUT_LINE('Error inserting service: ' || SQLERRM);
                RAISE;
        END;
    END LOOP;
END;

-- execute

BEGIN
    ImportFromJSON();
END;