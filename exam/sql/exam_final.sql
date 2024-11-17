/* Удаление созданной базы данных SALES (если ранее такая база данных существовала) */
DROP DATABASE IF EXISTS sales;

/* Создание чистой базы данных SALES */
CREATE DATABASE sales;

/* Проверяем, что создалась база данных SALES */
SELECT datname FROM pg_database
WHERE datname='sales';

/* Проверка количества импортированных данных в таблицу SALES_IMPORT */
SELECT COUNT(*) AS IMPORT_COUNT
    FROM sales_import;

/*
    Проверка качественного переноса импортированных данных в таблицу SALES_IMPORT.
    Вывод 10 случайных строк таблицы
*/
SELECT *
    FROM sales_import
    ORDER BY
        RANDOM()  -- Запускаем механизм случайности...
    LIMIT 10;  -- ...и извлекаем 10 случайных строк.


/*
    Приведение типов
    Создаем временный столбец для хранения преобразованных данных
 */
ALTER TABLE innopolis ADD COLUMN release_date_new DATE;

/*
    Перенос данных
    Скопируем данные из старого столбца в новый, преобразуя данные с помощью функции TO_DATE
 */
UPDATE innopolis
SET release_date_new = TO_DATE(release_date, 'YYYY-MM-DD')
WHERE release_date IS NOT NULL;

/*
    Удаление старого столбца
    Удаляем старый столбец
 */
ALTER TABLE innopolis DROP COLUMN release_date;

/*
    Переименование нового столбца
    Переименуем временный столбец в исходное имя
 */
ALTER TABLE innopolis RENAME COLUMN release_date_new TO release_date;

-------

/*
    Приведение типов
    Создаем временный столбец для хранения преобразованных данных
 */
ALTER TABLE innopolis ADD COLUMN total_sales_new FLOAT;

/*
    Перенос данных
    Скопируем данные из старого столбца в новый, преобразуя данные с помощью функции TO_DATE
 */
UPDATE innopolis
SET total_sales_new = total_sales
WHERE total_sales IS NOT NULL;

/*
    Удаление старого столбца
    Удаляем старый столбец
 */
ALTER TABLE innopolis DROP COLUMN total_sales;

/*
    Переименование нового столбца
    Переименуем временный столбец в исходное имя
 */
ALTER TABLE innopolis RENAME COLUMN total_sales_new TO total_sales;

ALTER TABLE innopolis
ALTER COLUMN total_sales
SET DATA TYPE float;


-------


/*
 Поиск самого длинного названия игры
 */
SELECT title, LENGTH(title)
FROM innopolis
ORDER BY LENGTH(title) DESC
LIMIT 10;

/*
 Поиск часто встречающихся слов в играх
 */
WITH word_list AS (
    SELECT
        unnest(string_to_array(lower(title), ' ')) AS word
    FROM
        innopolis
)

SELECT
    word,
    COUNT(*) AS occurrences
FROM
    word_list
WHERE
    word <> ''  -- Исключаем пустые слова
    AND
    LENGTH(word) > 3
GROUP BY
    word
ORDER BY
    occurrences DESC
LIMIT 10;  -- Ограничиваем выборку наиболее частыми словами (например, 10)

/* Анализ временных данных */

/* ABC-анализ */
WITH revenue AS (
    SELECT
        title,
        SUM(total_sales) AS total_revenue
    FROM
        innopolis
    GROUP BY
        title
),
ranked_revenue AS (
    SELECT
        title,
        total_revenue,
        SUM(total_revenue) OVER () AS grand_total,
        SUM(total_revenue) OVER (ORDER BY total_revenue DESC) AS cumulative_revenue
    FROM
        revenue
),
abc_analysis AS (
    SELECT
        title,
        total_revenue,
        cumulative_revenue,
        grand_total,
        ROUND(cumulative_revenue / grand_total * 100, 2) AS cumulative_percentage
    FROM
        ranked_revenue
)

SELECT
    title,
    total_revenue,
    cumulative_percentage,
    CASE
        WHEN cumulative_percentage <= 80 THEN 'A'
        WHEN cumulative_percentage <= 95 THEN 'B'
        ELSE 'C'
    END AS category
FROM
    abc_analysis
ORDER BY
    cumulative_percentage;

SELECT version();
