/* Удаление созданной базы данных INNOPOLIS (если существует) */
DROP DATABASE IF EXISTS innopolis;

/* Создание базы данных INNOPOLIS */
CREATE DATABASE innopolis;

/*
   Задание 1.
   Через анонимный блок реализовать проверку целого числа на четность,
   число должно быть как переменная
*/
DO $$
DECLARE
    number INTEGER := 42;  -- Здесь можно задать любое целое число
BEGIN
    IF number % 2 = 0 THEN  -- Проверяем, делится ли число на 2 без остатка. Если да, то число четное.
        RAISE NOTICE 'Число % - четное.', number;  -- Выводим сообщение, если число - четное.
    ELSE
        RAISE NOTICE 'Число % - нечетное.', number;  -- Выводим сообщение, если число - нечетное.
    END IF;
END $$;

/*
   Задание 2.
   Через анонимный блок посчитать сколько четных и нечетных чисел в некотором промежутке чисел,
   левая граница и правая граница диапазона должны быть как переменные
*/
DO $$
DECLARE
    min_range INTEGER := 2;  -- левая граница диапазона
    max_range INTEGER := 4; -- правая граница диапазона
    even_count INTEGER := 0; -- счетчик четных чисел
    odd_count INTEGER := 0;  -- счетчик нечетных чисел
    i INTEGER;               -- переменная для итерации
BEGIN
    FOR i IN min_range..max_range LOOP
        IF i % 2 = 0 THEN
            even_count := even_count + 1;  -- увеличиваем счетчик четных чисел
        ELSE
            odd_count := odd_count + 1;    -- увеличиваем счетчик нечетных чисел
        END IF;
    END LOOP;

    RAISE NOTICE 'В промежутке от % до % всего % нечетных чисел и % четных', min_range, max_range, odd_count, even_count;
END $$;

/*
   Задание 3.
   Через анонимный блок определить является ли число простым или нет,
   число должно быть как переменная
*/
DO $$
DECLARE
    number INTEGER := 1; -- Здесь можно задать любое целое число, которое нужно проверить
    is_simple BOOLEAN := TRUE; -- Логическая переменная, которая будет изменяться при проверке числа.
    i INTEGER; -- счётчик итераций
BEGIN
    IF number < 2 THEN
        is_simple := FALSE; -- Число непростое, т.к. меньше 2
    ELSE
        /*
            Проверка на делимость от 2 до floor(sqrt(number)):
            sqrt - квадратный корень, floor - округление до ближайшего целого
        */
        FOR i IN 2..floor(sqrt(number)) LOOP --
            IF number % i = 0 THEN
                is_simple := FALSE; -- Если число делится на i, то НЕ простое
                EXIT;
            END IF;
        END LOOP;
    END IF;

    IF is_simple THEN
        RAISE NOTICE 'Число % является простым', number;
    ELSE
        RAISE NOTICE 'Число % НЕ является простым', number;
    END IF;
END $$;

/*
   Задание 4.
   Через анонимный блок посчитать сколько всего есть простых чисел в некотором промежутке чисел,
   левая граница и правая граница диапазона должны быть как переменные
*/
DO $$
DECLARE
    min_range INT := 1;  -- Левая граница диапазона
    max_range INT := 1000;  -- Правая граница диапазона
    simple_count INT := 0;  -- Счетчик простых чисел
    number INT;  -- Счетчик текущего числа
    is_simple BOOLEAN;  -- Логическая переменная, которая будет изменяться при проверке числа.
BEGIN
    FOR number IN min_range..max_range LOOP
        IF number < 2 THEN
            CONTINUE;  -- Число непростое, т.к. меньше 2
        END IF;

        is_simple := TRUE;  -- Предположим, что number - простое

        /*
            Проверка на делимость от 2 до floor(sqrt(number)):
            sqrt - квадратный корень, floor - округление до ближайшего целого
        */
        FOR i IN 2..floor(sqrt(number)) LOOP
            IF number % i = 0 THEN
                is_simple := FALSE;  -- Если делится, то НЕ простое
                EXIT;
            END IF;
        END LOOP;

        IF is_simple THEN
            simple_count := simple_count + 1;  -- Увеличиваем счетчик простых чисел
        END IF;
    END LOOP;

    RAISE NOTICE 'В промежутке от % до % всего % простых чисел', min_range, max_range, simple_count;
END $$;

/*
   Задание 5.
   Вывести анонимным блоком таблицу умножения от 1 до 10 вертикально.
   Код должен быть как можно короче. Последний пример должен быть 10 * 10 = 100
*/
DO $$
BEGIN
    FOR n IN 1..10 LOOP
        FOR i IN 1..10 LOOP
            RAISE NOTICE '% * % = %', n, i, n * i;  -- Вывод в консоль вида 1 * 10 = 10
        END LOOP;
    END LOOP;
END $$;
