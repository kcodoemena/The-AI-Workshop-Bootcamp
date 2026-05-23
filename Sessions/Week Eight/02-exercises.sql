-- =============================================================
-- Week 8: SQL Joins  -  EXERCISES
-- The AI Workshop Bootcamp  |  9 May 2026
-- =============================================================
-- Try each exercise yourself first. Use AI as a partner, not as a
-- shortcut. Compare your answer to 03-solutions.sql at the end.
--
-- Tables (recap):
--   Patients     (PatientID, NHSNumber, FirstName, LastName, ...)
--   Wards        (WardID, WardName, WardType, Capacity, Site)
--   Admissions   (AdmissionID, PatientID, WardID, AdmissionDate,
--                 DischargeDate, AdmissionType, Diagnosis, ...)
--   Observations (ObservationID, AdmissionID, ObsDateTime,
--                 ObsType, ObsValue, RecordedBy)
-- =============================================================

USE BootcampDB;
GO


-- -------------------------------------------------------------
-- EXERCISE 1   (warm-up, INNER JOIN)
-- -------------------------------------------------------------
-- Return one row per admission with these columns:
--   PatientFullName, AdmissionDate, Diagnosis, AdmissionType
-- Order by AdmissionDate ascending.

-- Your query here:




-- -------------------------------------------------------------
-- EXERCISE 2   (LEFT JOIN, finding the gaps)
-- -------------------------------------------------------------
-- List EVERY ward and the number of admissions it has had.
-- Wards with zero admissions must still appear (with count = 0).
-- Order by AdmissionCount descending.

-- Your query here:




-- -------------------------------------------------------------
-- EXERCISE 3   (anti-join pattern)
-- -------------------------------------------------------------
-- Find patients who have NEVER been admitted.
-- Return: PatientID, FirstName, LastName, RegisteredGP.

-- Your query here:




-- -------------------------------------------------------------
-- EXERCISE 4   (multi-table, 3 joins)
-- -------------------------------------------------------------
-- For every observation, return:
--   PatientFullName, WardName, ObsDateTime, ObsType, ObsValue
-- Order by ObsDateTime ascending.

-- Your query here:




-- -------------------------------------------------------------
-- EXERCISE 5   (mixed INNER + LEFT)
-- -------------------------------------------------------------
-- Return one row per admission with:
--   PatientFullName, WardName, AdmissionDate,
--   FirstObsType, FirstObsValue
-- "First observation" = the earliest ObsDateTime for that admission.
-- Admissions with NO observations should still appear (NULLs allowed).
-- Hint: a subquery or APPLY may help, but it is solvable with joins
-- and a GROUP BY trick. AI-assisted attempts welcome.

-- Your query here:




-- -------------------------------------------------------------
-- EXERCISE 6   (BONUS - self join)
-- -------------------------------------------------------------
-- Find pairs of patients who share the same RegisteredGP and
-- the same Postcode prefix (first 3 characters, e.g. 'LS1').
-- Return: PatientA, PatientB, GP, PostcodePrefix.
-- Avoid duplicate pairs (A-B and B-A) and self-pairs (A-A).

-- Your query here:




-- -------------------------------------------------------------
-- EXERCISE 7   (BONUS - AI prompting practice)
-- -------------------------------------------------------------
-- Without writing the SQL yourself, write the BEST PROMPT you can
-- to get an AI to produce a correct query for this question:
--
-- "Show me each patient who is currently still admitted (no
--  discharge date), the ward they are on, the most recent vital
--  signs observation taken, and how many days they have been in."
--
-- Paste your prompt as a comment below. Discuss in the chat what
-- makes the prompt good or bad. Then test it with Claude or Copilot.

-- Your prompt:




-- =============================================================
-- END OF EXERCISES
-- Solutions are in 03-solutions.sql  (no peeking until you've tried!)
-- =============================================================
