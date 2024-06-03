-- 1. Review Data
SELECT * FROM world_layoff.layoffs;

Use world_layoff;
-- In real world, any dataset must be extracting data from another suorce. Making cleaning oriented chnages on row data directly may invite unnecessary hazards. 
-- To avoid, create duplicate dataset/staging.

Create table layoff_staging 
like layoffs;

Select * from layoff_staging; -- Verify the duplication of the table.

Insert layoff_staging 
select * from layoffs; -- Data has been loaded, verifed by running upper query.

-- As this dataset didn't contain any primary key to verify duplicates, the way of working with them is little different. 
-- To check duplicate use row_number to count duplicates rows based on the applied over partition by 
Select *, 
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off,'date', stage, country, funds_raised_millions) 
as Row_num
from layoff_staging;
-- After finding duplicate row, it's time to delete it

With duplicate_cte as
(
Select *, 
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) 
as Row_num
from layoff_staging
)
select * from duplicate_cte
where Row_num >1;

-- another way of checking duplicate rows
/* SELECT *
FROM layoff_staging
GROUP by 'company', location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
having count(*)>1;
*/

Select * from layoff_staging
where Company = "Yahoo"; -- Verify outcomes

Create table layoffs_staging2
(
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
);

Select * from layoffs_staging2;

-- Insert all data from layoff_staging table
Insert into layoffs_staging2
Select *, 
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) 
as row_num
from layoff_staging;

-- verify outcome
Select * from layoffs_staging2
where row_num >1;

Set SQL_SAFE_UPDATES = 0;

Savepoint sp1;

-- Delete all rows with more than 1 duplicate rows
Delete from layoffs_staging2
where row_num >1;

-- Standardizing data --
-- In company there are a white space. It's time to remove them.
Select company, TRIM(company)
from layoffs_staging2;

Update layoffs_staging2
set company = TRIM(company);

-- Let's check for industry 
Select Distinct industry
from layoffs_staging2; -- there are many entry in industry with similar industry like crypto, cryptocurrency

Select * from layoffs_staging2
where industry like 'Crypto%';
-- Let's update all Crypto% with Crypto

Update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

-- Let's verify for other columns as well. Time for country
Select Distinct country
from layoffs_staging2;

Update layoffs_staging2
set country = 'United States'
where country like 'United States%'; -- Select Distinct country, TRIM(Trailing(.) from country) from layoffs_staging2

-- Next column is date, rightnow it is in string format. Let's update.

ALTER TABLE layoffs_staging2 ADD COLUMN date_temp DATE;
UPDATE layoffs_staging2
SET date_temp = STR_TO_DATE(`date`, '%m/%d/%y');
SELECT `date`, date_temp FROM layoffs_staging2;
ALTER TABLE layoffs_staging2 DROP COLUMN `date`;
ALTER TABLE layoffs_staging2 CHANGE COLUMN date_temp `date` DATE;

-- NULL Values --

Select * from layoffs_staging2 where country is NULL; -- No null
Select * from layoffs_staging2 where company is NULL; -- no null
Select * from layoffs_staging2 where location is NULL; -- no null
Select * from layoffs_staging2 where total_laid_off is NULL; -- many more rows, can't replace or delete it
Select * from layoffs_staging2 where percentage_laid_off is NULL; -- many more rows, can't replace or delete it
Select * from layoffs_staging2 where funds_raised_millions is NULL; -- many more rows, can't replace or delete it
Select * from layoffs_staging2 where stage is NULL; 
Select * from layoffs_staging2 where industry is NULL; -- Only 1 data is null, let's check for blank data
Select * 
from layoffs_staging2
where industry is null 
or industry = ""; -- only 4 rows, let's see if we can replace it using same company and location information.

Select * 
from layoffs_staging2
where company = "Bally's Interactive"; -- using this query, I came to know that industry is listed for same company and location, so we can populate this data

-- Let's see all those data is populatable or not using select statement.
Select *
from layoffs_staging2 t1
Join layoffs_staging2 t2
on t1.company = t2.company
and t1.location = t2.location
where (t1.industry is NULL OR t1. industry = "")
and t2.industry is not null;

savepoint sp2; 

-- Here we have null and blank industry both so let's replace all with null
Update layoffs_staging2 
set industry = null
where industry ="";

-- Time to update indystry using self join
Update layoffs_staging2 t1
Join layoffs_staging2 t2
on t1.company = t2.company
and t1.location = t2.location 
set t1.industry = t2.industry
where t1.industry is NULL
and t2.industry is not null;

-- Let's verify 
Select * from layoffs_staging2
where industry is null; -- There is one company Bally's Interactive from location Providence is not a part of population (no industry data is available)

-- During null vale verification, there are companies with null values in both total_laid_off and percntage_laid_off -- which is not really helpful data for analysis
-- Let's check

Select * 
from layoffs_staging2
where total_laid_off is null 
and percentage_laid_off is null; -- total 361 rows -- suggests no layoffs or unknown layoffs, but not really useful data for layoff analysis

Delete from layoffs_staging2
where total_laid_off is null 
and percentage_laid_off is null;

Select * from layoffs_staging2;
-- as we added row_num from our end to check duplicate data, it is unnecessary column after deleting duplicate rows
-- let's delete it

Alter table layoffs_staging2
Drop column row_num;

Savepoint sp3;

Select * from layoffs_staging2;