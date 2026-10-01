-- ====================================================================
-- Project: World Layoffs Data Cleaning
-- Dataset: Raw Layoffs Data
-- Tool: MySQL Workbench
-- Description: Cleaning raw data by removing duplicates, standardizing 
--              text/dates, handling missing values, and dropping unused columns.
-- ====================================================================

USE world_layoffs;

-- --------------------------------------------------------------------
-- Step 0: Create Staging Table
-- --------------------------------------------------------------------

CREATE TABLE layoffs_staging 
LIKE layoffs;

INSERT INTO layoffs_staging 
SELECT * FROM layoffs;


-- --------------------------------------------------------------------
-- Step 1: Remove Duplicates
-- --------------------------------------------------------------------

CREATE TABLE `layoffs_clean` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_clean
SELECT *,
       ROW_NUMBER() OVER(
           PARTITION BY company, location, industry, total_laid_off, 
                        percentage_laid_off, `date`, stage, country, funds_raised_millions
       ) AS row_num
FROM layoffs_staging;

DELETE 
FROM layoffs_clean
WHERE row_num > 1;


-- --------------------------------------------------------------------
-- Step 2: Standardize Data
-- --------------------------------------------------------------------

-- Trim whitespace from company names
UPDATE layoffs_clean
SET company = TRIM(company);

-- Standardize industry naming
UPDATE layoffs_clean
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Clean trailing dots in country names
UPDATE layoffs_clean
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Convert date text format to standard SQL DATE
UPDATE layoffs_clean
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_clean
MODIFY COLUMN `date` DATE;


-- --------------------------------------------------------------------
-- Step 3: Handle Null and Blank Values
-- --------------------------------------------------------------------

UPDATE layoffs_clean
SET industry = NULL
WHERE industry = '';

-- Populate missing industry values using self join
UPDATE layoffs_clean t1
JOIN layoffs_clean t2
    ON t1.company = t2.company
   AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;


-- --------------------------------------------------------------------
-- Step 4: Remove Unnecessary Columns and Rows
-- --------------------------------------------------------------------

DELETE 
FROM layoffs_clean
WHERE total_laid_off IS NULL 
  AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_clean
DROP COLUMN row_num;

-- Final output check
SELECT * 
FROM layoffs_clean;
  
