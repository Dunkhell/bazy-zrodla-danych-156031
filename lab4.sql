-- zad 1.1
CREATE OR REPLACE FUNCTION get_job_name(job_id IN VARCHAR2) RETURN VARCHAR2 IS
    v_job_name VARCHAR2(50);
BEGIN
    SELECT job_title
    INTO v_job_name
    FROM JOBS
    WHERE job_id = get_job_name.job_id;

    IF v_job_name IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Praca o podanym ID nie istnieje.');
    END IF;

    RETURN v_job_name;
END;

DECLARE
    v_job_name VARCHAR2(50);
BEGIN
    v_job_name := get_job_name('AD_VP');
    DBMS_OUTPUT.PUT_LINE('Nazwa pracy: ' || v_job_name);
END;
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
END;

DECLARE
    v_annual_salary NUMBER;
BEGIN
    --v_annual_salary := calculate_annual_salary(145);
    v_annual_salary := calculate_annual_salary(102);
    DBMS_OUTPUT.PUT_LINE('Roczne zarobki: ' || v_annual_salary);
END;

-- zad 1.3
CREATE OR REPLACE FUNCTION extract_area_code(phone_number IN VARCHAR2) RETURN VARCHAR2 IS
    v_area_code VARCHAR2(10);
BEGIN
    v_area_code := SUBSTR(phone_number, 1, INSTR(phone_number, '-') - 1);

    RETURN v_area_code;
END;

DECLARE
    v_area_code VARCHAR2(10);
BEGIN
    v_area_code := extract_area_code('123-456789');
    DBMS_OUTPUT.PUT_LINE('Numer kierunkowy: ' || v_area_code);
END;

-- zad 1.4
CREATE OR REPLACE FUNCTION capitalize_first_last(input_str IN VARCHAR2) RETURN VARCHAR2 IS
    v_result_str VARCHAR2(100);
BEGIN
    v_result_str := INITCAP(SUBSTR(input_str, 1, 1));

    v_result_str := v_result_str || LOWER(SUBSTR(input_str, 2, LENGTH(input_str) - 2));

    v_result_str := v_result_str || INITCAP(SUBSTR(input_str, LENGTH(input_str)));

    RETURN v_result_str;
END;


DECLARE
    v_result_str VARCHAR2(100);
BEGIN
    v_result_str := capitalize_first_last('testInput'); -- Przykładowy ciąg znaków
    DBMS_OUTPUT.PUT_LINE('Wynik: ' || v_result_str);
END;

-- zad 1.5
-- TODO

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
END;

DECLARE
    v_employee_count   NUMBER;
    v_department_count NUMBER;
BEGIN
    v_employee_count := get_employee_department_count('United Kingdom', v_department_count);
    DBMS_OUTPUT.PUT_LINE('Liczba pracowników: ' || v_employee_count);
    DBMS_OUTPUT.PUT_LINE('Liczba departamentów: ' || v_department_count);
END;
