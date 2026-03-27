-- 1. Створення таблиць
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

-- 2. Заповнення таблиць даними
INSERT INTO Player (username, email, password_hash, rating) VALUES
('Andrii_KPI', 'aistratij85@gmail.com', 'hashed_pass_1', 1600),
('FrontEnd_Dev', 'partner@kpi.edu', 'hashed_pass_2', 1450),
('GrandMaster', 'gm@example.com', 'hashed_pass_3', 2500);

INSERT INTO Time_Control (name, initial_time_sec, increment_sec) VALUES
('Bullet 1+0', 60, 0),
('Blitz 5+3', 300, 3),
('Rapid 15+10', 900, 10);

INSERT INTO Tournament (title, start_date) VALUES 
('KPI Spring Cup', '2026-04-15 18:00:00');

INSERT INTO Game (white_player_id, black_player_id, time_control_id, tournament_id, result) VALUES
(1, 2, 3, NULL, 'WhiteWins'),
(3, NULL, 2, NULL, 'InProgress');

INSERT INTO Move (game_id, move_number, notation) VALUES
(1, 1, 'e4'), (1, 2, 'e5'), (1, 3, 'Nf3'), (1, 4, 'Nc6');

INSERT INTO Friendship (user1_id, user2_id, status) VALUES
(1, 2, 'accepted'), (2, 3, 'pending');