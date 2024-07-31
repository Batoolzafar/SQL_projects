-- DATA CLEANING -- 
-- 1-Remove Duplicates
-- 2-Standardize the columns 
-- 3-Null Values or blank values
-- 4-Removing columns that are not neccesary

# DUPLICATING THE RAW DATA
create table layoff_staging
like layoffs;
select * from layoff_staging;
insert into layoff_staging
select * from layoffs;

# HANDLING THE DUPLICATE VALUES
-- Assigning Row NUmbers 
select *,
row_number() over() as row_num 
from layoff_staging;

-- Checking for Duplicates
select *,
row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num 
from layoff_staging;


WITH duplicates_cte1
AS
(
select *,
row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num 
from layoff_staging
)
SELECT * FROM duplicates_cte1 WHERE row_num > 1;

-- Creating a new table with the column of row numbers 
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

-- Deleting Duplicate Rows
SELECT * 
FROM layoff_staging6 
WHERE row_num > 1;

DELETE FROM layoff_staging6 
WHERE row_num > 1;

# STANDARDIZING THE COLUMNS
-- Company
SELECT company,trim(company) FROM layoff_staging6;
UPDATE layoff_staging6
set company = trim(company);


-- Industry  
SELECT 
DISTINCT industry 
FROM layoff_staging6 ORDER BY 1 ;

SELECT *
FROM layoff_staging6
where industry LIKE "Crypto%"
;
UPDATE layoff_staging6
SET industry = "Crypto"
WHERE industry LIKE "Crypto%";


-- LOCATION
SELECT DISTINCT location 
FROM layoff_staging6 
order by 1; -- no issue

-- COUNTRY 
SELECT DISTINCT country 
FROM layoff_staging6 
order by 1;

SELECT DISTINCT country , TRIM(TRAILING "." FROM country) 
FROM layoff_staging6 
order by 1;


UPDATE layoff_staging6
SET country = TRIM(TRAILING "." FROM country) 
WHERE country LIKE 'United States%';


-- DATE column

SELECT DISTINCT(`date`) 
FROM layoff_staging6;

SELECT DISTINCT(`date`),STR_TO_DATE(`date`,"%m/%d/%Y")
FROM layoff_staging6;
-- changing date format
UPDATE layoff_staging6
SET `date` = STR_TO_DATE(`date`,"%m/%d/%Y");
-- changing date datatype (NEVER TO THIS ON RAW DATA)
ALTER TABLE layoff_staging6
MODIFY COLUMN `date` DATE;



# HANDLING NULL VALUES

-- Null values in Industry column
SELECT industry FROM layoff_staging6;
SELECT * FROM layoff_staging6
WHERE industry IS NULL
OR  industry = '' ;

update layoff_staging6
set industry = NULL 
WHERE industry = "";

-- Same Companies in same location belong to same industry
select company,industry 
from layoff_staging6 
group by company,industry order by company;
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
drop column row_num; -- not required

-- total_laid_off and percentage_laid_off

select *  
from layoff_staging6 
where total_laid_off is null and percentage_laid_off is null;

delete 
from layoff_staging6 
where total_laid_off is null and percentage_laid_off is null;