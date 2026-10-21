-- Employee Audit Trigger Project (MySQL / MariaDB)
CREATE DATABASE IF NOT EXISTS employee_audit_db;
USE employee_audit_db;

CREATE TABLE IF NOT EXISTS employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department VARCHAR(80) NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    email VARCHAR(150) UNIQUE
);

CREATE TABLE IF NOT EXISTS employee_audit (
    audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    operation ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    employee_id INT NULL,
    changed_by VARCHAR(100) NOT NULL,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    old_values JSON NULL,
    new_values JSON NULL
);

DROP TRIGGER IF EXISTS employees_after_insert;
DROP TRIGGER IF EXISTS employees_after_update;
DROP TRIGGER IF EXISTS employees_after_delete;

DELIMITER $$

CREATE TRIGGER employees_after_insert
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_audit
      (operation, employee_id, changed_by, old_values, new_values)
    VALUES
      ('INSERT', NEW.employee_id, COALESCE(@audit_user, USER()),
       NULL,
       JSON_OBJECT('employee_id', NEW.employee_id,
                   'employee_name', NEW.employee_name,
                   'department', NEW.department,
                   'salary', NEW.salary,
                   'email', NEW.email));
END$$

CREATE TRIGGER employees_after_update
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_audit
      (operation, employee_id, changed_by, old_values, new_values)
    VALUES
      ('UPDATE', NEW.employee_id, COALESCE(@audit_user, USER()),
       JSON_OBJECT('employee_id', OLD.employee_id,
                   'employee_name', OLD.employee_name,
                   'department', OLD.department,
                   'salary', OLD.salary,
                   'email', OLD.email),
       JSON_OBJECT('employee_id', NEW.employee_id,
                   'employee_name', NEW.employee_name,
                   'department', NEW.department,
                   'salary', NEW.salary,
                   'email', NEW.email));
END$$

CREATE TRIGGER employees_after_delete
AFTER DELETE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_audit
      (operation, employee_id, changed_by, old_values, new_values)
    VALUES
      ('DELETE', OLD.employee_id, COALESCE(@audit_user, USER()),
       JSON_OBJECT('employee_id', OLD.employee_id,
                   'employee_name', OLD.employee_name,
                   'department', OLD.department,
                   'salary', OLD.salary,
                   'email', OLD.email),
       NULL);
END$$

DELIMITER ;

-- Optional demo rows (run once; skip if already present)
INSERT INTO employees (employee_name, department, salary, email)
VALUES
('Aarav Sharma', 'IT', 45000.00, 'aarav@example.com'),
('Meera Patil', 'HR', 38000.00, 'meera@example.com');
