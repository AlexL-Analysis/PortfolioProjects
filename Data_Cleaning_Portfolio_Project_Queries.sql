-- =====================================================
-- 📊 DATA CLEANING PROJECT: JOB LAYOFFS DATASET
-- =====================================================
-- Objective:
-- Clean and prepare raw layoffs data for analysis by:
-- 1. Removing duplicates
-- 2. Standardising values
-- 3. Handling null / missing data
-- 4. Removing unnecessary records/columns
--
--  Key Skills Demonstrated:
--    • Staging table pattern to preserve raw data integrity
--    • Duplicate detection using ROW_NUMBER() with window functions
--    • Data standardisation via TRIM, LIKE, and STR_TO_DATE
--    • Null handling with self-joins to impute missing values
--    • Iterative schema refinement using ALTER TABLE
-- =====================================================


-- ==============================
-- 1. CREATE STAGING TABLE
-- ==============================

-- Best practice: never alter the raw source data directly.
-- A staging table acts as a safe working copy, preserving the original
-- in case the cleaning process needs to be revised or re-run.
CREATE TABLE layoffs_staging
LIKE layoffs_raw;

INSERT INTO layoffs_staging
SELECT * FROM layoffs_raw;


-- ==============================
-- 2. REMOVE DUPLICATES
-- ==============================

-- ROW_NUMBER() partitioned across all meaningful columns identifies
-- rows that are truly identical — row_num > 1 flags the duplicates.
-- This approach is more reliable than DELETE JOIN on datasets without a unique key.
WITH duplicate_cte AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY company, location, industry, total_laid_off, 
                         percentage_laid_off, `date`, stage, country, funds_raised_millions
        ) AS row_num
    FROM layoffs_staging
)

SELECT *
FROM duplicate_cte
WHERE row_num > 1;


-- A second staging table is created to materialise the row numbers,
-- since CTEs cannot be targeted directly in a DELETE statement in MySQL.
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

INSERT INTO layoffs_staging2
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off, 
                     percentage_laid_off, `date`, stage, country, funds_raised_millions
    )
FROM layoffs_staging;

-- Delete all rows flagged as duplicates, keeping only the first occurrence
DELETE
FROM layoffs_staging2
WHERE row_num > 1;


-- ==============================
-- 3. STANDARDISE DATA
-- ==============================

-- Whitespace in string fields causes silent mismatches in joins and GROUP BY.
-- TRIM() ensures company names are consistent across the dataset.
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Normalises industry variants (e.g. 'Crypto Currency', 'CryptoCurrency')
-- to a single canonical label, preventing fragmented groupings in analysis.
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Removes trailing punctuation introduced during data entry or export.
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Converts the date column from a raw string to a proper DATE type,
-- enabling accurate date filtering, sorting, and time-series analysis.
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- ==============================
-- 4. HANDLE NULL / MISSING DATA
-- ==============================

-- Blank strings are functionally missing but won't match IS NULL checks.
-- Converting them to NULL first ensures consistent null handling downstream.
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Self-join to impute missing industry values from other records of the same company.
-- A more robust approach than dropping rows — maintains data where enough context exists.

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


-- ==============================
-- 5. REMOVE IRRELEVANT RECORDS
-- ==============================

-- Rows with no layoff figures in either column carry no analytical value.
-- Removing them avoids skewing counts, averages, and trend calculations.

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- ==============================
-- 6. FINAL CLEANUP
-- ==============================

	-- The row_num column was a temporary helper for duplicate detection only.
-- Dropping it keeps the final schema clean and production-ready.
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


-- ==============================
--  FINAL CLEANED DATASET READY
-- ==============================

SELECT *
FROM layoffs_staging2;
