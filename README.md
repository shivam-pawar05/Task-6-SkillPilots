# Employee Audit Trigger System

A beginner-friendly MySQL/MariaDB project that records every `INSERT`, `UPDATE`, and `DELETE` performed on the `employees` table into an `employee_audit` table using database triggers.

## Requirements
- VS Code
- MySQL 8+ or MariaDB (XAMPP includes MariaDB)
- phpMyAdmin or MySQL command line (optional but recommended)

## Project files
- `schema.sql` — creates the database, tables, and three triggers.
- `test_queries.sql` — sample DML operations and queries to verify the audit trail.
- `audit_demo.html` — optional static project overview page; no server needed to preview it.

## Run using XAMPP + phpMyAdmin
1. Install/open XAMPP and start **MySQL**.
2. Open `http://localhost/phpmyadmin`.
3. Choose the **Import** tab, select `schema.sql`, and click **Import/Go**.
   - If your phpMyAdmin does not allow importing a `.sql` file containing `CREATE DATABASE`, open the SQL tab and run the contents of `schema.sql` in sections, or remove the first two lines and select/create `employee_audit_db` first.
4. Open the SQL tab and run the statements in `test_queries.sql` one at a time.
5. Run `SELECT * FROM employee_audit ORDER BY audit_id DESC;` to see the log.

## Run in VS Code with MySQL CLI
Open the VS Code terminal and run:
```bash
mysql -u root -p < schema.sql
```
If your local root account has no password, press Enter when prompted. Adjust username/password to match your setup.

Then run:
```bash
mysql -u root -p employee_audit_db < test_queries.sql
```

## Important note about the audit user
The triggers use `COALESCE(@audit_user, USER())`. To label an action with an application username during a SQL session, set:
```sql
SET @audit_user = 'demo_user';
```
If it is not set, the database connection user is recorded. Set this variable in the same connection before performing DML.

## What is logged?
- Operation type: `INSERT`, `UPDATE`, or `DELETE`
- Employee ID
- Database/application user
- Timestamp
- Old row values (for UPDATE/DELETE)
- New row values (for INSERT/UPDATE)

## Quick verification
After an insert, `new_values` is populated.
After an update, both `old_values` and `new_values` are populated.
After a delete, `old_values` is populated.

## Troubleshooting
- **`DELIMITER` error in a SQL editor:** `DELIMITER` is a client command. Run the complete file using phpMyAdmin's Import feature or the MySQL CLI, not by selecting only a trigger body in a query box.
- **Duplicate email:** The `email` field is unique. Change the email before rerunning the demo insert.
- **Table already exists:** The tables use `IF NOT EXISTS`, but triggers are dropped and recreated. Do not repeatedly run the demo inserts unless you change their emails.
- **JSON type issue on older MariaDB:** If your version does not support `JSON_OBJECT`, upgrade to a supported MySQL/MariaDB version or adapt the audit columns to `LONGTEXT`.

## Security limitation
This is an educational audit trail, not tamper-proof compliance logging. A database administrator with sufficient privileges may alter or delete audit records.
