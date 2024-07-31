select * from layoff_staging6;
-- Data Range
select max(`date`),min(`date`)
from layoff_staging6;

-- Analyzing the Layoffs 
SELECT MIN(total_laid_off),MIN(percentage_laid_off) FROM layoff_staging6;
SELECT MAX(total_laid_off),MAX(percentage_laid_off) FROM layoff_staging6;

-- LAYOFFS of individual companies 

SELECT company, sum(total_laid_off) AS sum_of_layoffs,sum(funds_raised_millions) total_funds 
FROM layoff_staging6 
GROUP BY company 
ORDER BY 2 desc;
-- -- Company with most layoffs
SELECT company, sum(total_laid_off) AS sum_of_layoffs,sum(funds_raised_millions) total_funds 
FROM layoff_staging6 
GROUP BY company 
ORDER BY 2 desc
LIMIT 1 ;

-- FUNDS of individual companies 

SELECT company, sum(total_laid_off) AS sum_of_layoffs,sum(funds_raised_millions) total_funds 
FROM layoff_staging6 
GROUP BY company 
ORDER BY 3 desc;
-- -- Company with most funds
SELECT company, sum(total_laid_off) AS sum_of_layoffs,sum(funds_raised_millions) total_funds 
FROM layoff_staging6 
GROUP BY company 
ORDER BY 3 desc
LIMIT 1;

-- Companies with 100% laid off
select count(company)
from layoff_staging6 where percentage_laid_off = 1;

-- -- The sum_layoffs here also shows the total employees
select company,percentage_laid_off,SUM(total_laid_off) as sum_layoffs
from layoff_staging6 
where percentage_laid_off = 1 
group by company order by sum_layoffs desc ;

-- Funds raised by Companies with 100% laid off
SELECT company,percentage_laid_off,SUM(funds_raised_millions) AS sum_funds
FROM layoff_staging6
WHERE percentage_laid_off = 1
GROUP BY company, percentage_laid_off
ORDER BY sum_funds DESC;
    
-- Total Layoffs in each country
-- -- The first in sequence is the country with most layoffs
select company,country,
sum(total_laid_off) over(partition by country ) as sum_laid_off_per_country
from layoff_staging6 order by 3 desc; 

-- Total Layoffs in companies within same country and location
-- -- The first in sequence is the location with most layoffs
select company,location,country,
sum(total_laid_off) over(partition by location,country) as sum_laid_off_per_location_and_country
from layoff_staging6 order by 4 desc;

-- Industry wise layoffs 
-- -- The first in sequence is the industry with most layoffs
select company,industry,
sum(total_laid_off) over(partition by industry) as sum_laid_off_per_industry
from layoff_staging6 order by 3 desc;

-- MAX AND MIN layoffs
-- -- companies with minimum layoffs
select * 
from layoff_staging6 
where total_laid_off = (SELECT min(total_laid_off) FROM layoff_staging6);

-- -- companies with maximum layoffs
select * 
from layoff_staging6 
where total_laid_off = (SELECT max(total_laid_off) FROM layoff_staging6);

-- MAX AND MIN funds 
-- -- companies with minimum funds
select * 
from layoff_staging6 
where funds_raised_millions = (SELECT min(funds_raised_millions) FROM layoff_staging6) ;
-- -- companies with maximum funds
select * 
from layoff_staging6 
where funds_raised_millions = (SELECT max(funds_raised_millions) FROM layoff_staging6) ;

-- Years with most layoffs
SELECT YEAR(`date`)
,SUM(total_laid_off) 
FROM layoff_staging6 
GROUP BY  YEAR(`date`)
order by SUM(total_laid_off) desc;

-- Years with most funds
SELECT YEAR(`date`),
SUM(funds_raised_millions) 
FROM layoff_staging6 
GROUP BY  YEAR(`date`)
order by SUM(funds_raised_millions) desc;

-- Layoffs of companies at different stages
select stage,sum(total_laid_off)
from layoff_staging6 group by stage order by 2 desc;

-- Monthly Layoffs each year
SELECT SUBSTRING(`date`,1,7) AS `month`,
SUM(total_laid_off) FROM layoff_staging6  
where SUBSTRING(`date`,1,7) is not null 
GROUP BY `month` ORDER BY 2 ;

-- Running Total
WITH Running_Total AS 
(
SELECT SUBSTRING(`date`,1,7) AS `month`,
SUM(total_laid_off) as sum_layoffs FROM layoff_staging6  
where SUBSTRING(`date`,1,7) is not null 
GROUP BY `month` ORDER BY 1 asc
)
SELECT `month`,sum_layoffs,sum(sum_layoffs) over( order by `month`) as running_Total 
from Running_Total ;


