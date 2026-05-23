# Data Profiling Cheat Sheet | Week 10

A one-page reference for the four lenses, the anomaly patterns, and a copy-paste AI prompt template. Pin this somewhere visible.

---

## The Four Lenses

Every dataset gets profiled by asking four questions, in order.

| Lens | Question | Core SQL |
|---|---|---|
| **Shape** | How big is it? | `COUNT(*)` |
| **Completeness** | How much is missing? | `SUM(CASE WHEN col IS NULL THEN 1 ELSE 0 END)` |
| **Uniqueness** | How varied is each column? | `COUNT(DISTINCT col)` |
| **Range** | Where do values fall? | `MIN`, `MAX`, `AVG`, `STDEV` + CASE bands |

Profile every new dataset through all four. Skip one, miss a bug.

---

## Templates You Will Reuse

### Multi-table shape report

```sql
SELECT 'TableA' AS table_name, COUNT(*) AS row_count FROM TableA
UNION ALL
SELECT 'TableB',                 COUNT(*)              FROM TableB
ORDER BY row_count DESC;
```

### Full NULL profile in one row

```sql
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN col_a IS NULL THEN 1 ELSE 0 END) AS null_a,
    SUM(CASE WHEN col_b IS NULL THEN 1 ELSE 0 END) AS null_b
FROM YourTable;
```

### Frequency table with percentages

```sql
SELECT
    col,
    COUNT(*) AS frequency,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS pct
FROM YourTable
GROUP BY col
ORDER BY frequency DESC;
```

### Histogram via CASE buckets

```sql
SELECT
    CASE
        WHEN numeric_col < 10  THEN '1. Under 10'
        WHEN numeric_col < 50  THEN '2. 10-49'
        WHEN numeric_col < 100 THEN '3. 50-99'
        ELSE                       '4. 100+'
    END AS bucket,
    COUNT(*) AS frequency
FROM YourTable
GROUP BY CASE ... END   -- repeat the CASE here
ORDER BY bucket;
```

---

## Anomaly Detection Patterns

**Statistical outliers (z-score > 2)**

```sql
WITH stats AS (
    SELECT AVG(CAST(val AS FLOAT)) AS mu, STDEV(val) AS sd FROM YourTable
)
SELECT * FROM YourTable t CROSS JOIN stats s
WHERE ABS((t.val - s.mu) / NULLIF(s.sd, 0)) > 2;
```

**Format / pattern checks (LIKE with character classes)**

| Check | Pattern |
|---|---|
| Has a non-digit | `col LIKE '%[^0-9]%'` |
| Has a non-letter | `col LIKE '%[^A-Za-z]%'` |
| Wrong length | `LEN(col) <> N` |
| Looks like a UK postcode | `col LIKE '[A-Z][A-Z0-9]%[0-9][A-Z][A-Z]'` |

**Cross-field consistency**

```sql
SELECT * FROM Admissions
WHERE DischargeDate < AdmissionDate;     -- impossible ordering

SELECT o.* FROM Observations o
JOIN Admissions a ON o.AdmissionID = a.AdmissionID
WHERE o.ObsDateTime < a.AdmissionDate
   OR o.ObsDateTime > a.DischargeDate;   -- out of window
```

---

## Sentinel Values to Watch For

These look like data but are really "we don't know" in disguise.

- Dates: `1900-01-01`, `9999-12-31`, `1970-01-01`
- Numbers: `-1`, `0`, `9999`, `999999`, `-999`
- Strings: `'N/A'`, `'NULL'`, `'?'`, `'Unknown'`, `'TBC'`, empty string
- IDs: `0`, padding like `'000000'`

Profile for these explicitly. `WHERE col = 'N/A'` is a real query.

---

## The AI Profiling Prompt Template

Five parts. Paste, fill in, hit send.

```
DIALECT
I'm using T-SQL on SQL Server.

SCHEMA
Table <Name> has columns:
  - <col_1> <type> <NULL|NOT NULL>
  - <col_2> <type> <NULL|NOT NULL>
  ...

GOAL
Write a single query that returns a one-row profile of <Name>.
The row should include:
  - total rows
  - NULL count for each nullable column
  - distinct count for <col_X>
  - <any other specific metric you need>

QUALITY
- Use aliases. One projected column per line.
- T-SQL syntax only.
- Use a CTE only if it improves readability.

VERIFY
After the query, list 3 sanity checks I should run on the output.
```

Always run the AI's query yourself and read the result. AI hallucinations are most dangerous on column names. Verify against the actual schema.

---

## Five Profiling Mistakes To Avoid

1. **Profiling only one table at a time.** Always profile related tables together; the bugs are at the joins.
2. **Trusting `COUNT(*)` to mean "rows of data".** It includes rows with all-NULL payload. Use `COUNT(non_null_col)` when you care about real data.
3. **Forgetting that `NULL != NULL`.** `WHERE col = NULL` returns nothing. Always `IS NULL`.
4. **Bucketing without seeing the spread first.** Run min/max before you write CASE bands or you'll pick the wrong boundaries.
5. **Profiling once, then never again.** Data drifts. Re-profile on a schedule.

---

## Useful T-SQL Profiling Functions

| Function | Use for |
|---|---|
| `COUNT_BIG(*)` | Row counts on tables >2bn rows |
| `STDEV`, `VAR` | Spread of numeric data |
| `NTILE(n)` | Bucketing into N equal-sized groups |
| `PERCENTILE_CONT` | True median / quartiles (window function) |
| `LEN(col)` | String length |
| `DATALENGTH(col)` | Byte length (catches trailing whitespace) |
| `LTRIM(RTRIM(col))` | Reveal whitespace issues |
| `TRY_CAST(col AS INT)` | Find non-numeric values in a string column |
