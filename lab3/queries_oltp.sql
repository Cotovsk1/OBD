INSERT INTO Player (username, email, password_hash, rating) VALUES
('Stockfish_Lvl_1', 'bot1@chess-engine.local', 'bot_pass', 800),
('Stockfish_Lvl_8', 'bot8@chess-engine.local', 'bot_pass', 3200),
('Oksana_Chess', 'oksana.play@ukr.net', 'hashed_pass_4', 1950),
('Kyiv_Tactician', 'kyiv.tact@gmail.com', 'hashed_pass_5', 2100),
('NoobSlayer2026', 'slayer@example.com', 'hashed_pass_6', 1100),
('Vasyl_Master', 'vasyl.m@ukr.net', 'pass_vasyl_123', 1850);

INSERT INTO Time_Control (name, initial_time_sec, increment_sec) VALUES
('Bullet 2+1', 120, 1),
('Blitz 3+2', 180, 2),
('Classical 90+30', 5400, 30);

INSERT INTO Tournament (title, start_date) VALUES
('Summer Online Open', '2026-06-01 10:00:00'),
('Beginners Arena', '2026-04-27 15:00:00'),
('Autumn Blitz Championship', '2026-09-10 12:00:00');

INSERT INTO Game (white_player_id, black_player_id, time_control_id, tournament_id, result) VALUES
(6, 7, 5, 1, 'Draw'), 
(8, 4, 3, 3, 'BlackWins'), 
(3, 5, 6, NULL, 'InProgress'), 
(1, 6, 2, NULL, 'WhiteWins'),
INSERT INTO public.game (white_player_id, black_player_id, time_control_id, tournament_id, result) 
VALUES (
    (SELECT MAX(id) FROM public.player),     
    4,                                        
    2,                                        
    (SELECT MAX(id) FROM public.tournament),  
    'InProgress'
);

INSERT INTO Move (game_id, move_number, notation) VALUES
(3, 1, 'e4'),
(3, 2, 'c5'),
(3, 3, 'Nf3'),
(3, 4, 'd6'),
(3, 5, 'd4'),
(3, 6, 'cxd4');

INSERT INTO Move (game_id, move_number, notation) VALUES
(4, 1, 'f3'),
(4, 2, 'e5'),
(4, 3, 'g4'),
(4, 4, 'Qh4#'); -- Мат (BlackWins)

INSERT INTO Friendship (user1_id, user2_id, status) VALUES
(1, 6, 'accepted'),
(6, 7, 'accepted'),
(8, 1, 'pending'), 
(7, 8, 'blocked'); 

-- Select
-- Вивести імена та рейтинги всіх гравців, у яких рейтинг вище 2000
SELECT username, rating 
FROM public.player 
WHERE rating > 2000;

-- Знайти всі ігри, які зараз знаходяться в процесі ('InProgress')
SELECT id, white_player_id, black_player_id, played_at 
FROM public.game 
WHERE result = 'InProgress';

-- Знайти друзів конкретного користувача (наприклад, Андрія, id=1), де запит прийнято
SELECT user2_id, created_at 
FROM public.friendship 
WHERE user1_id = 1 AND status = 'accepted';

-- Update
-- Гравець Andrii_KPI (id=1) виграв партію, оновлюємо його рейтинг (+15 пунктів)
UPDATE public.player 
SET rating = rating + 15 
WHERE id = 1;

-- Гра, яка була 'InProgress' (наприклад, id=2), завершилася внічию
UPDATE public.game 
SET result = 'Draw' 
WHERE id = 2 AND result = 'InProgress';

-- Користувач прийняв запит у друзі (змінюємо 'pending' на 'accepted')
UPDATE public.friendship 
SET status = 'accepted' 
WHERE user1_id = 2 AND user2_id = 3 AND status = 'pending';

-- Delete
-- Видаляємо всі відхилені запити в друзі, щоб очистити базу
DELETE FROM public.friendship 
WHERE status = 'blocked';

-- Видаляємо випадково створений турнір, який ще не розпочався і не має ігор
-- (Припустимо, ми створили тестовий турнір з назвою 'Test')
INSERT INTO public.tournament (title, start_date) VALUES ('Test Tournament', '2026-12-31 23:59:59'); -- створюємо для тесту видалення

DELETE FROM public.tournament 
WHERE title = 'Test Tournament';

