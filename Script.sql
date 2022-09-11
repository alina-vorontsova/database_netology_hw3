-- CREATE-запросы
CREATE TABLE IF NOT EXISTS Musician (
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS Genre (
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS MusicianGenre (
	musician_id INTEGER NOT NULL REFERENCES Musician(id),
	genre_id INTEGER NOT NULL REFERENCES Genre(id),
	CONSTRAINT pk_mg PRIMARY KEY (musician_id, genre_id)
);

CREATE TABLE IF NOT EXISTS Album (
	id SERIAL PRIMARY KEY,
	name VARCHAR(200) UNIQUE NOT NULL,
	release_year INTEGER NOT NULL CONSTRAINT album_release_year CHECK (release_year > 0)
);

CREATE TABLE IF NOT EXISTS AlbumMusician (
	musician_id INTEGER NOT NULL REFERENCES Musician(id),
	album_id INTEGER NOT NULL REFERENCES Album(id),
	CONSTRAINT pk_am PRIMARY KEY (musician_id, album_id)
);

CREATE TABLE IF NOT EXISTS Song (
	id SERIAL PRIMARY KEY,
	name VARCHAR(200) UNIQUE NOT NULL,
	album_id INTEGER NOT NULL REFERENCES Album(id),
	duration INTEGER NOT NULL CONSTRAINT song_duration CHECK (duration > 0) -- в секундах 
);

CREATE TABLE IF NOT EXISTS Compilation (
	id SERIAL PRIMARY KEY,
	name VARCHAR(200) UNIQUE NOT NULL,
	release_year INTEGER NOT NULL CONSTRAINT compilation_release_year CHECK (release_year > 0)
);

CREATE TABLE IF NOT EXISTS SongCompilation (
	compilation_id INTEGER NOT NULL REFERENCES Compilation(id),
	song_id INTEGER NOT NULL REFERENCES Song(id),
	CONSTRAINT pk_sc PRIMARY KEY (compilation_id, song_id)
); 

-- INSERT-запросы 
-- не менее 8 исполнителей
INSERT INTO Musician (name)
VALUES 
	('David Bowie'), 
	('Iggy Pop'),
	('Oasis'),
	('The Smiths'),
	('Brand New'),
	('The Cure'),
	('Blur'),
	('My Chemical Romance');

-- не менее 5 жанров
INSERT INTO Genre (name)
VALUES 
	('britpop'),
	('rock'),
	('glam rock'),
	('new wave'),
	('alternative');

-- не менее 8 альбомов
INSERT INTO Album (name, release_year)
VALUES 
	('Heroes', 2020), -- неверный год, чтобы соответствовать условию выборки
	('Lust for Life', 1977),
	('Definitely Maybe', 2019), -- неверный год, чтобы соответствовать условию выборки
	('The Queen is Dead', 1986), 
	('Deja Entendu', 2003), 
	('Wish', 2018), -- неверный год, чтобы соответствовать условию выборки
	('Parklife', 1994),
	('Three Cheers for Sweet Revenge', 2018); -- неверный год, чтобы соответствовать условию выборки 

-- не менее 15 треков
INSERT INTO Song (name, album_id, duration)
VALUES
	('Heroes', 1, 453),
	('V-2 Schneider', 1, 191),
	('The Passenger', 2, 281),
	('Tonight', 2, 220),
	('Live Forever', 3, 285),
	('Supersonic', 3, 283),
	('There Is a Light That Never Goes Out', 4, 215),
	('Bigmouth Strikes Again', 3, 212),  -- неверный альбом, чтобы соответствовать условию выборки
	('The Quiet Things That No One Ever Knows', 5, 241),
	('The Boy Who Blocked His Own Shot', 5, 279),
	('High', 6, 213),
	('A Letter to my Elise', 6, 311), -- неверное название, чтобы соответствовать условию выборки
	('Girls & Boys', 7, 291), 
	('Parklife', 7, 186), 
	('To the End', 8, 181),
	('My Interlude', 8, 57); -- неверное название, чтобы соответствовать условию выборки 

-- не менее 8 сборников
INSERT INTO Compilation (name, release_year)
VALUES 
	('Compilation1', 2000),
	('Compilation2', 2002),
	('Compilation3', 2005),
	('Compilation4', 2008),
	('Compilation5', 2013),
	('Compilation6', 2018),
	('Compilation7', 2020),
	('Compilation8', 2021);

-- исполнители с альбомами
INSERT INTO AlbumMusician (musician_id, album_id)
VALUES 
	(1, 1),
	(2, 2),
	(3, 3),
	(4, 4),
	(5, 5),
	(6, 6),
	(7, 7),
	(8, 8);

-- исполнители с жанрами
INSERT INTO MusicianGenre (musician_id, genre_id)
VALUES 
	(1, 3),
	(2, 3),
	(3, 1),
	(4, 4),
	(5, 2),
	(5, 5),
	(6, 4),
	(7, 1),
	(8, 2),
	(8, 5);

-- сборники с треками
INSERT INTO SongCompilation (compilation_id, song_id)
VALUES 
	(1, 1),
	(1, 2),
	(2, 3),
	(2, 4),
	(3, 5),
	(3, 6),
	(4, 7),
	(4, 8),
	(5, 9),
	(5, 10),
	(6, 11),
	(6, 12),
	(7, 13),
	(7, 14),
	(8, 15);

-- SELECT-запросы
-- количество исполнителей в каждом жанре
SELECT name, COUNT(name) FROM Genre AS g
LEFT JOIN MusicianGenre AS mg ON g.id = mg.genre_id 
GROUP BY g.name
ORDER BY COUNT(name) DESC;

-- количество треков, вошедших в альбомы 2019-2020 годов
-- v.1 вывод названия треков из альбомов и года выхода
SELECT s.name, a.release_year FROM Album AS a
LEFT JOIN Song AS s ON s.album_id = a.id
WHERE a.release_year = 2019 OR a.release_year = 2020;

-- v.2 вывод названия альбомов, вышедших в 2019-2020 годах и количества треков в них 
SELECT a.name, COUNT(s.name) FROM Song AS s
LEFT JOIN Album AS a ON a.id = s.album_id
WHERE a.release_year = 2019 OR a.release_year = 2020
GROUP BY a.name
ORDER BY COUNT(s.name) DESC;

-- средняя продолжительность треков по каждому альбому (в секундах)
SELECT a.name, AVG(duration) FROM Song AS s 
LEFT JOIN Album AS a ON a.id = s.album_id 
GROUP BY a.name
ORDER BY AVG(duration) DESC;

-- все исполнители, которые не выпустили альбомы в 2020 году
-- v.1 
SELECT m.name FROM Musician AS m
LEFT JOIN AlbumMusician AS am ON am.musician_id = m.id
LEFT JOIN Album AS a ON a.id = am.album_id 
WHERE release_year NOT IN (
	SELECT release_year FROM Album 
	WHERE release_year = 2020);

-- v.2 сначала написала так, но после разбора вопроса в ТГ изменила на v.1, хотя не очень понимаю, в чём разница 
SELECT m.name FROM Musician AS m
LEFT JOIN AlbumMusician AS am ON am.musician_id = m.id
LEFT JOIN Album AS a ON a.id = am.album_id 
WHERE release_year != 2020;

-- названия сборников, в которых присутствует конкретный исполнитель (выберите сами)
SELECT DISTINCT c.name FROM Compilation AS c 
LEFT JOIN SongCompilation AS sg ON sg.compilation_id = c.id 
LEFT JOIN Song AS s ON s.id = sg.song_id 
LEFT JOIN Album AS a ON a.id = s.album_id 
LEFT JOIN AlbumMusician AS am ON am.album_id = a.id 
LEFT JOIN Musician AS m ON m.id = am.musician_id 
WHERE m.name = 'Oasis';

-- название альбомов, в которых присутствуют исполнители более 1 жанра
SELECT a.name FROM Album AS a
LEFT JOIN AlbumMusician AS am ON am.album_id = a.id 
LEFT JOIN Musician AS m ON m.id = am.musician_id
LEFT JOIN MusicianGenre AS mg ON mg.musician_id = m.id 
LEFT JOIN Genre AS g ON g.id = mg.genre_id
GROUP BY a.name 
HAVING COUNT(g.name) > 1;

-- наименование треков, которые не входят в сборники
SELECT s.name FROM Song AS s
LEFT JOIN SongCompilation AS sg ON sg.song_id = s.id 
WHERE sg.song_id IS NULL;

-- исполнителя(-ей), написавшего самый короткий по продолжительности трек (теоретически таких треков может быть несколько)
SELECT m.name, s.name, MIN(duration) FROM Song AS s
LEFT JOIN Album AS a ON a.id = s.album_id 
LEFT JOIN AlbumMusician AS am ON am.album_id = a.id 
LEFT JOIN Musician AS m ON m.id = am.musician_id
GROUP BY m.name, s.name, duration
HAVING duration = (SELECT MIN(duration) FROM Song);

-- название альбомов, содержащих наименьшее количество треков
SELECT DISTINCT a.name FROM Album AS a
LEFT JOIN Song AS s ON s.album_id = a.id 
WHERE s.album_id IN (
	SELECT 	album_id FROM Song 
	GROUP BY album_id
	ORDER BY COUNT(id)
	LIMIT 1); 