-- =============================================================
-- WEEK 11 - DATA QUALITY EXERCISES
-- 7 exercises. Numbers 1-4 in class, 5-7 as homework.
-- Database: BootcampDB (T-SQL)
-- =============================================================
-- Every check should return the same shape where possible:
--   rule_name, violations, status ('PASS' / 'FAIL')
-- That consistency is the whole point - it lets checks stack.
-- =============================================================

USE BootcampDB;
GO


-- =============================================================
-- EXERCISE 1 - A COMPLETENESS CHECK
-- Goal: Write a single check on Wards.Site that returns:
--   rule_name, violations (count of NULL Site), and status.
-- Status is 'PASS' only if there are zero NULLs.
-- Hint: SUM(CASE WHEN Site IS NULL THEN 1 ELSE 0 END).
-- (Spoiler: Ward A has a NULL Site, so this should FAIL.)
-- =============================================================

-- Your query here:




-- =============================================================
-- EXERCISE 2 - DUPLICATE DETECTION
-- Goal: Find any patients who share the same FirstName, LastName,
-- AND DateOfBirth (a likely duplicate person, even with different IDs).
-- Return the name, DOB, and how many records match.
-- Hint: GROUP BY the three columns, HAVING COUNT(*) > 1.
-- =============================================================

-- Your query here:




-- =============================================================
-- EXERCISE 3 - A VALIDITY CHECK
-- Goal: Write a check confirming every Wards.Capacity is a sensible
-- positive number (greater than 0 and at most 200). Return
-- rule_name, violations, status.
-- Hint: SUM(CASE WHEN Capacity <= 0 OR Capacity > 200 THEN 1 ELSE 0 END).
-- =============================================================

-- Your query here:




-- =============================================================
-- EXERCISE 4 - A REFERENTIAL CHECK
-- Goal: Confirm every Admission points to a Patient that exists.
-- Return rule_name, violations (count of orphan admissions), status.
-- Hint: LEFT JOIN Admissions to Patients, count where the patient
--       side is NULL.
-- (Spoiler: the FK guarantees zero. A passing check is still useful.)
-- =============================================================

-- Your query here:




-- =============================================================
-- EXERCISE 5 - BUILD A MINI SCORECARD (BONUS)
-- Goal: Combine your checks from Exercises 1, 3, and 4 into ONE
-- result set using UNION ALL. Order so failures appear first.
-- Hint: each SELECT must project the same three columns in the
--       same order. ORDER BY status DESC at the end.
-- =============================================================

-- Your query here:




-- =============================================================
-- EXERCISE 6 - DEDUPLICATION WITH ROW_NUMBER (BONUS)
-- Goal: For the Observations table, imagine you only want to keep
-- ONE observation per (AdmissionID, ObsType) - the earliest one.
-- Use ROW_NUMBER() to tag each row, then show which rows you'd KEEP
-- and which you'd DROP.
-- Hint: ROW_NUMBER() OVER (PARTITION BY AdmissionID, ObsType
--                          ORDER BY ObsDateTime) AS rn
--       then CASE WHEN rn = 1 THEN 'KEEP' ELSE 'DROP' END.
-- =============================================================

-- Your query here:




-- =============================================================
-- EXERCISE 7 - AI QUALITY SUITE (HOMEWORK)
-- Goal: Use the five-part template from the deck to ask AI to
-- generate a full quality check suite for the Admissions table,
-- returned as a single UNION ALL scorecard.
-- Your suite should cover at least:
--   - Completeness (a NOT NULL check)
--   - Validity (AdmissionType in an allowed set)
--   - Consistency (DischargeDate not before AdmissionDate)
--
-- Run the AI's query. In the cohort channel, post:
--   1. Your prompt
--   2. Whether it ran first time
--   3. One check the AI suggested that you hadn't thought of
-- =============================================================

-- Your prompt and notes here:




-- =============================================================
-- END OF EXERCISES
-- Solutions are in 03-solutions.sql - have a real go first!
-- =============================================================
