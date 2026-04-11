-- =====================================================
-- 📊 SQL MINI PROJECT: STORED PROCEDURES
-- =====================================================
-- Objective:
-- Demonstrate the use of stored procedures to:
-- 1. Simplify repeated queries
-- 2. Improve query reusability
-- 3. Introduce parameter-driven data retrieval
-- =====================================================

-- Key Skills Demonstrated:
--    • Writing and executing stored procedures in MySQL
--    • Returning multiple result sets from a single call
--    • Using input parameters for dynamic, reusable logic
--    • Creating clear and organized SQL that follows best practices used in real-world situations

-- ==============================
-- 1. BASE QUERY (REFERENCE)
-- ==============================

-- Retrieve employees earning ≥ $ 50,000
SELECT *
FROM employee_salary
WHERE salary >= 50000;


-- ==============================
-- 2. BASIC STORED PROCEDURE
-- ==============================

-- Create a simple stored procedure for high salaries
CREATE PROCEDURE get_high_salaries()
SELECT *
FROM employee_salary
WHERE salary >= 50000;

-- Execute procedure
CALL get_high_salaries();


-- ==============================
-- 3. MULTIPLE QUERIES IN ONE PROCEDURE
-- ==============================

-- Demonstrates returning multiple result sets
DELIMITER //

CREATE PROCEDURE get_salary_ranges()
BEGIN
    -- High salaries
    SELECT *
    FROM employee_salary
    WHERE salary >= 50000;

    -- Mid-level salaries
    SELECT *
    FROM employee_salary
    WHERE salary >= 10000;
END //

DELIMITER ;

-- Execute procedure
CALL get_salary_ranges();


-- ==============================
-- 4. PARAMETERISED PROCEDURE
-- ==============================

-- Retrieve salary for a specific employee
DELIMITER //

CREATE PROCEDURE get_employee_salary(p_employee_id INT)
BEGIN
    SELECT salary
    FROM employee_salary
    WHERE employee_id = p_employee_id;
END //

DELIMITER ;

-- Execute procedure with parameter
CALL get_employee_salary(1);
