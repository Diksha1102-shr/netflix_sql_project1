-- Netflix Project
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id VARCHAR(6),
    type    VARCHAR(10),
    title    VARCHAR(150),
    director VARCHAR(208),
    castS	 VARCHAR(1000),
    country  VARCHAR(150),
    date_added VARCHAR(50),
    release_year INT,
    rating	     VARCHAR(10),
    duration	 VARCHAR(15),
    listed_in    VARCHAR(100),
    description  VARCHAR(250)
);

-- To verify Table
SELECT * FROM netflix;

SELECT
     COUNT(*) as total_content 
FROM netflix;

SELECT 
   DISTINCT casts
FROM netflix;

SELECT 
   DISTINCT type
FROM netflix;

-- 15 business problem question 

Select * FROM netflix WHERE type='Movie';
-- Question 1: Count the number of Movies vs TV Shows
SELECT type, COUNT(*) as total_content FROM netflix GROUP BY type;

-- Question 2: Find the most common rating for movies and TV shows
SELECT
    type,
    rating
FROM (
    SELECT
        type,
        rating,
        COUNT(*) AS cnt,
        RANK() OVER (
            PARTITION BY type
            ORDER BY COUNT(*) DESC
        ) AS ranking
    FROM netflix
    GROUP BY 1, 2
) as t1
WHERE 
    ranking = 1

-- Question 3: List all movies released in a specific year (e.g., 2020)
-- filter 2020
-- movies 
SELECT * FROM netflix WHERE  type = 'Movie' AND  release_year = 2020

-- Question 4: Find the top 5 countries with the most content on Netflix

SELECT
    UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Question 5: Identify the longest movie
SELECT * FROM netflix
WHERE 
    type = 'Movie'
	AND
	duration = (Select MAX(duration) FROM netflix)

-- Question 6: Find content added in the last 5 years
 
-- converting date columns from 'month date, year' written in text to writte in numbers 'MM/DD/YY'.
SELECT *,
TO_DATE(date_added, 'Month DD, YYYY') FROM netflix
--final query
SELECT * FROM netflix WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'


--Question 7: Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT * FROM netflix WHERE  director ILIKE '%Rajiv Chilaka%'

-- Question 8: List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE 
     type = 'TV Show'
	 AND
     SPLIT_PART(duration, ' ', 1)::NUMERIC > 5 

-- Question 9: Count the number of content items in each genre
SELECT 
UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
COUNT(show_id) as total_content
FROM netflix
GROUP BY 1

-- Question 10: Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
SELECT 
EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
COUNT(*),
ROUND(
COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India') * 100 ,2) AS avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1

-- Question 11: List all movies that are documentaries
SELECT * FROM netflix WHERE listed_in ILIKE '%documentaries%'

-- Question 12:  Find all content without a director
SELECT * FROM netflix WHERE director IS NULL 

-- Question 13:  Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * FROM netflix
WHERE
casts ILIKE '%Salman Khan%'
AND 
release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 14

---- Question 14:  Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
--show_id,
--casts,
UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
COUNT(*) as total_content
FROM netflix 
WHERE country ILIKE '%India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

--Question 15: Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

WITH new_table 
AS
( 
SELECT 
*, 
  CASE 
  WHEN 
      description ILIKE '%kill%' OR
	  description ILIKE '%violence%' THEN 'Bad_Content'
	  ELSE 'Good_Content'
  END category 
FROM netflix
)
SELECT category,
COUNT(*) AS total_content
FROM new_table 
GROUP BY 1