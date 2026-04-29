SELECT COUNT(*) AS total_players FROM Player;

SELECT 
    AVG(rating) AS average_rating, 
    MAX(rating) AS highest_rating, 
    MIN(rating) AS lowest_rating 
FROM Player;

SELECT result, COUNT(*) AS games_count
FROM Game
GROUP BY result;

SELECT game_id, COUNT(*) AS total_moves
FROM Move
GROUP BY game_id;

SELECT g.id, p1.username AS white_player, p2.username AS black_player, tc.name AS mode
FROM Game g
JOIN Player p1 ON g.white_player_id = p1.id
JOIN Player p2 ON g.black_player_id = p2.id
JOIN Time_Control tc ON g.time_control_id = tc.id;

SELECT p.username, t.title AS tournament_title
FROM Player p
LEFT JOIN Game g ON p.id = g.white_player_id OR p.id = g.black_player_id
LEFT JOIN Tournament t ON g.tournament_id = t.id;

SELECT p1.username AS user_a, p2.username AS user_b, f.status
FROM Player p1
FULL JOIN Friendship f ON p1.id = f.user1_id
FULL JOIN Player p2 ON f.user2_id = p2.id;

SELECT username, rating
FROM Player
WHERE rating > (SELECT AVG(rating) FROM Player);

SELECT t.title, 
       (SELECT COUNT(*) FROM Game g WHERE g.tournament_id = t.id) AS games_in_tournament
FROM Tournament t;

SELECT tc.name, COUNT(g.id) as usage_count
FROM Time_Control tc
JOIN Game g ON tc.id = g.time_control_id
GROUP BY tc.name
HAVING COUNT(g.id) > (
    SELECT COUNT(*) / COUNT(DISTINCT time_control_id) FROM Game
);

SELECT p.username, COUNT(g.id) AS games_played
FROM Player p
JOIN Game g ON p.id = g.white_player_id OR p.id = g.black_player_id
GROUP BY p.username
HAVING COUNT(g.id) > 10;
