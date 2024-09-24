/* Удаление созданной базы данных INNOPOLIS */
DROP DATABASE IF EXISTS innopolis;

/* Создание базы данных INNOPOLIS */
CREATE DATABASE innopolis;

/* Создание таблицы PERSON (Физические лица) */
CREATE TABLE Person
(
    PersonID INT PRIMARY KEY,               -- идентификатор физического лица (первичный ключ)
    FirstName VARCHAR(50) NOT NULL,         -- имя физического лица
    MiddleName VARCHAR(50),                 -- отчество физического лица
    LastName VARCHAR(50) NOT NULL,          -- фамилия физического лица
    DateOfBirth DATE NOT NULL,              -- атрибут "Дата рождения"
    PhoneNumber VARCHAR(12) NOT NULL        -- атрибут "Номер телефона"
);

/* Создание таблица STUDENT (Студент) */
CREATE TABLE Student
(
    StudentID INT PRIMARY KEY,                          -- идентификатор студента (первичный ключ)
    PersonID  INT NOT NULL UNIQUE,                      -- идентификатор физического лица
    FOREIGN KEY (PersonID) REFERENCES Person (PersonID) -- связь с таблицей "Физические лица"
);

/* Создание таблицы DEPARTMENT (Кафедра) */
CREATE TABLE Department
(
    DepartmentID INT PRIMARY KEY,            -- идентификатор кафедры (первичный ключ)
    DepartmentName VARCHAR(100) NOT NULL,    -- атрибут "Название"
    Statute TEXT NOT NULL                    -- атрибут "Устав"
);

/* Создание таблицы LECTURER (Преподаватель) */
CREATE TABLE Lecturer
(
    LecturerID INT PRIMARY KEY,            -- идентификатор преподавателя (первичный ключ)
    PersonID INT NOT NULL UNIQUE,          -- идентификатор физического лица
    Diploma VARCHAR(100) NOT NULL,         -- атрибут "Диплом"
    StartDate DATE NOT NULL,               -- атрибут "Дата начала трудовой деятельности"
    Address VARCHAR(200) NOT NULL,         -- атрибут "Адрес"
    DepartmentID INT NOT NULL,             -- идентификатор кафедры, на которой работает преподаватель
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),  -- связь с таблицей "Кафедры"
    FOREIGN KEY (PersonID) REFERENCES Person(PersonID) -- связь с таблицей "Физические лица"
);

/* Создание таблицы COURSE (Курс) */
CREATE TABLE Course
(
    CourseID INT PRIMARY KEY,              -- идентификатор курса (первичный ключ)
    CourseName VARCHAR(100) NOT NULL,      -- атрибут "Название"
    CourseHours INT NOT NULL,              -- атрибут "Длительность"
    LecturerID INT NOT NULL,               -- идентификатор преподавателя, читающего курс
    FOREIGN KEY (LecturerID) REFERENCES Lecturer(LecturerID) -- связь с таблицей "Преподаватели"
);

/* Создание таблицы HOMEWORK (Домашняя работа) */
CREATE TABLE Homework
(
    HomeworkID INT PRIMARY KEY,                -- идентификатор домашней работы (первичный ключ)
    HomeworkName VARCHAR(100) NOT NULL,        -- атрибут "Название"
    CourseID INT NOT NULL,                     -- идентификатор курса по которому задается домашнее задание
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID) -- связь с таблицей "Курсы"
);

/* Создание соединительной таблицы COURSEENROLLMENT (Зачисление на курс) */
CREATE TABLE CourseEnrollment
(
    CourseEnrollmentID INT PRIMARY KEY,                     -- идентификатор зачисления на курс (первичный ключ)
    StudentID          INT  NOT NULL,                       -- идентификатор студента
    CourseID           INT  NOT NULL,                       -- идентификатор курса
    EnrollmentDate     DATE NOT NULL,                       -- Дата зачисления на курс
    FOREIGN KEY (StudentID) REFERENCES Student (StudentID), -- связь с таблицей "Студенты"
    FOREIGN KEY (CourseID) REFERENCES Course (CourseID)     -- связь с таблицей "Курсы"
);

/* Создание соединительной таблицы HOMEWORKSUBMISSION (Выполнение домашнего задания) */
CREATE TABLE HomeworkSubmission
(
    HomeworkSubmissionID INT PRIMARY KEY,      -- идентификатор выполнения домашнего задания (первичный ключ)
    HomeworkID INT NOT NULL,                   -- идентификатор домашнего задания
    StudentID INT NOT NULL,                    -- идентификатор студента
    HomeworkMark INT NOT NULL,                 -- оценка домашней работы
    FOREIGN KEY (HomeworkID) REFERENCES Homework(HomeworkID),  -- связь с таблицей "Домашняя работа"
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID)  -- связь с таблицей "Студенты"
);