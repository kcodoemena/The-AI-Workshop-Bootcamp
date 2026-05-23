-- =============================================================
-- Week 8: SQL Joins  (Walkthrough File)
-- The AI Workshop Bootcamp  |  Saturday, 9 May 2026
-- Tutor: Kelechi Odoemena  |  Database: BootcampDB
-- =============================================================
-- Run blocks one at a time using Ctrl+Shift+E (or highlight + Ctrl+Shift+E)

USE BootcampDB;
GO

-- =============================================================
-- 0. RECAP  (where we left off)
-- =============================================================
-- Last week we used CASE statements to transform single-table data.
-- Today we work across MULTIPLE tables. Run this to remind yourself
-- what tables exist:

SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- Quick peek at each table:
SELECT TOP 3 * FROM Patients;
SELECT TOP 3 * FROM Wards;
SELECT TOP 3 * FROM Admissions;
SELECT TOP 3 * FROM Observations;
GO


-- =============================================================
-- 1. THE PROBLEM JOINS SOLVE
-- =============================================================
-- Patients table has WHO. Admissions table has WHEN/WHERE. Neither
-- alone answers: "Which patient was admitted on 5 Jan 2024?"

-- Patients alone: no admission info
SELECT PatientID, FirstName, LastName FROM Patients;

-- Admissions alone: just IDs, no patient names
SELECT AdmissionID, PatientID, AdmissionDate, Diagnosis FROM Admissions;
GO


-- =============================================================
-- 2. INNER JOIN  (the matching rows from both tables)
-- =============================================================
-- Pattern:
--   SELECT ...
--   FROM   left_table  AS l
--   INNER JOIN right_table AS r
--     ON l.key = r.key

-- Example A: Every admission, with the patient's name
SELECT
    p.FirstName,
    p.LastName,
    a.AdmissionDate,
    a.Diagnosis
FROM Patients AS p
INNER JOIN Admissions AS a
    ON p.PatientID = a.PatientID
ORDER BY a.AdmissionDate;

-- Example B: Same query, with the ward name added (still INNER)
SELECT
    p.FirstName + ' ' + p.LastName AS PatientName,
    w.WardName,
    a.AdmissionDate,
    a.Diagnosis
FROM Patients AS p
INNER JOIN Admissions AS a ON p.PatientID = a.PatientID
INNER JOIN Wards      AS w ON a.WardID    = w.WardID
ORDER BY a.AdmissionDate;
GO


-- =============================================================
-- 3. LEFT JOIN  (everything on the left, matches on the right)
-- =============================================================
-- Use LEFT JOIN when you want to KEEP rows even if the right side
-- has no match. Unmatched right-side columns become NULL.

-- Example C: All patients, with their admissions if any.
-- Useful for spotting patients who have NEVER been admitted.
SELECT
    p.PatientID,
    p.FirstName,
    p.LastName,
    a.AdmissionID,
    a.AdmissionDate,
    a.Diagnosis
FROM Patients AS p
LEFT JOIN Admissions AS a
    ON p.PatientID = a.PatientID
ORDER BY p.PatientID;

-- Example D: "Find patients with no admission" pattern
--   LEFT JOIN + WHERE right_key IS NULL  =  anti-join
SELECT
    p.PatientID,
    p.FirstName,
    p.LastName
FROM Patients AS p
LEFT JOIN Admissions AS a
    ON p.PatientID = a.PatientID
WHERE a.AdmissionID IS NULL;
GO


-- =============================================================
-- 4. THE LEFT JOIN GOTCHA   (silently turns into INNER JOIN)
-- =============================================================
-- Putting a filter on the RIGHT table in WHERE drops the NULL rows.

-- Wrong (acts like INNER JOIN):
SELECT p.FirstName, p.LastName, a.Diagnosis
FROM Patients AS p
LEFT JOIN Admissions AS a ON p.PatientID = a.PatientID
WHERE a.AdmissionType = 'Emergency';   -- removes patients with no admission

-- Right (filter inside the ON clause):
SELECT p.FirstName, p.LastName, a.Diagnosis
FROM Patients AS p
LEFT JOIN Admissions AS a
    ON p.PatientID = a.PatientID
   AND a.AdmissionType = 'Emergency';
GO


-- =============================================================
-- 5. RIGHT & FULL OUTER  (sister joins, used less often)
-- =============================================================
-- RIGHT JOIN keeps everything on the right side. Most teams just
-- swap table order and use LEFT JOIN for readability.

-- All wards with admissions; wards with no admissions still show up.
SELECT
    w.WardName,
    a.AdmissionID,
    a.Diagnosis
FROM Admissions AS a
RIGHT JOIN Wards AS w
    ON a.WardID = w.WardID
ORDER BY w.WardName;

-- FULL OUTER JOIN keeps unmatched rows from BOTH sides.
SELECT
    w.WardName,
    a.AdmissionID
FROM Admissions AS a
FULL OUTER JOIN Wards AS w
    ON a.WardID = w.WardID;
GO


-- =============================================================
-- 6. MULTI-TABLE JOINS  (chaining 3+ tables)
-- =============================================================
-- Read top to bottom. Each new JOIN is a hop along a foreign key.

-- Example E: Patient name + ward + every observation taken
SELECT
    p.FirstName + ' ' + p.LastName AS Patient,
    w.WardName,
    a.AdmissionDate,
    o.ObsType,
    o.ObsValue,
    o.ObsDateTime
FROM Patients     AS p
INNER JOIN Admissions   AS a ON p.PatientID  = a.PatientID
INNER JOIN Wards        AS w ON a.WardID     = w.WardID
INNER JOIN Observations AS o ON a.AdmissionID = o.AdmissionID
ORDER BY p.LastName, o.ObsDateTime;

-- Example F: Mixing INNER and LEFT (a common real-world pattern)
-- Every patient with their ward (if admitted), plus any observations.
SELECT
    p.FirstName + ' ' + p.LastName AS Patient,
    w.WardName,
    a.AdmissionDate,
    o.ObsType,
    o.ObsValue
FROM Patients     AS p
LEFT JOIN Admissions   AS a ON p.PatientID   = a.PatientID
LEFT JOIN Wards        AS w ON a.WardID      = w.WardID
LEFT JOIN Observations AS o ON a.AdmissionID = o.AdmissionID
ORDER BY p.LastName;
GO


-- =============================================================
-- 7. SELF JOIN  (joining a table to itself)
-- =============================================================
-- Find pairs of patients who share the same GP.
SELECT
    p1.FirstName + ' ' + p1.LastName AS PatientA,
    p2.FirstName + ' ' + p2.LastName AS PatientB,
    p1.RegisteredGP
FROM Patients AS p1
INNER JOIN Patients AS p2
    ON p1.RegisteredGP = p2.RegisteredGP
   AND p1.PatientID    < p2.PatientID;   -- prevents duplicates and self-pairs
GO


-- =============================================================
-- 8. JOIN + AGGREGATE  (the analyst's bread and butter)
-- =============================================================
-- How many admissions per ward?
SELECT
    w.WardName,
    COUNT(a.AdmissionID) AS AdmissionCount
FROM Wards AS w
LEFT JOIN Admissions AS a ON w.WardID = a.WardID
GROUP BY w.WardName
ORDER BY AdmissionCount DESC;

-- LEFT JOIN matters here: a ward with zero admissions still appears
-- with a count of 0. Switch it to INNER JOIN and that ward vanishes.
GO


-- =============================================================
-- 9. AI-ASSISTED JOIN WRITING  (live demo prompt examples)
-- =============================================================
-- Prompt A (good):
-- "Given these tables in T-SQL: Patients(PatientID, FirstName, LastName),
--  Admissions(AdmissionID, PatientID, AdmissionDate, Diagnosis), write a
--  query that lists every patient with their most recent admission date,
--  including patients who have never been admitted."

-- Prompt B (better, gives the AI a quality bar):
-- "...Use a LEFT JOIN. Use table aliases. Show NULL where there is
--  no admission. Order by LastName."

-- Always ask the AI to EXPLAIN the join strategy. Then run it. Trust,
-- but verify with a row count check.
GO


-- =============================================================
-- END OF WALKTHROUGH
-- Next: open  02-exercises.sql  and try them yourself.
-- =============================================================
