CREATE DATABASE Movies;
USE Movies;
CREATE TABLE movies (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255),
  rating VARCHAR(255),
  genre VARCHAR(255),
  year INT,
  released VARCHAR(255),
  score FLOAT,
  votes FLOAT,
  director VARCHAR(255),
  writer VARCHAR(255),
  star VARCHAR(255),
  country VARCHAR(255),
  budget FLOAT,
  gross FLOAT,
  company VARCHAR(255),
  runtime FLOAT
);

-- Looking the dataset
SELECT * 
FROM movies;

-- Checking missing data
SELECT *
FROM movies
WHERE name is null
OR rating is null
OR genre is null
OR year is null
OR released is null
OR score is null
OR votes is null
OR director is null
OR writer is null
OR star is null
OR country is null
OR budget is null
OR gross is null
OR company is null
OR runtime is null;

-- Checking if the year column match with the released column
SELECT year, released
FROM movies;

SELECT year,
SUBSTR(released, INSTR(released, ',') +2, 4) AS year_corrected,
SUBSTR(released, 1, INSTR(released, '(')-2) AS date_corrected
FROM movies;

-- Creating a year corrected column
ALTER TABLE movies
ADD DateReleased VARCHAR(255);

UPDATE movies
SET DateReleased = SUBSTR(released, 1, INSTR(released, '(')-2);

ALTER TABLE movies
ADD year_corrected int;

UPDATE movies
SET year_corrected = SUBSTR(DateReleased, -4);

-- Checking double data
SELECT *,
ROW_NUMBER() OVER(PARTITION BY score, votes, director, writer, star, company
					ORDER BY name) row_num
FROM movies
ORDER BY row_num DESC;

-- Checking outliers
SELECT *
FROM movies
ORDER BY gross DESC;

SELECT *
FROM movies
ORDER BY budget DESC;

-- Checking budget and gross relationship -- scatterplot or heatmap
SELECT budget, gross
FROM movies
ORDER BY gross;

-- Checking score and gross relationship
SELECT score, ROUND(AVG(gross), 2)
FROM movies
GROUP BY score
ORDER BY gross;

-- Checking rating and gross relationship
SELECT rating, ROUND(AVG(gross), 2) AS "average gross"
FROM movies
GROUP BY rating;

-- Checking rating and budget relationship
SELECT rating, ROUND(AVG(budget), 2) as "average budget"
FROM movies
GROUP BY rating;

-- Checking star and budget relationship
SELECT star, ROUND(AVG(budget), 2) AS "average budget"
FROM movies
GROUP BY star
ORDER BY 2 DESC;

-- Checking director and budget relationship
SELECT director, ROUND(AVG(budget), 2) AS "average budget"
FROM movies
GROUP BY director
ORDER BY 2 DESC;

-- Checking writer and budget relationship
SELECT writer, ROUND(AVG(budget), 2) AS "average budget"
FROM movies
GROUP BY writer
ORDER BY 2 DESC;

-- Checking writer and gross relationship
SELECT writer, ROUND(AVG(gross), 2) AS "average gross"
FROM movies
GROUP BY writer
ORDER BY 2 DESC;

-- Checking director and gross relationship
SELECT director, ROUND(AVG(gross), 2) AS "average gross"
FROM movies
GROUP BY director
ORDER BY 2 DESC;

-- Checking star and gross relationship
SELECT star, ROUND(AVG(gross), 2) AS "average gross"
FROM movies
GROUP BY star
ORDER BY 2 DESC;

-- Checking company and budget relationship
SELECT company, ROUND(AVG(budget), 2) AS "average budget"
FROM movies
GROUP BY company
ORDER BY 2 DESC;

-- Looking the companies with higher profit
SELECT company, ROUND(AVG(gross), 2) AS "average gross"
FROM movies
GROUP BY company
ORDER BY 2 DESC;

-- Checking budget and gross along the years
SELECT ROUND(AVG(budget), 2) AS "average budget", 
ROUND(AVG(gross),2) AS "average gross", year_corrected
FROM movies
GROUP BY year_corrected
ORDER BY year_corrected;
