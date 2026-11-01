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
Read [Terse Mode](references/terse-mode.md); apply it to reasoning, critic
prompts and reports, and status notes. Spec artifacts stay normal prose.

## Critic models

Use the user's current model and reasoning configuration for the architect.
For critics, choose the cheapest adequate model tier and effort, unless the
user specifies otherwise. Tiers: large (Claude Opus, OpenAI Sol), mid (Sonnet,
Terra), small (Haiku, Luna).

- **Full pass:** one tier below the architect at high effort, never below mid.
  Use the architect's tier for changes touching security, authorization, data
  integrity, migrations, or public contracts, or after a critic pass that was
  malformed or whose findings adjudication rejected as wrong.
- **Delta pass:** small tier at high effort suffices.

Use the harness's family alias (for example `sonnet` in Claude Code), never a
versioned model ID, so the latest release is always used. If the harness offers
no model or effort selection, or no model of the needed tier, inherit the
caller's. A cheaper critic never relaxes verdicts or the readiness gate.

Every time a critic is spawned, state in a status line to the user its pass
type, model family, exact version, and reasoning effort, for example
`Spawning critic (full pass): Claude Sonnet 5.5 (claude-sonnet-5-5), effort high`.
Take the version from what the harness reports or resolves for the alias; if it
cannot be determined, say `latest (unresolved)` rather than guessing. Record
the same for the final report.

## State and limits

Track review cycles, critic passes (full/delta), changed artifacts, validation
status, outstanding findings, and whether an agreed CLEAN pass covers the
current artifact snapshot (including added/deleted files). Every artifact edit,
and every repository change that invalidates review evidence, clears that
coverage unless a delta pass restores it.

Default limit: six review cycles per invocation, unless the user specifies
otherwise. Before starting any new cycle, enforce this limit and stop NOT
CONVERGED if exhausted. Reaching the limit never implies readiness.

After the first architect review, write a **context file** outside the
repository (for example in a temp or scratch directory) so critics need not
rediscover it: target path, artifact list, relevant implementation and spec
paths, conventions, and the validation command. Facts only — never findings,
opinions, or expected outcomes.

**Trivial edit:** a localized edit within one artifact that changes no
requirement, scope, interface, ownership, data model, or design decision (for
example clarified wording, a fixed reference, a sharpened task, or a typo).
When unsure, it is not trivial.

## Review loop

1. **Architect review.** Increment review cycles. First cycle: read all
   artifacts and repository context per the Architect Protocol. Later cycles:
   reread edits since your last review, the artifact content they interact
   with, and the latest critic findings; full critic passes cover the whole change.
2. **Resolve findings.** Verify findings against evidence. Correct all valid
   REQUIRED and RECOMMENDED findings with focused artifact edits. Stop BLOCKED
   for a genuine blocker that available context cannot resolve. Choose
   reasonable technical approaches yourself when context supports them.
3. **Validate.** Discover the applicable command from repository instructions
   or the installed OpenSpec CLI's help; validate the target.
   - Success: record PASSED.
   - Tooling absent: record NOT AVAILABLE; continue with that limitation.
   - Artifact errors: correct in-scope artifacts and retry, at most three
     validation attempts per cycle, including post-critic validation. If still
     invalid, or further edits need validation after the budget is spent, stop
     NOT CONVERGED and report the latest artifacts as unvalidated.
   - Tool crash, permissions, environment, or external failure: inspect the
     cause and retry once only if safe and useful. Do not rewrite artifacts
     to repair infrastructure. If unresolved, stop BLOCKED with validation
     ERROR and the dependency/access needed. Never relabel a failed invocation
     as absent tooling. Validation errors exclusively outside the target stop
     BLOCKED with validation FAILED and the external prerequisite identified;
     do not edit unrelated files.
4. **Independent critic.** Choose the pass type:
   - **Delta pass** when the previous full pass returned `CHANGES_REQUIRED`,
     none of its material findings was rejected, and every edit since that full
     pass is trivial. Scope: those edits.
   - **Full pass** otherwise.

   Create a new history-free context per pass (e.g. `fork_turns="none"`), with
   read/search tools only where supported. Supply only: pass type, target path,
   absolute paths to the context file, `references/critic.md`,
   `references/review-criteria.md`, and `references/terse-mode.md`, and for a
   delta pass the edits since the last full pass. Never paste file contents the
   critic can read itself, and never supply prior reasoning, findings, verdicts,
   corrections, or an expected outcome. Increment critic passes. If a wait times
   out (for `multi_agent_v1__wait_agent`, set `timeout_ms` to `3600000`), wait
   again on the same critic instead of spawning a duplicate. Use the fallback
   below only when the critic reaches a final failure state or is unavailable.
5. **Adjudicate.** Independently verify every finding for correctness,
   applicability, severity, and value; record concise evidence for rejections.
   A valid human/external blocker stops the run. Revise accepted findings,
   validate under step 3, then start a new cycle. A non-CLEAN verdict whose
   material findings are all rejected gives no coverage; begin another cycle
   without edits. Rejection never converts a verdict into CLEAN. Missing,
   malformed, failed, or `INCOMPLETE` output gives no coverage; retry next cycle.
6. **Finish or repeat.** Coverage requires `VERDICT: CLEAN` with independent
   architect agreement; if the architect finds a material issue despite CLEAN,
   handle it under step 2. Once an agreed CLEAN pass (full, or delta per step 4)
   covers the final snapshot, verify the readiness gate. Do not re-run an
   identical pass on unchanged artifacts. Stop NOT CONVERGED when the same
   rejected material finding recurs in two consecutive cycles, a correction is
   reversed and then proposed again, or cycles are exhausted without a genuine
   blocker. Use BLOCKED only for a concrete missing decision, fact, access, or
   external dependency. Preserve outstanding findings; never force agreement.

## Critic fallback

If isolated, history-free contexts are unavailable, reread current artifacts and
relevant repository context, then apply the Critic Contract as a separate phase
without relying on prior conclusions. The same counters, verdicts, limits, and
gate apply. Disclose reduced independence; a history-inheriting child does not
count as an isolated critic.

## Readiness gate

Declare IMPLEMENTATION READY only when:

- No valid BLOCKER, REQUIRED, or RECOMMENDED findings remain.
- The implementation plan is complete and an agreed CLEAN pass covers the
  final artifacts.
- Validation passed, or tooling was absent and that limitation is disclosed.
- Critics used fresh history-free contexts where supported; otherwise disclose
  the fallback.
- This workflow modified only the target change's artifacts.

OPTIONAL findings do not prevent readiness.

## Final report

Keep concise; use caveman level for status lines and normal prose for anything
the user must decide or act on. Include:

- Outcome: IMPLEMENTATION READY, BLOCKED, or NOT CONVERGED.
- Target; review cycles; critic passes (full/delta); whether final coverage came
  from a full or delta pass.
- Artifacts changed and material architectural improvements, if any.
- Validation: PASSED, NOT AVAILABLE, FAILED, ERROR, or NOT RUN if stopped early;
  include the command and any failure or limitation.
- Isolated critics: yes/no; disclose fallback limitations. Critic model, version, and effort per pass.
- Application code modified by this workflow: no.

For BLOCKED, give the minimum missing decision/dependency and why it matters.
For NOT CONVERGED, give unresolved findings/disagreement, relevant rejection
evidence, and the stopping reason. Neither outcome implies readiness.
Omit the full review history unless requested.
