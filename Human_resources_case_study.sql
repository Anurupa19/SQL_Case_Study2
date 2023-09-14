-- Create 'departments' table
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    manager_id INT
);

-- Create 'employees' table
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    hire_date DATE,
    job_title VARCHAR(50),
    department_id INT REFERENCES departments(id)
);

-- Create 'projects' table
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    start_date DATE,
    end_date DATE,
    department_id INT REFERENCES departments(id)
);

-- Insert data into 'departments'
INSERT INTO departments (name, manager_id)
VALUES ('HR', 1), ('IT', 2), ('Sales', 3);

-- Insert data into 'employees'
INSERT INTO employees (name, hire_date, job_title, department_id)
VALUES ('John Doe', '2018-06-20', 'HR Manager', 1),
       ('Jane Smith', '2019-07-15', 'IT Manager', 2),
       ('Alice Johnson', '2020-01-10', 'Sales Manager', 3),
       ('Bob Miller', '2021-04-30', 'HR Associate', 1),
       ('Charlie Brown', '2022-10-01', 'IT Associate', 2),
       ('Dave Davis', '2023-03-15', 'Sales Associate', 3);

-- Insert data into 'projects'
INSERT INTO projects (name, start_date, end_date, department_id)
VALUES ('HR Project 1', '2023-01-01', '2023-06-30', 1),
       ('IT Project 1', '2023-02-01', '2023-07-31', 2),
       ('Sales Project 1', '2023-03-01', '2023-08-31', 3);
       
       UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name = 'John Doe')
WHERE name = 'HR';

UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name = 'Jane Smith')
WHERE name = 'IT';

UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name = 'Alice Johnson')
WHERE name = 'Sales';

select * from employees;
select * from departments;
select * from projects;

-- 1. Find the longest ongoing project for each department.
select d.name as department_name,
p.name as project_name,
timestampdiff(day, p.start_date, p.end_date) as duration
from projects p join departments d
on p.department_id=d.id
order by timestampdiff(day, p.start_date, p.end_date) desc
limit 1;

-- 2. Find all employees who are not managers.
select * from employees
where job_title not like '%Manager';

-- 3. Find all employees who have been hired after the start of a project in their department.
select e.name as employee_name
from employees e join projects p
on e.department_id=p.department_id
where e.hire_date>p.start_date;

-- 4. Rank employees within each department based on their hire date (earliest hire gets the highest rank).
select department_id, name, hire_date, 
rank() over(partition by department_id order by hire_date) as emp_rank
from employees;

-- 5. Find the duration between the hire date of each employee and the hire date of the next employee hired in the same department.
with new_hire_date as
(select department_id, name, hire_date as prev_hire_date,
lag(hire_date) over(partition by department_id) as curr_hire_date
from employees)
select department_id, datediff(prev_hire_date, curr_hire_date) as diff_days
from new_hire_date
where datediff(prev_hire_date, curr_hire_date) is not null
order by datediff(prev_hire_date, curr_hire_date) desc;

