-- =============================================================
-- WEEK 10 - DATA PROFILING EXERCISES
-- 7 exercises. Numbers 1-4 in class, 5-7 as homework.
-- Database: BootcampDB (T-SQL)
-- =============================================================
-- Try writing each query yourself first. If stuck for more than
-- two minutes, ask AI - but verify the output before trusting it.
-- =============================================================

USE BootcampDB;
GO


-- =============================================================
-- EXERCISE 1 - SHAPE WARM-UP
-- Goal: Produce a single result set with the row count for every
-- table in BootcampDB, sorted by row count descending.
-- Hint: UNION ALL with literal strings for the table name.
-- =============================================================

-- Your query here:




-- =============================================================
-- EXERCISE 2 - NULL PROFILE
-- Goal: For the Patients table, produce a single-row result that
-- shows the total row count and the number of NULLs in EACH column
-- of the table (other than PatientID and CreatedDate).
-- Hint: SUM(CASE WHEN col IS NULL THEN 1 ELSE 0 END) per column.
-- =============================================================

-- Your query here:




-- =============================================================
-- EXERCISE 3 - CARDINALITY FREQUENCY TABLE
-- Goal: For the Wards table, return each distinct WardType with
-- its frequency (how many rows have it) and percentage of the total,
-- ordered by frequency descending.
-- Hint: GROUP BY WardType, then COUNT(*) and a percentage column
--       using a window function: COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ().
-- =============================================================

-- Your query here:




-- =============================================================
-- EXERCISE 4 - AGE DISTRIBUTION HISTOGRAM
-- Goal: Bucket patients into age bands and count how many fall into
-- each band. Use these bands:
--   < 40, 40-59, 60-79, 80+
-- Hint: Use CASE inside both SELECT and GROUP BY (or wrap in a CTE).
-- =============================================================

-- Your query here:




-- =============================================================
-- EXERCISE 5 - LENGTH OF STAY OUTLIERS (BONUS)
-- Goal: For admissions that have been discharged, compute the length
-- of stay in days. Then list any admission whose stay is more than
-- 2 standard deviations away from the mean.
-- Hint: Use a CTE with AVG and STDEV, then join back.
-- Bonus: also return the z-score for each outlier.
-- =============================================================

-- Your query here:




-- =============================================================
-- EXERCISE 6 - POSTCODE FORMAT CHECK (BONUS)
-- Goal: List any patient whose Postcode does NOT match the basic
-- UK pattern of "2-4 letters, space, 1 digit + 2 letters".
-- Hint: A simple LIKE pattern with [A-Z][A-Z]%[0-9][A-Z][A-Z]
--       gets you most of the way. Don't worry about perfect coverage.
-- =============================================================

-- Your query here:




-- =============================================================
-- EXERCISE 7 - AI PROMPTING PRACTICE (HOMEWORK)
-- Goal: Use the five-part template from the deck to write a prompt
-- that asks AI to generate a profile query for the Observations table.
-- Your profile should report:
--   - Total rows
--   - NULL count for each column
--   - Distinct ObsType count
--   - The most common RecordedBy value and its count
--
-- Paste the prompt and the AI's response into the cohort channel.
-- Then run the AI's query and tell us whether it worked first time
-- or needed corrections.
-- =============================================================

-- Your prompt and notes here:




-- =============================================================
-- END OF EXERCISES
-- Solutions are in 03-solutions.sql - have a real go first!
-- =============================================================
