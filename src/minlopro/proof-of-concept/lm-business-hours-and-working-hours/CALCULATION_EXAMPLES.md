# `calculateFutureBusinessDatetime` - Calculation Examples

## Method Overview

The method calculates a future datetime by adding **48 business hours** to a given start time, then ensures the result falls within **working hours (9:00-18:00)** on a **working day (Mon-Fri)**.

### Algorithm

1. Convert 48 hours to milliseconds.
2. Call `BusinessHours.add()` to add 48h of business time to the start datetime.
3. Validate the result against **three conditions** (all must be true):
    - **`isWithinBusinessHours`** — `BusinessHours.isWithin()` confirms the datetime falls inside configured Business Hours.
    - **`isWithinWorkingHours`** — The hour (in the BH timezone) is in the range [9, 18).
    - **`isWorkingDay`** — The day of week (in the BH timezone) is not Saturday or Sunday.
4. If any condition fails, advance by 1 hour and re-check. Repeat until all three pass.
5. Return the final datetime.

### Assumptions

- Business Hours record is configured as **24/7 for all days** (Monday through Sunday, including weekends).
- Since every day is a business day, `BusinessHours.add()` treats **48 business hours as 48 calendar hours** (minus any holidays).
- Holidays **may** be configured — `BusinessHours.add()` skips holiday time, and `BusinessHours.isWithin()` returns false during holidays.
- Working hours window enforced by the code: **9:00 - 18:00, Monday-Friday only**.
- Timezone: Business Hours timezone (e.g. `Europe/Kyiv`).

> **Key insight:** There is a deliberate tension between the Business Hours config (24/7 all week) and the code's own validation (Mon-Fri, 9-18). `BusinessHours.add()` freely counts time through weekends, but the while-loop post-adjustment rejects any result that lands on a weekend or outside 9-18. The `isWorkingDay` check is critical here — without it, weekend results would pass validation since `BusinessHours.isWithin()` returns true for weekends in a 24/7 schedule.

---

## Case 1: Saturday at 13:00

**Input:** Saturday, 13:00

### Step-by-step

| Step | Action                                   | Result                                                                                                                                                                            |
| ---- | ---------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | `BusinessHours.add(Saturday 13:00, 48h)` | Saturday **is** a business day in 24/7 config. The engine counts 48 calendar hours straight through.                                                                              |
| 2    | Sat 13:00 + 48 hours                     | Sat 13:00 → Sun 13:00 (24h) → **Mon 13:00** (48h).                                                                                                                                |
| 3    | Validate Mon 13:00                       | `isWithinBusinessHours` = true (24/7 schedule). `isWithinWorkingHours`: hour = 13, in [9, 18) → **true**. `isWorkingDay` = true (Monday). Combined: **PASS** — no looping needed. |

**Output: Monday, 13:00**

---

## Case 2: Friday at 11:00

**Input:** Friday, 11:00

### Step-by-step

| Step | Action                                    | Result                                                                                                                                                   |
| ---- | ----------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | `BusinessHours.add(Friday 11:00, 48h)`    | Friday is a business day. In a 24/7 config, weekends are counted too. The engine counts 48 calendar hours straight through.                              |
| 2    | Fri 11:00 + 48 hours                      | Fri 11:00 → Sat 11:00 (24h) → **Sun 11:00** (48h).                                                                                                       |
| 3    | Validate Sun 11:00                        | `isWithinBusinessHours` = true (24/7). `isWithinWorkingHours`: hour = 11, in [9, 18) → **true**. `isWorkingDay`: Sunday → **false**. Combined: **FAIL**. |
| 4    | Loop: advance +1h per iteration on Sunday | Sun 12:00 → 13:00 → ... → 17:00. All fail because `isWorkingDay` = false (still Sunday).                                                                 |
| 5    | Sun 18:00 → 19:00 → ... → 23:00           | All fail: `isWorkingDay` = false **and** `isWithinWorkingHours` = false (hour >= 18).                                                                    |
| 6    | Mon 00:00 → 01:00 → ... → 08:00           | `isWorkingDay` = true (Monday), but hour < 9 → `isWithinWorkingHours` = false. All fail.                                                                 |
| 7    | Validate Mon 09:00                        | `isWithinBusinessHours` = true. `isWithinWorkingHours`: hour = 9, in [9, 18) → **true**. `isWorkingDay` = true (Monday). Combined: **PASS**.             |

**Output: Monday, 09:00**

> Note: The loop iterates 22 times (Sun 12:00 through Mon 08:00) before finding a valid slot.

---

## Case 3: Wednesday at 14:00

**Input:** Wednesday, 14:00

### Step-by-step

| Step | Action                                    | Result                                                                                                                                                                   |
| ---- | ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1    | `BusinessHours.add(Wednesday 14:00, 48h)` | Wednesday is a business day. In a 24/7 config, the engine counts 48 calendar hours straight through. No weekends to worry about within this range.                       |
| 2    | Wed 14:00 + 48 hours                      | Wed 14:00 → Thu 14:00 (24h) → **Fri 14:00** (48h).                                                                                                                       |
| 3    | Validate Fri 14:00                        | `isWithinBusinessHours` = true (24/7). `isWithinWorkingHours`: hour = 14, in [9, 18) → **true**. `isWorkingDay` = true (Friday). Combined: **PASS** — no looping needed. |

**Output: Friday, 14:00** (same week)

---

## Case 4: Thursday at 10:00

**Input:** Thursday, 10:00

### Step-by-step

| Step | Action                                   | Result                                                                                                                                                     |
| ---- | ---------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | `BusinessHours.add(Thursday 10:00, 48h)` | Thursday is a business day. 48 calendar hours straight through.                                                                                            |
| 2    | Thu 10:00 + 48 hours                     | Thu 10:00 → Fri 10:00 (24h) → **Sat 10:00** (48h).                                                                                                         |
| 3    | Validate Sat 10:00                       | `isWithinBusinessHours` = true (24/7). `isWithinWorkingHours`: hour = 10, in [9, 18) → **true**. `isWorkingDay`: Saturday → **false**. Combined: **FAIL**. |
| 4    | Loop: advance +1h on Saturday            | Sat 11:00 → 12:00 → ... → 17:00. All fail because `isWorkingDay` = false.                                                                                  |
| 5    | Sat 18:00 → 19:00 → ... → 23:00          | All fail: `isWorkingDay` = false **and** `isWithinWorkingHours` = false.                                                                                   |
| 6    | Sun 00:00 → 01:00 → ... → 23:00          | All fail: `isWorkingDay` = false (Sunday).                                                                                                                 |
| 7    | Mon 00:00 → 01:00 → ... → 08:00          | `isWorkingDay` = true (Monday), but hour < 9 → `isWithinWorkingHours` = false. All fail.                                                                   |
| 8    | Validate Mon 09:00                       | `isWithinBusinessHours` = true. `isWithinWorkingHours`: hour = 9, in [9, 18) → **true**. `isWorkingDay` = true. Combined: **PASS**.                        |

**Output: Monday, 09:00**

> Note: The loop iterates 47 times (Sat 11:00 through Mon 08:00) before finding a valid slot.

---

## Case 5: Thursday at 19:00

**Input:** Thursday, 19:00

### Step-by-step

| Step | Action                                   | Result                                                                                                                                                                                    |
| ---- | ---------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | `BusinessHours.add(Thursday 19:00, 48h)` | Thursday is a business day. 48 calendar hours straight through.                                                                                                                           |
| 2    | Thu 19:00 + 48 hours                     | Thu 19:00 → Fri 19:00 (24h) → **Sat 19:00** (48h).                                                                                                                                        |
| 3    | Validate Sat 19:00                       | `isWithinBusinessHours` = true (24/7). `isWithinWorkingHours`: hour = 19, **not** in [9, 18) → **false**. `isWorkingDay`: Saturday → **false**. Combined: **FAIL** (two conditions fail). |
| 4    | Loop: advance +1h on Saturday            | Sat 20:00 → 21:00 → 22:00 → 23:00. All fail: `isWorkingDay` = false **and** hour >= 18.                                                                                                   |
| 5    | Sun 00:00 → 01:00 → ... → 23:00          | All fail: `isWorkingDay` = false (Sunday).                                                                                                                                                |
| 6    | Mon 00:00 → 01:00 → ... → 08:00          | `isWorkingDay` = true, but hour < 9 → `isWithinWorkingHours` = false. All fail.                                                                                                           |
| 7    | Validate Mon 09:00                       | All three conditions → **true**. Combined: **PASS**.                                                                                                                                      |

**Output: Monday, 09:00**

> Note: The loop iterates 38 times (Sat 20:00 through Mon 08:00) before finding a valid slot.

---

## Case 6: Thursday at 14:00

**Input:** Thursday, 14:00

### Step-by-step

| Step | Action                                   | Result                                                                                                                                                     |
| ---- | ---------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | `BusinessHours.add(Thursday 14:00, 48h)` | Thursday is a business day. 48 calendar hours straight through.                                                                                            |
| 2    | Thu 14:00 + 48 hours                     | Thu 14:00 → Fri 14:00 (24h) → **Sat 14:00** (48h).                                                                                                         |
| 3    | Validate Sat 14:00                       | `isWithinBusinessHours` = true (24/7). `isWithinWorkingHours`: hour = 14, in [9, 18) → **true**. `isWorkingDay`: Saturday → **false**. Combined: **FAIL**. |
| 4    | Loop: advance +1h on Saturday            | Sat 15:00 → 16:00 → 17:00. All fail: `isWorkingDay` = false.                                                                                               |
| 5    | Sat 18:00 → ... → 23:00                  | All fail: `isWorkingDay` = false **and** `isWithinWorkingHours` = false.                                                                                   |
| 6    | Sun 00:00 → ... → 23:00                  | All fail: `isWorkingDay` = false (Sunday).                                                                                                                 |
| 7    | Mon 00:00 → ... → 08:00                  | `isWorkingDay` = true, but hour < 9. All fail.                                                                                                             |
| 8    | Validate Mon 09:00                       | All three conditions → **true**. Combined: **PASS**.                                                                                                       |

**Output: Monday, 09:00**

> Note: The loop iterates 43 times (Sat 15:00 through Mon 08:00) before finding a valid slot.

---

## Case 7: Thursday at 11:00 (Friday is a holiday)

**Input:** Thursday, 11:00 | **Holiday:** Friday

### Step-by-step

| Step | Action                                   | Result                                                                                                                                                                |
| ---- | ---------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | `BusinessHours.add(Thursday 11:00, 48h)` | Thursday is a business day. The engine counts forward, but **skips Friday entirely** (holiday).                                                                       |
| 2    | Thu 11:00 → Fri 00:00 = 13h consumed     | 48 - 13 = **35 hours remaining**. Friday is a holiday — 0 hours counted, skip to Saturday 00:00.                                                                      |
| 3    | Sat 00:00 → Sun 00:00 = 24h consumed     | 35 - 24 = **11 hours remaining**. (Saturday is a business day in 24/7 config.)                                                                                        |
| 4    | Sun 00:00 + 11 hours = **Sun 11:00**     | All 48 business hours consumed.                                                                                                                                       |
| 5    | Validate Sun 11:00                       | `isWithinBusinessHours` = true (24/7, Sunday is not a holiday). `isWithinWorkingHours`: hour = 11 → **true**. `isWorkingDay`: Sunday → **false**. Combined: **FAIL**. |
| 6    | Loop: advance through Sunday             | Sun 12:00 → ... → 17:00 (fail — Sunday). Sun 18:00 → ... → 23:00 (fail — Sunday + hour >= 18).                                                                        |
| 7    | Mon 00:00 → ... → 08:00                  | `isWorkingDay` = true, but hour < 9. All fail.                                                                                                                        |
| 8    | Validate Mon 09:00                       | All three conditions → **true**. Combined: **PASS**.                                                                                                                  |

**Output: Monday, 09:00**

> The holiday pushes the `BusinessHours.add()` result from what would have been Saturday 11:00 into Sunday 11:00 (an extra 24h shift), and then the loop advances to Monday 09:00.

---

## Case 8: Friday at 13:00 (Monday is a holiday)

**Input:** Friday, 13:00 | **Holiday:** Monday

### Step-by-step

| Step | Action                                 | Result                                                                                                                                                                |
| ---- | -------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | `BusinessHours.add(Friday 13:00, 48h)` | Friday is a business day. The engine counts forward through the weekend but **skips Monday entirely** (holiday).                                                      |
| 2    | Fri 13:00 → Sat 00:00 = 11h consumed   | 48 - 11 = **37 hours remaining**.                                                                                                                                     |
| 3    | Sat 00:00 → Sun 00:00 = 24h consumed   | 37 - 24 = **13 hours remaining**.                                                                                                                                     |
| 4    | Sun 00:00 + 13 hours = **Sun 13:00**   | All 48 business hours consumed. Monday (holiday) was never reached — it wasn't needed.                                                                                |
| 5    | Validate Sun 13:00                     | `isWithinBusinessHours` = true (24/7, Sunday is not a holiday). `isWithinWorkingHours`: hour = 13 → **true**. `isWorkingDay`: Sunday → **false**. Combined: **FAIL**. |
| 6    | Loop: advance through Sunday           | Sun 14:00 → ... → 17:00 (fail — Sunday). Sun 18:00 → ... → 23:00 (fail — Sunday + hour >= 18).                                                                        |
| 7    | Mon 00:00 → ... → 23:00                | `isWorkingDay` = true (Monday), but `isWithinBusinessHours` = **false** (Monday is a holiday!). All 24 hours fail.                                                    |
| 8    | Tue 00:00 → ... → 08:00                | `isWithinBusinessHours` = true, `isWorkingDay` = true, but hour < 9. All fail.                                                                                        |
| 9    | Validate Tue 09:00                     | All three conditions → **true**. Combined: **PASS**.                                                                                                                  |

**Output: Tuesday, 09:00**

> This case demonstrates the **holiday guard** in action. Even though Monday passes the `isWorkingDay` check (it's not Sat/Sun), `BusinessHours.isWithin()` returns **false** for the entire holiday, causing the loop to skip Monday entirely and land on Tuesday 09:00.

---

## Summary Table

| Case | Input           | Holidays | `BusinessHours.add()` Result | Adjustment | Final Output      |
| ---- | --------------- | -------- | ---------------------------- | ---------- | ----------------- |
| 1    | Saturday 13:00  | None     | Monday 13:00                 | None       | **Monday 13:00**  |
| 2    | Friday 11:00    | None     | Sunday 11:00                 | +22 hours  | **Monday 09:00**  |
| 3    | Wednesday 14:00 | None     | Friday 14:00                 | None       | **Friday 14:00**  |
| 4    | Thursday 10:00  | None     | Saturday 10:00               | +47 hours  | **Monday 09:00**  |
| 5    | Thursday 19:00  | None     | Saturday 19:00               | +38 hours  | **Monday 09:00**  |
| 6    | Thursday 14:00  | None     | Saturday 14:00               | +43 hours  | **Monday 09:00**  |
| 7    | Thursday 11:00  | Friday   | Sunday 11:00                 | +22 hours  | **Monday 09:00**  |
| 8    | Friday 13:00    | Monday   | Sunday 13:00                 | +44 hours  | **Tuesday 09:00** |

---

## Validation Logic (`isWithinBusinessAndWorkingHours`)

All three conditions must be **true** for the datetime to be accepted:

| #   | Condition               | What it checks                                                                 | Why it matters with 24/7 BH                                                                                                                         |
| --- | ----------------------- | ------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | `isWithinBusinessHours` | `BusinessHours.isWithin(bhId, dt)` — datetime is inside configured BH schedule | Always true for non-holiday moments in a 24/7 config. Becomes the **holiday guard**: returns false during configured holidays (see Case 8).         |
| 2   | `isWithinWorkingHours`  | Hour (in BH timezone) is in [9, 18)                                            | Constrains results to the custom 9am-6pm working window, since BH itself allows all 24 hours.                                                       |
| 3   | `isWorkingDay`          | Day of week (in BH timezone) is not Saturday/Sunday                            | **Essential** in a 24/7 config — without this, weekend datetimes would pass validation because `BusinessHours.isWithin()` returns true on weekends. |

**Key takeaway:** With 24/7 business hours, `BusinessHours.add()` simply adds 48 calendar hours (skipping only holidays). The heavy lifting shifts to the while-loop: conditions 2 and 3 enforce the Mon-Fri 9-18 window that the Business Hours config itself does not restrict. The `isWorkingDay` check is the **primary weekend filter**, while `isWithinBusinessHours` serves as the **holiday guard** (Case 8 demonstrates this clearly).
