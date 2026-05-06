# Документація до Лабораторної роботи: Нормалізація БД

## Зміст

1. [Короткий виклад вимог](#Короткий-виклад-вимог)
    
2. [Пошук надлишковості та аномалій](#Пошук-надлишковості-та-аномалій)
    
3. [Перелік функціональних залежностей (ФЗ)](#Перелік-функціональних-залежностей-ФЗ)
    
4. [Перевірка нормальних форм](#Перевірка-нормальних-форм)
    
5. [Застосування нормалізації](#Застосування-нормалізації)
    
6. [Перероблений дизайн таблиць (ALTER TABLE)](#Перероблений-дизайн-таблиць-ALTER-TABLE)
    
7. [Оновлена ER-діаграма](#Оновлена-ER-діаграма)
    
8. [Висновок](#Висновок)
    

---

## Короткий виклад вимог

- **Пошук надлишковості та аномалій:** виявлення потенційної надлишковості даних (повторювані значення) або аномалій модифікації (проблеми вставки/оновлення/видалення) у поточній схемі.
    
- **Перелік функціональних залежностей (ФЗ):** визначення мінімального набору ФЗ для кожної таблиці.
    
- **Перевірка нормальних форм:** оцінка поточного стану таблиць (1NF, 2NF, 3NF) на основі структури ключів та залежностей.
    
- **Застосування нормалізації:** декомпозиція таблиць до вищих нормальних форм (до 3NF включно) для усунення часткових, транзитивних чи прихованих залежностей.
    

---

## Пошук надлишковості та аномалій

Для аналізу початкової БД використаємо структуру таблиць шахової платформи, створену в попередній лабораторній роботі:

SQL

```sql
CREATE TABLE Player (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    rating INT NOT NULL CHECK (rating >= 100) DEFAULT 1200
);

CREATE TABLE Time_Control (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    initial_time_sec INT NOT NULL,
    increment_sec INT NOT NULL
);

CREATE TABLE Tournament (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    start_date TIMESTAMP NOT NULL
);

CREATE TABLE Game (
    id SERIAL PRIMARY KEY,
    white_player_id INT NOT NULL REFERENCES Player(id) ON DELETE RESTRICT,
    black_player_id INT REFERENCES Player(id) ON DELETE RESTRICT,
    time_control_id INT NOT NULL REFERENCES Time_Control(id) ON DELETE RESTRICT,
    tournament_id INT REFERENCES Tournament(id) ON DELETE SET NULL,
    result VARCHAR(20) CHECK (result IN ('WhiteWins', 'BlackWins', 'Draw', 'InProgress')),
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Move (
    id SERIAL PRIMARY KEY,
    game_id INT NOT NULL REFERENCES Game(id) ON DELETE CASCADE,
    move_number INT NOT NULL CHECK (move_number > 0),
    notation VARCHAR(10) NOT NULL
);

CREATE TABLE Friendship (
    user1_id INT NOT NULL REFERENCES Player(id) ON DELETE CASCADE,
    user2_id INT NOT NULL REFERENCES Player(id) ON DELETE CASCADE,
    status VARCHAR(20) CHECK (status IN ('pending', 'accepted', 'blocked')) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user1_id, user2_id)
);
```

В ході аналізу цієї структури було виявлено такі проблеми:

1. **Надлишковість ключа в `Move`:** Сурогатний ключ `id` у таблиці ходів є зайвим. Унікальність ходу природно та однозначно визначається парою `(game_id, move_number)`. Наявність окремого `id` маскує справжній унікальний ключ і дозволяє потенційну аномалію дублювання номеру ходу (наприклад, два "перших" ходи в одній грі під різними `id`).
    
2. **Повторювані текстові дані в `Game` (Порушення DRY):** Текстове поле `result` містить повторювані рядки (`WhiteWins`, `BlackWins` тощо) для тисяч ігор. Це збільшує об'єм бази даних та створює аномалію оновлення: якщо в майбутньому знадобиться додати новий тип фіналу (наприклад, `TechnicalLoss` або `Aborted`), доведеться змінювати системне обмеження `CHECK` на рівні DDL самої таблиці.
    
3. **Логічна аномалія в `Friendship`:** Поточна структура дозволяє користувачеві надіслати запит або додати у друзі самого себе (`user1_id = user2_id`), що порушує бізнес-логіку соціальної взаємодії платформи.
    

---

## Перелік функціональних залежностей (ФЗ)

- **Таблиця `Player`:**
    
    - `id` $\rightarrow$ `username`, `email`, `password_hash`, `rating` _(Пряма залежність від PK)_
        
    - `username` $\rightarrow$ `id`, `email`, `password_hash`, `rating` _(Залежність від унікального ключа)_
        
    - `email` $\rightarrow$ `id`, `username`, `password_hash`, `rating` _(Залежність від унікального ключа)_
        
- **Таблиця `Time_Control`:**
    
    - `id` $\rightarrow$ `name`, `initial_time_sec`, `increment_sec`
        
- **Таблиця `Tournament`:**
    
    - `id` $\rightarrow$ `title`, `start_date`
        
- **Таблиця `Game`:**
    
    - `id` $\rightarrow$ `white_player_id`, `black_player_id`, `time_control_id`, `tournament_id`, `result`, `played_at`
        
- **Таблиця `Move`:**
    
    - `id` $\rightarrow$ `game_id`, `move_number`, `notation`
        
    - `{game_id, move_number}` $\rightarrow$ `notation` _(Прихована функціональна залежність неключових атрибутів від природного ключа)_
        
- **Таблиця `Friendship`:**
    
    - `{user1_id, user2_id}` $\rightarrow$ `status`, `created_at` _(Залежність від складеного PK)_
        

---

## Перевірка нормальних форм

- **1NF:** **Виконується.** Усі атрибути є атомарними, таблиці не містять масивів чи списків ходів або гравців у межах однієї комірки.
    
- **2NF:** **Виконується.** Усі неключові атрибути повністю залежать від своїх первинних ключів (оскільки більшість ПК сурогатні й складаються з одного поля `id`).
    
- **3NF:** **Частково порушується (або є неоптимальною).** * У таблиці `Move` сурогатний `id` створює ситуацію, коли природний складений ключ `{game_id, move_number}` став неключовим атрибутом, який при цьому повністю визначає `notation`.
    
    - Поле `result` в таблиці `Game` зберігає повторювані текстові константи, що є ознакою необхідності виділення таблиці-довідника для забезпечення концепції чистих сутностей 3NF.
        

### Початкова структура (1NF / 2NF)

- `Player` (`id`, username, email, password_hash, rating)
    
- `Time_Control` (`id`, name, initial_time_sec, increment_sec)
    
- `Tournament` (`id`, title, start_date)
    
- `Game` (`id`, white_player_id, black_player_id, time_control_id, tournament_id, **result**, played_at)
    
- `Move` (**id**, game_id, move_number, notation)
    
- `Friendship` (**user1_id, user2_id**, status, created_at)
    

### Фінальна структура (3NF)

- `Player` (`id`, username, email, password_hash, rating)
    
- `Time_Control` (`id`, name, initial_time_sec, increment_sec)
    
- `Tournament` (`id`, title, start_date)
    
- `Game_Result` (`id`, code, description) — _Нова таблиця-довідник_
    
- `Game` (`id`, white_player_id, black_player_id, time_control_id, tournament_id, **result_id**, played_at) — _Заміна тексту на ID_
    
- `Move` (**game_id, move_number**, notation) — _Усунено сурогатний ID, сформовано правильний складений ПК_
    
- `Friendship` (**user1_id, user2_id**, status, created_at)
    

---

## Застосування нормалізації

1. **Реорганізація таблиці `Move`:** Видаляємо сурогатний стовпець `id`. Перетворюємо поля `game_id` та `move_number` на складений первинний ключ `PRIMARY KEY (game_id, move_number)`. Це гарантує унікальність кожного ходу в межах окремої шахової партії на рівні ядра СКБД.
    
2. **Виділення довідника результатів `Game_Result`:** Створюємо окрему таблицю для статусів завершення гри. У таблиці `Game` замінюємо текстове поле `result` на зовнішній ключ `result_id`. Це усуває надлишковість збереження рядків і спрощує майбутнє масштабування статусів.
    
3. **Додавання бізнес-обмеження у `Friendship`:** Додаємо перевірку `CHECK (user1_id <> user2_id)` для усунення логічної аномалії самододавання у друзі.
    

---

## Перероблений дизайн таблиць (ALTER TABLE)

Нижче наведено SQL-команди для трансформації існуючої структури бази даних під вимоги 3NF:

SQL

```sql
-- 1. Створення таблиці-довідника результатів ігор
CREATE TABLE Game_Result (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    description VARCHAR(50) NOT NULL
);

-- Наповнення довідника базовими даними
INSERT INTO Game_Result (code, description) VALUES 
('WhiteWins', 'Перемога білих'),
('BlackWins', 'Перемога чорних'),
('Draw', 'Нічия'),
('InProgress', 'Партія триває');

-- 2. Модифікація таблиці Game (перехід на зовнішній ключ результату)
ALTER TABLE Game ADD COLUMN result_id INT;
-- (Примітка: Тут міг би бути скрипт міграції даних, якби БД була заповнена)
ALTER TABLE Game DROP COLUMN result;
ALTER TABLE Game ADD CONSTRAINT fk_game_result FOREIGN KEY (result_id) REFERENCES Game_Result(id) ON DELETE RESTRICT;

-- 3. Оптимізація таблиці Move (Заміна ПК на складений)
ALTER TABLE Move DROP CONSTRAINT move_pkey; -- Видаляємо старий ПК на id
ALTER TABLE Move DROP COLUMN id; -- Видаляємо непотрібний стовпець
ALTER TABLE Move ADD PRIMARY KEY (game_id, move_number); -- Створюємо новий складений ПК

-- 4. Виправлення аномалії у таблиці Friendship
ALTER TABLE Friendship ADD CONSTRAINT chk_not_self_friend CHECK (user1_id <> user2_id);
```

---

## Оновлена ER діаграма

На основі внесених змін було перебудовано зв'язки між сутностями.

- **Головні зміни на схемі:** З'явився новий зв'язок `1:M` (Один до багатьох) від `Game_Result` до `Game`. У таблиці `Move` поля `game_id` та `move_number` тепер об'єднані в один первинний ключ.
    



---

## Висновок

Під час виконання лабораторної роботи було проведено детальний аналіз та оптимізацію початкової схеми бази даних шахової платформи. За допомогою інструментів нормалізації (1NF, 2NF, 3NF) вдалося локалізувати й ліквідувати надлишковість даних та потенційні аномалії.

Завдяки рефакторингу таблиці `Move` ми позбулися зайвого сурогатного ідентифікатора, натомість забезпечивши жорстку цілісність даних через складений первинний ключ. Створення таблиці-довідника `Game_Result` дозволило винести повторювані текстові мітки в окрему сутність, реалізувавши принцип **«Єдиного джерела істини»** (Single Source of Truth). Оновлена схема повністю готова до високих навантажень та подальшого розширення бізнес-логіки.
