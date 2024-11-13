/* Удаление созданной базы данных SALES (если существует) */
DROP DATABASE IF EXISTS sales;

/* Создание базы данных SALES */
CREATE DATABASE sales;

/* Проверяем, что создалась наша база данных */
SELECT datname FROM pg_database
WHERE datname='sales';