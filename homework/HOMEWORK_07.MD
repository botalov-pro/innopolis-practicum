# ЗАДАНИЕ 7

Исполнитель: Боталов Константин Владимирович

* [Ссылка на настоящий файл](https://github.com/botalov-pro/innopolis-practicum/blob/main/homework/HOMEWORK_07.MD)
* [Ссылка на финальный SQL-файл](https://github.com/botalov-pro/innopolis-practicum/blob/main/homework/sql/homework_07.sql)


## Постановка задания

1. Подгружаем в БД файл [HW_task_7.sql](https://github.com/botalov-pro/innopolis-practicum/blob/main/homework/src/HW_task_7.sql).
2. Найти среднюю зарплату всех кто родился после 01.01.1990
3. Найти средний возраст (по полным годам) всех по отделам с указанием наименований отделов
4. Найти суммарную годовую зарплату по каждому отделу и итого по компании
5. Найти количество сотрудников во всех возможных комбинациях отдел – должность
6. Для каждой должности соберите имена сотрудников как массив
7. Создайте итоги по отделу и должности по средней зарплате (ROLLUP используем)
8. (усложненное необязательное) Найдите в одном запросе отдел, где моложе всего сотрудники в среднем, и посчитайте для него среднюю заработную плату, то есть должно быть три столбца - имя отдела, средний возраст там, средняя зарплата там

## Выполнение задания

### Задача 1.

Найти среднюю зарплату всех кто родился после 01.01.1990

```postgresql
/* Задача 1.
   Найти среднюю зарплату всех кто родился после 01.01.1990
*/
SELECT AVG(salary) AS avg_salary
FROM workers
WHERE birthday > '1990-01-01';
```

![](img/img_32.png)

**Результат:** средняя зарплата всех, кто родился после 01.01.1990 г., составляет **60900**.

### Задача 2.

Найти средний возраст (по полным годам) всех по отделам с указанием наименований отделов.

```postgresql
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
    departments AS d ON w.dept_id = d.d_id -- Соединяем таблицы workers и departments по ключу dept_id
GROUP BY
    d.name_dept; -- Группируем данные по названиям отделов
```

![](img/img_33.png)

**Результат:** вычислили средний возраст сотрудиков по отделам. Самый "молодой" отдел - Administraton (средний возраст 29,5 лет). Самый "старый" отдел - IT (средний возраст 43 года).

### Задача 3.

Найти суммарную годовую зарплату по каждому отделу и итого по компании

```postgresql
/* Задача 3.
    Найти суммарную годовую зарплату по каждому отделу и итого по компании
*/
SELECT d.name_dept AS department,
       SUM(w.salary) * 12 AS total_annual_salary  -- Вычисляем общую зарплату по отделу в месяц и год (12 месяцев)
FROM workers w
JOIN departments d ON w.dept_id = d.d_id
GROUP BY ROLLUP (d.name_dept);  -- Группируем по отделам и выводим информацию по всей компании (ROLLUP)
```

![](img/img_34.png)

**Результат:** вычислили суммарную годовую зарплату по каждому отделу. Самый "дорогой" отдел - Accounting (**2 615 000** в год). Самый "экономный" отдел - Administration (**1 452 000** в год). Годовой бюджет компании на заработную плату составляет **10 116 000**. 

### Задача 4.

Найти количество сотрудников во всех возможных комбинациях отдел - должность.

```postgresql
/* Задача 4.
   Найти количество сотрудников во всех возможных комбинациях отдел - должность.

   Вариант 1. Без использования оператора CUBE
*/
SELECT
    d.name_dept AS department,
    j.name_job AS job,
    COUNT(w.w_id) AS employee_count
FROM
    departments d
CROSS JOIN
    jobs j
LEFT JOIN
    workers w ON d.d_id = w.dept_id AND j.j_id = w.job_id
GROUP BY
    d.name_dept, j.name_job
ORDER BY
    d.name_dept, j.name_job;
```

![](img/img_35.png)

**Результат:** вычислили количество сотрудников во всех возможных комбинациях "отдел - должность" без использования оператора CUBE.

```postgresql
/* Задача 4.
   Найти количество сотрудников во всех возможных комбинациях отдел - должность.

   Вариант 2. С использованием оператора CUBE
*/
SELECT
    d.name_dept AS department,
    j.name_job AS job,
    COUNT(w.w_id) AS employee_count
FROM
    workers AS w
JOIN
    departments AS d ON w.dept_id = d.d_id
JOIN
    jobs AS j ON w.job_id = j.j_id
GROUP BY
    CUBE (d.name_dept, j.name_job)
ORDER BY
    d.name_dept, j.name_job;
```

![](img/img_36.png)

**Результат:** вычислили количество сотрудников во всех возможных комбинациях "отдел - должность" с использованием оператора CUBE.

```postgresql
/* Задача 4.
   Найти количество сотрудников во всех возможных комбинациях отдел - должность.

   Вариант 3. С использованием оператора ROLLUP.
*/

SELECT
    d.name_dept AS department,
    j.name_job AS job,
    COUNT(w.w_id) AS employee_count
FROM
    workers AS w
JOIN
    departments AS d ON w.dept_id = d.d_id
JOIN
    jobs AS j ON w.job_id = j.j_id
GROUP BY
    ROLLUP(d.name_dept, j.name_job)
ORDER BY
    d.name_dept, j.name_job;
```

![](img/img_37.png)

**Результат:** вычислили количество сотрудников во всех возможных комбинациях "отдел - должность" с использованием оператора ROLLUP.

### Задача 5.

Для каждой должности соберите имена сотрудников как массив.

```postgresql
/* Задача 5.
   Для каждой должности соберите имена сотрудников как массив.
*/
SELECT
    j.name_job AS job,
    ARRAY_AGG(w.name_worker) AS workers_names
FROM
    workers AS w
JOIN
    jobs AS j ON w.job_id = j.j_id
GROUP BY
    j.name_job
ORDER BY
    j.name_job;
```

![](img/img_38.png)

**Результат:** собрали для каждой должности имена сотрудников как массив с использованием функции **ARRAY_AGG**.