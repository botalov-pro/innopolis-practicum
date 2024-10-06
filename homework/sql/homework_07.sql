/* Удаление созданной базы данных INNOPOLIS */
DROP DATABASE IF EXISTS innopolis;

/* Создание базы данных INNOPOLIS */
CREATE DATABASE innopolis;

/* Удаление созданной таблицы JOBS */
DROP TABLE IF EXISTS jobs;

/* Создание таблицы JOBS */
CREATE TABLE jobs (
    j_id SERIAL PRIMARY KEY,
	name_job VARCHAR(45)
                  );

/* Добавление данных в таблицу JOBS */
INSERT INTO jobs (name_job)
VALUES ('специалист'), ('помощник'), ('начальник');

/* Удаление созданной таблицы DEPARTMENTS */
DROP TABLE IF EXISTS departments;

/* Создание таблицы DEPARTMENTS */
CREATE TABLE departments (
    d_id SERIAL PRIMARY KEY,
	name_dept VARCHAR(45)
                         );

/* Добавление данных в таблицу DEPARTMENTS */
INSERT INTO departments (name_dept)
	VALUES  ('Sales'),
			('IT'),
			('Marketing'),
			('Accounting'),
			('Administration');

/* Удаление созданной таблицы WORKERS */
DROP TABLE IF EXISTS workers;

/* Создание таблицы WORKERS */
CREATE TABLE workers (
    w_id INT PRIMARY KEY,
	name_worker VARCHAR(45),
	dept_id INT REFERENCES departments,
	job_id INT REFERENCES jobs,
	salary INT,
	birthday DATE
                     );

/* Добавление данных в таблицу WORKERS */
INSERT INTO workers (w_id, name_worker, dept_id, job_id,salary,birthday)
	VALUES  (100, 'AndreyEx', 1,1, 50000,'1990-01-02'),
			(200, 'Boris', 2,3, 55000,'1980-01-02'),
			(300, 'Anna', 2,2, 70000,'1970-05-05'),
			(400, 'Anton', 3,1, 95000,'1995-06-06'),
			(500, 'Dima', 2,2, 60000,'1992-12-07'),
			(600, 'Трофим', 3,2, 60000,'1983-04-22'),
			(501, 'Maxs', 4, 1,35000,'2000-02-19'),
			(700, 'Helen', 4,3, 65000,'1990-09-25'),
			(800, 'Igor', 5,1, 56000,'1996-08-04'),
			(900, 'Лука', 5,3, 65000,'1992-12-07'),
			(1100, 'Федор', 1,2, 49000,'1983-04-22'),
			(1200, 'Влад', 1, 3,65000,'2000-02-19'),
			(1300, 'Михась', 4,2, 62000,'1990-09-25'),
			(1400, 'Лавр', 4,2, 56000,'1996-08-04');

/* Задача 1.
   Найти среднюю зарплату всех кто родился после 01.01.1990
*/
SELECT AVG(salary) AS avg_salary
FROM workers
WHERE birthday > '1990-01-01';

/* Задача 2.
   Найти средний возраст (по полным годам) всех по отделам с указанием наименований отделов.
*/
SELECT
    d.name_dept,
    AVG(    -- Вычисляем средний возраст сотрудников
            -- Вычисляем возраст всех сотрудников (на текущую дату) и извлекаем количество полных лет
            EXTRACT(YEAR FROM age(w.birthday))
    ) AS average_age -- Записываем возраст в полных годах для каждого работника в отдельный столбец
FROM
    workers AS w
JOIN
    departments AS d ON w.dept_id = d.d_id      -- Соединяем таблицы workers и departments по ключу dept_id
GROUP BY
    d.name_dept;                                -- Группируем данные по названиям отделов

/* Задача 3.
    Найти суммарную годовую зарплату по каждому отделу и итого по компании
*/
SELECT d.name_dept AS department,
       SUM(w.salary) * 12 AS total_annual_salary  -- Вычисляем общую зарплату по отделу в месяц и год (12 месяцев)
FROM workers w
JOIN departments d ON w.dept_id = d.d_id
GROUP BY ROLLUP (d.name_dept);  -- Группируем по отделам и выводим информацию по всей компании (ROLLUP)


-- найти количество сотрудников во всех возможных комбинациях отдел - должность


-- для каждой должности соберите имена сотрудников как массив


-- создайте итоги по отделу и должности по средней зарплате (ROLLUP используем)



-- найдите в одном запросе отдел, где моложе всего сотрудники в среднем,
-- и посчитайте для него среднюю заработную плату
-- то есть должно быть три столбца - имя отдела, средний возраст там, средняя зарплата там





