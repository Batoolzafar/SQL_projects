-- DATA CLEANING -- 
-- 1-Remove Duplicates
-- 2-Standardize the columns 
-- 3-Null Values or blank values
-- 4-Removing columns that are not neccesary

-- the very first step is to create a duplicate of the raw data because in real world we are changing the data alot so we need the actual data to keep the side safe
create table layoff_staging
like layoffs;
select * from layoff_staging;
insert into layoff_staging
select * from layoffs;

-- Assigning row numbers for duplicates
select *,
row_number() over() as row_num -- doesn't help in checking duplicates
from layoff_staging;
-- we remember from previous analysis that there are unique row_number sequence assigned to each partition we may create partitions on most of or all the columns to see if any two or more rows are under the same partition or repeated
select *,
row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num 
from layoff_staging;
-- the row_num is not added into the layoff_staging, so to check for duplicates we need to use  CTE or subquery to use the data retrieved by adding the row number
WITH duplicates_cte1
AS
(
select *,
row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num 
from layoff_staging
)
SELECT * FROM duplicates_cte1 WHERE row_num > 1;
-- we have to delete one of the duplicated rows

-- the problem in deleting is that now i can not select the same CTE and apply the same delete method because update is not possible 
-- and it will never delete the rows from actual data too because it's the CTE 
-- Therefore we have used another strategy like we are going to create the same table again or to be specific we are just saving the data from CTE into a table to make it useable
CREATE TABLE `layoff_staging6` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int -- added
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `layoff_staging6`
select *,
row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num 
from layoff_staging;

SELECT * FROM layoff_staging6 WHERE row_num > 1;
DELETE FROM layoff_staging6 WHERE row_num > 1;




-- STANDARDIZING COLUMNS 
-- company column
SELECT company,trim(company) FROM layoff_staging6;
UPDATE layoff_staging6
set company = trim(company);
-- industry column
SELECT DISTINCT industry FROM layoff_staging6 ORDER BY 1 ;
SELECT *
FROM layoff_staging6
where industry LIKE "Crypto%"
;
UPDATE layoff_staging6
SET industry = "Crypto"
WHERE industry LIKE "Crypto%";

SELECT * FROM layoff_staging6;

-- LOCATION Column
SELECT DISTINCT location FROM layoff_staging6 order by 1;
-- no visible issue

-- COUNTRY Column
SELECT DISTINCT country FROM layoff_staging6 order by 1;
SELECT DISTINCT country , TRIM(TRAILING "." FROM country) FROM layoff_staging6 order by 1;


UPDATE layoff_staging6
SET country = TRIM(TRAILING "." FROM country) 
WHERE country LIKE 'United States%';

-- DATE column

SELECT DISTINCT(`date`) FROM layoff_staging6;
SELECT DISTINCT(`date`),STR_TO_DATE(`date`,"%m/%d/%Y")
FROM layoff_staging6;
-- changing date format
UPDATE layoff_staging6
SET `date` = STR_TO_DATE(`date`,"%m/%d/%Y");
-- changing date datatype (NEVER TO THIS ON RAW DATA)
ALTER TABLE layoff_staging6
MODIFY COLUMN `date` DATE;


-- DEALING WITH THE NULL VALUES
SELECT * FROM layoff_staging6
WHERE total_laid_off IS NULL;

SELECT * FROM layoff_staging6
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- null values in industry
SELECT * FROM layoff_staging6
WHERE industry IS NULL
OR  industry = '' ;
SELECT industry FROM layoff_staging6;

-- checking for null values= we got to know there are only four one null remaining empty
-- making all null
update layoff_staging6
set industry = NULL 
WHERE industry = "";
-- the comapnies with no defined industries are already there in data where industries are defined hence they will be given the same
select * from layoff_staging6 where company = "Airbnb";
select * from layoff_staging6 where company = "Bally's Interactive";
select * from layoff_staging6 where company = "Carvana";
select * from layoff_staging6 where company = "Juul";

select company,industry from layoff_staging6 group by company,industry order by company;

-- same companies ---> same industries
-- update if industry of company x = NULL ---> set industry = industry of company x' (self join logic)

-- This gives a table where we are able to compare the industries where the companies and location are same 
SELECT t1.industry,t2.industry
from layoff_staging6 as t1
join layoff_staging6 as t2
	on t1.company = t2.company and t1.location = t2.location
where t1.industry is null and t2.industry is not null;

update layoff_staging6 as t1
join layoff_staging6 as t2
	on t1.company = t2.company and t1.location = t2.location
set t1.industry = t2.industry    
where t1.industry is null and t2.industry is not null;
select * from layoff_staging6 where industry is null;

alter table layoff_staging6
drop column row_num;


select *  from layoff_staging6 where total_laid_off is null and percentage_laid_off is null;

delete from layoff_staging6 where total_laid_off is null and percentage_laid_off is null;
-- this is a great logic but unfourtunately total laid off and the percentage laid off are not related to each other in a way their name suggest and percentage laid off is the percentage of laid off out of the total number employees that might be in the company which is not known
-- if total_laid_off is null and percentage_total_laid_of is not null then p*100.
-- if total_laid_off is not null and percentage_laid_of is null then p/100.
-- select * from layoff_staging6 where percentage_laid_off is null;
-- update layoff_staging6
-- set percentage_laid_off = total_laid_off/100
-- where percentage_laid_off is null and total_laid_off IS NOT NULL;
-- select total_laid_off,percentage_laid_off from layoff_staging6 ;


-- UPDATE layoff_staging6
-- SET percentage_laid_off = total_laid_off / 100
-- WHERE total_laid_off IS NOT NULL
--   AND percentage_laid_off IS NULL;

-- UPDATE layoff_staging6
-- SET total_laid_off = percentage_laid_off * 100
-- WHERE total_laid_off IS NULL
--   AND percentage_laid_off IS NOT NULL;


 SELECT company FROM layoff_staging6 order by company desc;


