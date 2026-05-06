CREATE TABLE Player (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    rating INT NOT NULL CHECK (rating >= 100) DEFAULT 1200
);

-- Таблиця налаштувань контролю часу
CREATE TABLE Time_Control (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    initial_time_sec INT NOT NULL,
    increment_sec INT NOT NULL
);

-- Таблиця шахових турнірів
CREATE TABLE Tournament (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    start_date TIMESTAMP NOT NULL
);

-- Нова таблиця-довідник для результатів ігор (Забезпечує вимоги 3NF)
CREATE TABLE Game_Result (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,       -- Код для логіки (напр. 'WhiteWins')
    description VARCHAR(50) NOT NULL       -- Зрозумілий опис (напр. 'Перемога білих')
);

-- Таблиця шахових партій (ігор)
CREATE TABLE Game (
    id SERIAL PRIMARY KEY,
    white_player_id INT NOT NULL REFERENCES Player(id) ON DELETE RESTRICT,
    black_player_id INT REFERENCES Player(id) ON DELETE RESTRICT,
    time_control_id INT NOT NULL REFERENCES Time_Control(id) ON DELETE RESTRICT,
    tournament_id INT REFERENCES Tournament(id) ON DELETE SET NULL,
    result_id INT REFERENCES Game_Result(id) ON DELETE RESTRICT, -- Зв'язок з довідником замість TEXT
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблиця ходів (Оптимізовано: складений ПК замість сурогатного ID)
CREATE TABLE Move (
    game_id INT NOT NULL REFERENCES Game(id) ON DELETE CASCADE,
    move_number INT NOT NULL CHECK (move_number > 0),
    notation VARCHAR(10) NOT NULL,
    
    -- Складений первинний ключ гарантує унікальність ходу в межах конкретної партії
    PRIMARY KEY (game_id, move_number)
);

-- Таблиця соціальних зв'язків (дружби)
CREATE TABLE Friendship (
    user1_id INT NOT NULL REFERENCES Player(id) ON DELETE CASCADE,
    user2_id INT NOT NULL REFERENCES Player(id) ON DELETE CASCADE,
    status VARCHAR(20) CHECK (status IN ('pending', 'accepted', 'blocked')) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (user1_id, user2_id),
    -- Обмеження для усунення логічної аномалії (не можна додати в друзі самого себе)
    CONSTRAINT chk_not_self_friend CHECK (user1_id <> user2_id)
);
