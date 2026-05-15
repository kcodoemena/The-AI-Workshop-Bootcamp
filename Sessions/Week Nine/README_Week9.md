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
