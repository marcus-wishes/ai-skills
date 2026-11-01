---
name: iterative-code-review
description: Review uncommitted changes or a specified Git commit range as a senior engineer, architect, and QA engineer. Implement clearly correct, maintainable fixes and repeat validation with an independent critic until no finding above low severity remains.
license: MIT
metadata:
    category: code-quality
    workflow: review-fix-verify
---

# Iterative Code Review

Perform a rigorous, repository-aware code review and remediation cycle.
Requires a Git repository; use the critic fallback when subagents are unavailable.

## Role

Act simultaneously as a senior software engineer in the project's languages and
ecosystem, a senior system architect (boundaries, dependencies, contracts,
evolution, reliability, security, operations), and a senior QA engineer
(correctness, regressions, edge cases, coverage, determinism, failure modes).
Treat overengineering as a first-class review target, in the original changes
and in your own fixes.

Read [Review Standards](references/review-standards.md) (safety, review areas,
severity, fix policy) and [Implementor Protocol](references/implementor.md)
before reviewing. The main agent owns implementation decisions, validation, and
adjudication; it may delegate fully specified edits per the Implementor
Protocol. The critic independently reviews and returns findings; it never edits.
Read [Terse Mode](references/terse-mode.md); apply it to reasoning, subagent
prompts and reports, and status notes, never to code, docs, or commits.

## Subagent models

The main agent keeps the user's model and reasoning settings. For each subagent
it chooses the cheapest model tier and reasoning effort adequate to the task,
unless the user specifies otherwise. Tiers are provider-neutral; map them to
the harness's model families:

| Tier | Claude | OpenAI |
| --- | --- | --- |
| Large | Opus | Sol |
| Mid | Sonnet | Terra |
| Small | Haiku | Luna |

Use the harness's family alias (for example `sonnet` in Claude Code), never a
versioned model ID, so the latest release is always used. If the harness offers
no model or effort selection, or no model of the needed tier, inherit the caller's.

- **Full critic pass:** default one tier below the main agent at high effort,
  never below the mid tier. Use the main agent's tier when the scope touches
  security, authorization, concurrency, data integrity, migrations, or public
  contracts, or after a critic pass that was malformed or whose findings
  adjudication rejected as wrong.
- **Delta critic pass:** small tier at high effort suffices.
- **Delegated implementor:** see the Implementor Protocol.

A cheaper critic never relaxes verdicts or the completion gate.

Every time a subagent is spawned, state in a status line to the user its role,
model family, exact version, and reasoning effort, for example
`Spawning critic (full pass): Claude Sonnet 5.5 (claude-sonnet-5-5), effort high`.
Take the version from what the harness reports or resolves for the alias; if it
cannot be determined, say `latest (unresolved)` rather than guessing. Record
the same for the final report.

## Invocation and scope

Determine the review target from the user's request:

- `uncommitted`, `working tree`, or no explicit scope: all uncommitted tracked and untracked changes relevant to the task
- `last N commits`: `HEAD~N..HEAD`
- A single commit, such as `abc123`: the changes introduced by that commit
- A Git range, such as `main..HEAD` or `v1.4.0..HEAD`: that exact range
- A PR branch comparison: the user-provided base and head revisions

If scope is absent and the intent is unclear, ask this single question before changing anything:

> Should I review the current uncommitted working tree or a specific commit range?

Resolve revisions to immutable commit IDs. Record initial working-tree changes
so unrelated pre-existing edits are not mistaken for session fixes. If the
selected head is not checked out, use an isolated checkout for remediation;
do not apply historical fixes to an unrelated working tree.
For a single commit, compare with its parent (the empty tree for a root commit).
For a merge commit, use its first parent unless the user specifies otherwise;
state that choice in the scope report.

## Gather repository context

Inspect only what is needed to understand the selected changes:

1. Applicable guidance: `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, README files, architecture docs, nested instruction files.
2. Primary language, build system, formatter, linter, type checker, test and CI commands.
3. The selected diff, affected files, and directly relevant call sites, tests, interfaces, schemas, configuration, and docs.
4. Language-server diagnostics where available.

Then write a **context file** outside the repository (for example in a temp or
scratch directory) so critics need not rediscover it: repository path, resolved
scope/base/head, initial working-tree baseline, guidance file paths, validation
commands, and relevant files and callers. Facts only — never findings,
opinions, or expected outcomes. Update it when scope facts change.

Do not claim to have inspected files, executed commands, or verified behavior
that you did not actually inspect, execute, or verify.

## Review-fix loop

Track state (`REVIEWING`, `FIXING`, `VALIDATING`, `CRITIQUING`, `PAUSED`,
`COMPLETE`, or `NOT CONVERGED`), cycles, critic passes (full/delta), outstanding
findings, validation results, and whether an agreed CLEAN pass covers the
current content snapshot. Every edit or relevant context change clears that
coverage unless a delta pass restores it. Keep only concise evidence and
decisions in the main context; do not retain full critic transcripts.

Default limit: six cycles unless the user specifies otherwise. Check the limit
before each new cycle. Resuming PAUSED continues the active cycle with its
existing validation-attempt count. Exhaustion when a new cycle is needed, or
repeated disagreement, stops as `NOT CONVERGED`, never `COMPLETE`. A user
decision does not reset counters; if exhausted, report the need for an extended
budget to continue.

**Trivial fix:** a localized edit in one file that changes no interface,
contract, persisted data, or control flow beyond the finding's direct site, and
does not touch security, authorization, concurrency, or data-integrity logic
(for example a missing null check, wrong constant, typo, assertion fix, or doc
correction). When unsure, it is not trivial.

1. **Review.** Increment cycles. First cycle: inspect the full selected scope
   and relevant context. Later cycles: inspect only edits since your last
   review, their direct callers and tests, and the latest critic findings; full
   critic passes cover the whole scope. Capture a content snapshot before review.
2. **Fix.** Apply all independent, unambiguous findings above Low using the
   Implementor Protocol. Handle unresolved decisions through its PAUSED protocol.
3. **Validate.** Run relevant checks and inspect the resulting changes. Disclose
   unavailable checks and unrelated failures; never describe failed or
   unexecuted checks as passed. Reuse successful results when content and
   environment are unchanged. Validation failures caused by selected changes
   block completion. At most three validation rounds per cycle, including
   critic-driven fixes; if more are needed, begin the next budgeted cycle.
4. **Critique.** Read [Critic Contract](references/critic.md). Choose the pass type:
   - **Delta pass** when the previous full pass returned `CHANGES_REQUIRED`,
     none of its material findings was rejected, and every edit since that full
     pass is trivial. Scope: those edits plus direct callers and tests.
   - **Full pass** otherwise.

   Create one fresh, history-free subagent (for example `fork_turns="none"`)
   with read-only tools where supported. Supply only: pass type, absolute paths
   to the context file, `references/review-standards.md`, `references/critic.md`,
   and `references/terse-mode.md`, the session diff or a snapshot path (delta
   pass: only edits since the last full pass), and applicable user constraints
   and decisions. Never supply prior reasoning, findings, verdicts, or expected
   outcomes. Increment critic passes.

   Exactly one critic at a time; run no other critic, delegated implementor,
   validation, or app/server/e2e command while it is active. If a wait times out
   (for `multi_agent_v1__wait_agent`, set `timeout_ms` to `3600000`), wait again
   on the same critic; only a final failure state makes its output unavailable,
   and that pass is retried next cycle, never replaced by a parallel spawn.
   Changes to the reviewed snapshot during the pass invalidate its verdict.
5. **Adjudicate.** Independently verify each finding against repository evidence
   and the severity definitions. Implement accepted unambiguous fixes, validate
   them within the cycle budget, and continue. Route findings needing a user
   decision through the Implementor Protocol. Record concise evidence for
   rejections; rejection never turns a non-CLEAN verdict into CLEAN. Missing,
   malformed, or failed output gives no coverage; retry next cycle.
6. **Finish or repeat.** Enter `COMPLETE` only when an agreed CLEAN pass (full,
   or delta per step 4) covers the final snapshot, including added, deleted, and
   untracked files; no Critical/High/Medium findings or pending decisions
   remain; and all fixes are validated as far as tooling permits. Do not re-run
   an identical pass on unchanged content. Stop as `NOT CONVERGED` when the same
   rejected material finding recurs in two consecutive cycles or a correction is
   reversed and then proposed again; report the dispute.

If isolated contexts are unavailable, perform the Critic Contract as a separate
read-only phase and disclose reduced independence. A history-inheriting child
does not count as isolated. Apply the same verdicts, counters, and completion gate.

Do not downgrade, defer, or omit findings to reach completion. If validation
cannot run, report the exact command, reason, and remaining uncertainty.

## Final response

Lead with outcome (`COMPLETE`, `PAUSED`, or `NOT CONVERGED`), cycle and critic
counts (full/delta), whether critics were isolated or used the fallback, whether
the final coverage came from a full or delta pass, and the model, version, and effort used
for critics and delegated implementors. Use caveman level (see Terse Mode) for
these status lines, Scope, and Validation; write Remaining findings and any
pending decision in normal prose.

### Scope

- Git scope reviewed, files materially inspected, guidance and validation commands used

### Changes made

- Each automatic fix, its reason, and affected files; tests or docs added/updated

### Validation

- Commands run and results; checks not run, with the reason

### Remaining findings

- State `No findings above low severity remain` only when supported; this alone
  does not imply COMPLETE if the critic gate remains unmet
- Otherwise list unresolved findings, severity, pending decisions or
  disagreement, and the stopping reason

### Low-severity notes

- Only actionable low-severity observations; do not implement them unless requested
