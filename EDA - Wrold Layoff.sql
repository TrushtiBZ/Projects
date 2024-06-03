-- Exploratory Data Analysis
Use World_layoff;
Select * from layoffs_staging2;

-- Date range
Select min(date), max(date)
from layoffs_staging2;
-- This date range suggests the time period of covid-19.

-- Maximum laid_off in a day
Select max(total_laid_off) 
from Layoffs_staging2; -- OP: 12000

-- Maximum laid_off with its percentage ratio in a day
Select max(total_laid_off), max(percentage_laid_off)
from Layoffs_staging2;

-- How many companies laid_off all employess in the given time period? 
Select count(company)
from layoffs_staging2
where percentage_laid_off = 1; 

Select *
from layoffs_staging2
where percentage_laid_off = 1
Order by total_laid_off DESC;

-- How many employees laid_off from a company?
Select company, sum(total_laid_off)
from layoffs_staging2
Group by company
order by 2 DESC; 

-- Which industry laid-off maximum employee?
Select industry, sum(total_laid_off)
from layoffs_staging2
Group by industry
order by 2 DESC; 

-- Which country laid-off maximum employee?
Select country, sum(total_laid_off)
from layoffs_staging2
Group by country
order by 2 DESC;

Select Year(date), sum(total_laid_off)
from layoffs_staging2
Group by Year(date)
order by 1 DESC; -- laid_offs based on years

Select stage, sum(total_laid_off)
from layoffs_staging2
Group by stage
order by 2 DESC; -- laid_offs based on stage

Select stage, avg(percentage_laid_off)
from layoffs_staging2
Group by stage
order by 2 DESC;  -- % laid_offs based on the stage

Select substring(date,1,7) as month, sum(total_laid_off)
from layoffs_staging2
where substring(date,1,7) is not null
group by month
Order by 1 ASC; -- lay offs based on months

-- Which company raised maximum funds?
Select company, percentage_laid_off, max(funds_raised_millions)
from layoffs_staging2;

-- Total funds_raised_millions by company
Select Company, Sum(funds_raised_millions) as Total_raised_funds
from layoffs_staging2
Group by company
order by total_raised_funds DESC;

-- FUnds_raised by company based on year
Select company, funds_raised_millions, year(date) as year
from layoffs_staging2
Group by company
order by funds_raised_millions DESC;

-- total funds raised by company based on year
Select Company, Sum(funds_raised_millions) as Total_raised_funds, year(date) as year
from layoffs_staging2
Group by company
order by total_raised_funds DESC; 


-- Let's find out roolling pattern
With Rolling_total as 
(
Select substring(date,1,7) as month, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(date,1,7) is not null
group by month
Order by 1 ASC
)
Select month, sum(total_off) over (order by month) as rolling_total
from Rolling_total;

-- 
Select company, year(date), sum(total_laid_off)
from layoffs_staging2
Group by company, year(date)
order by 1 ASC; 

With company_year (company,year,total_laid_off) as
(
Select company, year(date), sum(total_laid_off)
from layoffs_staging2
Group by company, year(date)
), company_year_rank as
(
Select *, 
dense_rank() over(partition by year order by total_laid_off DESC) as ranking
from company_year where year is not null 
order by ranking ASC
)
Select *
from company_year_rank
where ranking <= 5 order by year;

-- Top 5 company ranking based on total funds raised by year
With company_year (company, year, Total_funds_raised) as
(
Select company, year(date) as year, sum(funds_raised_millions) as total_funds_raised
from layoffs_staging2
Group by company, year(date)
), fundranking as
(
Select *, 
dense_rank() over(partition by year order by total_funds_raised DESC) as fundranking
from company_year where year is not null 
order by fundranking ASC
)
Select *
from fundranking 
where fundranking<= 5
order by year;

