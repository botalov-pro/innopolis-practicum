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
	ROUND(AVG(g.critic_score), 2) AS critic_score,
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
    Создание материализованного представления по 2 представлениям
*/
-- Удаляем мат. представление, если существует
DROP MATERIALIZED VIEW IF EXISTS top_100_games_join;

-- Создаём мат. представление
CREATE MATERIALIZED VIEW top_100_games_join AS
SELECT
    v1.title,
    v1.console,
	v1.genre,
	v1.publisher,
	v1.developer
FROM
    top_100_games_by_sales v1  -- Представление по количеству продаж
INTERSECT
SELECT
    v2.title,
    v2.console,
	v2.genre,
	v2.publisher,
	v2.developer
FROM
    top_100_games_by_critics v2;  -- Представление по оценкам критиков

-- Вывод мат. представления
SELECT * FROM top_100_games_join;

/*
    Поиск популярной консоли
*/
SELECT
	console,
	COUNT(console) AS console_count
	FROM
		top_100_games_join
	GROUP BY
		console
	ORDER BY console_count DESC;

/*
    Поиск самого успешного издателя
*/
SELECT
	publisher,
	COUNT(publisher) AS publisher_count
	FROM
		top_100_games_join
	GROUP BY
		publisher
	ORDER BY publisher_count DESC;

/*
    Поиск популярного издателя по коэффициенту:
    количество продаж / игра
*/
SELECT
	p.name AS publisher,  -- наименование издателя
	SUM(g.total_sales) AS total_sales,  -- кол-во продаж
	COUNT(g.title) AS games_count,  -- кол-во игр
	ROUND(AVG(g.critic_score), 2) AS critic_score_avg,  -- средняя оценка критиков
	ROUND(SUM(g.total_sales) / COUNT(g.title), 2) AS rate  -- коэффициент ПРОДАЖИ / ИГРЫ
	FROM games g
	JOIN publishers p ON g.publisher_id = p.id
	WHERE
		release_date >= NOW() - INTERVAL '20 years'  -- интервал: 20 лет
	GROUP BY
		p.name
	HAVING
		COUNT(g.title) >= 20 -- не менее 20 игр
	ORDER BY
		rate DESC  -- сортируем по коэффициенту
	LIMIT 10;  -- ТОП-10 издателей

/*
    Поиск популярного жанра игры: ТОП-10
*/
SELECT
	j.name AS genre,
	SUM(g.total_sales) AS total_sales
	FROM games g
	JOIN genres j ON g.genre_id = j.id
	WHERE
		release_date >= NOW() - INTERVAL '20 years'
	GROUP BY
		genre
	ORDER BY
		total_sales DESC
	LIMIT 10;

/*
 Поиск часто встречающихся слов в играх
 */
WITH word_list AS (SELECT unnest(string_to_array(lower(title), ' ')) AS word
                   FROM games)  -- строим массив слов из всех названий игр
SELECT word,
       COUNT(*) AS count
FROM word_list
WHERE word <> '' -- Исключаем пустые слова
  AND LENGTH(word) > 3  -- длина слова: более 3 символов
GROUP BY word
ORDER BY count DESC
LIMIT 10;  -- Ограничиваем выборку наиболее частыми словами (например, 10)

/*
    Выбор рынка игры
*/
SELECT
	SUM(na_sales) AS "North America",
	SUM(jp_sales) AS Japan,
	SUM(pal_sales) AS Europe,
	SUM(other_sales) AS Other
	FROM games;

/*
    Определение наиболее перспективной серии игр:
    извлекаем первые слова из названия и считаем их встречаемость в названии
*/
SELECT
    SUBSTRING(title FROM '^[^ ]+') AS first_word,   -- Извлекаем первое слово из названия
    COUNT(*) AS game_count,                         -- Считаем количество игр
    ARRAY_AGG(title) AS titles                      -- Собираем названия игр в массив
FROM
    top_100_games_join
GROUP BY
    first_word                                      -- Группируем по первому слову
HAVING
    COUNT(*) > 1                                    -- Отбираем группы, где более одной строки
ORDER BY
    game_count DESC, first_word;                    -- Сортируем по встречаемости игр и первому слову

/*
    Проверка количества серий игр
*/
SELECT title, console FROM top_100_games_join ORDER BY title;

/*
    Создание таблицы для отслеживания изменений в таблице GAMES
*/
DROP TABLE IF EXISTS change_log_tbl_games;  -- Удаление таблицы (если существует)

-- Создание таблицы
CREATE TABLE change_log_tbl_games (
    id SERIAL PRIMARY KEY,
    game_id INT REFERENCES games(id) ON DELETE CASCADE,  -- Ссылка на таблицу игр с каскадным удалением

    old_title VARCHAR(255),  -- Название игры
    new_title VARCHAR(255),

    old_console_id INT,  -- Идентификатор консоли (FK)
    new_console_id INT,

    old_genre_id INT,  -- Идентификатор жанра (FK)
    new_genre_id INT,

    old_publisher_id INT,  -- Идентификатор издателя (FK)
    new_publisher_id INT,

    old_developer_id INT,  -- Идентификатор разработчика (FK)
    new_developer_id INT,

    old_img VARCHAR(255),  -- Обложка игры
    new_img VARCHAR(255),

    old_release_date DATE,  -- Дата выхода игры
    new_release_date DATE,

    old_critic_score DECIMAL(4, 2),  -- Оценка критиков
    new_critic_score DECIMAL(4, 2),

    old_total_sales DECIMAL(10, 2),  -- Количество продаж во всем мире (в миллионах экземпляров)
    new_total_sales DECIMAL(10, 2),

    old_na_sales DECIMAL(10, 2),  -- Количество продаж в Северной Америке (в миллионах экземпляров)
    new_na_sales DECIMAL(10, 2),

    old_jp_sales DECIMAL(10, 2),  -- Количество продаж в Японии (в миллионах экземпляров)
    new_jp_sales DECIMAL(10, 2),

    old_pal_sales DECIMAL(10, 2),  -- Количество продаж в странах PAL (в миллионах экземпляров)
    new_pal_sales DECIMAL(10, 2),

    old_other_sales DECIMAL(10, 2),  -- Количество продаж в других регионах (в миллионах экземпляров)
    new_other_sales DECIMAL(10, 2),

    old_last_update DATE,  -- Дата последнего обновления данных
    new_last_update DATE,

    change_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


SELECT * FROM change_log_tbl_games; -- Проверка создания таблицы изменений

/*
    Функция триггера:
    добавление записи в таблицу CHANGE_LOG_TBL_GAMES
*/
CREATE OR REPLACE FUNCTION log_changes_tbl_games()
RETURNS TRIGGER AS $$
BEGIN
    -- Проверяем, изменились ли какие-либо из полей:
    IF (NEW.title IS DISTINCT FROM OLD.title) THEN
        INSERT INTO change_log_tbl_games (game_id, old_title, new_title)
        VALUES (OLD.id, OLD.title, NEW.title);
    END IF;

    IF (NEW.console_id IS DISTINCT FROM OLD.console_id) THEN
        INSERT INTO change_log_tbl_games (game_id, old_console_id, new_console_id)
        VALUES (OLD.id, OLD.console_id, NEW.console_id);
    END IF;

    IF (NEW.genre_id IS DISTINCT FROM OLD.genre_id) THEN
        INSERT INTO change_log_tbl_games (game_id, old_genre_id, new_genre_id)
        VALUES (OLD.id, OLD.genre_id, NEW.genre_id);
    END IF;

    IF (NEW.publisher_id IS DISTINCT FROM OLD.publisher_id) THEN
        INSERT INTO change_log_tbl_games (game_id, old_publisher_id, new_publisher_id)
        VALUES (OLD.id, OLD.publisher_id, NEW.publisher_id);
    END IF;

    IF (NEW.developer_id IS DISTINCT FROM OLD.developer_id) THEN
        INSERT INTO change_log_tbl_games (game_id, old_developer_id, new_developer_id)
        VALUES (OLD.id, OLD.developer_id, NEW.developer_id);
    END IF;

	IF (NEW.img IS DISTINCT FROM OLD.img) THEN
        INSERT INTO change_log_tbl_games (game_id, old_img, new_img)
        VALUES (OLD.id, OLD.img, NEW.img);
    END IF;

	IF (NEW.release_date IS DISTINCT FROM OLD.release_date) THEN
        INSERT INTO change_log_tbl_games (game_id, old_release_date, new_release_date)
        VALUES (OLD.id, OLD.release_date, NEW.release_date);
    END IF;

	IF (NEW.critic_score IS DISTINCT FROM OLD.critic_score) THEN
        INSERT INTO change_log_tbl_games (game_id, old_critic_score, new_critic_score)
        VALUES (OLD.id, OLD.critic_score, NEW.critic_score);
    END IF;

	IF (NEW.total_sales IS DISTINCT FROM OLD.total_sales) THEN
        INSERT INTO change_log_tbl_games (game_id, old_total_sales, new_total_sales)
        VALUES (OLD.id, OLD.total_sales, NEW.total_sales);
    END IF;

	IF (NEW.na_sales IS DISTINCT FROM OLD.na_sales) THEN
        INSERT INTO change_log_tbl_games (game_id, old_na_sales, new_na_sales)
        VALUES (OLD.id, OLD.na_sales, NEW.na_sales);
    END IF;

	IF (NEW.jp_sales IS DISTINCT FROM OLD.jp_sales) THEN
        INSERT INTO change_log_tbl_games (game_id, old_jp_sales, new_jp_sales)
        VALUES (OLD.id, OLD.jp_sales, NEW.jp_sales);
    END IF;

	IF (NEW.pal_sales IS DISTINCT FROM OLD.pal_sales) THEN
        INSERT INTO change_log_tbl_games (game_id, old_pal_sales, new_pal_sales)
        VALUES (OLD.id, OLD.pal_sales, NEW.pal_sales);
    END IF;

	IF (NEW.other_sales IS DISTINCT FROM OLD.other_sales) THEN
        INSERT INTO change_log_tbl_games (game_id, old_other_sales, new_other_sales)
        VALUES (OLD.id, OLD.other_sales, NEW.other_sales);
    END IF;

	IF (NEW.last_update IS DISTINCT FROM OLD.last_update) THEN
        INSERT INTO change_log_tbl_games (game_id, old_last_update, new_last_update)
        VALUES (OLD.id, OLD.last_update, NEW.last_update);
    END IF;

    RETURN NEW; -- Возвращаем новые значения
END;
$$ LANGUAGE plpgsql;

/*
    Проверка работы триггера
*/
-- Удалим ранее созданные данные о тестовых играх
DELETE FROM games
WHERE title IN ('Updated: This is Test Game 1', 'Updated: This is Test Game 2');

-- Вставить новую запись в таблицу GAMES
INSERT INTO games (title, console_id, genre_id, publisher_id, developer_id, img, release_date, critic_score, total_sales, na_sales, jp_sales, pal_sales, other_sales, last_update)
VALUES
('This is Test Game 1', 1, 1, 1, 1, 'path/to/image1.jpg', '2020-01-01', 7.50, 10.50, 1.50, 3.20, 0.70, 6.10, CURRENT_DATE),
('This is Test Game 2', 2, 2, 2, 2, 'path/to/image2.jpg', '2022-12-31', 8.30, 23.40, 7.50, 3.99, 1.23, 0.73, CURRENT_DATE);

-- Проверим, что игры были добавлены
SELECT * FROM games WHERE title IN ('This is Test Game 1', 'This is Test Game 2');

-- Обновляем записи в таблице GAMES (вызываем триггер)
UPDATE games
SET
    title = 'Updated: This is Test Game 1',
    console_id = 3,
    genre_id = 3,
    publisher_id = 3,
    developer_id = 3,
    img = 'path/to/new/image3.jpg',
    release_date = '2021-01-01',
    critic_score = 2.50,
    total_sales = 21.00,
    na_sales = 3.00,
    jp_sales = 6.40,
    pal_sales = 1.40,
    other_sales = 12.20,
    last_update = CURRENT_DATE
WHERE title = 'This is Test Game 1';

UPDATE games
SET
    title = 'Updated: This is Test Game 2',
    console_id = 4,
    genre_id = 4,
    publisher_id = 4,
    developer_id = 4,
    img = 'path/to/new/image4.jpg',
    release_date = '2019-12-31',
    critic_score = 5.10,
    total_sales = 46.80,
    na_sales = 15.00,
    jp_sales = 8.99,
    pal_sales = 2.46,
    other_sales = 1.50,
    last_update = CURRENT_DATE
WHERE title = 'This is Test Game 2';

-- Проверяем таблицу изменений
SELECT *
FROM change_log_tbl_games
WHERE game_id IN (
    SELECT id
    FROM games
    WHERE title IN ('Updated: This is Test Game 1', 'Updated: This is Test Game 2')
)
ORDER BY old_title;