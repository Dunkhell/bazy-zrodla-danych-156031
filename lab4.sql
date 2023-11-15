-- zad 3.1
CREATE OR REPLACE PACKAGE ALL_FUNCTIONS AS
    FUNCTION get_job_name(job_id IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION calculate_annual_salary(employee_id IN NUMBER) RETURN NUMBER;
    FUNCTION extract_area_code(phone_number IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION capitalize_first_last(input_str IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION get_employee_department_count(country_name IN VARCHAR2,
                                           v_department_count OUT NUMBER) RETURN NUMBER;
end ALL_FUNCTIONS;

CREATE OR REPLACE PACKAGE BODY ALL_FUNCTIONS AS
-- zad 1.1
CREATE OR REPLACE FUNCTION get_job_name(search_job_id IN VARCHAR2) RETURN VARCHAR2 IS
    v_job_name VARCHAR2(50);
BEGIN
    SELECT job_title
    INTO v_job_name
    FROM JOBS
    WHERE job_id = get_job_name.search_job_id;

    IF v_job_name IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Praca o podanym ID nie istnieje.');
    END IF;

    RETURN v_job_name;
END get_job_name;

-- zad 1.2

CREATE OR REPLACE FUNCTION calculate_annual_salary(employee_id IN NUMBER) RETURN NUMBER IS
    v_annual_salary  NUMBER;
    v_monthly_salary NUMBER;
    v_commission_pct NUMBER;
BEGIN
    SELECT SALARY, COMMISSION_PCT
    INTO v_monthly_salary, v_commission_pct
    FROM employees
    WHERE EMPLOYEE_ID = calculate_annual_salary.employee_id;
    if v_commission_pct IS NULL THEN
        v_annual_salary := v_monthly_salary * 12;
    ELSE
        v_annual_salary := v_monthly_salary * 12 + (v_monthly_salary * v_commission_pct);
    end if;

    IF v_monthly_salary IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Pracownik o podanym ID nie istnieje.');
    END IF;


    RETURN v_annual_salary;
END calculate_annual_salary;

-- zad 1.3
CREATE OR REPLACE FUNCTION extract_area_code(phone_number IN VARCHAR2) RETURN VARCHAR2 IS
    v_area_code VARCHAR2(10);
BEGIN
    v_area_code := SUBSTR(phone_number, 1, INSTR(phone_number, '-') - 1);

    RETURN v_area_code;
END extract_area_code;

-- zad 1.4
CREATE OR REPLACE FUNCTION capitalize_first_last(input_str IN VARCHAR2) RETURN VARCHAR2 IS
    v_result_str VARCHAR2(100);
BEGIN
    v_result_str := INITCAP(SUBSTR(input_str, 1, 1));

    v_result_str := v_result_str || LOWER(SUBSTR(input_str, 2, LENGTH(input_str) - 2));

    v_result_str := v_result_str || INITCAP(SUBSTR(input_str, LENGTH(input_str)));

    RETURN v_result_str;
END capitalize_first_last;

-- zad 1.6
CREATE OR REPLACE FUNCTION get_employee_department_count(country_name IN VARCHAR2,
                                                         v_department_count OUT NUMBER) RETURN NUMBER IS
    v_employee_count NUMBER;
BEGIN
    SELECT COUNT(DISTINCT e.employee_id), COUNT(DISTINCT d.DEPARTMENT_ID)
    INTO v_employee_count, v_department_count
    FROM employees e
             LEFT JOIN departments d ON e.department_id = d.department_id
             LEFT JOIN locations l ON d.location_id = l.location_id
    WHERE l.COUNTRY_ID =
          (SELECT COUNTRY_ID FROM COUNTRIES c WHERE c.COUNTRY_NAME = get_employee_department_count.country_name);

    IF v_employee_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Brak danych dla podanego kraju.');
    END IF;

    RETURN v_employee_count;
END get_employee_department_count;
END ALL_FUNCTIONS;


-- zad 1.1
DECLARE
    v_job_name VARCHAR2(50);
BEGIN
    v_job_name := get_job_name('AD_VP');
    DBMS_OUTPUT.PUT_LINE('Nazwa pracy: ' || v_job_name);
END;

-- zad 1.2
DECLARE
    v_annual_salary NUMBER;
BEGIN
    --v_annual_salary := calculate_annual_salary(145);
    v_annual_salary := calculate_annual_salary(102);
    DBMS_OUTPUT.PUT_LINE('Roczne zarobki: ' || v_annual_salary);
END;

-- zad 1.3
DECLARE
    v_area_code VARCHAR2(10);
BEGIN
    v_area_code := extract_area_code('123-456789');
    DBMS_OUTPUT.PUT_LINE('Numer kierunkowy: ' || v_area_code);
END;

-- zad 1.4
DECLARE
    v_result_str VARCHAR2(100);
BEGIN
    v_result_str := capitalize_first_last('testInput'); -- Przykładowy ciąg znaków
    DBMS_OUTPUT.PUT_LINE('Wynik: ' || v_result_str);
END;

-- zad 1.5
-- TODO

-- zad 1.6
DECLARE
    v_employee_count   NUMBER;
    v_department_count NUMBER;
BEGIN
    v_employee_count := get_employee_department_count('United Kingdom', v_department_count);
    DBMS_OUTPUT.PUT_LINE('Liczba pracowników: ' || v_employee_count);
    DBMS_OUTPUT.PUT_LINE('Liczba departamentów: ' || v_department_count);
END;


-- zad 2.1
CREATE TABLE archiwum_departamentow
(
    id              NUMBER,
    nazwa           VARCHAR(50),
    data_zamkniecia DATE,
    ostatni_manager NUMBER
);

CREATE OR REPLACE TRIGGER archive_department
    AFTER DELETE
    ON DEPARTMENTS
    FOR EACH ROW
BEGIN
    INSERT INTO archiwum_departamentow
    VALUES (:OLD.DEPARTMENT_ID, :OLD.DEPARTMENT_NAME, CURRENT_DATE, :OLD.MANAGER_ID);
end;

INSERT INTO DEPARTMENTS
VALUES (1234, 'Test_usuwania', 100, 1000);
SELECT *
FROM DEPARTMENTS
WHERE department_id = 1234;
SELECT *
FROM archiwum_departamentow;
DELETE
FROM DEPARTMENTS
WHERE department_id = 1234;
SELECT *
FROM archiwum_departamentow;


-- zad 2.2
CREATE TABLE ZLODZIEJE
(
    user_id NUMBER,
    data    DATE
);

CREATE OR REPLACE TRIGGER sprawdzanie_zarobkow
    BEFORE INSERT OR UPDATE OF salary
    ON EMPLOYEES
    FOR EACH ROW
BEGIN
    IF :NEW.salary < 2000 OR :NEW.salary > 26000 THEN
        INSERT INTO ZLODZIEJE (user_id, data)
        VALUES (:OLD.EMPLOYEE_ID, SYSDATE);

        RAISE_APPLICATION_ERROR(-20202, 'Zarobki muszą być w przedziale 2000 - 26000');
    END IF;
END;

UPDATE EMPLOYEES
SET SALARY = 200000
WHERE EMPLOYEE_ID = 103;
SELECT *
FROM ZLODZIEJE;


-- zad 2.3
CREATE SEQUENCE employee_seq
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE;

CREATE OR REPLACE TRIGGER auto_increment_trigger
    BEFORE INSERT
    ON employees
    FOR EACH ROW
BEGIN
    SELECT employee_seq.NEXTVAL
    INTO :new.employee_id
    FROM dual;
end;

INSERT INTO EMPLOYEES (FIRST_NAME, LAST_NAME, EMAIL, JOB_ID, HIRE_DATE)
VALUES ('test', 'adamczyk', 'email@person.com', 'AD_PRES', CURRENT_DATE);
SELECT *
FROM EMPLOYEES
where FIRST_NAME = 'test';

-- zad 2.4
CREATE OR REPLACE TRIGGER blokada_JOD_GRADES_DELETE
    BEFORE DELETE
    ON JOB_GRADES
BEGIN
    RAISE_APPLICATION_ERROR(-20202, 'Operacje DELETE na tabeli JOD_GRADES są zabronione');
end;

DELETE
FROM JOB_GRADES
WHERE GRADE = 'A';

-- zad 2.5
CREATE OR REPLACE TRIGGER zachowaj_stare_wartosci_salary_jobs
    BEFORE UPDATE
    ON jobs
    FOR EACH ROW
BEGIN
    :NEW.min_salary := :OLD.min_salary;
    :NEW.max_salary := :OLD.max_salary;
end;

UPDATE JOBS
SET MAX_SALARY = 20000
WHERE JOB_ID = 'AC_ACCOUNT';
SELECT *
FROM JOBS
WHERE JOB_ID = 'AC_ACCOUNT';

-- zad 3.2
CREATE OR REPLACE PACKAGE region_package AS
    PROCEDURE create_region(p_region_id NUMBER, p_region_name VARCHAR2);
    PROCEDURE update_region(p_region_id NUMBER, p_region_name VARCHAR2);
    PROCEDURE delete_region(p_region_id NUMBER);
    FUNCTION get_region_by_id(p_region_id NUMBER) RETURN VARCHAR2;
    FUNCTION get_all_regions RETURN SYS_REFCURSOR;
END region_package;

CREATE OR REPLACE PACKAGE BODY region_package AS
    PROCEDURE create_region(p_region_id NUMBER, p_region_name VARCHAR2) IS
    BEGIN
        INSERT INTO REGIONS (REGION_ID, REGION_NAME) VALUES (p_region_id, p_region_name);
    END create_region;

    PROCEDURE update_region(p_region_id NUMBER, p_region_name VARCHAR2) IS
    BEGIN
        UPDATE REGIONS SET REGION_NAME = p_region_name WHERE REGION_ID = p_region_id;
    END update_region;

    PROCEDURE delete_region(p_region_id NUMBER) IS
    BEGIN
        DELETE FROM REGIONS WHERE REGION_ID = p_region_id;
    END delete_region;

    FUNCTION get_region_by_id(p_region_id NUMBER) RETURN VARCHAR2 IS
        v_region_name VARCHAR2(25);
    BEGIN
        SELECT REGION_NAME INTO v_region_name FROM REGIONS WHERE REGION_ID = p_region_id;
        RETURN v_region_name;
    END get_region_by_id;

    FUNCTION get_all_regions RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR SELECT * FROM REGIONS;
        RETURN v_cursor;
    END get_all_regions;
END region_package;

BEGIN
    region_package.create_region(261, 'Asia');
    region_package.create_region(262, 'North America');
    COMMIT;
END;

BEGIN
    region_package.update_region(261, 'European Union');
    COMMIT;
END;

DECLARE
    v_region_name VARCHAR2(25);
BEGIN
    v_region_name := region_package.get_region_by_id(261);
    DBMS_OUTPUT.PUT_LINE('Region Name: ' || v_region_name);
END;

DECLARE
    v_cursor SYS_REFCURSOR;
    v_region_id NUMBER;
    v_region_name VARCHAR2(25);
BEGIN
    v_cursor := region_package.get_all_regions;
    LOOP
        FETCH v_cursor INTO v_region_id, v_region_name;
        EXIT WHEN v_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Region ID: ' || v_region_id || ', Region Name: ' || v_region_name);
    END LOOP;
    CLOSE v_cursor;
END;

BEGIN
    region_package.delete_region(262);
    COMMIT;
END;
