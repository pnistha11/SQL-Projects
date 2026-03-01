select * from layoffs_stagging;

select *,
row_number() over(
partition by
company, industry, total_laid_off ,percentage_laid_off, `date`) as row_num
from layoffs_stagging;

-- Finding Duplicats

with duplicate_cte as
(
select *,
row_number() over(
partition by
company, location, industry, total_laid_off ,percentage_laid_off, `date`, stage, country , funds_raised) as row_num
from layoffs_stagging
)
select * 
from duplicate_cte
where row_num > 1;


select * from layoffs_stagging
where company = 'Cars24';

CREATE TABLE `layoffs_stagging2` (
  `company` text,
  `location` text,
  `total_laid_off` text,
  `date` text,
  `percentage_laid_off` text,
  `industry` text,
  `source` text,
  `stage` text,
  `funds_raised` int DEFAULT NULL,
  `country` text,
  `date_added` text,
  `row_num` int 
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


insert into layoffs_stagging2
select *,
row_number() over(
partition by
company, location, industry, total_laid_off ,percentage_laid_off, `date`, stage, country , funds_raised) as row_num
from layoffs_stagging; 

select * from layoffs_stagging2
where row_num > 1;

-- Remove Duplicates

SET SQL_SAFE_UPDATES = 0;

DELETE FROM layoffs_stagging2
WHERE row_num > 1;

SET SQL_SAFE_UPDATES = 1;


-- Standardize Data

select company, trim(company)
from layoffs_stagging2;

update layoffs_stagging2
set company = trim(company);

select distinct industry
from layoffs_stagging2
order by 1;

select * 
from layoffs_stagging2
where industry like 'crypto%';

select distinct location 
from layoffs_stagging2
order by 1;

select distinct country 
from layoffs_stagging2
order by 1;

select `date`,
str_to_date(`date`,'%m/%d/%Y')  
from layoffs_stagging2;

update layoffs_stagging2
set `date` = str_to_date(`date`,'%m/%d/%Y');

select `date`
from layoffs_stagging2;

alter table layoffs_stagging2
modify column `date` date;

select * from layoffs_stagging2
where total_laid_off = ''
	and percentage_laid_off = '' ;

delete 
from layoffs_stagging2
where total_laid_off = ''
	and percentage_laid_off = '' ;
    
select * 
from layoffs_stagging2 
where industry = '';

select *
from layoffs_stagging2
where company = 'Appsmith';

select *
from layoffs_stagging2
where company = 'Eyeo';

select * from layoffs_stagging2;

alter table layoffs_stagging2
drop column row_num;