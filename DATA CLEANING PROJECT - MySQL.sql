-- =====================================================
-- 📊 DATA CLEANING PROJECT: JOB LAYOFFS DATASET
-- =====================================================
-- Objective:
-- Clean and prepare raw layoffs data for analysis by:
-- 1. Removing duplicates
-- 2. Standardising values
-- 3. Handling null / missing data
-- 4. Removing unnecessary records/columns
-- =====================================================


-- ==============================
-- 1. CREATE STAGING TABLE
-- ==============================

-- Create a working copy of the raw dataset
CREATE TABLE layoffs_staging
LIKE layoffs_raw;

-- Insert raw data into staging table
INSERT INTO layoffs_staging
SELECT * FROM layoffs_raw;


-- ==============================
-- 2. REMOVE DUPLICATES
-- ==============================

-- Identify duplicates using ROW_NUMBER()
WITH duplicate_cte AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY company, location, industry, total_laid_off, 
                         percentage_laid_off, `date`, stage, country, funds_raised_millions
        ) AS row_num
    FROM layoffs_staging
)

-- View duplicate records
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


-- Create new table including row numbers
CREATE TABLE layoffs_staging2 (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT,
    percentage_laid_off TEXT,
    `date` TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT,
    row_num INT
);

-- Insert data with row numbers
INSERT INTO layoffs_staging2
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off, 
                     percentage_laid_off, `date`, stage, country, funds_raised_millions
    )
FROM layoffs_staging;

-- Delete duplicate rows
DELETE
FROM layoffs_staging2
WHERE row_num > 1;


-- ==============================
-- 3. STANDARDISE DATA
-- ==============================

-- Remove leading/trailing spaces in company names
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Standardise industry naming (e.g., Crypto variations)
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Clean country names (remove trailing periods)
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Convert date from text → DATE format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Change column type to DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- ==============================
-- 4. HANDLE NULL / MISSING DATA
-- ==============================

-- Convert blank industry values to NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Fill missing industry values using matching company records
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


-- ==============================
-- 5. REMOVE IRRELEVANT RECORDS
-- ==============================

-- Remove rows where layoff data is missing entirely
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- ==============================
-- 6. FINAL CLEANUP
-- ==============================

-- Remove helper column used for duplicate detection
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


-- ==============================
-- ✅ FINAL CLEANED DATASET READY
-- ==============================

SELECT *
FROM layoffs_staging2;