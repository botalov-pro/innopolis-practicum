/* Удаление созданной базы данных SALES (если существует) */
DROP DATABASE IF EXISTS sales;

/* Создание базы данных SALES */
CREATE DATABASE sales;

/* Проверяем, что создалась наша база данных */
SELECT datname FROM pg_database
WHERE datname='sales';

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

