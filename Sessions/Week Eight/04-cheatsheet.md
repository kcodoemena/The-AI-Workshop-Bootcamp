# SQL Joins Cheat Sheet

**The AI Workshop Bootcamp - Week 8** | Tutor: Kelechi Odoemena

---

## The 4 Join Types You Need

| Join | Returns | Use When |
|---|---|---|
| `INNER JOIN` | Rows where the key exists in BOTH tables | You only want matched data |
| `LEFT JOIN` | All rows from LEFT, matched rows from RIGHT (NULL if no match) | You want to keep everything on the left, even unmatched |
| `RIGHT JOIN` | Mirror of LEFT | Rare. Most teams flip the table order and use LEFT |
| `FULL OUTER JOIN` | All rows from both, NULLs where unmatched | You want to see everything, including gaps on either side |

---

## The Anatomy of a Join

```sql
SELECT  l.col1, r.col2
FROM    left_table  AS l
LEFT JOIN right_table AS r
    ON  l.key = r.key;
```

**Three things to always include:**

1. **Aliases** (`AS p`, `AS a`). Saves typing, makes column ownership obvious.
2. **Explicit join type** (`INNER`, `LEFT`). Never rely on the default.
3. **The ON clause**. Forgetting it produces a Cartesian product (rows multiply).

---

## Visual Mental Model

```
INNER JOIN          LEFT JOIN           FULL OUTER JOIN
                                        
    L   R              L   R               L   R
   ___ ___            ___ ___             ___ ___
  /   X   \          /XXX X   \          /XXX X XXX\
 |  L | R  |        |XXX | R  |         |XXX | XXX|
  \___X___/          \XXX X___/          \XXX X XXX/
   ^                  ^                   ^
   only matches       all of L            everything
                      + matches of R
```

---

## Top 5 Pitfalls

**1. Cartesian product**

Forgetting `ON` returns every left row paired with every right row. If your row count explodes, this is why.

**2. WHERE on a LEFT JOIN's right table**

```sql
LEFT JOIN Admissions a ...
WHERE a.AdmissionType = 'Emergency';
```

This silently turns it into an INNER JOIN. Put the filter inside `ON`:

```sql
LEFT JOIN Admissions a
    ON p.PatientID = a.PatientID
   AND a.AdmissionType = 'Emergency';
```

**3. Ambiguous column names**

`SELECT PatientID FROM ... JOIN ...` fails when both tables have a `PatientID` column. Always prefix with the alias: `p.PatientID`.

**4. COUNT vs COUNT(column) on LEFT JOINs**

`COUNT(*)` counts rows including the NULL-padded ones from unmatched lefts. `COUNT(a.AdmissionID)` only counts non-NULL right-side values. Use the second when you want zeros for empty groups.

**5. Forgetting that NULL never equals NULL**

`NULL = NULL` is `UNKNOWN`, not `TRUE`. Use `IS NULL` / `IS NOT NULL`.

---

## Anti-Join Pattern (find what does not exist)

```sql
SELECT p.PatientID, p.FirstName
FROM Patients p
LEFT JOIN Admissions a ON p.PatientID = a.PatientID
WHERE a.AdmissionID IS NULL;
```

Reads as: give me the patients with **no matching admission**.

---

## Multi-Table Join Pattern

```sql
SELECT p.FirstName, w.WardName, o.ObsType, o.ObsValue
FROM Patients     AS p
INNER JOIN Admissions   AS a ON p.PatientID  = a.PatientID
INNER JOIN Wards        AS w ON a.WardID     = w.WardID
INNER JOIN Observations AS o ON a.AdmissionID = o.AdmissionID;
```

**Read it top to bottom as hops along foreign keys.** Each new line is one more bridge between tables.

---

## AI Prompting Template for Joins

Paste this into Claude or Copilot:

```
You are writing T-SQL for SQL Server.

Schema:
  <paste CREATE TABLE blocks or column lists with PK/FK markers>

Task (one sentence):
  <what you want back, in plain English>

Quality bar:
  - Use table aliases (p, a, w, o)
  - Use the right join type (INNER vs LEFT)
  - Handle NULLs explicitly
  - Order by <column>

Before writing the query, explain your join strategy in
two sentences. Then give the query in one code block.
```

**Always do these three checks after the AI gives you a query:**

1. Read it. Do you understand each line?
2. Run it. Does the row count look right?
3. Sanity-check one row by hand against the source tables.

---

## Quick Reference: T-SQL Join Syntax

```sql
-- INNER (matches only)
FROM A INNER JOIN B ON A.id = B.a_id

-- LEFT (all of A, matches of B)
FROM A LEFT  JOIN B ON A.id = B.a_id

-- RIGHT (rare, prefer rewriting as LEFT)
FROM A RIGHT JOIN B ON A.id = B.a_id

-- FULL OUTER (everything)
FROM A FULL  OUTER JOIN B ON A.id = B.a_id

-- CROSS (Cartesian, every combination, no ON)
FROM A CROSS JOIN B
```

---

**Next week:** Subqueries & CTEs. We will combine them with joins.
