# Week 9 — Subqueries & CTEs
**The AI Workshop SQL & AI Bootcamp**
📅 Saturday, 16 May 2026

---

## Session Overview

This week we move from single-query thinking to **modular SQL** — breaking complex problems into readable, reusable building blocks using subqueries and Common Table Expressions (CTEs).

---

## Topics Covered

### 1. Nested Queries (Subqueries)
- What is a subquery and where can it live? (`SELECT`, `FROM`, `WHERE`, `HAVING`)
- Correlated vs non-correlated subqueries
- Scalar subqueries — returning a single value
- Subqueries with `IN`, `EXISTS`, and `NOT EXISTS`
- When subqueries hurt performance and what to do about it

### 2. Common Table Expressions (CTEs)
- Syntax: `WITH cte_name AS (...)`
- Why CTEs improve readability and maintainability over nested subqueries
- Chaining multiple CTEs in a single query
- Recursive CTEs — traversing hierarchical data
- CTEs vs subqueries vs temp tables — when to use which

---

## Learning Objectives

By the end of this session, you will be able to:

- Write subqueries inside `SELECT`, `FROM`, and `WHERE` clauses
- Identify when a query is correlated and understand its performance implications
- Refactor deeply nested SQL into clean, named CTEs
- Chain multiple CTEs to solve multi-step analytical problems
- Use a recursive CTE to walk a simple hierarchy (e.g. org chart, category tree)

---

## Worked Examples

All examples below use **inline views built with `VALUES`** — no real tables needed. Copy and run them directly in your SQL environment.

---

### Setting Up: Inline Views with VALUES

```sql
-- Patients
CREATE VIEW vw_patients AS
SELECT * FROM (VALUES
    (1, 'Amara Osei',      'Cardiology',    3),
    (2, 'David Mensah',    'Orthopaedics',  1),
    (3, 'Fatima Al-Rashid','Cardiology',    5),
    (4, 'James Okafor',    'Neurology',     2),
    (5, 'Priya Patel',     'Orthopaedics',  0)
) AS p(patient_id, patient_name, ward, spell_count);

-- Ward averages (pre-computed for illustration)
CREATE VIEW vw_ward_avg AS
SELECT * FROM (VALUES
    ('Cardiology',    4.0),
    ('Orthopaedics',  0.5),
    ('Neurology',     2.0)
) AS w(ward, avg_spells);

-- Discharges
CREATE VIEW vw_discharges AS
SELECT * FROM (VALUES
    (1, 'Amara Osei',    '2026-04-10'),
    (3, 'Fatima Al-Rashid','2026-04-22'),
    (4, 'James Okafor',  '2026-05-01')
) AS d(patient_id, patient_name, discharge_date);
```

---

### Example 1 — Scalar Subquery in WHERE
*Patients in Cardiology with above-average spell counts for their ward.*

```sql
SELECT patient_name, spell_count
FROM   vw_patients
WHERE  ward = 'Cardiology'
  AND  spell_count > (
           SELECT avg_spells
           FROM   vw_ward_avg
           WHERE  ward = 'Cardiology'   -- correlated on ward name
       );
```

> **Result:** Fatima Al-Rashid (5 spells > avg 4.0). Amara Osei (3) falls below the average.

---

### Example 2 — NOT EXISTS (Patients Never Discharged)
*Find patients who have no matching discharge record.*

```sql
SELECT patient_name, ward
FROM   vw_patients p
WHERE  NOT EXISTS (
           SELECT 1
           FROM   vw_discharges d
           WHERE  d.patient_id = p.patient_id
       );
```

> **Result:** David Mensah, Priya Patel — neither appears in `vw_discharges`.

---

### Example 3 — Refactoring a Nested Subquery into a CTE
**Before (hard to read):**

```sql
SELECT patient_name, spell_count
FROM (
    SELECT patient_name, spell_count, ward
    FROM   vw_patients
    WHERE  spell_count > 1
) AS filtered
WHERE ward = 'Cardiology';
```

**After (CTE — same result, far clearer):**

```sql
WITH active_patients AS (
    SELECT patient_name, spell_count, ward
    FROM   vw_patients
    WHERE  spell_count > 1
)
SELECT patient_name, spell_count
FROM   active_patients
WHERE  ward = 'Cardiology';
```

> Both return Amara Osei and Fatima Al-Rashid. The CTE version names the intent.

---

### Example 4 — Chained CTEs (Patient Journey Summary)
*Build a multi-step pipeline: filter → enrich → summarise.*

```sql
WITH
-- Step 1: only patients with at least one spell
active AS (
    SELECT patient_id, patient_name, ward, spell_count
    FROM   vw_patients
    WHERE  spell_count > 0
),

-- Step 2: tag whether they were discharged
with_discharge_flag AS (
    SELECT a.*,
           CASE WHEN d.patient_id IS NOT NULL THEN 'Yes' ELSE 'No' END AS discharged
    FROM   active a
    LEFT JOIN vw_discharges d ON d.patient_id = a.patient_id
),

-- Step 3: summarise by ward
ward_summary AS (
    SELECT ward,
           COUNT(*)                                   AS total_patients,
           SUM(spell_count)                           AS total_spells,
           SUM(CASE WHEN discharged = 'Yes' THEN 1 ELSE 0 END) AS discharged_count
    FROM   with_discharge_flag
    GROUP BY ward
)

SELECT *
FROM   ward_summary
ORDER BY total_spells DESC;
```

> Each CTE is a named, testable step — swap out any one without touching the others.

---

### Example 5 (Stretch) — Recursive CTE: Referral Hierarchy

```sql
-- Inline referral chain: who referred whom?
CREATE VIEW vw_referrals AS
SELECT * FROM (VALUES
    (1, 'Dr. Afolabi',   NULL),          -- top-level consultant
    (2, 'Dr. Nwosu',     1),
    (3, 'Dr. Mensah',    1),
    (4, 'Dr. Patel',     2),
    (5, 'Dr. Al-Rashid', 2)
) AS r(clinician_id, clinician_name, referred_by_id);

-- Walk the hierarchy from the top down
WITH RECURSIVE referral_chain AS (
    -- Anchor: start at the top-level consultant
    SELECT clinician_id, clinician_name, referred_by_id, 0 AS depth
    FROM   vw_referrals
    WHERE  referred_by_id IS NULL

    UNION ALL

    -- Recursive: find everyone referred by the current level
    SELECT r.clinician_id, r.clinician_name, r.referred_by_id, rc.depth + 1
    FROM   vw_referrals r
    JOIN   referral_chain rc ON r.referred_by_id = rc.clinician_id
)
SELECT REPEAT('  ', depth) || clinician_name AS hierarchy,
       depth
FROM   referral_chain
ORDER BY depth, clinician_id;
```

> **Output (indented):** Dr. Afolabi → Dr. Nwosu, Dr. Mensah → Dr. Patel, Dr. Al-Rashid.
> The recursion stops automatically when no more rows match.

---

## Exercises

Practice queries will use **BootcampDB** — our NHS-inspired sample database.

| # | Task | Concept |
|---|------|---------|
| 1 | Find patients whose spell count is above the ward average | Scalar subquery in `WHERE` |
| 2 | List wards that have never had a discharge | `NOT EXISTS` subquery |
| 3 | Rewrite a nested subquery as a CTE | CTE refactoring |
| 4 | Produce a patient journey summary using chained CTEs | Multi-CTE pipeline |
| 5 | *(Stretch)* Build a recursive CTE over a referral hierarchy | Recursive CTE |

---

## Pre-Session Checklist

- [ ] Codespace / Docker Compose environment running
- [ ] BootcampDB connected and accessible
- [ ] Week 8 assignment submitted (or flagged for review)
- [ ] Slides loaded and screen share tested

---

## Resources

- [SQL CTEs — Microsoft Docs](https://learn.microsoft.com/en-us/sql/t-sql/queries/with-common-table-expression-transact-sql)
- [Recursive CTEs explained](https://learn.microsoft.com/en-us/sql/t-sql/queries/with-common-table-expression-transact-sql#guidelines-for-defining-and-using-recursive-common-table-expressions)
- GitHub repo: `the-ai-workshop/sql-bootcamp` → `week-09/`

---

*The AI Workshop CIC — Building data skills that matter.*
