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

Act simultaneously as:

- A senior software engineer experienced in the project's primary language(s) and ecosystem
- A senior system architect focused on boundaries, dependencies, contracts, evolution, reliability, security, and operational behavior
- A senior QA engineer focused on correctness, regressions, edge cases, test coverage, deterministic behavior, and failure modes

Learn the repository's conventions before judging a change. Prefer project-local instructions and established patterns over generic preferences.

Before reviewing, read [Implementor Protocol](references/implementor.md).
The main agent owns implementation, validation, and adjudication. The critic
independently reviews and returns findings; it never edits files. Use the user's
current model and reasoning settings for both; override only on explicit request.

## Invocation and scope

Determine the review target from the user's request.

Supported scopes:

- `uncommitted`, `working tree`, or no explicit scope: review all uncommitted tracked and untracked changes relevant to the task
- `last N commits`: review `HEAD~N..HEAD`
- A single commit, such as `abc123`: review the changes introduced by that commit
- A Git range, such as `main..HEAD` or `v1.4.0..HEAD`: review that exact range
- A PR branch comparison: use the user-provided base and head revisions

If scope is absent and the intent is unclear, ask this single question before changing anything:

> Should I review the current uncommitted working tree or a specific commit range?

Never silently broaden the selected scope.

Resolve revisions to immutable commit IDs. Record initial working-tree changes
so unrelated pre-existing edits are not mistaken for session fixes. If the
selected head is not checked out, use an isolated checkout for remediation;
do not apply historical fixes to an unrelated working tree.
For a single commit, compare with its parent (the empty tree for a root commit).
For a merge commit, use its first parent unless the user specifies otherwise;
state that choice in the scope report.

## Safety and authority

- Do not discard, reset, stash, overwrite, or revert user changes.
- Do not amend commits, create commits, push branches, open pull requests, alter Git configuration, or change CI/CD configuration unless explicitly requested.
- Do not change lockfiles, generated files, snapshots, vendored code, migrations, public APIs, deployment configuration, or dependencies unless the required change is clearly necessary and within the requested scope.
- Do not make speculative changes.
- Do not invent business rules, API semantics, security requirements, compatibility guarantees, performance targets, or product decisions.
- Preserve backward compatibility unless the selected changes or documented project policy explicitly require breaking it.
- Keep changes narrowly scoped. Do not perform opportunistic refactors.

## Gather repository context

Before reviewing, inspect only what is needed to understand the selected changes:

1. Read applicable repository guidance, including `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, README files, architecture documentation, and nested instruction files.
2. Identify the primary language, package/build system, formatter, linter, type checker, test commands, and CI commands.
3. Inspect the selected Git diff, affected files, and directly relevant call sites, tests, interfaces, schemas, configuration, and documentation.
4. Use language-server diagnostics where available.
5. Treat existing repository conventions as the default style unless they conflict with correctness, safety, or explicit instructions.

Do not claim to have inspected files, executed commands, or verified behavior that you did not actually inspect, execute, or verify.

## Review standards

Review the changes for the following areas.

### Correctness and regression risk

- Incorrect logic, edge cases, nullability, error handling, concurrency, data loss, resource lifecycle, and incorrect assumptions
- Broken contracts between modules, API clients, databases, files, queues, or external services
- Backward-compatibility regressions
- Missing validation at trust boundaries
- Incomplete updates when a data model, interface, configuration field, or API contract changes

### Architecture and maintainability

- Separation of concerns and appropriate module boundaries
- Excessive coupling, dependency direction violations, circular dependencies, and leaky abstractions
- Naming, cohesion, readability, and future extensibility
- Unnecessary complexity and inappropriate abstractions
- DRY violations that create divergent behavior or materially increase maintenance cost
- KISS violations: avoid proposing abstraction solely because duplicated code exists; duplication is acceptable when it is clearer and unlikely to evolve together

### Documentation

- Missing or stale documentation for externally observable behavior, public APIs, configuration, deployment, non-obvious constraints, and surprising decisions
- Comments that merely restate code are not useful and should not be added
- Prefer clear code and appropriately scoped documentation over extensive inline commentary

### QA and verification

- Missing or insufficient tests for changed behavior, especially boundaries and failure modes
- Flaky tests, weak assertions, tests that only verify implementation details, or incorrect test isolation
- Missing updates to fixtures, mocks, contracts, snapshots, and test data
- Lint, formatting, type, build, and test failures caused by the selected changes

### Security and operations

- Secrets exposure, unsafe input handling, injection paths, insecure defaults, authorization mistakes, sensitive-data logging, and unsafe deserialization
- Failure behavior, observability, configuration validation, and retry/idempotency concerns where relevant

## Severity

Assign a severity to each finding:

- **Critical**: likely security vulnerability, data loss/corruption, outage, serious authorization failure, or severe regression
- **High**: clear functional defect, compatibility break, or major reliability issue likely to affect users or production
- **Medium**: meaningful maintainability, testability, documentation, robustness, or design issue that should be addressed before merging
- **Low**: minor clarity, style, or localized improvement with little practical risk
- **Info**: observation or optional improvement; do not treat as a finding requiring resolution

Only Critical, High, and Medium findings block completion.

## Review-fix loop

Track state (`REVIEWING`, `FIXING`, `VALIDATING`, `CRITIQUING`, `PAUSED`,
`COMPLETE`, or `NOT CONVERGED`), cycles, critic passes, consecutive agreed CLEAN
passes, outstanding findings, and validation results. Keep only concise evidence
and decisions in the main context; do not retain full critic transcripts.

Default limit: six cycles unless the user specifies otherwise. Check the limit
before each new cycle. Resuming PAUSED continues the active cycle with its
existing validation-attempt count; do not increment cycles merely for resuming.
Exhaustion when a new cycle is needed, or repeated disagreement, stops as
`NOT CONVERGED`, never `COMPLETE`. A user decision does not reset counters;
if exhausted, report the need for an extended budget to continue.

1. **Review.** Increment cycles. Inspect the full selected scope and relevant
   context, including all fixes made during this invocation. For a commit range,
   retain the original base/head and include subsequent remediation changes;
   for uncommitted scope, include relevant tracked and untracked files. Capture
   a content snapshot before review; refresh it and re-review after any edits.
2. **Fix.** Apply all independent, unambiguous findings above Low severity using
   the Implementor Protocol. Handle unresolved decisions through its PAUSED protocol.
3. **Validate.** Run relevant checks and inspect the resulting changes. Re-review
   corrections before requesting a critic. Disclose unavailable checks and
   unrelated failures; never describe failed or unexecuted checks as passed.
   Reuse successful results when reviewed content and relevant environment are
   unchanged; repeat checks only after changes or new evidence warrants it.
   Validation failures caused by selected changes block completion. Limit
   validation rounds to three per cycle, including critic-driven fixes;
   if still failing or further validation is needed, begin the next budgeted
   cycle. Never use an inner retry loop to bypass the cycle limit.
4. **Critique.** Read [Critic Contract](references/critic.md). Create one fresh,
   history-free subagent per pass (for example, `fork_turns="none"`). Supply only
   the repository path, resolved scope/base/head, initial working-tree baseline
   and session diff (including added/deleted files) or paths to those snapshots,
   applicable user constraints and decisions, and absolute paths to this skill
   and the contract. Have it read current files and relevant repository guidance.
   Do not supply prior reasoning, findings, verdicts, or expected outcomes.
   Use read-only tool restrictions where supported. Increment critic passes. When
   using `multi_agent_v1__wait_agent`, set `timeout_ms` to `3600000` rather than
   relying on its 30-second default. A `timed_out: true` result only means the
   wait ended; wait again on the same still-running critic instead of treating it
   as failed or spawning a duplicate. Only a final failure state makes critic
   output unavailable.
   Compare the reviewed content snapshot after the pass; concurrent changes
   invalidate its verdict and reset clean passes.
5. **Adjudicate.** Independently verify each critic finding against repository
   evidence and the severity definitions. Implement accepted unambiguous fixes,
   validate them within the cycle budget, and begin a new cycle. Route accepted
   findings needing a user decision through the Implementor Protocol. Record
   concise evidence for rejections; rejection cannot turn a non-CLEAN verdict
   into CLEAN. Missing, malformed, or
   failed critic output resets clean passes; retry in the next cycle.
6. **Check convergence.** Only a CLEAN verdict with main-agent agreement counts.
   Every edit or relevant context change resets clean passes. After the first
   CLEAN, run a complete new review and fresh critic pass. Use content snapshots
   or hashes, including added/deleted/untracked files, to confirm both passes
   cover unchanged reviewed content. Any other verdict resets clean passes.
7. **Finish or repeat.** Enter `COMPLETE` only after two consecutive agreed CLEAN
   passes, no remaining Critical/High/Medium findings or pending decisions, and
   validation of all fixes as far as available tooling permits. Otherwise repeat.
   The same rejected material finding in two consecutive cycles, or a correction
   reversed and then proposed again, stops as `NOT CONVERGED`; report the dispute.

If isolated contexts are unavailable, perform the Critic Contract as a separate
read-only phase and disclose reduced independence. A history-inheriting child
does not count as isolated. Apply the same verdicts, counters, and completion gate.

Do not downgrade, defer, or omit findings to reach completion. If validation
cannot run, report the exact command, reason, and remaining uncertainty.

## Final response

Provide a concise review report with these sections:

Lead with outcome (`COMPLETE`, `PAUSED`, or `NOT CONVERGED`), cycle/critic/clean
counts, and whether critics were isolated or used the fallback.

### Scope

- Git scope reviewed
- Files materially inspected
- Repository guidance and validation commands used

### Changes made

- Each automatic fix, its reason, and affected files
- Tests or documentation added/updated

### Validation

- Commands run and their results
- Checks not run, with the reason

### Remaining findings

- State `No findings above low severity remain` only when supported; this alone
  does not imply COMPLETE if the critic gate remains unmet
- Otherwise list unresolved findings, severity, pending decisions or disagreement,
  and the stopping reason

### Low-severity notes

- List only actionable low-severity observations
- Do not implement low-severity changes unless requested
