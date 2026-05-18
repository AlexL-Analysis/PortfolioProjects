-- =====================================================
-- 📊 EXPLORATORY DATA ANALYSIS (EDA) PROJECT
-- TECH LAYOFFS DATASET
-- =====================================================
-- Objective:
-- Explore global layoff trends to identify:
-- 1. Companies with the highest layoffs
-- 2. Industries and countries most affected
-- 3. Yearly layoff trends
-- 4. Business patterns across funding stages
-- 5. Rolling monthly layoff trends over time
-- =====================================================


-- =====================================================
-- 🛠️ KEY SKILLS DEMONSTRATED
-- =====================================================
-- ✔ Data Aggregation
-- ✔ GROUP BY & ORDER BY
-- ✔ Common Table Expressions (CTEs)
-- ✔ Window Functions
-- ✔ Time-Series Analysis
-- ✔ Ranking Functions
-- ✔ Business Insight Extraction
-- =====================================================


-- ==============================
-- 1. INITIAL DATA EXPLORATION
-- ==============================

-- View cleaned dataset
SELECT *
FROM layoffs_staging2;

-- Find maximum layoffs and layoff percentages
SELECT 
    MAX(total_laid_off) AS highest_layoffs,
    MAX(percentage_laid_off) AS max_percentage_laid_off
FROM layoffs_staging2;


-- ==============================
-- 2. COMPANIES WITH 100% LAYOFFS
-- ==============================

-- Companies that laid off their entire workforce
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Analyse funding levels for companies with complete layoffs
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


-- ==============================
-- 3. TOTAL LAYOFFS BY COMPANY
-- ==============================

-- Identify companies with the highest layoffs
SELECT 
    company,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC;


-- ==============================
-- 4. DATE RANGE ANALYSIS
-- ==============================

-- Determine dataset timeframe
SELECT 
    MIN(`date`) AS start_date,
    MAX(`date`) AS end_date
FROM layoffs_staging2;


-- ==============================
-- 5. LAYOFFS BY INDUSTRY
-- ==============================

-- Analyse which industries were most impacted
SELECT 
    industry,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC;


-- ==============================
-- 6. LAYOFFS BY COUNTRY
-- ==============================

-- Identify countries with the highest layoffs
SELECT 
    country,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC;


-- ==============================
-- 7. YEARLY LAYOFF TRENDS
-- ==============================

-- Analyse layoffs by year
SELECT 
    YEAR(`date`) AS layoff_year,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY layoff_year
ORDER BY layoff_year DESC;


-- ==============================
-- 8. LAYOFFS BY COMPANY STAGE
-- ==============================

-- Evaluate which business stages were most affected
SELECT 
    stage,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_layoffs DESC;


-- ==============================
-- 9. MONTHLY ROLLING TOTAL ANALYSIS
-- ==============================

-- Monthly layoffs trend
SELECT 
    SUBSTRING(`date`, 1, 7) AS month,
    SUM(total_laid_off) AS monthly_layoffs
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY month
ORDER BY month ASC;

-- Rolling cumulative layoffs over time
WITH Rolling_Total AS
(
    SELECT 
        SUBSTRING(`date`, 1, 7) AS month,
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
    GROUP BY month
)

SELECT 
    month,
    total_laid_off,
    SUM(total_laid_off) OVER (ORDER BY month) AS rolling_total
FROM Rolling_Total;


-- ==============================
-- 10. YEARLY COMPANY RANKINGS
-- ==============================

-- Total layoffs by company per year
SELECT 
    company,
    YEAR(`date`) AS layoff_year,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company, layoff_year
ORDER BY company ASC;

-- Rank top companies by layoffs each year
WITH Company_Year AS
(
    SELECT 
        company,
        YEAR(`date`) AS years,
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)
),

Company_Year_Rank AS
(
    SELECT *,
        DENSE_RANK() OVER (
            PARTITION BY years
            ORDER BY total_laid_off DESC
        ) AS ranking
    FROM Company_Year
    WHERE years IS NOT NULL
)

SELECT *
FROM Company_Year_Rank
WHERE ranking <= 5;


-- =====================================================
-- 	KEY INSIGHTS
-- =====================================================
--  Identified companies with the largest workforce reductions
--  Determined industries most affected by layoffs
--  Analysed global layoff distribution by country
--  Tracked layoffs over time using rolling totals
--  Ranked top companies by yearly layoffs
--  Demonstrated advanced SQL analysis using:
--      - CTEs
--      - Window Functions
--      - Aggregations
--      - Time-Series Analysis
-- =====================================================