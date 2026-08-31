-- =====================================================================
-- Layoffs 2020-2025 : Data Cleaning
-- Run order: 00_setup.sql  ->  01_data_cleaning.sql  ->  02_eda.sql
--
-- Cleaning order matters here. Blanks are converted to NULL BEFORE any
-- column is retyped, because MySQL silently turns '' into 0 on an INT
-- cast, which would make 776 real layoff events look like zero-person
-- events and corrupt every AVG(), MIN() and COUNT() downstream.
-- =====================================================================

USE world_layoffs;


-- ---------------------------------------------------------------------
-- 1. Staging table
-- ---------------------------------------------------------------------
-- InnoDB, not MyISAM: the dedupe below is a destructive DELETE and
-- MyISAM has no transactions, so a mistake cannot be rolled back.

DROP TABLE IF EXISTS layoffs_staging2;

CREATE TABLE layoffs_staging2 (
    company             TEXT,
    location            TEXT,
    total_laid_off      TEXT,
    `date`              TEXT,
    percentage_laid_off TEXT,
    industry            TEXT,
    source              TEXT,
    stage               TEXT,
    funds_raised        TEXT,
    country             TEXT,
    date_added          TEXT,
    row_num             INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Column order matches layoffs_staging exactly, so SELECT * is safe here.
INSERT INTO layoffs_staging2
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off,
                        percentage_laid_off, `date`, stage, country, funds_raised
       ) AS row_num
FROM layoffs_staging;


-- ---------------------------------------------------------------------
-- 2. Remove duplicates
-- ---------------------------------------------------------------------
-- Expect 3 rows removed from 4,248. Genuine duplication is rare in this
-- dataset; the check is still worth running, but it is not the story.

SELECT COUNT(*) AS duplicates_found
FROM layoffs_staging2
WHERE row_num > 1;

START TRANSACTION;

DELETE FROM layoffs_staging2
WHERE row_num > 1;

COMMIT;

ALTER TABLE layoffs_staging2 DROP COLUMN row_num;


-- ---------------------------------------------------------------------
-- 3. Standardize text
-- ---------------------------------------------------------------------

UPDATE layoffs_staging2
SET company  = TRIM(company),
    location = TRIM(location),
    industry = TRIM(industry),
    country  = TRIM(country),
    stage    = TRIM(stage);

-- Collapse Crypto / Crypto Currency / CryptoCurrency into one label.
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Strip trailing periods from country names (e.g. 'United States.').
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);


-- ---------------------------------------------------------------------
-- 4. Blanks -> NULL  (must happen before retyping)
-- ---------------------------------------------------------------------

UPDATE layoffs_staging2
SET total_laid_off      = NULLIF(total_laid_off, ''),
    percentage_laid_off = NULLIF(percentage_laid_off, ''),
    funds_raised        = NULLIF(funds_raised, ''),
    industry            = NULLIF(industry, ''),
    location            = NULLIF(location, ''),
    country             = NULLIF(country, ''),
    stage               = NULLIF(stage, ''),
    source              = NULLIF(source, ''),
    `date`              = NULLIF(`date`, ''),
    date_added          = NULLIF(date_added, '');


-- ---------------------------------------------------------------------
-- 5. Backfill missing industry from the same company
-- ---------------------------------------------------------------------
-- Affects Appsmith and Eyeo, which each appear more than once.

UPDATE layoffs_staging2 t1
JOIN   layoffs_staging2 t2
       ON  t1.company = t2.company
       AND t1.industry IS NULL
       AND t2.industry IS NOT NULL
SET t1.industry = t2.industry;

-- Confirm none remain.
SELECT company, location
FROM layoffs_staging2
WHERE industry IS NULL;


-- ---------------------------------------------------------------------
-- 6. Drop rows with no layoff measurement at all
-- ---------------------------------------------------------------------
-- Expect ~694 rows. These record that an event happened but carry
-- neither a headcount nor a percentage, so they cannot support analysis.

SELECT COUNT(*) AS rows_with_no_measure
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- ---------------------------------------------------------------------
-- 7. Convert types
-- ---------------------------------------------------------------------

-- Verify every date parses before altering the column.
-- Must return 0. If it does not, fix those rows first.
SELECT COUNT(*) AS unparseable_dates
FROM layoffs_staging2
WHERE `date` IS NOT NULL
  AND STR_TO_DATE(`date`, '%m/%d/%Y') IS NULL;

UPDATE layoffs_staging2
SET `date`      = STR_TO_DATE(`date`,      '%m/%d/%Y'),
    date_added  = STR_TO_DATE(date_added,  '%m/%d/%Y');

ALTER TABLE layoffs_staging2
    MODIFY `date`     DATE NULL,
    MODIFY date_added DATE NULL;

-- Headcounts arrive as '24.0', '80.0'. Round through DECIMAL first so the
-- INT conversion does not raise a truncation warning on every row.
UPDATE layoffs_staging2
SET total_laid_off = CAST(CAST(total_laid_off AS DECIMAL(12,2)) AS SIGNED)
WHERE total_laid_off IS NOT NULL;

ALTER TABLE layoffs_staging2
    MODIFY total_laid_off      INT           NULL,
    MODIFY percentage_laid_off DECIMAL(4,3)  NULL,
    MODIFY funds_raised        DECIMAL(12,2) NULL,
    MODIFY company             VARCHAR(255)  NOT NULL,
    MODIFY location            VARCHAR(255)  NULL,
    MODIFY industry            VARCHAR(100)  NULL,
    MODIFY stage               VARCHAR(100)  NULL,
    MODIFY country             VARCHAR(100)  NULL;


-- ---------------------------------------------------------------------
-- 8. Indexes
-- ---------------------------------------------------------------------

CREATE INDEX idx_date     ON layoffs_staging2 (`date`);
CREATE INDEX idx_company  ON layoffs_staging2 (company);
CREATE INDEX idx_industry ON layoffs_staging2 (industry);


-- ---------------------------------------------------------------------
-- 9. Validation
-- ---------------------------------------------------------------------
-- Expected: ~3,551 rows, 776 NULL headcounts, 0 zero-value headcounts,
-- date range 2020-03-11 to 2025-12-11.

SELECT COUNT(*)                                             AS total_rows,
       SUM(total_laid_off IS NULL)                          AS null_headcount,
       SUM(total_laid_off = 0)                              AS zero_headcount,
       SUM(industry IS NULL)                                AS null_industry,
       MIN(`date`)                                          AS earliest,
       MAX(`date`)                                          AS latest,
       FORMAT(SUM(total_laid_off), 0)                       AS total_laid_off
FROM layoffs_staging2;

-- zero_headcount MUST be 0. Any other value means blanks were cast to
-- integers somewhere and the NULL handling above did not take effect.
