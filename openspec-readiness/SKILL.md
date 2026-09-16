---
name: openspec-readiness
description: >
  Iteratively review and improve an OpenSpec change as a senior system
  architect until it reaches a stable implementation-ready state with no
  remaining BLOCKER, REQUIRED, or RECOMMENDED changes. Does not implement
  application code.
---

# OpenSpec Implementation Readiness

Improve one OpenSpec change until an engineer can implement it without
inventing requirements or resolving avoidable architectural ambiguity.
Modify only artifacts belonging to that change; never application code,
tests, configuration, or unrelated files.

## Start

Example: `Use $openspec-readiness for openspec/changes/add-export.`

Resolve the explicit target name/path or an unambiguous conversational target.
Otherwise inspect available changes: select the sole active change, or ask
which change when multiple candidates exist. If none exists or the explicit
target is missing, report BLOCKED; do not create or substitute a change.

Read [Architect Protocol](references/architect.md) and
[Review Criteria](references/review-criteria.md) before reviewing. Read
[Critic Contract](references/critic.md) before creating a critic or applying
the fallback. Review Criteria owns the severity definitions.

Use the user's current model and reasoning configuration. Inherit these for
critics; override only at the user's explicit request.

## State and limits

Track review cycles, critic passes, consecutive clean passes, changed artifacts,
validation status, and outstanding findings. Start counters at zero.
Default limit: six review cycles per invocation, unless the user
specifies otherwise. Reaching the limit never implies readiness.
Before starting any new cycle, enforce this limit and stop NOT CONVERGED if
exhausted, including when an earlier step directs a restart.
Every artifact edit resets consecutive clean passes to zero.

## Review loop

1. **Architect review.** Increment review cycles. Reread current artifacts and
   inspect repository context using the Architect Protocol. Search for new
   issues, not just previous corrections.
2. **Resolve findings.** Verify findings against evidence. Correct all valid
   REQUIRED and RECOMMENDED findings with focused artifact edits. Stop BLOCKED
   for a genuine blocker that available context cannot resolve. Choose
   reasonable technical approaches yourself when context supports them.
3. **Validate.** Discover the applicable command from repository instructions
   or the installed OpenSpec CLI's help; validate the target.
   - Success: record PASSED.
   - Tooling absent: record NOT AVAILABLE; continue with that limitation.
   - Artifact errors: correct in-scope artifacts and retry, at most three
     validation attempts per cycle. If still invalid, stop NOT CONVERGED.
     This budget includes post-critic validation. If further edits need
     validation after the budget is spent, stop NOT CONVERGED and report
     the latest artifacts as unvalidated.
   - Tool crash, permissions, environment, or external failure: inspect the
     cause and retry once only if safe and useful. Do not rewrite artifacts
     to repair infrastructure. If unresolved, stop BLOCKED with validation
     ERROR and the dependency/access needed. Never relabel a failed invocation
     as absent tooling. Validation errors exclusively outside the target stop
     BLOCKED with validation FAILED and the external prerequisite identified;
     do not edit unrelated files.
4. **Independent critic.** Create a new context for every critic pass, with
   read/search tools only when restrictions are supported. Explicitly disable
   inherited conversation history (e.g. `fork_turns="none"` where supported).
   Supply only the target, full Critic Contract and Review Criteria, instructions
   to read current artifacts, and access to relevant repository context.
   Do not supply prior reasoning, findings, verdicts, corrections, or an expected
   outcome. Increment critic passes. When using `multi_agent_v1__wait_agent`, set
   `timeout_ms` to `3600000` rather than relying on its 30-second default. A
   `timed_out: true` result only means the wait ended; wait again on the same
   still-running critic instead of treating it as failed or spawning a duplicate.
   Use the fallback below only when the critic reaches a final failure state or
   is unavailable.
5. **Adjudicate.** Independently verify every critic finding for correctness,
   applicability, severity, and value. Record concise evidence for rejections.
   A valid human/external blocker stops the run. Accepted findings needing
   edits reset clean passes; revise, validate under step 3, then start a new
   complete cycle.
   If all material findings are rejected but the verdict is not CLEAN, reset
   clean passes and begin another cycle without edits. Rejection never converts
   a verdict into CLEAN. Missing, malformed, or failed critic output likewise
   resets clean passes; retry in the next cycle.
6. **Count CLEAN.** Only `VERDICT: CLEAN` with independent architect agreement
   increments clean passes. Any other result resets the count. If the architect
   finds a material issue despite CLEAN, handle it under step 2 and begin another
   cycle. After the first CLEAN, run another full architect and fresh critic pass.
7. **Finish or repeat.** After two consecutive agreed CLEAN verdicts, verify the
   readiness gate. Otherwise repeat unless the cycle limit is reached or reviews
   are oscillating. Stop NOT CONVERGED for repeated disagreement, oscillation,
   or exhausted cycles without a genuine blocker. Use BLOCKED only for a concrete
   missing decision, fact, access, or external dependency. Preserve outstanding
   findings; never force agreement.

Treat the same rejected material finding in two consecutive cycles, or a
correction reversed and then proposed again, as repeated disagreement or
oscillation respectively.

Track every artifact edit, including validation and critic-driven corrections.
Use a content snapshot or hashes to confirm the final two CLEAN reviews cover
unchanged target artifacts, including added/deleted files. Relevant repository
changes that invalidate review evidence also reset clean passes.

## Critic fallback

If isolated, history-free contexts are unavailable, reread current artifacts and
relevant repository context, then apply the Critic Contract as a separate phase
without relying on prior conclusions. The same counters, verdicts, limits, and
gate apply. Disclose reduced independence; a history-inheriting child does not
count as an isolated critic.

## Readiness gate

Declare IMPLEMENTATION READY only when:

- No valid BLOCKER, REQUIRED, or RECOMMENDED findings remain.
- The implementation plan is complete and the architect agrees with two
  consecutive CLEAN critic verdicts on unchanged artifacts.
- Validation passed, or tooling was absent and that limitation is disclosed.
- Critics used fresh history-free contexts where supported; otherwise disclose
  the fallback.
- This workflow modified only the target change's artifacts.

OPTIONAL findings do not prevent readiness.

## Final report

Keep concise. Include:

- Outcome: IMPLEMENTATION READY, BLOCKED, or NOT CONVERGED.
- Target; review cycles; critic passes; consecutive CLEAN passes.
- Artifacts changed and material architectural improvements, if any.
- Validation: PASSED, NOT AVAILABLE, FAILED, ERROR, or NOT RUN if stopped early;
  include the command and any failure or limitation.
- Isolated critics: yes/no; disclose fallback limitations.
- Application code modified by this workflow: no.

For BLOCKED, give the minimum missing decision/dependency and why it matters.
For NOT CONVERGED, give unresolved findings/disagreement, relevant rejection
evidence, and the stopping reason. Neither outcome implies readiness.
Omit the full review history unless requested.
