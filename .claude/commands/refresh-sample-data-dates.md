# Refresh Sample Data Dates

Scan all test/sample data files under `config/data/` and shift any past dates into the next half of the calendar year, relative to today.

## Context

Today's date is available via the `currentDate` system context. Use it to determine which dates are stale and what the target window should be.

**Target window rule:**
- If today falls in H1 (Jan–Jun): push dates into H2 of the current year (Jul–Dec).
- If today falls in H2 (Jul–Dec): push dates into H1 of the next year (Jan–Jun).

Within the target window, preserve a realistic spread — don't cluster everything at the same date.

## Steps

1. **Discover** — Find all files under `config/data/` that contain ISO date strings (`YYYY-MM-DD`). Check `.json` and `.csv` files.

2. **Audit** — For each file, list every date field found and flag which values are in the past (before today).

3. **Propose mapping** — Before writing anything, show the user a concise mapping table:
   - Field name | Current value | Proposed value
   - Only include rows where the current value is in the past.
   - Get explicit approval before proceeding.

4. **Apply** — Once approved, update the files. Keep all other fields untouched. Preserve JSON formatting (indentation, key order).

5. **Verify** — Re-scan the files and confirm no past dates remain. Report a summary: files changed, total dates updated.

## Notes

- Do **not** update dates that are already in the future — leave them alone.
- Preserve day-of-month when possible (e.g., `2025-03-15` → `2026-09-15`), only adjust if the resulting date would be invalid (e.g., Feb 30).
- If a file has no past dates, skip it and say so.
- Do not touch `soql-queries/`, `sfdmu/`, or `README.md` — date strings there are query templates or documentation, not data.
