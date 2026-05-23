# Facilitator Guide | Week 10 | Introduction to Data Profiling

**When:** Saturday, 23 May 2026, 1pm UK
**Where:** Zoom
**Duration:** 75 to 80 minutes
**Tutor:** Kelechi Odoemena

---

## Pre-Session Checklist (15 min before)

- [ ] Open Codespaces and run `seed.sql` to refresh BootcampDB
- [ ] Smoke test: `SELECT COUNT(*) FROM Patients;` returns 10
- [ ] Open `01-walkthrough-profiling.sql` in VS Code
- [ ] Have Claude.ai (or Copilot) open in a second tab for the AI demo
- [ ] Open the deck in Presenter View
- [ ] Confirm Zoom is recording

---

## Session Flow (75 to 80 min)

| Time | Block | Slides |
|---|---|---|
| 0:00 to 0:05 | Welcome, recap of Week 9, today's goal | 1 to 3 |
| 0:05 to 0:12 | Why profile, the four lenses, schema reminder | 4 to 6 |
| 0:12 to 0:30 | Lens by lens: shape, NULLs, cardinality, range, distributions (live demo) | 7 to 14 |
| 0:30 to 0:45 | Anomaly detection: statistical, pattern, cross-field | 15 to 18 |
| 0:45 to 0:55 | AI as a profiling partner (live demo) | 19 |
| 0:55 to 1:10 | Hands-on exercises (1 to 4 together) | 20 to 21 |
| 1:10 to 1:20 | Recap, what's next, Q&A | 22 to 24 |

If time slips, cut Exercise 4 first, then condense the anomaly detection trio.

---

## Key Messages

1. **Profile before you query.** You can't trust analysis on a dataset you've never inspected.
2. **The four lenses are non-negotiable.** Shape, completeness, uniqueness, range. Every dataset. Every time.
3. **Anomalies are not always outliers.** Sometimes they're format problems, sentinel values, or logical impossibilities.
4. **AI accelerates the typing, not the thinking.** You still own verification.

---

## AI Demo Script (Slide 19)

Open Claude.ai. Run two prompts side by side.

**Vague prompt** (show what to avoid):

> Profile my admissions table.

**Structured prompt** (the good one):

> I'm using T-SQL on SQL Server.
>
> Table Admissions has columns:
> - AdmissionID INT PK
> - PatientID INT NOT NULL
> - WardID INT NULL
> - AdmissionDate DATETIME NOT NULL
> - DischargeDate DATETIME NULL
> - AdmissionType NVARCHAR(50) NULL
> - Diagnosis NVARCHAR(200) NULL
>
> Write a single query that returns total rows, NULL count per nullable column, and distinct count for AdmissionType. Use aliases, one projected column per line, T-SQL syntax only. After the query, list 3 sanity checks for the output.

Run the resulting query in Codespaces live. Note the difference in usability.

---

## Common Questions and How To Answer

**"What about NULL vs empty string?"**
> Both are missing data, both need profiling, but they're not the same. `WHERE col IS NULL` only catches NULL. Add `OR col = ''` to catch empties. Better yet, run both as separate columns in your profile.

**"Why STDEV and not VAR?"**
> They're related: STDEV is the square root of VAR. STDEV is in the same units as your data, so it's more interpretable. Use VAR if you're doing further statistical work, STDEV for everyday profiling.

**"How do I profile a 10 billion row table?"**
> Sample first. `TABLESAMPLE (1 PERCENT)` or a deterministic WHERE clause like `WHERE patient_id % 100 = 0` gives you 1% of rows for the cost of 1%. Profile the sample, then validate the most critical findings on the full table.

**"What's the difference between this and Week 11?"**
> Today is the foundation: how to look at data. Next week we turn the findings into quality checks you can automate and rerun on a schedule.

---

## Exercise Walkthrough Script

If running short, walk through these three only in class. The rest are homework.

**Exercise 1 (Shape)** - 2 minutes. Easy win. Just UNION ALL.

**Exercise 2 (NULL profile)** - 3 minutes. This is the muscle-memory query. Make sure every student writes it themselves, even if AI could do it instantly.

**Exercise 3 (Cardinality + percentages)** - 4 minutes. This is where window functions click for some students. Take time to explain `SUM(COUNT(*)) OVER ()`.

**Exercise 4 (Histogram)** - 4 minutes. Beware students putting the CASE in SELECT but not GROUP BY. Show both versions: the raw CASE-in-GROUP-BY and the cleaner CTE wrap.

---

## If Things Go Wrong

| Problem | Fallback |
|---|---|
| Codespace won't start | Run queries against a local SQL Server or SQLite (the patterns transfer; only `STDEV` and `NTILE` syntax may differ) |
| Live AI demo fails | Use the screenshots in the deck speaker notes, talk through what would happen |
| Running over time | Skip exercises 5 to 7, point at them as homework, end on time |
| Quiet room, no questions | Use the "what's one thing you'd profile at work this week?" prompt on slide 24 |

---

## Post-Session Actions

- [ ] Push the deck and SQL files to the bootcamp repo under `week-10/`
- [ ] Post the cheat sheet in the cohort channel
- [ ] Share the Zoom recording link
- [ ] Tease Week 11 in the channel: "We're turning today's profiling into automated quality checks"
