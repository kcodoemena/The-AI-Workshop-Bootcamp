-- =============================================================
-- WEEK 11 - DATA QUALITY SOLUTIONS
-- =============================================================
-- Each solution has the query plus a short note on the reasoning.
-- There's often more than one correct answer; these are clean,
-- idiomatic versions that follow the rule_name / violations /
-- status pattern.
-- =============================================================

USE BootcampDB;
GO


-- =============================================================
-- EXERCISE 1 - A COMPLETENESS CHECK
-- =============================================================

SELECT
    'Wards.Site not null'                              AS rule_name,
    SUM(CASE WHEN Site IS NULL THEN 1 ELSE 0 END)      AS violations,
    CASE
        WHEN SUM(CASE WHEN Site IS NULL THEN 1 ELSE 0 END) = 0
        THEN 'PASS' ELSE 'FAIL'
    END                                                AS status
FROM Wards;

-- Reasoning: Ward A has a NULL Site in the seed data, so this returns
-- violations = 1 and status = FAIL. That's the correct, useful result.
-- A check that catches a real gap is doing its job.


-- =============================================================
-- EXERCISE 2 - DUPLICATE DETECTION
-- =============================================================

SELECT
    FirstName,
    LastName,
    DateOfBirth,
    COUNT(*) AS record_count
FROM Patients
GROUP BY FirstName, LastName, DateOfBirth
HAVING COUNT(*) > 1;

-- Reasoning: GROUP BY collapses identical (name, name, DOB) combinations;
-- HAVING COUNT(*) > 1 keeps only those that appear more than once.
-- In our clean seed data this returns ZERO rows - which is a pass.
-- The pattern is what matters: point it at a messy CSV import and it
-- will surface real duplicate people instantly.


-- =============================================================
-- EXERCISE 3 - A VALIDITY CHECK
-- =============================================================

SELECT
    'Wards.Capacity in range (1-200)'                  AS rule_name,
    SUM(CASE WHEN Capacity <= 0 OR Capacity > 200
             THEN 1 ELSE 0 END)                         AS violations,
    CASE
        WHEN SUM(CASE WHEN Capacity <= 0 OR Capacity > 200
                 THEN 1 ELSE 0 END) = 0
        THEN 'PASS' ELSE 'FAIL'
    END                                                AS status
FROM Wards;

-- Reasoning: a "range" validity check codifies a business rule -
-- a ward can't have zero or negative beds, and 200+ is implausible.
-- Our seed values (18 to 50) all pass. Note: also consider a NULL
-- check, since Capacity is nullable. You could add
-- "OR Capacity IS NULL" to be strict.


-- =============================================================
-- EXERCISE 4 - A REFERENTIAL CHECK
-- =============================================================

SELECT
    'Admissions reference a valid patient'             AS rule_name,
    COUNT(*)                                           AS violations,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM Admissions a
LEFT JOIN Patients p ON a.PatientID = p.PatientID
WHERE p.PatientID IS NULL;

-- Reasoning: LEFT JOIN keeps every admission; rows where the patient
-- side is NULL are orphans (an admission pointing at a missing patient).
-- The FK constraint guarantees zero here, but you run this anyway -
-- because data loaded around the constraint (bulk inserts, ETL) can
-- still break it. The check is your seatbelt.


-- =============================================================
-- EXERCISE 5 - MINI SCORECARD
-- =============================================================

SELECT 'Wards.Site not null' AS rule_name,
       SUM(CASE WHEN Site IS NULL THEN 1 ELSE 0 END) AS violations,
       CASE WHEN SUM(CASE WHEN Site IS NULL THEN 1 ELSE 0 END) = 0
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM Wards
UNION ALL
SELECT 'Wards.Capacity in range (1-200)',
       SUM(CASE WHEN Capacity <= 0 OR Capacity > 200 THEN 1 ELSE 0 END),
       CASE WHEN SUM(CASE WHEN Capacity <= 0 OR Capacity > 200 THEN 1 ELSE 0 END) = 0
            THEN 'PASS' ELSE 'FAIL' END
FROM Wards
UNION ALL
SELECT 'Admissions reference a valid patient',
       COUNT(*),
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM Admissions a
LEFT JOIN Patients p ON a.PatientID = p.PatientID
WHERE p.PatientID IS NULL
ORDER BY status DESC, rule_name;

-- Reasoning: every branch projects exactly three columns in the same
-- order, so UNION ALL stacks them cleanly. ORDER BY status DESC floats
-- 'FAIL' above 'PASS' so problems jump out. This is the core artifact
-- of the whole week - one query, one glance, whole-database health.


-- =============================================================
-- EXERCISE 6 - DEDUPLICATION WITH ROW_NUMBER
-- =============================================================

WITH ranked AS (
    SELECT
        ObservationID,
        AdmissionID,
        ObsType,
        ObsDateTime,
        ObsValue,
        ROW_NUMBER() OVER (
            PARTITION BY AdmissionID, ObsType
            ORDER BY ObsDateTime
        ) AS rn
    FROM Observations
)
SELECT
    ObservationID,
    AdmissionID,
    ObsType,
    ObsDateTime,
    ObsValue,
    rn,
    CASE WHEN rn = 1 THEN 'KEEP' ELSE 'DROP' END AS action
FROM ranked
ORDER BY AdmissionID, ObsType, rn;

-- Reasoning: PARTITION BY restarts the numbering for each
-- (AdmissionID, ObsType) group; ORDER BY ObsDateTime makes rn = 1 the
-- earliest reading. Keep rn = 1, drop the rest. To actually delete in
-- production you'd wrap this in a DELETE ... WHERE rn > 1, but tagging
-- first (and eyeballing it) is the safe habit.


-- =============================================================
-- EXERCISE 7 - AI QUALITY SUITE
-- =============================================================
-- Example prompt using the five-part template:
/*
Dialect:
I'm using T-SQL on SQL Server.

Schema:
Table Admissions has columns:
- AdmissionID INT PK
- PatientID INT NOT NULL (FK to Patients)
- WardID INT NULL (FK to Wards)
- AdmissionDate DATETIME NOT NULL
- DischargeDate DATETIME NULL
- AdmissionType NVARCHAR(50) NULL
- Diagnosis NVARCHAR(200) NULL

Goal:
Generate a data quality check suite as a single result set combined
with UNION ALL. Each check must return three columns in this order:
rule_name (text), violations (int), status ('PASS' or 'FAIL').

Dimensions to cover:
- Completeness: AdmissionDate and PatientID must never be null
- Validity: AdmissionType must be one of Emergency, Elective, Transfer
- Consistency: DischargeDate must not be earlier than AdmissionDate

Verify:
After the suite, tell me which dimension each check covers, and name
any check you could NOT write from the schema alone.
*/

-- A reasonable AI-generated answer:
SELECT 'Admissions.AdmissionDate not null' AS rule_name,
       SUM(CASE WHEN AdmissionDate IS NULL THEN 1 ELSE 0 END) AS violations,
       CASE WHEN SUM(CASE WHEN AdmissionDate IS NULL THEN 1 ELSE 0 END) = 0
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM Admissions
UNION ALL
SELECT 'Admissions.PatientID not null',
       SUM(CASE WHEN PatientID IS NULL THEN 1 ELSE 0 END),
       CASE WHEN SUM(CASE WHEN PatientID IS NULL THEN 1 ELSE 0 END) = 0
            THEN 'PASS' ELSE 'FAIL' END
FROM Admissions
UNION ALL
SELECT 'Admissions.AdmissionType valid',
       SUM(CASE WHEN AdmissionType NOT IN ('Emergency','Elective','Transfer') THEN 1 ELSE 0 END),
       CASE WHEN SUM(CASE WHEN AdmissionType NOT IN ('Emergency','Elective','Transfer') THEN 1 ELSE 0 END) = 0
            THEN 'PASS' ELSE 'FAIL' END
FROM Admissions
UNION ALL
SELECT 'Admissions.discharge not before admission',
       SUM(CASE WHEN DischargeDate < AdmissionDate THEN 1 ELSE 0 END),
       CASE WHEN SUM(CASE WHEN DischargeDate < AdmissionDate THEN 1 ELSE 0 END) = 0
            THEN 'PASS' ELSE 'FAIL' END
FROM Admissions
ORDER BY status DESC, rule_name;

-- What AI should flag it CAN'T check from schema alone:
--   - Accuracy (does the diagnosis match the patient's real condition?)
--   - Whether NULL DischargeDate genuinely means "still admitted"
--   These need business context, not just column definitions.


-- =============================================================
-- END OF SOLUTIONS
-- The scorecard pattern (Exercise 5) is the one to keep. Build it
-- once, add a row per rule, schedule it, and you have a living
-- quality monitor.
-- =============================================================
