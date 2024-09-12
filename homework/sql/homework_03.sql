/* Удаление созданных таблиц */
DROP TABLE IF EXISTS workers;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS jobs;

/* Создание таблицы JOBS */
CREATE TABLE jobs (
    j_id SERIAL PRIMARY KEY,
	name_job VARCHAR(45)
                  );

/* Создание таблицы DEPARTMENTS */
CREATE TABLE departments (
	d_id SERIAL  PRIMARY KEY,
	name_dept VARCHAR(45)
                         );

/* Создание таблицы WORKERS */
CREATE TABLE workers (
    w_id INT PRIMARY KEY,
    name_worker VARCHAR(45),
    dept_id INT REFERENCES departments,
    job_id INT REFERENCES jobs,
    salary INT
                     );

/* Добавление данных в таблицу JOBS */
INSERT INTO jobs (name_job)
    VALUES ('специалист'), ('помощник'), ('начальник');

/* Добавление данных в таблицу DEPARTMENTS */
INSERT INTO departments (name_dept)
	VALUES  ('Sales'),
			('IT'),
			('Marketing'),
			('Accounting'),
			('Administration');

/* Добавление данных в таблицу WORKERS */
INSERT INTO workers (w_id, name_worker, dept_id, job_id,salary)
    VALUES
        (100, 'AndreyEx', 1, 1, 50000),
		(200, 'Boris', 2, 3, 55000),
		(300, 'Anna', 2, 2, 70000),
		(400, 'Anton', 3, 1, 95000),
		(500, 'Dima', 2, 2, 60000),
		(600, 'Трофим', 3, 2, 60000),
		(501, 'Maxs', 4, 1,35000),
		(700, 'Helen', 4, 3, 65000),
		(800, 'Igor', 5, 1, 56000);

/* Задание 1.
   Вывести все отделы с начальниками (используем CTE)
 */

WITH boss_dept AS (                                         -- создаем CTE (временную таблицу)
    SELECT name_dept                                        -- выводим только названия отделов
    FROM workers
    LEFT JOIN departments d on d.d_id = workers.dept_id     -- Получаем в единую временную таблицу //
    LEFT JOIN jobs j on j.j_id = workers.job_id             -- информацию о работниках, их должностях и отделах
    WHERE LOWER(name_job) LIKE 'начальник'                  -- Фильтруем по названию должности 'начальник'
)
SELECT * FROM boss_dept;


/* Задание 2.
   Вывести те должности, которых нет в отделе Accounting (используем вложенный запрос)
 */

-- Вариант решения 1. Через 2 вложенных запроса

SELECT name_job
FROM jobs
WHERE name_job NOT IN (
    SELECT j.name_job
    FROM workers w
    JOIN jobs j ON w.job_id = j.j_id
    WHERE w.dept_id = (
        SELECT d_id
        FROM departments
        WHERE name_dept = 'Accounting'
    )
);

-- Вариант решения 2. Через общую таблицу и 1 вложенный запрос

SELECT name_job
FROM jobs
WHERE name_job NOT IN (
    SELECT name_job                                         -- выводим только названия должностей
    FROM workers
    LEFT JOIN departments d on d.d_id = workers.dept_id     -- Получаем единую таблицу //
    LEFT JOIN jobs j on j.j_id = workers.job_id             -- с информацией о работниках, их должностях и отделах
    WHERE
        name_dept = 'Accounting'
    )
;



/* Задание 3.
   Вывести все отделы без начальников (используем вложенные запросы)
 */

SELECT name_dept
FROM departments d
WHERE d.d_id NOT IN (
    SELECT w.dept_id                                -- подзапрос - выводим id отделов с начальниками
        FROM workers w
        JOIN jobs j ON w.job_id = j.j_id
        WHERE LOWER(j.name_job) LIKE 'начальник'
    )
;


/* Задание 4.
   Вывести всех работников у которых зарплата больше чем у единственного специалиста отдела Sales (используем вложенные запросы)
 */

SELECT name_worker, salary
FROM workers
WHERE salary > (
  SELECT salary
  FROM workers
  WHERE dept_id = (SELECT d_id FROM departments WHERE name_dept = 'Sales')  -- фильтруем по отделу Sales
    AND job_id = (SELECT j_id FROM jobs WHERE name_job = 'специалист')      -- фильтруем по должности 'специалист'
  LIMIT 1                                                                   -- страхуемся, чтобы был единственный сотрудник
);

/* Задание 5.
   Вывести всех работников у которых зарплата больше чем у единственного специалиста отдела Sales (используем CTE)
 */

-- Вариант решения 1. С одним CTE и одним подзапросом.

WITH sales_specialist AS (
  SELECT *
  FROM workers w
  JOIN jobs j ON w.job_id = j.j_id
  JOIN departments d ON w.dept_id = d.d_id
  WHERE d.name_dept = 'Sales' AND j.name_job = 'специалист'
  LIMIT 1
)
SELECT w.name_worker, w.salary
FROM workers w
WHERE w.salary > (SELECT salary FROM sales_specialist)
;

-- Вариант решения 2. С двумя CTE и подзапросом в одном из CTE.

WITH sales_specialist AS (                                      -- выбираем единственного специалиста из отдела Sales и его зарплату
    SELECT w.w_id, w.salary
    FROM workers w
    JOIN jobs j ON w.job_id = j.j_id
    JOIN departments d ON w.dept_id = d.d_id
    WHERE d.name_dept = 'Sales' AND j.name_job = 'специалист'
    LIMIT 1
),
higher_salaries AS (                                            -- выбираем всех специалистов у кого зарплата выше
    SELECT w.name_worker, w.salary
    FROM workers w
    WHERE w.salary > (SELECT salary FROM sales_specialist)
)
SELECT * FROM higher_salaries;                                  -- выводим данные