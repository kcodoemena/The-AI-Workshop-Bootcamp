-- =============================================================
<<<<<<< HEAD
-- Week 8: SQL Joins  -  SOLUTIONS
-- The AI Workshop Bootcamp  |  9 May 2026
-- =============================================================
-- Each solution includes a short reasoning note. Multiple correct
-- answers exist. Yours may differ. What matters is the result set
-- and the join strategy.
=======
-- WEEK 10 - DATA PROFILING SOLUTIONS
-- =============================================================
-- Each solution includes the query and a short note on the
-- reasoning behind it. There's often more than one correct
-- answer; these are clean, idiomatic versions.
>>>>>>> 991899ae31f2b857908051818e7656f77b4b0889
-- =============================================================

USE BootcampDB;
GO


<<<<<<< HEAD
-- -------------------------------------------------------------
-- EXERCISE 1   (INNER JOIN)
-- -------------------------------------------------------------
-- INNER JOIN drops patients without admissions, which is what
-- we want here (one row per admission).
SELECT
    p.FirstName + ' ' + p.LastName AS PatientFullName,
    a.AdmissionDate,
    a.Diagnosis,
    a.AdmissionType
FROM Patients   AS p
INNER JOIN Admissions AS a ON p.PatientID = a.PatientID
ORDER BY a.AdmissionDate;
GO


-- -------------------------------------------------------------
-- EXERCISE 2   (LEFT JOIN with COUNT)
-- -------------------------------------------------------------
-- LEFT JOIN keeps wards even if no admissions exist. Crucially,
-- COUNT(a.AdmissionID) counts non-NULLs, so empty wards return 0
-- (whereas COUNT(*) would return 1 for those rows -- a classic bug).
SELECT
    w.WardName,
    COUNT(a.AdmissionID) AS AdmissionCount
FROM Wards      AS w
LEFT JOIN Admissions AS a ON w.WardID = a.WardID
GROUP BY w.WardName
ORDER BY AdmissionCount DESC;
GO


-- -------------------------------------------------------------
-- EXERCISE 3   (Anti-join: LEFT JOIN + IS NULL)
-- -------------------------------------------------------------
-- The textbook "find what does not exist" pattern.
SELECT
    p.PatientID,
    p.FirstName,
    p.LastName,
    p.RegisteredGP
FROM Patients   AS p
LEFT JOIN Admissions AS a ON p.PatientID = a.PatientID
WHERE a.AdmissionID IS NULL;
GO


-- -------------------------------------------------------------
-- EXERCISE 4   (3-table INNER JOIN)
-- -------------------------------------------------------------
-- Observations -> Admissions -> Patients (and Wards).
-- Order does not affect results, only readability.
SELECT
    p.FirstName + ' ' + p.LastName AS PatientFullName,
    w.WardName,
    o.ObsDateTime,
    o.ObsType,
    o.ObsValue
FROM Observations AS o
INNER JOIN Admissions AS a ON o.AdmissionID = a.AdmissionID
INNER JOIN Patients   AS p ON a.PatientID   = p.PatientID
INNER JOIN Wards      AS w ON a.WardID      = w.WardID
ORDER BY o.ObsDateTime;
GO


-- -------------------------------------------------------------
-- EXERCISE 5   (Mixed joins, "first observation per admission")
-- -------------------------------------------------------------
-- Approach: pre-aggregate observations to find the first ObsDateTime
-- per admission, then join back to get the actual ObsType/Value.
WITH FirstObs AS (
    SELECT
        AdmissionID,
        MIN(ObsDateTime) AS FirstObsTime
    FROM Observations
    GROUP BY AdmissionID
)
SELECT
    p.FirstName + ' ' + p.LastName AS PatientFullName,
    w.WardName,
    a.AdmissionDate,
    o.ObsType  AS FirstObsType,
    o.ObsValue AS FirstObsValue
FROM Admissions AS a
INNER JOIN Patients AS p ON a.PatientID = p.PatientID
LEFT JOIN  Wards    AS w ON a.WardID    = w.WardID
LEFT JOIN  FirstObs AS f ON a.AdmissionID = f.AdmissionID
LEFT JOIN  Observations AS o
       ON f.AdmissionID = o.AdmissionID
      AND f.FirstObsTime = o.ObsDateTime
ORDER BY a.AdmissionDate;
GO

-- Alternative using OUTER APPLY (cleaner when you need TOP 1):
SELECT
    p.FirstName + ' ' + p.LastName AS PatientFullName,
    w.WardName,
    a.AdmissionDate,
    fo.ObsType  AS FirstObsType,
    fo.ObsValue AS FirstObsValue
FROM Admissions AS a
INNER JOIN Patients AS p ON a.PatientID = p.PatientID
LEFT JOIN  Wards    AS w ON a.WardID    = w.WardID
OUTER APPLY (
    SELECT TOP 1 o.ObsType, o.ObsValue
    FROM Observations AS o
    WHERE o.AdmissionID = a.AdmissionID
    ORDER BY o.ObsDateTime ASC
) AS fo
ORDER BY a.AdmissionDate;
GO


-- -------------------------------------------------------------
-- EXERCISE 6   (BONUS - self join)
-- -------------------------------------------------------------
-- Two tricks here:
--   (1) p1.PatientID < p2.PatientID  removes self-pairs and dupes
--   (2) LEFT(p1.Postcode, 3)         extracts the 3-char prefix
SELECT
    p1.FirstName + ' ' + p1.LastName AS PatientA,
    p2.FirstName + ' ' + p2.LastName AS PatientB,
    p1.RegisteredGP                  AS GP,
    LEFT(p1.Postcode, 3)             AS PostcodePrefix
FROM Patients AS p1
INNER JOIN Patients AS p2
    ON p1.RegisteredGP   = p2.RegisteredGP
   AND LEFT(p1.Postcode, 3) = LEFT(p2.Postcode, 3)
   AND p1.PatientID      < p2.PatientID
ORDER BY GP, PostcodePrefix;
GO


-- -------------------------------------------------------------
-- EXERCISE 7   (BONUS - good prompt template)
-- -------------------------------------------------------------
-- A strong prompt has FIVE parts:
--
-- 1. Dialect:        "Write T-SQL for SQL Server."
-- 2. Schema:         Paste the CREATE TABLE statements (or column
--                    lists with PK/FK).
-- 3. Goal:           One clear English sentence describing the result.
-- 4. Quality bar:    "Use aliases. Use LEFT JOIN where appropriate.
--                    Handle NULLs. Order by X."
-- 5. Verification:   "Explain the join strategy. List any assumptions."
--
-- Example for the question in Ex 7:
/*
You are writing T-SQL for SQL Server.

Schema:
  Patients(PatientID PK, FirstName, LastName, ...)
  Wards(WardID PK, WardName, ...)
  Admissions(AdmissionID PK, PatientID FK, WardID FK,
             AdmissionDate, DischargeDate, ...)
  Observations(ObservationID PK, AdmissionID FK,
               ObsDateTime, ObsType, ObsValue, ...)

Task:
For each patient currently still admitted (DischargeDate IS NULL),
return: PatientFullName, WardName, the most recent observation
(type and value), and the number of days since AdmissionDate.

Quality bar:
- Use table aliases.
- Use INNER JOIN to Admissions and Wards.
- Use OUTER APPLY (or a window function) for the most recent
  observation so the row count stays one per admission.
- Compute days as DATEDIFF(DAY, a.AdmissionDate, GETDATE()).
- Order by days descending.

Before answering, briefly explain your join strategy, then give
the query in a single code block.
*/
GO
=======
-- =============================================================
-- EXERCISE 1 - SHAPE WARM-UP
-- =============================================================
-- The trick is a tagged UNION ALL: each branch returns a literal
-- string identifying the table plus its COUNT(*). Order at the end.

SELECT 'Observations' AS table_name, COUNT(*) AS row_count FROM Observations
UNION ALL
SELECT 'Admissions',                 COUNT(*)              FROM Admissions
UNION ALL
SELECT 'Patients',                   COUNT(*)              FROM Patients
UNION ALL
SELECT 'Wards',                      COUNT(*)              FROM Wards
ORDER BY row_count DESC;


-- =============================================================
-- EXERCISE 2 - NULL PROFILE
-- =============================================================
-- Single-row profile using SUM(CASE...) per column. Skip the PK
-- and CreatedDate since they're system fields with defaults.

SELECT
    COUNT(*)                                                AS total_rows,
    SUM(CASE WHEN NHSNumber    IS NULL THEN 1 ELSE 0 END)   AS null_nhs_number,
    SUM(CASE WHEN FirstName    IS NULL THEN 1 ELSE 0 END)   AS null_first_name,
    SUM(CASE WHEN LastName     IS NULL THEN 1 ELSE 0 END)   AS null_last_name,
    SUM(CASE WHEN DateOfBirth  IS NULL THEN 1 ELSE 0 END)   AS null_dob,
    SUM(CASE WHEN Gender       IS NULL THEN 1 ELSE 0 END)   AS null_gender,
    SUM(CASE WHEN Postcode     IS NULL THEN 1 ELSE 0 END)   AS null_postcode,
    SUM(CASE WHEN RegisteredGP IS NULL THEN 1 ELSE 0 END)   AS null_gp
FROM Patients;

-- Reasoning: every column gets its own SUM(CASE WHEN ... IS NULL...).
-- This pattern scales: paste the column list, copy-replace into the
-- template, done. Easy for AI to generate from a schema dump too.


-- =============================================================
-- EXERCISE 3 - CARDINALITY FREQUENCY TABLE
-- =============================================================
-- Window function gives percentage in one pass, no subquery needed.

SELECT
    WardType,
    COUNT(*)                                                            AS frequency,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,2))      AS pct_of_total
FROM Wards
GROUP BY WardType
ORDER BY frequency DESC;

-- Reasoning: SUM(COUNT(*)) OVER () is the trick - it sums the per-group
-- counts across all rows in the result set. Faster and cleaner than a
-- correlated subquery.


-- =============================================================
-- EXERCISE 4 - AGE DISTRIBUTION HISTOGRAM
-- =============================================================
-- The CASE-in-GROUP-BY pattern. The label string starts with a number
-- so it sorts naturally.

SELECT
    CASE
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 40 THEN '1. Under 40'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 60 THEN '2. 40-59'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 80 THEN '3. 60-79'
        ELSE                                                  '4. 80+'
    END                         AS age_band,
    COUNT(*)                    AS patient_count
FROM Patients
GROUP BY
    CASE
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 40 THEN '1. Under 40'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 60 THEN '2. 40-59'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 80 THEN '3. 60-79'
        ELSE                                                  '4. 80+'
    END
ORDER BY age_band;

-- Cleaner alternative using a CTE (avoids repeating the CASE):
WITH banded AS (
    SELECT
        CASE
            WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 40 THEN '1. Under 40'
            WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 60 THEN '2. 40-59'
            WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 80 THEN '3. 60-79'
            ELSE                                                  '4. 80+'
        END AS age_band
    FROM Patients
)
SELECT age_band, COUNT(*) AS patient_count
FROM banded
GROUP BY age_band
ORDER BY age_band;


-- =============================================================
-- EXERCISE 5 - LENGTH OF STAY OUTLIERS
-- =============================================================
-- Two-step: CTE for stats, then join back to compute z-scores.
-- Filter for discharged admissions so the LOS calc works.

WITH los AS (
    SELECT
        AdmissionID,
        DATEDIFF(DAY, AdmissionDate, DischargeDate) AS stay_days
    FROM Admissions
    WHERE DischargeDate IS NOT NULL
),
stats AS (
    SELECT
        AVG(CAST(stay_days AS FLOAT)) AS mean_stay,
        STDEV(stay_days)              AS sd_stay
    FROM los
)
SELECT
    l.AdmissionID,
    l.stay_days,
    s.mean_stay,
    s.sd_stay,
    (l.stay_days - s.mean_stay) / NULLIF(s.sd_stay, 0) AS z_score
FROM los l
CROSS JOIN stats s
WHERE ABS((l.stay_days - s.mean_stay) / NULLIF(s.sd_stay, 0)) > 2
ORDER BY ABS((l.stay_days - s.mean_stay) / NULLIF(s.sd_stay, 0)) DESC;

-- Reasoning: NULLIF on the stddev guards against divide-by-zero
-- when all values are identical (sd = 0). With our small seed set
-- you may get zero outliers - and that's a legitimate result.


-- =============================================================
-- EXERCISE 6 - POSTCODE FORMAT CHECK
-- =============================================================
-- T-SQL LIKE has character classes [A-Z] that work for our purposes.
-- This catches the most common malformed cases.

SELECT
    PatientID,
    FirstName,
    LastName,
    Postcode,
    LEN(Postcode)               AS pc_length,
    CASE
        WHEN Postcode IS NULL                              THEN 'NULL'
        WHEN Postcode NOT LIKE '[A-Z][A-Z]%[0-9][A-Z][A-Z]'
         AND Postcode NOT LIKE '[A-Z][0-9]%[0-9][A-Z][A-Z]'
                                                            THEN 'Wrong shape'
        WHEN Postcode NOT LIKE '% %'                       THEN 'Missing space'
        ELSE 'OK'
    END                         AS issue
FROM Patients
WHERE Postcode IS NULL
   OR Postcode NOT LIKE '% %'
   OR (Postcode NOT LIKE '[A-Z][A-Z]%[0-9][A-Z][A-Z]'
       AND Postcode NOT LIKE '[A-Z][0-9]%[0-9][A-Z][A-Z]');

-- Reasoning: UK postcodes have several shape variants (L1 1AA, LS1 4AP,
-- SW1A 1AA). The simple two-pattern check above catches the common ones
-- without trying to be a full regex. In real work you'd use a regex
-- function (e.g. via SQLCLR or a downstream Python step) for full coverage.


-- =============================================================
-- EXERCISE 7 - AI PROMPTING PRACTICE
-- =============================================================
-- Example prompt using the five-part template:
/*
Dialect:
I'm using T-SQL on SQL Server.

Schema:
Table Observations has columns:
- ObservationID INT (PK, identity)
- AdmissionID INT (FK to Admissions, NOT NULL)
- ObsDateTime DATETIME (NOT NULL)
- ObsType NVARCHAR(50) NULL
- ObsValue NVARCHAR(20) NULL
- RecordedBy NVARCHAR(100) NULL

Goal:
Write a single SQL query that returns a one-row profile of this table.
The row should include:
  - total_rows
  - NULL count for each nullable column
  - distinct_obs_types
  - most_common_recorder (the RecordedBy value that appears most often)
  - most_common_recorder_count

Quality:
- Use aliases. One projected column per line.
- Use a CTE if it makes the most_common_recorder logic cleaner.
- T-SQL syntax only.

Verify:
After the query, list three sanity checks I should run on the output
before trusting it.
*/

-- A reasonable AI-generated answer:
WITH recorder_freq AS (
    SELECT TOP 1
        RecordedBy,
        COUNT(*) AS recorder_count
    FROM Observations
    WHERE RecordedBy IS NOT NULL
    GROUP BY RecordedBy
    ORDER BY COUNT(*) DESC
)
SELECT
    (SELECT COUNT(*)                                                 FROM Observations) AS total_rows,
    (SELECT SUM(CASE WHEN ObsType    IS NULL THEN 1 ELSE 0 END)      FROM Observations) AS null_obs_type,
    (SELECT SUM(CASE WHEN ObsValue   IS NULL THEN 1 ELSE 0 END)      FROM Observations) AS null_obs_value,
    (SELECT SUM(CASE WHEN RecordedBy IS NULL THEN 1 ELSE 0 END)      FROM Observations) AS null_recorded_by,
    (SELECT COUNT(DISTINCT ObsType)                                   FROM Observations) AS distinct_obs_types,
    rf.RecordedBy                                                                        AS most_common_recorder,
    rf.recorder_count                                                                    AS most_common_recorder_count
FROM recorder_freq rf;

-- Sanity checks to run:
--   1. total_rows should match a plain SELECT COUNT(*) FROM Observations.
--   2. null counts should each be <= total_rows.
--   3. most_common_recorder_count should be <= total_rows minus null_recorded_by.
>>>>>>> 991899ae31f2b857908051818e7656f77b4b0889


-- =============================================================
-- END OF SOLUTIONS
<<<<<<< HEAD
=======
-- Keep these around as templates. Profile queries are repetitive
-- on purpose - the value is in running them, not in writing them
-- from scratch every time.
>>>>>>> 991899ae31f2b857908051818e7656f77b4b0889
-- =============================================================
