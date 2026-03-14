# Out-of-Office Range — Calculation Examples

## Core Idea

A full week has **7 × 24 = 168 hour-slots**, numbered from `0` (Monday 00:00) to `167` (Sunday 23:00).

Any day + hour combination is collapsed into a single integer called a **week position**:

```
weekPosition = (dayNumber - 1) * 24 + hour

dayNumber: Monday = 1, Tuesday = 2, ... Sunday = 7
```

Examples:

| Day & Hour     | Formula         | Week Position |
| -------------- | --------------- | ------------- |
| Monday 00:00   | (1-1) × 24 + 0  | 0             |
| Monday 09:00   | (1-1) × 24 + 9  | 9             |
| Friday 17:00   | (5-1) × 24 + 17 | 113           |
| Saturday 12:00 | (6-1) × 24 + 12 | 132           |
| Sunday 23:00   | (7-1) × 24 + 23 | 167           |

The current datetime and both OOO boundaries are all converted to this scale, then compared as plain integers.

---

## Case 1 — Normal Window (no week-boundary crossing)

**Config:** OOO Saturday 09:00 → Sunday 20:00

```
Mon      Tue      Wed      Thu      Fri      Sat      Sun
|        |        |        |        |        |        |        |
0       24       48       72       96      120      144      168
                                             [=======129→164==]
                                             Sat 09  →  Sun 20
```

`startPos (129) < endPos (164)` → the window sits entirely within the line.

**Check:** `currentPos >= 129 AND currentPos < 164`

| Moment         | Position | In OOO?                  |
| -------------- | -------- | ------------------------ |
| Saturday 12:00 | 132      | ✅ yes                   |
| Sunday 19:00   | 163      | ✅ yes                   |
| Sunday 20:00   | 164      | ❌ no — end is exclusive |
| Friday 15:00   | 111      | ❌ no                    |

---

## Case 2 — Wrap-Around Window (crosses the week boundary)

**Config:** OOO Friday 17:00 → Monday 09:00

```
Mon      Tue      Wed      Thu      Fri      Sat      Sun      | Mon
|        |        |        |        |        |        |        | |
0       24       48       72       96      120      144      168| 0
[==9]                                        [=======113→167===|→9]
Mon 09 ←                                     Fri 17  →  (wraps)
```

`startPos (113) > endPos (9)` → the window is **split into two chunks** by the edge of the line:

- **Chunk A:** 113 → 167 (Friday evening through Sunday night)
- **Chunk B:** 0 → 8 (Monday early morning)

**Check:** `currentPos >= 113 OR currentPos < 9`

The condition flips from `AND` to `OR` because the current time only needs to land in _either_ chunk — not both at once.

| Moment          | Position | In OOO? | Reason                        |
| --------------- | -------- | ------- | ----------------------------- |
| Friday 17:00    | 113      | ✅ yes  | start is inclusive            |
| Saturday 12:00  | 132      | ✅ yes  | Chunk A                       |
| Sunday 23:00    | 167      | ✅ yes  | Chunk A                       |
| Monday 08:00    | 8        | ✅ yes  | Chunk B                       |
| Monday 09:00    | 9        | ❌ no   | end is exclusive              |
| Friday 16:00    | 112      | ❌ no   | one hour before start         |
| Wednesday 12:00 | 60       | ❌ no   | mid-week, outside both chunks |

---

## Case 3 — Same-Day Window

**Config:** OOO Sunday 08:00 → Sunday 20:00

Both boundaries share the same day, so `startPos (152) < endPos (164)` — this falls naturally into the **normal window** case.

**Check:** `currentPos >= 152 AND currentPos < 164`

---

## Case 4 — Zero-Length Window

**Config:** start == end (e.g. Monday 09:00 → Monday 09:00)

`startPos == endPos` → treated as **never OOO**. A window with no duration is considered misconfigured.

---

## Decision Tree

```
startPos < endPos  →  Normal window    →  current >= startPos AND current < endPos
startPos > endPos  →  Wrap-around      →  current >= startPos OR  current < endPos
startPos == endPos →  Zero-length      →  always false
```
