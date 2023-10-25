-- zad 1 i 2
DECLARE
    numer_max NUMBER(4);
    loc_id    NUMBER(4) := 3000;
BEGIN
    SELECT D.DEPARTMENT_ID
    INTO numer_max
    FROM DEPARTMENTS D
    ORDER BY DEPARTMENT_ID DESC FETCH NEXT 1 ROWS ONLY;
    dbms_output.put_line(numer_max);

    INSERT INTO DEPARTMENTS (DEPARTMENT_ID, DEPARTMENT_NAME, MANAGER_ID, LOCATION_ID)
    VALUES (numer_max + 10, 'EDUCATION', null, loc_id);

END;


-- zad 3
CREATE TABLE NEW_VALUES
(
    value VARCHAR(20)
);

DECLARE
    i NUMBER := 0;
BEGIN
    DELETE FROM NEW_VALUES;
    LOOP
        IF i = 4 THEN
            i := i + 1;
        ELSIF i = 6 THEN
            i := i + 1;
        END IF;
        INSERT INTO NEW_VALUES VALUES (i);
        i := i + 1;
        EXIT WHEN i >= 10;
    end loop;
END;


-- zad 4
DECLARE
    informacja_kraj countries%ROWTYPE;
BEGIN
    SELECT *
    INTO informacja_kraj
    FROM countries
    WHERE country_id = 'CA';

    DBMS_OUTPUT.PUT_LINE('Nazwa kraju: ' || informacja_kraj.country_name);
    DBMS_OUTPUT.PUT_LINE('Region ID: ' || informacja_kraj.region_id);
END;

-- zad 5 i 6
DECLARE
    TYPE department_table IS TABLE OF departments%ROWTYPE INDEX BY PLS_INTEGER;
    v_departments department_table;
BEGIN
    FOR dept_rec IN (SELECT * FROM departments)
        LOOP
            v_departments(dept_rec.department_id) := dept_rec;
        END LOOP;

    FOR i IN 10..100
        LOOP
            IF MOD(i, 10) != 0 THEN
                CONTINUE;
            END IF;
            IF v_departments.EXISTS(i) THEN
                DBMS_OUTPUT.PUT_LINE('Numer: ' || i || ', Nazwa departamentu: ' || v_departments(i).department_name ||
                                     ', Lokalizacja: ' || v_departments(i).location_id || ', Manager id: ' ||
                                     v_departments(i).manager_id);
            ELSE
                DBMS_OUTPUT.PUT_LINE('Numer: ' || i || ', Brak informacji o departamencie');
            END IF;
        END LOOP;
END;


-- zad 7
DECLARE
    CURSOR dept_50 IS
        SELECT e.LAST_NAME, E.SALARY
        FROM EMPLOYEES e
        WHERE e.DEPARTMENT_ID = 50;
BEGIN
    FOR wiersz IN dept_50
        LOOP
            if wiersz.SALARY >= 3100 THEN
                DBMS_OUTPUT.PUT_LINE(wiersz.LAST_NAME || ', nie dawać podwyżki');
            else
                DBMS_OUTPUT.PUT_LINE(wiersz.LAST_NAME || ', dać podwyzke');
            end if;
        end loop;
end ;

-- zad 8
DECLARE
    CURSOR v_employees_info IS
        SELECT e.FIRST_NAME, e.LAST_NAME, e.SALARY
        FROM EMPLOYEES e
        WHERE e.SALARY BETWEEN 1000 AND 5000 AND e.FIRST_NAME LIKE '%a%'
           OR e.SALARY BETWEEN 5000 AND 20000 AND e.FIRST_NAME LIKE '%b%';
BEGIN
    FOR wiersz IN v_employees_info
        LOOP
            DBMS_OUTPUT.PUT_LINE(wiersz.FIRST_NAME || ', ' || wiersz.LAST_NAME || ': ' || wiersz.SALARY);
        end loop;
end;

-- zad 9

CREATE OR REPLACE PROCEDURE ADD_JOBS(v_job_id JOBS.JOB_ID%TYPE, v_job_title JOBS.JOB_TITLE%TYPE)
AS
BEGIN
    INSERT INTO JOBS (JOB_ID, JOB_TITLE) VALUES (v_job_id, v_job_title);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Nie mozna bylo wykonac procedury');
end;

CALL ADD_JOBS(2137, 'Papiez');
CALL ADD_JOBS('AD_PRES', 'test-failed');


CREATE OR REPLACE PROCEDURE REPLACE_JOB_TITLE(v_job_id JOBS.JOB_ID%TYPE, v_job_title JOBS.JOB_TITLE%TYPE)
AS
BEGIN
    UPDATE JOBS j SET j.JOB_TITLE = v_job_title WHERE j.JOB_ID = v_job_id;
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Nie mozna bylo wykonac procedury');
        return;
    end if;
    COMMIT;

end;

CALL REPLACE_JOB_TITLE(2137, 'Papiesz');
CALL REPLACE_JOB_TITLE(2138, 'Papiesz');


CREATE OR REPLACE PROCEDURE DELETE_JOB(v_job_id JOBS.JOB_ID%TYPE)
AS
BEGIN
    DELETE FROM JOBS j WHERE j.JOB_ID = v_job_id;
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Nie mozna bylo wykonac procedury');
        return;
    end if;
    COMMIT;
end;

CALL DELETE_JOB(2137);
CALL DELETE_JOB(2137);


CREATE OR REPLACE PROCEDURE EMPLOYEE_INFO(v_employee_id EMPLOYEES.EMPLOYEE_ID%TYPE,
                                          nazwisko out EMPLOYEES.LAST_NAME%TYPE, zarobki out EMPLOYEES.SALARY%TYPE)
AS
BEGIN
    SELECT e.LAST_NAME, e.SALARY INTO nazwisko, zarobki FROM EMPLOYEES e WHERE e.EMPLOYEE_ID = v_employee_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak pracownika o podanym ID.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('B³¹d podczas pobierania danych pracownika: ' || SQLERRM);
end;

DECLARE
    v_Zarobki  EMPLOYEES.SALARY%TYPE;
    v_Nazwisko EMPLOYEES.LAST_NAME%TYPE;
BEGIN
    EMPLOYEE_INFO(101, v_Nazwisko, v_Zarobki);
    IF v_Zarobki IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Zarobki pracownika: ' || v_Zarobki);
        DBMS_OUTPUT.PUT_LINE('Nazwisko pracownika: ' || v_Nazwisko);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Brak pracownika o podanym ID lub wyst¹pi³ b³¹d: ' || v_Nazwisko);
    END IF;
END;


CREATE OR REPLACE PROCEDURE ADD_EMPLOYEE(
    v_FIRST_NAME EMPLOYEES.FIRST_NAME%TYPE,
    v_LAST_NAME EMPLOYEES.LAST_NAME%TYPE,
    v_EMAIL EMPLOYEES.EMAIL%TYPE,
    v_PHONE_NUMBER EMPLOYEES.PHONE_NUMBER%TYPE DEFAULT NULL,
    v_SALARY EMPLOYEES.SALARY%TYPE DEFAULT 1000,
    v_COMMISSION_PCT EMPLOYEES.COMMISSION_PCT%TYPE DEFAULT NULL,
    v_JOB_ID EMPLOYEES.JOB_ID%TYPE DEFAULT 'IT_PROG')
AS
    v_EMPLOYEE_ID NUMBER;
BEGIN
    SELECT (MAX(employee_id) + 1) INTO v_EMPLOYEE_ID FROM employees;
    IF v_SALARY > 20000 THEN
        DBMS_OUTPUT.PUT_LINE('Zbyt wysokie zarobki');
        RETURN;
    END IF;
    INSERT INTO EMPLOYEES (EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRE_DATE, SALARY, COMMISSION_PCT,
                           JOB_ID)
    VALUES (v_EMPLOYEE_ID, v_FIRST_NAME, v_LAST_NAME, v_EMAIL, v_PHONE_NUMBER, SYSDATE, v_SALARY, v_COMMISSION_PCT,
            v_JOB_ID);
    COMMIT;
END;


DECLARE
BEGIN
    ADD_EMPLOYEE('Adam', 'Nowak', 'a_nowak@email.com', '111111111', 3000);
    ADD_EMPLOYEE('Jan', 'Prezes', 'j_prezes@email.com', '222222222', 30000);
    ADD_EMPLOYEE('Polski', 'Polak', 'p_polak@email.com', '000000000');
END;
