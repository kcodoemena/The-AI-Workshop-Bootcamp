-- =============================================================
-- WEEK 11 - PROFILING FOR DATA QUALITY
-- Live walkthrough file for the Saturday session
-- Database: BootcampDB (T-SQL / SQL Server)
-- =============================================================
-- Last week we LOOKED at data. This week we turn what we find
-- into repeatable CHECKS that return pass or fail.
-- Each section maps to a slide in the deck.
-- =============================================================

USE BootcampDB;
GO

-- =============================================================
-- SECTION 0 - RECAP
-- The four lenses from last week: shape, completeness,
-- uniqueness, range. We profiled. Now we operationalise.
-- =============================================================

SELECT TOP 5 * FROM Patients;
SELECT TOP 5 * FROM Admissions;


-- =============================================================
-- SECTION 1 - THE SIX DIMENSIONS OF DATA QUALITY
-- A profile describes data. A quality check JUDGES it.
--   1. Completeness - is anything missing?
--   2. Uniqueness   - are there duplicates?
--   3. Validity     - does it match the rules?
--   4. Consistency  - do related fields agree?
--   5. Accuracy     - does it match reality?
--   6. Timeliness   - is it fresh enough?
-- =============================================================


-- =============================================================
-- SECTION 2 - THE QUALITY CHECK PATTERN
-- Every check returns the SAME shape: a rule name, a count of
-- violations, and a pass/fail verdict. That consistency is what
-- lets us stack hundreds of checks into one scorecard.
-- =============================================================

SELECT
    'Patients.Postcode not null'                       AS rule_name,
    SUM(CASE WHEN Postcode IS NULL THEN 1 ELSE 0 END)  AS violations,
    CASE
        WHEN SUM(CASE WHEN Postcode IS NULL THEN 1 ELSE 0 END) = 0
        THEN 'PASS' ELSE 'FAIL'
    END                                                AS status
FROM Patients;


-- =============================================================
-- SECTION 3 - COMPLETENESS CHECKS (with thresholds)
-- Not every NULL is a failure. Set a tolerance.
-- =============================================================

-- A completeness check with an acceptable threshold (5% NULLs OK)
SELECT
    'Admissions.DischargeReason <= 50% null'           AS rule_name,
    COUNT(*)                                           AS total_rows,
    SUM(CASE WHEN DischargeReason IS NULL THEN 1 ELSE 0 END) AS null_count,
    CAST(100.0 * SUM(CASE WHEN DischargeReason IS NULL THEN 1 ELSE 0 END)
         / COUNT(*) AS DECIMAL(5,2))                   AS pct_null,
    CASE
        WHEN 100.0 * SUM(CASE WHEN DischargeReason IS NULL THEN 1 ELSE 0 END)
             / COUNT(*) <= 50 THEN 'PASS' ELSE 'FAIL'
    END                                                AS status
FROM Admissions;
-- DischargeReason is NULL while a patient is still admitted - that's
-- expected, so a threshold (not zero) is the right call here.


-- =============================================================
-- SECTION 4 - UNIQUENESS: DUPLICATE DETECTION
-- The headline skill for this week.
-- =============================================================

-- 4a. Find duplicate VALUES in a column (GROUP BY ... HAVING)
-- Are there any repeated NHS numbers? (Should be zero - there's a
-- UNIQUE constraint. A passing check still earns its keep.)
SELECT
    NHSNumber,
    COUNT(*) AS times_seen
FROM Patients
GROUP BY NHSNumber
HAVING COUNT(*) > 1;

-- 4b. Find duplicate PEOPLE even when the ID differs
-- Same first name + last name + date of birth = likely same person
SELECT
    FirstName, LastName, DateOfBirth,
    COUNT(*) AS record_count
FROM Patients
GROUP BY FirstName, LastName, DateOfBirth
HAVING COUNT(*) > 1;

-- 4c. The dedup pattern with ROW_NUMBER()
-- When you DO have duplicates, this keeps one and tags the rest.
-- Imagine a raw import without constraints:
WITH raw_import AS (
    SELECT NHSNumber, FirstName, LastName, DateOfBirth FROM Patients
    UNION ALL
    SELECT '1234567890', 'James', 'Patel', '1952-03-14'  -- a planted duplicate
),
ranked AS (
    SELECT
        NHSNumber, FirstName, LastName,
        ROW_NUMBER() OVER (
            PARTITION BY NHSNumber
            ORDER BY FirstName
        ) AS rn
    FROM raw_import
)
SELECT
    NHSNumber, FirstName, LastName,
    rn,
    CASE WHEN rn = 1 THEN 'KEEP' ELSE 'DROP' END AS action
FROM ranked
ORDER BY NHSNumber, rn;


-- =============================================================
-- SECTION 5 - VALIDITY CHECKS (format / domain rules)
-- =============================================================

-- NHS number must be 10 digits, all numeric
SELECT
    'Patients.NHSNumber valid format'                  AS rule_name,
    SUM(CASE WHEN NHSNumber LIKE '%[^0-9]%'
              OR LEN(NHSNumber) <> 10 THEN 1 ELSE 0 END) AS violations,
    CASE
        WHEN SUM(CASE WHEN NHSNumber LIKE '%[^0-9]%'
                       OR LEN(NHSNumber) <> 10 THEN 1 ELSE 0 END) = 0
        THEN 'PASS' ELSE 'FAIL'
    END                                                AS status
FROM Patients;

-- Domain check: AdmissionType must be one of an allowed set
SELECT
    'Admissions.AdmissionType in allowed set'          AS rule_name,
    SUM(CASE WHEN AdmissionType NOT IN ('Emergency','Elective','Transfer')
             THEN 1 ELSE 0 END)                         AS violations,
    CASE
        WHEN SUM(CASE WHEN AdmissionType NOT IN ('Emergency','Elective','Transfer')
                 THEN 1 ELSE 0 END) = 0
        THEN 'PASS' ELSE 'FAIL'
    END                                                AS status
FROM Admissions;


-- =============================================================
-- SECTION 6 - CONSISTENCY CHECKS (cross-field + referential)
-- =============================================================

-- 6a. Cross-field: discharge must not precede admission
SELECT
    'Admissions.discharge after admission'             AS rule_name,
    SUM(CASE WHEN DischargeDate < AdmissionDate THEN 1 ELSE 0 END) AS violations,
    CASE
        WHEN SUM(CASE WHEN DischargeDate < AdmissionDate THEN 1 ELSE 0 END) = 0
        THEN 'PASS' ELSE 'FAIL'
    END                                                AS status
FROM Admissions;

-- 6b. Referential integrity: orphan observations
-- (Observations pointing to an Admission that doesn't exist.)
-- The FK prevents this in BootcampDB, but in ETL'd data it happens.
SELECT
    'Observations have a valid admission'              AS rule_name,
    COUNT(*)                                           AS violations,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM Observations o
LEFT JOIN Admissions a ON o.AdmissionID = a.AdmissionID
WHERE a.AdmissionID IS NULL;


-- =============================================================
-- SECTION 7 - TIMELINESS / FRESHNESS CHECKS
-- =============================================================

-- How stale is the most recent observation?
SELECT
    'Observations freshness'                           AS rule_name,
    MAX(ObsDateTime)                                   AS latest_obs,
    DATEDIFF(DAY, MAX(ObsDateTime), GETDATE())         AS days_since_latest,
    CASE
        WHEN DATEDIFF(DAY, MAX(ObsDateTime), GETDATE()) <= 30
        THEN 'PASS' ELSE 'FAIL'
    END                                                AS status
FROM Observations;
-- Note: our seed data is from 2024, so this will "fail" today -
-- a great talking point about what freshness means in practice.


-- =============================================================
-- SECTION 8 - THE QUALITY SCORECARD
-- Stack every check into ONE result set with UNION ALL.
-- This is the artifact you schedule and watch.
-- =============================================================

SELECT 'Patients.Postcode not null' AS rule_name,
       SUM(CASE WHEN Postcode IS NULL THEN 1 ELSE 0 END) AS violations,
       CASE WHEN SUM(CASE WHEN Postcode IS NULL THEN 1 ELSE 0 END) = 0
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM Patients
UNION ALL
SELECT 'Patients.NHSNumber valid',
       SUM(CASE WHEN NHSNumber LIKE '%[^0-9]%' OR LEN(NHSNumber) <> 10 THEN 1 ELSE 0 END),
       CASE WHEN SUM(CASE WHEN NHSNumber LIKE '%[^0-9]%' OR LEN(NHSNumber) <> 10 THEN 1 ELSE 0 END) = 0
            THEN 'PASS' ELSE 'FAIL' END
FROM Patients
UNION ALL
SELECT 'Admissions.discharge after admission',
       SUM(CASE WHEN DischargeDate < AdmissionDate THEN 1 ELSE 0 END),
       CASE WHEN SUM(CASE WHEN DischargeDate < AdmissionDate THEN 1 ELSE 0 END) = 0
            THEN 'PASS' ELSE 'FAIL' END
FROM Admissions
UNION ALL
SELECT 'Admissions.type in allowed set',
       SUM(CASE WHEN AdmissionType NOT IN ('Emergency','Elective','Transfer') THEN 1 ELSE 0 END),
       CASE WHEN SUM(CASE WHEN AdmissionType NOT IN ('Emergency','Elective','Transfer') THEN 1 ELSE 0 END) = 0
            THEN 'PASS' ELSE 'FAIL' END
FROM Admissions
ORDER BY status DESC, rule_name;
-- One glance tells you the health of the whole database.


-- =============================================================
-- SECTION 9 - AI PROMPTING FOR QUALITY RULES
-- =============================================================
/*
The five-part quality-rule prompt:

1. DIALECT:   "I'm using T-SQL on SQL Server."
2. SCHEMA:    "Table Patients has: NHSNumber CHAR(10) UNIQUE NOT NULL,
               DateOfBirth DATE NOT NULL, Gender NVARCHAR(10) NULL,
               Postcode NVARCHAR(8) NULL."
3. GOAL:      "Generate a data quality check suite. Each check must return
               rule_name, violations (int), and status ('PASS'/'FAIL'),
               combined with UNION ALL into one scorecard."
4. DIMENSIONS:"Cover completeness, uniqueness, validity, and consistency."
5. VERIFY:    "After the suite, list which dimension each check covers and
               any check you could NOT write from the schema alone."

The last line matters: accuracy and some consistency checks need business
context the schema can't give. AI naming that gap is a feature, not a bug.
*/


-- =============================================================
-- END OF WALKTHROUGH
-- Continue to 02-exercises.sql for the practical.
-- =============================================================
