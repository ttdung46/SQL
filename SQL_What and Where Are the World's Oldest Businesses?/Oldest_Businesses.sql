
--1. Select the oldest and newest founding years
SELECT MIN(year_founded) oldest_founding_years,
        MAX(year_founded) newest_founding_year
FROM businesses;

--2. How many businesses where the founding year was before 1000
SELECT COUNT(business)
FROM businesses
WHERE year_founded < 1000;

--3. Which businesses were founded before 1000?
SELECT  business,
        year_founded,
        b.country_code,
        category
FROM businesses AS b
    LEFT JOIN countries AS c 
    ON b.country_code = c.country_code
    LEFT JOIN categories AS ca
    ON b.category_code = ca.category_code
WHERE year_founded <1000
ORDER BY year_founded;


--4. Counting the categories
SELECT  category, 
        COUNT(category) as number_category
FROM businesses as b
LEFT JOIN categories as ca
    ON b.category_code = ca.category_code
GROUP BY category
ORDER BY number_category DESC;

--5. Oldest business by continent
SELECT  MIN(year_founded) as oldest,
        continent
FROM businesses as b 
INNER JOIN countries  as c
ON b.country_code = c.country_code
GROUP BY continent
ORDER BY oldest;

--6. Filtering counts by continent and category
SELECT  continent,
        category,
        COUNT(business) as n
FROM businesses as b
    LEFT JOIN categories as ca
        ON b.category_code = ca.category_code
    LEFT JOIN countries as c
        ON b.country_code = c.country_code
GROUP BY continent, category
HAVING  COUNT(business) > 5
ORDER BY n DESC;