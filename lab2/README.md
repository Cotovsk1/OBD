# Документація до Лабораторної (README)

## Зміст

1. Короткий виклад вимог
    
2. ER-діаграма, за якою створювалась БД
    
3. Код створення таблиць SQL
    
4. Код заповнення таблиць тестовими даними
    
5. Результати перевірки результатів
    

---

## Короткий виклад вимог

1. Написати SQL DDL-інструкції для створення кожної таблиці з розробленої ERD в PostgreSQL.
    
2. Вказати відповідні типи даних для кожного стовпця, вибрати первинний ключ (Primary Key) для кожної таблиці та визначити необхідні зовнішні ключі (Foreign Keys), а також обмеження UNIQUE, NOT NULL, CHECK або DEFAULT.
    
3. Вставити зразки рядків (тестові дані) за допомогою `INSERT INTO`.
    
4. Протестувати все в клієнті pgAdmin, щоб переконатися, що таблиці створені правильно, зв'язки працюють, а дані завантажуються коректно.
    

---

## ER-діаграма, за якою створювалась БД

За основу для цієї роботи була взята модель, що відповідає функціональним вимогам до курсового проєкту зі створення інтерактивного шахового застосунку. Архітектура дозволяє зберігати дані гравців, історію партій (як між людьми, так і проти комп'ютера), покрокову історію ходів, режими часу та соціальні зв'язки.

🖼️ _Переглянути ER-діаграму_

_(Тут вставиш скріншот своєї ER-діаграми з draw.io або Mermaid)_

**Рис. 1. ER-діаграма, відповідно до якої було розроблено код для створення таблиць БД.**

---

## Код створення таблиць SQL

Для зручності загальний код SQL-запиту розділено на логічні частини з поясненням призначення кожної таблиці.

### Код SQL-запиту для створення таблиці `Player`

SQL

```
CREATE TABLE Player (
    id SERIAL PRIMARY KEY, -- Унікальний ідентифікатор гравця
    username VARCHAR(50) UNIQUE NOT NULL, -- Унікальний нікнейм 
    email VARCHAR(100) UNIQUE NOT NULL, -- Унікальна електронна пошта
    password_hash VARCHAR(255) NOT NULL, -- Зашифрований пароль
    rating INT NOT NULL CHECK (rating >= 100) DEFAULT 1200 -- Рейтинг Elo (не може бути меншим за 100)
);
```

`Player` — базова таблиця, що зберігає облікові дані користувачів та їхній поточний шаховий рейтинг.

### Код SQL-запиту для створення таблиці `Time_Control`

SQL

```
CREATE TABLE Time_Control (
    id SERIAL PRIMARY KEY, -- Унікальний ідентифікатор режиму
    name VARCHAR(50) NOT NULL, -- Назва режиму (наприклад, "Бліц")
    initial_time_sec INT NOT NULL, -- Початковий час на партію у секундах
    increment_sec INT NOT NULL -- Додавання секунд за кожен хід
);
```

`Time_Control` — таблиця-довідник для зберігання налаштувань контролю часу, що застосовуються у партіях.

### Код SQL-запиту для створення таблиці `Tournament`

SQL

```
CREATE TABLE Tournament (
    id SERIAL PRIMARY KEY, -- Унікальний ідентифікатор турніру
    title VARCHAR(100) NOT NULL, -- Назва змагання
    start_date TIMESTAMP NOT NULL -- Час початку турніру
);
```

`Tournament` — таблиця для організації турнірів, яка дозволяє об'єднувати декілька партій в одну подію.

### Код SQL-запиту для створення таблиці `Game`

SQL

```
CREATE TABLE Game (
    id SERIAL PRIMARY KEY, -- Унікальний ідентифікатор партії
    white_player_id INT NOT NULL REFERENCES Player(id) ON DELETE RESTRICT, -- Гравець білими
    black_player_id INT REFERENCES Player(id) ON DELETE RESTRICT, -- Гравець чорними (NULL, якщо гра проти ШІ)
    time_control_id INT NOT NULL REFERENCES Time_Control(id) ON DELETE RESTRICT, -- Режим часу
    tournament_id INT REFERENCES Tournament(id) ON DELETE SET NULL, -- Прив'язка до турніру (NULL, якщо звичайна гра)
    result VARCHAR(20) CHECK (result IN ('WhiteWins', 'BlackWins', 'Draw', 'InProgress')), -- Статус/результат партії
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Час початку партії
);
```

`Game` — центральна таблиця, яка фіксує метадані кожної зіграної партії та пов'язує між собою гравців, режими та турніри.

### Код SQL-запиту для створення таблиці `Move`

SQL

```
CREATE TABLE Move (
    id SERIAL PRIMARY KEY, -- Унікальний ідентифікатор ходу
    game_id INT NOT NULL REFERENCES Game(id) ON DELETE CASCADE, -- Прив'язка до конкретної партії
    move_number INT NOT NULL CHECK (move_number > 0), -- Порядковий номер ходу
    notation VARCHAR(10) NOT NULL -- Запис ходу (наприклад, "e4" або "Nf3")
);
```

`Move` — таблиця, що зберігає покрокову історію (нотацію) кожної партії для можливості її подальшого аналізу.

### Код SQL-запиту для створення таблиці `Friendship`

SQL

```
CREATE TABLE Friendship (
    user1_id INT NOT NULL REFERENCES Player(id) ON DELETE CASCADE, -- Ініціатор запиту
    user2_id INT NOT NULL REFERENCES Player(id) ON DELETE CASCADE, -- Отримувач запиту
    status VARCHAR(20) CHECK (status IN ('pending', 'accepted', 'blocked')) DEFAULT 'pending', -- Статус дружби
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Час створення запиту
    PRIMARY KEY (user1_id, user2_id) -- Композитний первинний ключ для уникнення дублікатів
);
```

`Friendship` — асоціативна таблиця для реалізації зв'язку "багато-до-багатьох", що відповідає за соціальну взаємодію гравців.

---

## Код заповнення таблиць тестовими даними

Для перевірки працездатності бази даних та коректності зв'язків таблиці було заповнено довільними даними.

SQL

```
-- Додавання гравців
INSERT INTO Player (username, email, password_hash, rating) VALUES
('Andrii_KPI', 'aistratij85@gmail.com', 'hashed_pass_1', 1600),
('FrontEnd_Dev', 'partner@kpi.edu', 'hashed_pass_2', 1450),
('GrandMaster', 'gm@example.com', 'hashed_pass_3', 2500);

-- Додавання режимів часу
INSERT INTO Time_Control (name, initial_time_sec, increment_sec) VALUES
('Bullet 1+0', 60, 0),
('Blitz 5+3', 300, 3),
('Rapid 15+10', 900, 10);

-- Додавання турніру
INSERT INTO Tournament (title, start_date) VALUES 
('KPI Spring Cup', '2026-04-15 18:00:00');

-- Створення ігор
INSERT INTO Game (white_player_id, black_player_id, time_control_id, tournament_id, result) VALUES
(1, 2, 3, NULL, 'WhiteWins'), -- Гра Андрія проти партнера поза турніром
(3, NULL, 2, NULL, 'InProgress'); -- Гра Грандмастера проти Stockfish (ШІ)

-- Додавання ходів для першої партії
INSERT INTO Move (game_id, move_number, notation) VALUES
(1, 1, 'e4'),
(1, 2, 'e5'),
(1, 3, 'Nf3'),
(1, 4, 'Nc6');

-- Додавання друзів
INSERT INTO Friendship (user1_id, user2_id, status) VALUES
(1, 2, 'accepted'), -- Андрій та партнер друзі
(2, 3, 'pending'); -- Партнер відправив запит Грандмастеру
```

---

## Результати перевірки результатів

Після виконання запитів за допомогою інструменту **pgAdmin 4**, перевірено наявність даних у таблицях.


_![[Pasted image 20260327172518.png]]_
**Рис. 1. Таблиця Player з доданими даними.**



_![[Pasted image 20260327172804.png]]_
**Рис. 2. Таблиця Game з доданими даними.**



_![[Pasted image 20260327172831.png]]_
**Рис. 3. Таблиця Move з доданими даними.**


_![[Pasted image 20260327172908.png]]_
**Рис. 4. Таблиця Time_control з доданими даними.**


_![[Pasted image 20260327173106.png]]_
**Рис. 5. Таблиця Tournament.**

_![[Pasted image 20260327173220.png]]_
**Рис. 6. Таблиця Friendship.**