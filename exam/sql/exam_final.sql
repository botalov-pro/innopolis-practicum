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

/* Вывод таблицы с количеством уникальных значений по каждому столбцу */
DO $$
DECLARE
  cols TEXT;  -- Переменная для хранения агрегированного списка

BEGIN

    /*
        Очищаем (удаляем) временную таблицу counter
        перед ее заполнением
     */
    DROP TABLE IF EXISTS temp_counter;

    cols := string_agg(  -- объединяем строки в одну строку с разделителем (запятая)
                    'COUNT(DISTINCT ' || column_name::TEXT || ') '  || column_name::TEXT, ','
            )
    FROM (
        /*  Подзапрос для получения всех имен колонок из таблицы SALES_IMPORT */
        SELECT column_name
            FROM information_schema.columns
            WHERE
                table_name = 'sales_import'
            ) AS c;

    /*
       Создаем временную таблицу,
       где в качестве столбцов будут строки
       из переменной COLS (названия столбцов)
     */
    EXECUTE format(
            'CREATE TEMP TABLE temp_counter AS SELECT %s FROM sales_import;',
            cols
            );

END $$;

SELECT * FROM temp_counter;  -- Вывод данных из временной таблицы

/*
    Подсчет количества NULL-значений по каждому столбцу
*/
DO $$
DECLARE
  cols TEXT;  -- Переменная для хранения агрегированного списка

BEGIN

    -- Удаляем временную таблицу, если она существует
    DROP TABLE IF EXISTS temp_counter;

    cols := string_agg(  -- Объединяем строки в одну строку с разделителем (запятая)

                    /* Получаем разницу между общим количеством записей и ненулевыми значениями */
                    'COUNT(*) - COUNT(' || column_name::TEXT || ') AS ' || column_name::TEXT, ','
            )
    FROM (
        /* Подзапрос для получения всех имен колонок из таблицы sales_import */
        SELECT column_name
            FROM information_schema.columns
            WHERE
                table_name = 'sales_import'
            ) AS c;

    -- Создаем временную таблицу,
    -- где в качестве столбцов будут строки из переменной COLS (названия столбцов с подсчетом NULL)
    EXECUTE format(
            'CREATE TEMP TABLE temp_counter AS SELECT %s FROM sales_import;',
            cols
            );

END $$;

SELECT * FROM temp_counter;  -- Вывод данных из временной таблицы

/*
    Очистка null-значений
*/
UPDATE sales_import
SET
    total_sales = COALESCE(total_sales, 0),
    na_sales = COALESCE(na_sales, 0),
    jp_sales = COALESCE(jp_sales, 0),
    pal_sales = COALESCE(pal_sales, 0),
    other_sales = COALESCE(other_sales, 0),
    critic_score = COALESCE(critic_score, 0),
    release_date = COALESCE(release_date, '1900-01-01'),
    last_update = COALESCE(last_update, '1900-01-01'),
    developer = COALESCE(developer, '--UNKNOWN--');

/*
    Определение длины полей для текстовых значений:
    Максимальная длина поля * 1.5
*/
SELECT
    ROUND(MAX(LENGTH(title)) * 1.5) AS max_title_length,
	ROUND(MAX(LENGTH(img)) * 1.5) AS max_img_length,
	ROUND(MAX(LENGTH(console)) * 1.5) AS max_console_length,
    ROUND(MAX(LENGTH(genre)) * 1.5) AS max_genre_length,
    ROUND(MAX(LENGTH(publisher)) * 1.5) AS max_publisher_length,
    ROUND(MAX(LENGTH(developer)) * 1.5) AS max_developer_length
FROM sales_import;

/* Удаление таблиц справочников */
DROP TABLE IF EXISTS consoles;  -- Удаление таблицы сущности 'consoles' (Консоли)
DROP TABLE IF EXISTS genres;  -- Удаление таблицы сущности 'genres' (Жанры)
DROP TABLE IF EXISTS publishers;  -- Удаление таблицы сущности 'publishers' (Издатели)
DROP TABLE IF EXISTS developers;  -- Удаление таблицы сущности 'developers' (Разработчики)

/* Создание таблицы для сущности 'consoles' (Консоли) */
CREATE TABLE consoles (
    id SMALLSERIAL PRIMARY KEY,     -- Уникальный идентификатор консоли
    name VARCHAR(255) NOT NULL      -- Название консоли
);

/* Создание таблицы для сущности 'genres' (Жанры) */
CREATE TABLE genres (
    id SMALLSERIAL PRIMARY KEY,     -- Уникальный идентификатор жанра
    name VARCHAR(255) NOT NULL      -- Название жанра
);

/* Создание таблицы для сущности 'publishers' (Издатели) */
CREATE TABLE publishers (
    id SMALLSERIAL PRIMARY KEY,     -- Уникальный идентификатор издателя
    name VARCHAR(255) NOT NULL      -- Название издателя
);

/* Создание таблицы для сущности 'developers' (Разработчики) */
CREATE TABLE developers (
    id SMALLSERIAL PRIMARY KEY,     -- Уникальный идентификатор разработчика
    name VARCHAR(255) NOT NULL      -- Название разработчика
);

/*
    Заполнение таблицы-справочника 'consoles' (Консоли)
    и проверка заполнения таблицы
*/
INSERT INTO consoles(name)
    SELECT DISTINCT console
    FROM sales_import;

SELECT * FROM consoles;

/*
    Заполнение таблицы-справочника 'genres' (Жанры)
    и проверка заполнения таблицы
*/
INSERT INTO genres(name)
    SELECT DISTINCT genre
    FROM sales_import;

SELECT * FROM genres;

/*
    Заполнение таблицы-справочника 'publishers' (Издатели)
    и проверка заполнения таблицы
*/
INSERT INTO publishers(name)
    SELECT DISTINCT publisher
    FROM sales_import;

SELECT * FROM publishers;

/*
    Заполнение таблицы-справочника 'developers' (Разработчики)
    и проверка заполнения таблицы
*/
INSERT INTO developers(name)
    SELECT DISTINCT developer
    FROM sales_import;

SELECT * FROM developers;

/* Удаление таблицы для сущности 'games' (Игры) */
DROP TABLE IF EXISTS games;

/* Создание таблицы для сущности 'games' (Игры) */
CREATE TABLE games (
    id SERIAL PRIMARY KEY,                                  -- Уникальный идентификатор игры
    title VARCHAR(255) NOT NULL,                            -- Название игры
    img VARCHAR(255) DEFAULT NULL,                          -- Обложка игры
    console_id INT NOT NULL REFERENCES consoles(id),        -- Идентификатор консоли (FK)
    genre_id INT NOT NULL REFERENCES genres(id),            -- Идентификатор жанра (FK)
    publisher_id INT NOT NULL REFERENCES publishers(id),    -- Идентификатор издателя (FK)
    developer_id INT NOT NULL REFERENCES developers(id),    -- Идентификатор разработчика (FK)
    release_date DATE DEFAULT '1900-01-01',                 -- Дата выхода игры                                                       |
    critic_score DECIMAL(4, 2) DEFAULT 0,                   -- Оценка критиков (например, 8.75)
    total_sales DECIMAL(10, 2) DEFAULT 0,                   -- Количество продаж во всем мире (в миллионах экземпляров)
    na_sales DECIMAL(10, 2) DEFAULT 0,                      -- Количество продаж в Северной Америке (в миллионах экземпляров)
    jp_sales DECIMAL(10, 2) DEFAULT 0,                      -- Количество продаж в Японии (в миллионах экземпляров)
    pal_sales DECIMAL(10, 2) DEFAULT 0,                     -- Количество продаж в странах PAL (в миллионах экземпляров)
    other_sales DECIMAL(10, 2) DEFAULT 0,                   -- Количество продаж в других регионах (в миллионах экземпляров)
    last_update DATE DEFAULT '1900-01-01'                   -- Дата последнего обновления данных
);

/*
    Заполнение и проверка заполнения таблицы 'games' (Игры)
*/
INSERT INTO games (
                   title,
                   img,
                   console_id,
                   genre_id,
                   publisher_id,
                   developer_id,
                   release_date,
                   critic_score,
                   total_sales,
                   na_sales,
                   jp_sales,
                   pal_sales,
                   other_sales,
                   last_update)
SELECT
    title,
    img,
    (SELECT id FROM consoles WHERE name = console) AS console_id,
    (SELECT id FROM genres WHERE name = genre) AS genre_id,
    (SELECT id FROM publishers WHERE name = publisher) AS publisher_id,
    (SELECT id FROM developers WHERE name = developer) AS developer_id,
    TO_DATE(release_date, 'YYYY-MM-DD'),
    critic_score,
    total_sales,
    na_sales,
    jp_sales,
    pal_sales,
    other_sales,
    TO_DATE(last_update, 'YYYY-MM-DD')
FROM sales_import;

SELECT * FROM games;

/* Строим словарь данных базы данных SALES */
SELECT
    c.relname as "Таблица",     -- Название таблицы
    a.attnum as "№ п/п",        -- Номер столбца в таблице
    a.attname as "Поле",        -- Название столбца
    pt.typname as "Тип",        -- Тип данных для столбца
    CASE                        -- Определяем размер поля
        WHEN a.atttypmod = -1
            THEN NULL
        ELSE a.atttypmod
    END "Размер",
    a.attnotnull as "NULL",     -- Допускаются ли NULL-значения в поле
    CASE                        -- Является ли поле первичным ключом (PK)
        WHEN a.attnum IN(
        SELECT UNNEST(cn.conkey)
        FROM
            pg_catalog.pg_constraint cn
        WHERE
            cn.conrelid = a.attrelid
          AND cn.contype LIKE 'p')
            THEN 'PK'
    END as "Ключ"
FROM
  pg_catalog.pg_attribute a  -- Информация об атрибутах (полях) таблиц
  JOIN pg_catalog.pg_type pt ON a.atttypid = pt.oid  -- Информация о типах данных
  JOIN pg_catalog.pg_class c ON a.attrelid = c.oid  -- Информация о таблицах
  JOIN pg_catalog.pg_namespace n ON c.relnamespace = n.oid  -- Информация о схемах
  LEFT JOIN pg_catalog.pg_description ad ON ad.objoid = a.attrelid  -- Комментарии к объектам
  AND ad.objsubid = a.attnum
WHERE
  a.attnum > 0  -- Убираем системные поля (нумерация атрибутов начинается с 1)
  AND n.nspname = 'public'  -- Ограничиваем выборку только таблицами из схемы public
  and c.reltype <> 0  -- Убираем не-пользовательские объекты из выборки
ORDER BY
  c.relname,  -- Сортируем результат по названию таблицы...
  a.attnum;   -- ... и по номеру атрибута

/*
    Запрос на поиск значимых игр,
    которые total_sales => 0.5 и critic_score > 0
 */
SELECT id, title, total_sales, critic_score
	FROM games
	WHERE
		total_sales >= 0.5
		AND
		critic_score > 0
	ORDER BY
		total_sales ASC,
		critic_score ASC;

/*
    Удаление малозначимых игр,
    у которых total_sales < 0.5 и critic_score <= 0
 */
DELETE FROM games
WHERE
    total_sales < 0.5 OR
    critic_score <= 0;

/*
    Вычисление качества набора данных
    Сколько процентов записей от первоначального количества (64016) осталось
*/
SELECT
    ROUND((COUNT(title)::DECIMAL / 64016) * 100, 2) || '%' AS quality_db
FROM
    games;

/*
    Распределение глобальных продаж игр по времени
*/
SELECT
    EXTRACT(YEAR FROM release_date) AS year,
    SUM(total_sales) AS total_sales
    FROM
        games
    GROUP BY
        year
    ORDER BY
        year ASC;

/*
    Создание представления (view) "ТОП-100 игр" по количеству продаж
*/
DROP VIEW IF EXISTS top_100_games_by_sales;  -- Удаление представления (если существует)

CREATE VIEW top_100_games_by_sales AS  -- Создание представление
SELECT
	g.title,
	c.name AS console,
	j.name AS genre,
	p.name AS publisher,
	d.name AS developer,
	SUM(g.total_sales) AS total_sales,
	EXTRACT(YEAR FROM g.release_date) AS release_year
FROM games g
JOIN consoles c ON g.console_id = c.id
JOIN genres j ON g.genre_id = j.id
JOIN publishers p ON g.publisher_id = p.id
JOIN developers d ON g.developer_id = d.id
WHERE g.release_date >= NOW() - INTERVAL '20 years'
GROUP BY g.title, c.name, j.name, p.name, d.name, g.release_date
ORDER BY total_sales DESC
LIMIT 100;

SELECT * FROM top_100_games_by_sales;  -- Отображение представления

/*
    Создание представления (view) "ТОП-100 игр" по количеству оценок критиков (среднее значение)
*/

DROP VIEW IF EXISTS top_100_games_by_critics;  -- Удаление представления (если существует)

CREATE VIEW top_100_games_by_critics AS  -- Создание представление
SELECT
	g.title,
	c.name AS console,
	j.name AS genre,
	p.name AS publisher,
	d.name AS developer,
	ROUND(AVG(g.critic_score), 2) AS total_sales,
	EXTRACT(YEAR FROM g.release_date) AS release_year
FROM games g
JOIN consoles c ON g.console_id = c.id
JOIN genres j ON g.genre_id = j.id
JOIN publishers p ON g.publisher_id = p.id
JOIN developers d ON g.developer_id = d.id
WHERE g.release_date >= NOW() - INTERVAL '20 years'
GROUP BY g.title, c.name, j.name, p.name, d.name, g.release_date
ORDER BY critic_score DESC
LIMIT 100;

SELECT * FROM top_100_games_by_critics;  -- Отображение представления





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
