USE employee_audit_db;

-- Use a label for the current connection/session.
SET @audit_user = 'skillpilot_demo';

-- 1. INSERT: should create an INSERT audit row with new_values.
INSERT INTO employees (employee_name, department, salary, email)
VALUES ('Rohan Deshmukh', 'Engineering', 52000.00, 'rohan.demo@example.com');

SET @demo_employee_id = LAST_INSERT_ID();

-- 2. UPDATE: should capture both old_values and new_values.
UPDATE employees
SET salary = 56000.00, department = 'Platform Engineering'
WHERE employee_id = @demo_employee_id;

-- 3. DELETE: should capture old_values.
DELETE FROM employees
WHERE employee_id = @demo_employee_id;

-- 4. Inspect audit records.
SELECT audit_id, operation, employee_id, changed_by, changed_at, old_values, new_values
FROM employee_audit
ORDER BY audit_id DESC;

-- Optional: inspect employees still present.
SELECT * FROM employees ORDER BY employee_id;
