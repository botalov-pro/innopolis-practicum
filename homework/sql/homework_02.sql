/* Создание таблицы SALES */
CREATE TABLE sales                  -- Создание таблицы sales
(
    id SERIAL PRIMARY KEY,          -- Идентификатор продажи
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
