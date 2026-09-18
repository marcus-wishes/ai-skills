---
name: state-confidence
description: >
  Ends OpenSpec proposal and implementation work with an explicit Solution
  confidence percentage. Use on every OpenSpec proposal, change/spec authoring
  or review that produces or materially revises an implementation-ready
  proposal, and every implementation task such as coding, fixing, refactoring,
  configuration changes, or applying a spec. Mandatory after those tasks
  complete or when reporting their outcome.
---

# State Confidence

After finishing any **OpenSpec proposal** or **implementation** task, end the
reply with one line stating solution confidence as a percentage.

Emit the line only when the task is complete or you are reporting the outcome
for this turn—not mid-task before the deliverable is done.

## When this is mandatory

### 1. OpenSpec proposal work

Drafting, revising, finalizing, or materially reviewing an OpenSpec proposal,
change, or specification intended to enable implementation.

Require the confidence line when the work:

* creates a new implementation-oriented proposal or specification
* materially changes an existing proposal or specification
* reviews a proposal and produces concrete revisions, requirements, decisions,
  or implementation-ready guidance

Comment-only review with no material revision does **not** require it.

### 2. Implementation work

Writing, changing, or delivering code or equivalent executable/operational work.

Examples: application code, bug fixes, refactors, tests tied to the change,
configuration, SQL/scripts/IaC/build/CI, applying an OpenSpec, small edits
(renames, CSS, config).

Pure code review with no delivered change does **not** require it.

Do not skip for qualifying tasks, regardless of size. Partial or blocked
delivery still requires the line—score confidence in what was actually
delivered (or in the proposal artifacts as left), not in an imagined complete
solution.

## Output format

Own **final** line, after all other reply content:

```text
Solution confidence: <N>%
```

`<N>` is an integer from `0` to `100`. Exact prefix `Solution confidence: `.
No prose, qualifiers, or punctuation after the percentage. Exactly one such line.

Examples:

```text
Solution confidence: 97%
```

```text
Solution confidence: 43%
```

## What the score means

Confidence in the **delivered solution or artifact**, not in the explanation.

* **OpenSpec:** implementer can succeed from the artifacts without inventing
  critical requirements, behavior, constraints, or decisions.
* **Implementation:** delivered change fully and correctly satisfies the task.

Lower for ambiguity, missing context, untested paths, incomplete verification,
unresolved edge cases, contradictions, or speculation. Do not inflate merely
because the task is “done.”

## Calibration

| Range | Meaning |
|-------|---------|
| 95–100% | Complete and strongly verified; important paths checked; no material gaps. **100%** only if essentially no meaningful unresolved uncertainty. Passing tests alone ≠ `100%`. |
| 80–94% | Correct and substantially complete; limited leftover verification, edge cases, env behavior, or assumptions (e.g. prod-only integration unverified). |
| 60–79% | Directionally right; meaningful uncertainty (could not execute, assumption-heavy, partial system visibility, significant edges unchecked). |
| 30–59% | Substantial gaps, missing context, weak coverage, or speculation; useful but needs validation. |
| 0–29% | Highly uncertain, materially incomplete, major known problems, or mostly speculative. |
