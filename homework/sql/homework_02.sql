/* Создание базы данных INNOPOLIS */
CREATE DATABASE innopolis;

/* Создание таблицы SALES в базе данных */
CREATE TABLE sales                  -- Создание таблицы sales
(
    id SERIAL PRIMARY KEY,          -- Идентификатор продажи (первичный ключ)
    model VARCHAR(50) NOT NULL,     -- Модель телефона
    price DECIMAL(10,2) NOT NULL,   -- Цена телефона
    quantity INTEGER NOT NULL,      -- Количество проданных единиц
    date_of_sale DATE NOT NULL      -- Дата продажи
);

/* Добавление данных в таблицу SALES */
INSERT INTO sales
    (model, price, quantity, date_of_sale)
VALUES
    ('iPhone 12', 799, 5, '2024-08-01'),
    ('Galaxy S21', 699, 3, '2024-08-02'),
    ('Pixel 6', 599, 2, '2024-08-03'),
    ('iPhone 12', 799, 1, '2024-08-04'),
    ('Galaxy S21', 699, 4, '2024-08-05'),
    ('Pixel 6', 599, 3, '2024-08-06'),
    ('iPhone 13', 899, 2, '2024-08-07'),
    ('Galaxy S22', 799, 6, '2024-08-08'),
    ('Pixel 7', 699, 5, '2024-08-09'),
    ('iPhone 13', 899, 3, '2024-08-10')
;

/* 1. Использование оператора CASE
    Напишите SQL-запрос, который будет отображать id, model, price, quantity, и еще один столбец с названием price_category,
    который будет иметь значения:
    "High" для телефонов с ценой выше 800.
    "Medium" для телефонов с ценой между 600 и 800 включительно.
    "Low" для телефонов с ценой ниже 600.
*/
SELECT id, model, price, quantity,
        CASE
            WHEN price > 800 THEN 'High'        -- Выше 800
            WHEN price >= 600 THEN 'Medium'     -- Между 600 и 800
            ELSE 'Low'                          -- Ниже 600
        END AS price_category
    FROM sales
;

/* 2. Использование оператора BETWEEN
   Напишите SQL-запрос, который возвращает все продажи телефонов, которые произошли в первой неделе августа 2024 года (с 1 по 7 августа включительно).
*/
SELECT *
    FROM sales
    WHERE
        date_of_sale BETWEEN '2024-08-01' AND '2024-08-07'
;

/* 3. Использование оператора LIKE
   Напишите SQL-запрос, который возвращает все продажи моделей телефонов, которые начинаются с "iPhone".
*/
SELECT *
    FROM sales
    WHERE
        model LIKE 'iPhone%'
;

/* 4a. Операции с множествами (UNION):
   Напишите два запроса. Один должен возвращать все продажи телефонов с ценой ниже 700, а •другой — все продажи, где было продано более 3 единиц. Затем объедините результаты этих двух запросов с помощью UNION.
*/
SELECT *                -- Все продажи телефонов с ценой ниже 700
    FROM sales
    WHERE
        price < 700
UNION                   -- Объединить с ...
SELECT *                -- Все продажи, где было продано более 3 единиц
    FROM sales
    WHERE
        quantity > 3
;

/* 4b. Операции с множествами (EXCEPT):
   Напишите два запроса. Первый должен возвращать все продажи телефонов модели "Galaxy S21", а •второй — все продажи телефонов с количеством проданных единиц больше 2. Используйте EXCEPT, чтобы найти продажи "Galaxy S21", где количество проданных единиц меньше или равно 2
*/
SELECT *                -- Все продажи телефонов модели "Galaxy S21"
    FROM sales
    WHERE
        model = 'Galaxy S21'
EXCEPT                  -- Объединить c исключением ...
SELECT *                -- Все продажи телефонов с количеством проданных единиц больше 2
    FROM sales
    WHERE
        quantity > 2
;

/* 4c. Операции с множествами (INTERSECT):
   Напишите два запроса. Один должен возвращать все продажи, где было продано более 3 единиц, а другой — все продажи, где цена была ниже 800. Используйте INTERSECT, чтобы найти продажи, удовлетворяющие обоим условиям.
*/
SELECT *                -- Все продажи, где было продано более 3 единиц
    FROM sales
    WHERE
        quantity > 3
INTERSECT               -- Объединить c пересечением ...
SELECT *                -- Все продажи, где цена была ниже 800
    FROM sales
    WHERE
        price < 800
;