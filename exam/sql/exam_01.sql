/* Удаление созданной базы данных SOCIALNET (если существует) */
DROP DATABASE IF EXISTS socialnet;

/* Создание базы данных SOCIALNET */
CREATE DATABASE socialnet;

/* Удаление таблицы USERS */
DROP TABLE IF EXISTS users;

/* Создание таблицы USERS */
CREATE TABLE users (
	id BIGSERIAL PRIMARY KEY,                           -- уникальный идентификатор пользователя
    firstname VARCHAR(50) NOT NULL,                     -- имя пользователя
    lastname VARCHAR(50) NOT NULL,                      -- фамилия пользователя
    email VARCHAR(120) UNIQUE NOT NULL,                 -- адрес электронной почты пользователя
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,     -- дата обновления
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,     -- дата создания
    profile_picture VARCHAR(255),                       -- аватар пользователя (ссылка на изображение)
    bio TEXT,                                           -- краткая информация о пользователе
    password_hash VARCHAR(255) NOT NULL                 -- хэш пароля
);

/* Заполнение таблицы USERS */
INSERT INTO users (firstname, lastname, email, profile_picture, bio, password_hash)
VALUES
('Reuben', 'Nienow', 'arlo50@example.org', 'img/001.jpg', 'Vestibulum lobortis mi eu elit', 'c4ca4238a0b923820dcc509a6f75849b'),
('Frederik', 'Upton', 'terrence.cartwright@example.org', 'img/002.jpg', 'Mauris dictum dolor vitae tristique', 'c81e728d9d4c2f636f067f89cc14862c'),
('Unique', 'Windler', 'rupert55@example.org', 'img/003.jpg', 'Quisque lobortis nulla id facilisis', 'eccbc87e4b5ce2fe28308fd9f2a7baf3'),
('Norene', 'West', 'rebekah29@example.net', 'img/004.jpg', 'Vestibulum volutpat ipsum lacus, eu', 'a87ff679a2f3e71d9181a67b7542122c'),
('Frederick', 'Effertz', 'von.bridget@example.net', 'img/005.jpg', 'Aliquam eu lacus id nibh', 'e4da3b7fbbce2345d7772b0674a318d5'),
('Victoria', 'Medhurst', 'sstehr@example.net', 'img/006.jpg', 'Nunc mollis justo turpis, sit', '1679091c5a880faf6fb5e6087eb1b2dc'),
('Austyn', 'Braun', 'itzel.beahan@example.com', 'img/007.jpg', 'Nam in mi dui. Phasellus', '8f14e45fceea167a5a36dedd4bea2543'),
('Jaida', 'Kilback', 'johnathan.wisozk@example.com', 'img/008.jpg', 'Donec consequat risus et leo', 'c9f0f895fb98ab9159f51fd0297e236d'),
('Mireya', 'Orn', 'missouri87@example.org', 'img/009.jpg', 'Proin vitae mauris tellus. Nullam', '45c48cce2e2d7fbdea1afc51c7c6ad26'),
('Jordyn', 'Jerde', 'edach@example.com', 'img/010.jpg', 'Vivamus ut tincidunt dolor, at', 'd3d9446802a44259755d38e6d163e820')
;

/* Удаление таблицы STATUS */
DROP TABLE IF EXISTS status;

/* Создание таблицы STATUS */
CREATE TABLE status (
    id SERIAL PRIMARY KEY,                -- Уникальный идентификатор статуса
    name VARCHAR(255) NOT NULL            -- Наименование статуса
);

/* Заполнение таблицы STATUS */
INSERT INTO status (name)
VALUES ('delivered'), ('received'), ('read'), ('requested'), ('approved'), ('unfriended');

/* Удаление таблицы MESSAGES */
DROP TABLE IF EXISTS messages;

/* Создание таблицы MESSAGES */
CREATE TABLE messages (
	id BIGSERIAL PRIMARY KEY,                           -- уникальный идентификатор сообщения
	from_user_id INT NOT NULL,                          -- идентификатор пользователя, отправившего сообщение
    to_user_id INT NOT NULL,                            -- идентификатор пользователя, получившего сообщение
    body TEXT NOT NULL,                                 -- текст сообщения
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,     -- временная метка создания сообщения
    status INT NOT NULL,                                -- статус сообщения
    type VARCHAR(5),                                    -- тип сообщения
    FOREIGN KEY (from_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (to_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (status) REFERENCES status(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

/* Заполнение таблицы MESSAGES */
INSERT INTO messages (from_user_id, to_user_id, status, type, body)
VALUES
(1, 2, 3, 'text', 'Voluptatem ut quaerat quia. Pariatur esse amet ratione qui quia. In necessitatibus reprehenderit et. Nam accusantium aut qui quae nesciunt non.'),
(2, 1, 3, 'text', 'Sint dolores et debitis est ducimus. Aut et quia beatae minus. Ipsa rerum totam modi sunt sed. Voluptas atque eum et odio ea molestias ipsam architecto.'),
(3, 1, 3, 'text', 'Sed mollitia quo sequi nisi est tenetur at rerum. Sed quibusdam illo ea facilis nemo sequi. Et tempora repudiandae saepe quo.'),
(4, 1, 3, 'text', 'Quod dicta omnis placeat id et officiis et. Beatae enim aut aliquid neque occaecati odit. Facere eum distinctio assumenda omnis est delectus magnam.'),
(1, 5, 3, 'text', 'Voluptas omnis enim quia porro debitis facilis eaque ut. Id inventore non corrupti doloremque consequuntur. Molestiae molestiae deleniti exercitationem sunt qui ea accusamus deserunt.'),
(1, 6, 3, 'text', 'Rerum labore culpa et laboriosam eum totam. Quidem pariatur sit alias. Atque doloribus ratione eum rem dolor vitae saepe.'),
(1, 7, 3, 'text', 'Perspiciatis temporibus doloribus debitis. Et inventore labore eos modi. Quo temporibus corporis minus. Accusamus aspernatur nihil nobis placeat molestiae et commodi eaque.'),
(8, 1, 3, 'text', 'Suscipit dolore voluptas et sit vero et sint. Rem ut ratione voluptatum assumenda nesciunt ea. Quas qui qui atque ut. Similique et praesentium non voluptate iure. Eum aperiam officia quia dolorem.'),
(9, 3, 3, 'text', 'Et quia libero aut vitae minus. Rerum a blanditiis debitis sit nam. Veniam quasi aut autem ratione dolorem. Sunt quo similique dolorem odit totam sint sed.'),
(10, 2, 3, 'text', 'Praesentium molestias quia aut odio. Est quis eius ut animi optio molestiae. Amet tempore sequi blanditiis in est.'),
(8, 3, 3, 'text', 'Molestiae laudantium quibusdam porro est alias placeat assumenda. Ut consequatur rerum officiis exercitationem eveniet. Qui eum maxime sed in.'),
(8, 1, 3, 'text', 'Quo asperiores et id veritatis placeat. Aperiam ut sit exercitationem iste vel nisi fugit quia. Suscipit labore error ducimus quaerat distinctio quae quasi.'),
(8, 1, 3, 'text', 'Earum sunt quia sed harum modi accusamus. Quia dolor laboriosam asperiores aliquam quia. Sint id quasi et cumque qui minima ut quo. Autem sed laudantium officiis sit sit.'),
(4, 1, 3, 'text', 'Aut enim sint voluptas saepe. Ut tenetur quos rem earum sint inventore fugiat. Eaque recusandae similique earum laborum.'),
(4, 1, 3, 'text', 'Nisi rerum officiis officiis aut ad voluptates autem. Dolor nesciunt eum qui eos dignissimos culpa iste. Atque qui vitae quos odit inventore eum. Quam et voluptas quia amet.'),
(4, 1, 3, 'text', 'Consequatur ut et repellat non voluptatem nihil veritatis. Vel deleniti omnis et consequuntur. Et doloribus reprehenderit sed earum quas velit labore.'),
(2, 1, 3, 'text', 'Iste deserunt in et et. Corrupti rerum a veritatis harum. Ratione consequatur est ut deserunt dolores.'),
(8, 1, 3, 'text', 'Dicta non inventore autem incidunt accusamus amet distinctio. Aut laborum nam ab maxime. Maxime minima blanditiis et neque. Et laboriosam qui at deserunt magnam.'),
(8, 1, 3, 'text', 'Amet ad dolorum distinctio excepturi possimus quia. Adipisci veniam porro ipsum ipsum tempora est blanditiis. Magni ut quia eius qui.'),
(8, 1, 3, 'text', 'Porro aperiam voluptate quo eos nobis. Qui blanditiis cum id eos. Est sit reprehenderit consequatur eum corporis. Molestias quia quo sit architecto aut.')
;

DROP TABLE IF EXISTS friend_requests;
CREATE TABLE friend_requests (
	initiator_user_id INT  NOT NULL,
    target_user_id INT  NOT NULL,
    status VARCHAR(50),
	requested_at TIMESTAMP DEFAULT NOW(),
	updated_at TIMESTAMP,
    PRIMARY KEY (initiator_user_id, target_user_id),
    FOREIGN KEY (initiator_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (target_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO friend_requests (initiator_user_id, target_user_id, status, requested_at, updated_at)
VALUES
(1, 10, 'approved', '2023-01-05 06:40:37', '2023-01-05 16:28:19'),
(1, 2, 'requested', '2023-01-06 07:33:23', NULL),
(1, 3, 'approved', '2023-01-07 01:53:07', '2023-01-18 16:22:56'),
(4, 1, 'approved', '2023-01-08 15:57:26', '2023-01-15 18:12:00'),
(5, 2, 'approved', '2023-01-08 18:22:00', '2023-01-14 08:25:00'),
(6, 3, 'unfriended', '2023-01-09 17:07:59', '2023-01-09 17:12:45'),
(7, 1, 'requested', '2023-01-09 06:20:23', NULL),
(8, 6, 'unfriended', '2023-01-10 01:50:03', '2023-01-10 06:50:59'),
(9, 7, 'approved', '2023-01-11 22:52:09', NULL),
(10, 6, 'approved', '2023-01-12 00:32:15', '2023-01-12 10:22:15');


DROP TABLE IF EXISTS communities;
CREATE TABLE communities(
	id SERIAL PRIMARY KEY,
	name VARCHAR(150)
);

INSERT INTO communities (name)
VALUES ('atque'), ('beatae'), ('est'), ('eum'), ('hic'), ('nemo'), ('quis'), ('rerum'), ('tempora'), ('voluptas');


DROP TABLE IF EXISTS users_communities;
CREATE TABLE users_communities(
	user_id INT NOT NULL,
	community_id INT NOT NULL,
    PRIMARY KEY (user_id, community_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (community_id) REFERENCES communities(id) ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO users_communities (user_id, community_id)
VALUES
(1, 1), (1, 2), (1, 3),
(2, 1), (2, 2),
(3, 1), (3, 2), (3, 10), (3, 5), (3, 8),
(4, 1), (4, 2), (4, 3), (4, 8),
(5, 1), (5, 2), (5, 3), (5, 6), (5, 8), (5, 10),
(6, 1), (6, 2), (6, 3), (6, 6),
(7, 1), (7, 2), (7, 3), (7, 8), (7, 7), (7, 6),
(8, 1), (8, 2), (8, 3), (8, 5), (8, 7), (8, 9),
(9, 1), (9, 2),
(10, 1), (10, 10);

/* Проверяем, что создалась наша база данных */
SELECT datname FROM pg_database
WHERE datname='socialnet';

/* Найдите всех друзей пользователя с id = 1. */
SELECT *
FROM friend_requests
WHERE status = 'approved' AND target_user_id = 1;

/* Найдите все сообщения, в которых принимал участие пользователь id = 1. */
SELECT *
FROM messages
WHERE from_user_id = 1;

/* Найдите всех пользователей, кто состоит в сообществе 'beatae’. */
SELECT *
FROM communities
WHERE name = 'beatae';