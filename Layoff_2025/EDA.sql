-- Exploratory Data Analysis

select * from layoffs_stagging2;

select max(total_laid_off),max(percentage_laid_off)
from layoffs_stagging2;

select * from layoffs_stagging2
where percentage_laid_off = 1
order by total_laid_off desc;

select * from layoffs_stagging2
where percentage_laid_off = 1
order by funds_raised desc;

select* from layoffs_stagging2;

ALTER TABLE layoffs_stagging2
MODIFY total_laid_off INT;

select company, sum(total_laid_off)
from layoffs_stagging2
group by company
order by 2 desc;

select min(`date`), max(`date`)
from layoffs_stagging2;

select industry, sum(total_laid_off)
from layoffs_stagging2
group by industry
order by 2 desc;

select country, sum(total_laid_off)
from layoffs_stagging2
group by country
order by 2 desc;

select year(`date`), sum(total_laid_off)
from layoffs_stagging2
group by year(`date`) 
order by 1 desc;

select stage, sum(total_laid_off)
from layoffs_stagging2
group by stage 
order by 2 desc;

select company, sum(percentage_laid_off)
from layoffs_stagging2
group by company
order by 2 desc;

select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off
from layoffs_stagging2
group by `month`
order by 1 asc;

with rolling_total as
(
select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off
from layoffs_stagging2
group by `month`
order by 1 asc
)
select `month` , total_off
,sum(total_off) over(order by `month`) as rolling_ttxl 
from rolling_total;


select company, year(`date`) , sum(total_laid_off)
from layoffs_stagging2
group by company, year(`date`)
order by 3 desc;

with Company_year (Company,Years,Total_Laid_offs) as
(
select company, year(`date`) , sum(total_laid_off)
from layoffs_stagging2
group by company, year(`date`)
) ,Company_year_ranking as
(
select * , 
dense_rank() over(partition by Years order by Total_Laid_offs desc) as Ranking
from Company_year)
select * 
from Company_year_ranking
where Ranking <= 5
;
