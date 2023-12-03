-- Import Data in Table Using Query
-- COPY hrdata FROM 'D:\hrdata.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM hrdata;


-- ------------------------------------------------------------------------
-- Testing Employee Count 


-- Total Employee Count
SELECT SUM(employee_count) as employee_count FROM hrdata;


-- Employee count where education is High School
SELECT 
	SUM(employee_count) as high_school_employee_count 
FROM hrdata
WHERE education = 'High School'; 


-- Employee count where education is Associates Degree
SELECT 
	SUM(employee_count) as associates_degree_employee_count 
FROM hrdata
WHERE education = 'Associates Degree'; 


-- Employee count where education is Bachelor's Degree
SELECT 
	SUM(employee_count) as bachelor_degree_employee_count 
FROM hrdata
WHERE education = 'Bachelor''s Degree'; 


-- Employee count where education is Doctoral Degree
SELECT 
	SUM(employee_count) as doctoral_degree_employee_count 
FROM hrdata
WHERE education = 'Doctoral Degree'; 


-- Employee count where education is Master's Degree
SELECT 
	SUM(employee_count) as masters_degree_employee_count 
FROM hrdata
WHERE education = 'Master''s Degree'; 

-- ------------------------------------------------------------------------

-- Testing Attrition Count


-- Total Attrition Count

-- SELECT COUNT(attrition) FROM hrdata WHERE attrition = 'Yes';
SELECT 
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) as total_attrition_count 
FROM hrdata;


-- Employee count where education is Associates Degree
SELECT 
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) as associates_degree_total_attrition_count 
FROM hrdata
WHERE education = 'Associates Degree'; 


-- Employee count where education is Bachelor's Degree
SELECT 
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) as bachlors_degree_total_attrition_count  
FROM hrdata
WHERE education = 'Bachelor''s Degree'; 


-- Employee count where education is Doctoral Degree
SELECT 
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) as doctoral_degree_total_attrition_count  
FROM hrdata
WHERE education = 'Doctoral Degree'; 


-- Employee count where education is High School Degree
SELECT 
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) as high_school_degree_total_attrition_count  
FROM hrdata
WHERE education = 'High School'; 


-- Employee count where education is Master's Degree
SELECT 
	SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) as high_school_degree_total_attrition_count
FROM hrdata
WHERE education = 'Master''s Degree'; 

-- ------------------------------------------------------------------------

-- Testing Attrition Rate

-- SELECT ROUND(((SELECT COUNT(attrition) FROM hrdata WHERE attrition = 'Yes') / SUM(employee_count))*100, 2) FROM hrdata;


SELECT 
	ROUND(100 * SUM(CASE WHEN attrition = 'Yes' THEN 1.0 ELSE 0 END) / SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 1 END), 2) as Attrition_Rate
FROM hrdata;


-- ------------------------------------------------------------------------

-- Testing Active Employees

-- SELECT SUM(active_employee) FROM hrdata;

SELECT 
	COUNT(employee_count) - (SELECT COUNT(emp_no) FROM hrdata WHERE attrition = 'Yes') 
FROM hrdata;


-- ------------------------------------------------------------------------

-- Testing Average Age of Employees

SELECT ROUND(AVG(age), 2) FROM hrdata;


-- ------------------------------------------------------------------------
-- Column Not present
-- Testing Average Monthly Income of Employees

SELECT * FROM hrdata;
SELECT ROUND(AVG(monthly_income), 2) FROM hrdata;


-- ------------------------------------------------------------------------

-- Testing attrition by Gender

SELECT gender, COUNT(emp_no)
FROM hrdata
WHERE attrition = 'Yes'
GROUP BY gender
ORDER BY COUNT(emp_no) DESC;

-- ------------------------------------------------------------------------

-- Testing attrition by Department

SELECT * FROM hrdata;

SELECT 
	department, 
	COUNT(attrition) AS attrition,
	ROUND(100.0 * COUNT(attrition) / (SELECT COUNT(attrition) FROM hrdata WHERE attrition = 'Yes'), 2) AS percentage
FROM hrdata
WHERE attrition = 'Yes'
GROUP BY department
ORDER BY COUNT(attrition) DESC;


-- ------------------------------------------------------------------------

-- Testing attrition by Number of employees by age group

SELECT * FROM hrdata;

SELECT age_band, COUNT(emp_no)
FROM hrdata
GROUP BY age_band;

SELECT 
	age,  
	SUM(employee_count) AS employee_count 
FROM hrdata
GROUP BY age
ORDER by age;


-- ------------------------------------------------------------------------

-- Testing attrition by Education Field

SELECT * FROM hrdata;

SELECT education_field, COUNT(attrition) 
FROM hrdata
WHERE attrition = 'Yes'
GROUP BY education_field
ORDER BY COUNT(attrition) DESC;


-- ------------------------------------------------------------------------

-- Testing attrition by Gender for different age groups

SELECT 
	age_band, 
	gender, 
	COUNT(attrition) AS attrition,
	ROUND(100.0 * COUNT(attrition) / (SELECT COUNT(attrition) FROM hrdata WHERE attrition = 'Yes'), 2) AS percentage
FROM hrdata
WHERE attrition = 'Yes'
GROUP BY age_band, gender
ORDER BY age_band, gender DESC;


-- ------------------------------------------------------------------------

-- Testing Job Satisfaction Rating

-- Run this query first to activate the cosstab() function in postgres
CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT *,
	one + two + three + four AS grand_total
FROM crosstab(
	'
		SELECT job_role, job_satisfaction, SUM(employee_count)
		FROM hrdata
		GROUP BY job_role, job_satisfaction
		ORDER BY job_role, job_satisfaction
	'
) AS ct(job_role VARCHAR(50), one numeric, two numeric, three numeric, four numeric)
ORDER BY job_role;

-- The COALESCE() function is used to handle possible NULL values in the columns resulting from the pivot (one, two, three, four). It replaces NULL values with zeros (0).

SELECT *,
	COALESCE(one, 0) + COALESCE(two, 0) + COALESCE(three, 0) + COALESCE(four, 0) AS grand_total
FROM crosstab(
	'
		SELECT job_role, job_satisfaction, SUM(employee_count)
		FROM hrdata
		GROUP BY job_role, job_satisfaction
		ORDER BY job_role, job_satisfaction
	'
) AS ct(job_role VARCHAR(50), one numeric, two numeric, three numeric, four numeric)
ORDER BY job_role;



-- ERROR
-- Trying to create a row named Grand total which contains the grand total of each columns
SELECT 
	*,
	COALESCE(one, 0) + COALESCE(two, 0) + COALESCE(three, 0) + COALESCE(four, 0) AS grand_total
FROM (
	SELECT *	
	FROM crosstab(
		'
			SELECT job_role, job_satisfaction, SUM(employee_count)
			FROM hrdata
			GROUP BY job_role, job_satisfaction
			ORDER BY job_role, job_satisfaction
		'
	) AS ct(job_role VARCHAR(50), one numeric, two numeric, three numeric, four numeric)
	
	UNION ALL

	SELECT 'Grand Total',
		SUM(one) AS one,
        SUM(two) AS two,
        SUM(three) AS three,
        SUM(four) AS four
	FROM (
		SELECT job_role, job_satisfaction, SUM(employee_count)
		FROM hrdata
		GROUP BY job_role, job_satisfaction
	) AS subquery
) AS combined_data
ORDER BY CASE WHEN job_role = 'Grand Total' THEN 1 ELSE 0 END, job_role;


-- Important MAXX
-- Pivot table
WITH crosstab_result AS (
    SELECT *
    FROM crosstab(
        '
        SELECT job_role, job_satisfaction, SUM(employee_count)
        FROM hrdata
        GROUP BY job_role, job_satisfaction
        ORDER BY job_role, job_satisfaction
        '
    ) AS ct(job_role VARCHAR(50), one numeric, two numeric, three numeric, four numeric)
)
SELECT *,
       COALESCE(one, 0) + COALESCE(two, 0) + COALESCE(three, 0) + COALESCE(four, 0) AS grand_total
FROM (
    SELECT * FROM crosstab_result

    UNION ALL

    SELECT 'Grand Total', -- This is the new row
           SUM(one) AS one,
           SUM(two) AS two,
           SUM(three) AS three,
           SUM(four) AS four
    FROM crosstab_result
) AS combined_data
-- ORDER BY CASE WHEN job_role = 'Grand Total' THEN 1 ELSE 0 END, job_role;



