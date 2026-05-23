-- =============================================================
-- Week 8: SQL Joins  -  SOLUTIONS
-- The AI Workshop Bootcamp  |  9 May 2026
-- =============================================================
-- Each solution includes a short reasoning note. Multiple correct
-- answers exist. Yours may differ. What matters is the result set
-- and the join strategy.
-- =============================================================

USE BootcampDB;
GO


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


-- =============================================================
-- END OF SOLUTIONS
-- =============================================================
