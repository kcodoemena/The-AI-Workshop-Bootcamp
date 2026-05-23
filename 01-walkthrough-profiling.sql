-- =============================================================
-- WEEK 10 - INTRODUCTION TO DATA PROFILING
-- Live walkthrough file for the Saturday session
-- Database: BootcampDB (T-SQL / SQL Server)
-- =============================================================
-- Run each section in order during the live demo.
-- Each section maps to a slide in the deck.
-- =============================================================

USE BootcampDB;
GO

-- =============================================================
-- SECTION 0 - RECAP
-- Quick sanity check that the database is alive and seeded.
-- =============================================================

SELECT TOP 5 * FROM Patients;
SELECT TOP 5 * FROM Admissions;


-- =============================================================
-- SECTION 1 - THE FOUR LENSES (mental model)
-- Every dataset gets profiled through four questions:
--   1. Shape:        How big is it?
--   2. Completeness: How much is missing?
--   3. Uniqueness:   How varied is each column?
--   4. Range:        Where do values fall?
-- =============================================================


-- =============================================================
-- SECTION 2 - LENS 1: SHAPE & ROW COUNTS
-- =============================================================

-- Single table row count
SELECT COUNT(*) AS row_count FROM Patients;

-- Quick shape report across all four tables in one go
SELECT 'Patients'      AS table_name, COUNT(*) AS row_count FROM Patients
UNION ALL
SELECT 'Wards',         COUNT(*) FROM Wards
UNION ALL
SELECT 'Admissions',    COUNT(*) FROM Admissions
UNION ALL
SELECT 'Observations',  COUNT(*) FROM Observations
ORDER BY row_count DESC;


-- =============================================================
-- SECTION 3 - LENS 2: COMPLETENESS (NULL PROFILING)
-- =============================================================

-- Naive single-column check
SELECT
    COUNT(*)                                            AS total_rows,
    COUNT(DischargeDate)                                AS non_null_discharge,
    COUNT(*) - COUNT(DischargeDate)                     AS null_discharge,
    CAST(100.0 * (COUNT(*) - COUNT(DischargeDate)) / COUNT(*) AS DECIMAL(5,2))
                                                        AS pct_null_discharge
FROM Admissions;

-- A full NULL profile for every column in Admissions, in one query
-- Pattern: SUM(CASE WHEN col IS NULL THEN 1 ELSE 0 END) per column
SELECT
    COUNT(*)                                                       AS total_rows,
    SUM(CASE WHEN PatientID       IS NULL THEN 1 ELSE 0 END)       AS null_patient_id,
    SUM(CASE WHEN WardID          IS NULL THEN 1 ELSE 0 END)       AS null_ward_id,
    SUM(CASE WHEN AdmissionDate   IS NULL THEN 1 ELSE 0 END)       AS null_admission_date,
    SUM(CASE WHEN DischargeDate   IS NULL THEN 1 ELSE 0 END)       AS null_discharge_date,
    SUM(CASE WHEN AdmissionType   IS NULL THEN 1 ELSE 0 END)       AS null_admission_type,
    SUM(CASE WHEN Diagnosis       IS NULL THEN 1 ELSE 0 END)       AS null_diagnosis,
    SUM(CASE WHEN DischargeReason IS NULL THEN 1 ELSE 0 END)       AS null_discharge_reason
FROM Admissions;


-- =============================================================
-- SECTION 4 - LENS 3: UNIQUENESS (CARDINALITY)
-- =============================================================

-- Total rows vs distinct: the uniqueness ratio
SELECT
    COUNT(*)                  AS total_rows,
    COUNT(DISTINCT AdmissionType) AS distinct_types,
    COUNT(*) / COUNT(DISTINCT AdmissionType) AS rows_per_distinct
FROM Admissions;

-- Frequency table: which values dominate?
SELECT
    AdmissionType,
    COUNT(*)                                                AS frequency,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,2))
                                                            AS pct_of_total
FROM Admissions
GROUP BY AdmissionType
ORDER BY frequency DESC;

-- The TOP N pattern for high-cardinality columns
-- (most common diagnoses)
SELECT TOP 5
    Diagnosis,
    COUNT(*) AS frequency
FROM Admissions
GROUP BY Diagnosis
ORDER BY frequency DESC;


-- =============================================================
-- SECTION 5 - LENS 4: RANGE & DISTRIBUTION
-- =============================================================

-- Numeric: min / max / avg / stddev on Capacity
SELECT
    MIN(Capacity)               AS min_capacity,
    MAX(Capacity)               AS max_capacity,
    AVG(Capacity)               AS avg_capacity,
    STDEV(Capacity)             AS stdev_capacity
FROM Wards;

-- Date: oldest and youngest patient
SELECT
    MIN(DateOfBirth)            AS earliest_dob,
    MAX(DateOfBirth)            AS latest_dob,
    DATEDIFF(YEAR, MAX(DateOfBirth), GETDATE())  AS youngest_age_approx,
    DATEDIFF(YEAR, MIN(DateOfBirth), GETDATE())  AS oldest_age_approx
FROM Patients;

-- Distribution via CASE buckets (a "poor man's histogram")
SELECT
    CASE
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 40 THEN '1. Under 40'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 60 THEN '2. 40-59'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 80 THEN '3. 60-79'
        ELSE                                                  '4. 80+'
    END                         AS age_band,
    COUNT(*)                    AS patients
FROM Patients
GROUP BY
    CASE
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 40 THEN '1. Under 40'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 60 THEN '2. 40-59'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 80 THEN '3. 60-79'
        ELSE                                                  '4. 80+'
    END
ORDER BY age_band;


-- =============================================================
-- SECTION 6 - ANOMALY DETECTION: STATISTICAL OUTLIERS
-- =============================================================

-- Pattern: anything beyond 2 standard deviations from the mean
WITH stats AS (
    SELECT
        AVG(CAST(Capacity AS FLOAT)) AS mean_cap,
        STDEV(Capacity)              AS sd_cap
    FROM Wards
)
SELECT
    w.WardName,
    w.Capacity,
    s.mean_cap,
    s.sd_cap,
    (w.Capacity - s.mean_cap) / NULLIF(s.sd_cap, 0) AS z_score
FROM Wards w CROSS JOIN stats s
WHERE ABS((w.Capacity - s.mean_cap) / NULLIF(s.sd_cap, 0)) > 1.5;

-- Percentile-based outliers using NTILE (great for skewed data)
WITH ranked AS (
    SELECT
        WardName,
        Capacity,
        NTILE(4) OVER (ORDER BY Capacity) AS quartile
    FROM Wards
)
SELECT * FROM ranked
ORDER BY Capacity;


-- =============================================================
-- SECTION 7 - ANOMALY DETECTION: PATTERN & FORMAT CHECKS
-- =============================================================

-- NHS number should be exactly 10 digits. Find any that fail.
SELECT
    NHSNumber,
    LEN(NHSNumber)                                          AS length,
    CASE
        WHEN NHSNumber LIKE '%[^0-9]%' THEN 'Contains non-digit'
        WHEN LEN(NHSNumber) <> 10      THEN 'Wrong length'
        ELSE 'OK'
    END                                                     AS issue
FROM Patients
WHERE NHSNumber LIKE '%[^0-9]%' OR LEN(NHSNumber) <> 10;

-- ObsValue is NVARCHAR so it stores all sorts: '88%', '145/90', '38.2'
-- Profile the formats by ObsType
SELECT
    ObsType,
    ObsValue,
    LEN(ObsValue)                                           AS value_length,
    CASE
        WHEN ObsValue LIKE '%[^0-9.]%' AND ObsValue LIKE '%/%' THEN 'BP-style (n/n)'
        WHEN ObsValue LIKE '%[^0-9.]%' AND ObsValue LIKE '%[%]%' THEN 'Percent'
        WHEN ObsValue LIKE '%[^0-9.]%'                         THEN 'Has unit/symbol'
        WHEN ObsValue LIKE '%.%'                               THEN 'Decimal'
        ELSE 'Integer'
    END                                                     AS detected_format
FROM Observations
ORDER BY ObsType, ObsValue;


-- =============================================================
-- SECTION 8 - CROSS-FIELD CONSISTENCY
-- =============================================================

-- Find any admission where DischargeDate is before AdmissionDate
-- (none should exist - this is a logical impossibility)
SELECT
    AdmissionID,
    AdmissionDate,
    DischargeDate,
    DATEDIFF(DAY, AdmissionDate, DischargeDate) AS days_diff
FROM Admissions
WHERE DischargeDate < AdmissionDate;

-- Find observations recorded outside their admission window
SELECT
    o.ObservationID,
    o.AdmissionID,
    a.AdmissionDate,
    a.DischargeDate,
    o.ObsDateTime,
    CASE
        WHEN o.ObsDateTime < a.AdmissionDate                       THEN 'Before admission'
        WHEN o.ObsDateTime > ISNULL(a.DischargeDate, '9999-12-31') THEN 'After discharge'
        ELSE 'OK'
    END AS issue
FROM Observations o
INNER JOIN Admissions a ON o.AdmissionID = a.AdmissionID
WHERE o.ObsDateTime < a.AdmissionDate
   OR o.ObsDateTime > a.DischargeDate;


-- =============================================================
-- SECTION 9 - AI PROMPTING PATTERN FOR PROFILING
-- =============================================================
/*
The five-part profiling prompt template:

1. DIALECT:    "I'm using T-SQL on SQL Server."
2. SCHEMA:     "Table Admissions has columns:
                PatientID INT, WardID INT NULL,
                AdmissionDate DATETIME, DischargeDate DATETIME NULL,
                AdmissionType NVARCHAR(50), Diagnosis NVARCHAR(200)."
3. GOAL:       "Write a single query that produces a one-row profile of:
                total rows, NULL count per column, and distinct count per column."
4. QUALITY:    "Use aliases. One column per line. No subqueries unless needed."
5. VERIFY:     "After the query, list the 3 sanity checks I should run on the output."

Paste that prompt into Claude / Copilot / ChatGPT and you'll get a usable
profile query in seconds, plus a verification checklist for free.
*/


-- =============================================================
-- END OF WALKTHROUGH
-- Continue to 02-exercises.sql for the practical.
-- =============================================================
