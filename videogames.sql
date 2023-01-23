
-- game_sales_data definition

CREATE TABLE game_sales_data (
    rank INT,
    name VARCHAR(255),
    platform VARCHAR(255),
    publisher VARCHAR(255),
    developer VARCHAR(255),
    critic_score DECIMAL(3,1),
    user_score DECIMAL(3,1),
    total_shipped INT,
    year INT
);

--Dbeaver data import

-- Select all information for the top ten best-selling games
-- Order the results from best-selling game down to tenth best-selling

SELECT *
FROM game_sales_data gsd 
ORDER BY total_shipped  DESC
LIMIT 10

-- Fix the data by adding NULLs instead of empty cells

UPDATE game_sales_data 
SET user_score  = NULL
WHERE user_score  = '';

UPDATE game_sales_data 
SET critic_score  = NULL
WHERE critic_score  = '';

-- Check how many nulls we have in the ratings/9616

SELECT COUNT(*)
FROM game_sales_data gsd
WHERE critic_score IS NULL 
AND user_score IS NULL

--either rating NULLS/17392
--TOTAL: 19600

SELECT COUNT(*)
FROM game_sales_data gsd 
WHERE critic_score IS NULL 
OR user_score IS NULL


-- Selecting release year and average critic score for each year, rounded and aliased
-- Grouping by release year
-- Ordering the data from highest to lowest avg_critic_score and limiting to 10 results

SELECT year, ROUND(AVG(critic_score),2) as avg_critic_score
FROM game_sales_data gsd
GROUP BY year
ORDER BY AVG(critic_score) DESC
LIMIT 10

-- Update the query so that it only returns years that have more than twenty reviewed games

SELECT year, 
    ROUND(AVG(critic_score),2) as avg_critic_score,
    COUNT(*) as num_games
FROM game_sales_data gsd 
GROUP BY year
HAVING COUNT(*) > 20
ORDER BY AVG(critic_score) DESC
LIMIT 10

-- Selecting the year, an average of user_score, and a count of games released in a given year, aliased and rounded
-- Include only years with more than four reviewed games; group data by year
-- Order data by avg_user_score, and limit to ten results

SELECT year, 
    ROUND(AVG(user_score),2) as avg_user_score,
    COUNT(*) as num_games
FROM game_sales_data gsd 
GROUP BY year
HAVING COUNT(*) > 20
ORDER BY avg_user_score DESC
LIMIT 10


--Intersection of the most top rated games between BOTH critics and users
SELECT a1.year
FROM (
			SELECT year, 
		    ROUND(AVG(critic_score),2) as avg_critic_score,
		    COUNT(*) as num_games
		FROM game_sales_data gsd 
		GROUP BY year
		HAVING COUNT(*) > 20
		ORDER BY AVG(critic_score) DESC
		LIMIT 10
	) a1
JOIN (
			SELECT year, 
		    ROUND(AVG(user_score),2) as avg_user_score,
		    COUNT(*) as num_games
		FROM game_sales_data gsd 
		GROUP BY year
		HAVING COUNT(*) > 20
		ORDER BY avg_user_score DESC
		LIMIT 10
	) a2
	ON a1.year = a2.year
	
-- Select year and sum of games_sold, aliased as total_games_sold; order results by total_games_sold descending
-- Filter game_sales based on whether each year is in the list returned in the previous query

with years as(
SELECT a1.year
FROM 	(
			SELECT year, 
		    ROUND(AVG(critic_score),2) as avg_critic_score,
		    COUNT(*) as num_games
		FROM game_sales_data gsd 
		GROUP BY year
		HAVING COUNT(*) > 20
		ORDER BY AVG(critic_score) DESC
		LIMIT 10
		) a1
	JOIN (
			SELECT year, 
		    ROUND(AVG(user_score),2) as avg_user_score,
		    COUNT(*) as num_games
		FROM game_sales_data gsd 
		GROUP BY year
		HAVING COUNT(*) > 20
		ORDER BY avg_user_score DESC
		LIMIT 10
		) a2
	ON a1.year = a2.year
)
SELECT year, SUM(total_shipped) as total_games_sold
FROM game_sales_data gsd 
GROUP BY year
HAVING year IN (SELECT year from years)
ORDER BY total_games_sold DESC


--Look at the totals and compare

SELECT year, SUM(total_shipped) as total_games_sold
FROM game_sales_data gsd 
GROUP BY year
ORDER BY total_games_sold DESC