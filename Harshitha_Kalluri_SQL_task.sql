-- Q1. Find the top 5 districts with the highest number of colleges offering professional courses.
SELECT District, COUNT(DISTINCT CollegeName) AS CollegeCount
FROM CollegeCourses
WHERE IsProfessional LIKE '%Professional%'
GROUP BY District
ORDER BY CollegeCount DESC
LIMIT 5;

-- Q2. Calculate the average course duration (in months) for each Course Type and sort them in descending order.
SELECT CourseType, AVG(CourseDurationMonths) AS AvgDuration
FROM CollegeCourses
GROUP BY CourseType
ORDER BY AvgDuration DESC;

-- Q3. Count how many unique College Names offer each Course Category.
SELECT CourseCategory, COUNT(DISTINCT CollegeName) AS UniqueColleges
FROM CollegeCourses
GROUP BY CourseCategory;

-- Q4. Find the names of colleges offering both Post Graduate and Under Graduate courses.
SELECT CollegeName
FROM CollegeCourses
WHERE CourseType IN ('Under Graduate Course', 'Post Graduate Course')
GROUP BY CollegeName
HAVING COUNT(DISTINCT CourseType) = 2;

-- Q5. List all universities that have more than 10 unaided courses that are not professional.
SELECT University, COUNT(*) AS CourseCount
FROM CollegeCourses
WHERE CourseAidedStatus = 'UnAided' AND IsProfessional LIKE '%Non-Professional%'
GROUP BY University
HAVING COUNT(*) > 10;

-- Q6. Display colleges from the "Engineering" category that have at least one course with a duration greater than the category’s average.
WITH EngAvg AS (
    SELECT AVG(CourseDurationMonths) AS AvgDuration
    FROM CollegeCourses
    WHERE CourseCategory = 'Engineering'
)
SELECT DISTINCT CollegeName
FROM CollegeCourses, EngAvg
WHERE CourseCategory = 'Engineering' AND CourseDurationMonths > EngAvg.AvgDuration;

-- Q7. Assign a rank to each course within a College Name based on course duration, longest first.
SELECT CollegeName, CourseName, CourseDurationMonths,
RANK() OVER (PARTITION BY CollegeName ORDER BY CourseDurationMonths DESC) AS CourseRank
FROM CollegeCourses;

-- Q8. Find colleges where the longest and shortest course durations are more than 24 months apart.
SELECT CollegeName
FROM CollegeCourses
GROUP BY CollegeName
HAVING MAX(CourseDurationMonths) - MIN(CourseDurationMonths) > 24;

-- Q9. Show the cumulative number of professional courses offered by each university sorted alphabetically.
SELECT University, COUNT(*) AS TotalProfessionalCourses
FROM CollegeCourses
WHERE IsProfessional LIKE '%Professional%'
GROUP BY University
ORDER BY University;

-- Q10. Using a self-join or CTE, find colleges offering more than one course category.
WITH CategoryCount AS (
    SELECT CollegeName, COUNT(DISTINCT CourseCategory) AS CategoryCount
    FROM CollegeCourses
    GROUP BY CollegeName
)
SELECT CollegeName
FROM CategoryCount
WHERE CategoryCount > 1;

-- Q11. Create a temporary table (CTE) that includes average duration of courses by district and use it to list talukas where the average course duration is above the district average.
WITH DistrictAvg AS (
    SELECT District, AVG(CourseDurationMonths) AS DistrictAvgDuration
    FROM CollegeCourses
    GROUP BY District
),
TalukaAvg AS (
    SELECT District, Taluka, AVG(CourseDurationMonths) AS TalukaAvgDuration
    FROM CollegeCourses
    GROUP BY District, Taluka
)
SELECT T.Taluka, T.District
FROM TalukaAvg T
JOIN DistrictAvg D ON T.District = D.District
WHERE T.TalukaAvgDuration > D.DistrictAvgDuration;

-- Q12. Create a new column classifying course duration as:
--Short (< 12 months)
--Medium (12-36 months)
--Long (> 36 months)
--Then count the number of each duration type per course category.
SELECT CourseCategory,
       CASE
           WHEN CourseDurationMonths < 12 THEN 'Short'
           WHEN CourseDurationMonths BETWEEN 12 AND 36 THEN 'Medium'
           ELSE 'Long'
       END AS DurationType,
       COUNT(*) AS CourseCount
FROM CollegeCourses
GROUP BY CourseCategory,
         CASE
           WHEN CourseDurationMonths < 12 THEN 'Short'
           WHEN CourseDurationMonths BETWEEN 12 AND 36 THEN 'Medium'
           ELSE 'Long'
         END;

-- Q13. Extract only the course specialization from Course Name. (e.g., from "Bachelor of Engineering (B. E.) - Electrical", extract "Electrical")
SELECT CourseName,
       TRIM(SUBSTR(CourseName, INSTR(CourseName,'-') + 1)) AS Specialization
FROM CollegeCourses
WHERE CourseName LIKE '%-%';

-- Q14. . Count how many courses include the word Engineering in the name.
SELECT COUNT(*) AS EngineeringCourseCount
FROM CollegeCourses
WHERE CourseName LIKE '%Engineering%';

-- Q15. List all unique combinations of Course Name, Course Type, and Course Category
SELECT DISTINCT CourseName, CourseType, CourseCategory
FROM CollegeCourses;

-- Q16. Write a query to get all courses that are not offered by any Government college.
SELECT DISTINCT CourseName
FROM CollegeCourses
WHERE CollegeType != 'Government';

-- Q17. Find the university that has the second-highest number of aided courses.
WITH AidedCounts AS (
    SELECT University, COUNT(*) AS AidedCount
    FROM CollegeCourses
    WHERE CourseAidedStatus = 'Aided'
    GROUP BY University
)
SELECT University, AidedCount
FROM AidedCounts
ORDER BY AidedCount DESC
LIMIT 1;
-- Q18. Show courses whose durations are above the median course duration
WITH OrderedDurations AS (
    SELECT CourseDurationMonths,
           NTILE(2) OVER (ORDER BY CourseDurationMonths) AS Half
    FROM CollegeCourses
)
SELECT *
FROM CollegeCourses
WHERE CourseDurationMonths > (
    SELECT MAX(CourseDurationMonths)
    FROM OrderedDurations
    WHERE Half = 1
);

-- Q19. For each University, find the percentage of unaided courses that are professional.
WITH TotalUnaided AS (
    SELECT University, COUNT(*) AS Total
    FROM CollegeCourses
    WHERE CourseAidedStatus = 'UnAided'
    GROUP BY University
),
ProfessionalUnaided AS (
    SELECT University, COUNT(*) AS ProfCount
    FROM CollegeCourses
    WHERE CourseAidedStatus = 'UnAided' AND IsProfessional LIKE 'Professional%'
    GROUP BY University
)
SELECT T.University,
       CAST(P.ProfCount AS FLOAT) / T.Total * 100 AS ProfessionalPercent
FROM TotalUnaided T
JOIN ProfessionalUnaided P ON T.University = P.University;

-- Q20. Determine which Course Category has the highest average course duration and display the top 3.
SELECT CourseCategory, AVG(CourseDurationMonths) AS AvgDuration
FROM CollegeCourses
GROUP BY CourseCategory
ORDER BY AvgDuration DESC
LIMIT 3;

