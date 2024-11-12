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
