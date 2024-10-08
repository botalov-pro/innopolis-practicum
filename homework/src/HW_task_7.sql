DROP TABLE IF EXISTS jobs;
CREATE TABLE jobs (j_id SERIAL  PRIMARY KEY, 
					name_job VARCHAR(45));				
INSERT INTO jobs (name_job)	
VALUES  ('специалист'),('помощник'),('начальник');


DROP TABLE IF EXISTS deprartments;
CREATE TABLE departments (
	d_id SERIAL  PRIMARY KEY, 
	name_dept VARCHAR(45)	);
INSERT INTO departments (name_dept)
	VALUES  ('Sales'),
			('IT'),
			('Marketing'),
			('Accounting'),
			('Administration');


DROP TABLE IF EXISTS workers;
CREATE TABLE workers (w_id INT  PRIMARY KEY, 
			name_worker VARCHAR(45), 
			dept_id INT REFERENCES departments, 
			job_id INT REFERENCES jobs,
			salary INT,
			birthday DATE); 
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

-- найти среднюю зарплату всех кто родился после 01.01.1990


-- найти средний возраст (по полным годам) всех по отделам с указанием наименований отделов



-- найти суммарную годовую зарплату по каждому отделу и итого по компании


-- найти количество сотрудников во всех возможных комбинациях отдел - должность


-- для каждой должности соберите имена сотрудников как массив


-- создайте итоги по отделу и должности по средней зарплате (ROLLUP используем)



-- найдите в одном запросе отдел, где моложе всего сотрудники в среднем, 
-- и посчитайте для него среднюю заработную плату
-- то есть должно быть три столбца - имя отдела, средний возраст там, средняя зарплата там





