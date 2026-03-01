use world_layoffs;

select * from layoffs;

select * from layoffs_2025;

-- Data Cleaning

-- 1. Remove Duplicates
-- 2. Standardize Data
-- 3. Null Values or Blank Values
-- 4. Remove Any Columns

create table layoffs_stagging
like layoffs_2025;

select * from layoffs_stagging;

insert into layoffs_stagging
select * 
from layoffs_2025;

