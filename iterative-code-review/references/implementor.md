# Implementor Protocol

The main agent implements fixes (directly or through delegated edits), validates
results, and adjudicates critic findings, applying `review-standards.md`
(including its Fix policy). The review-fix loop and completion gate remain
authoritative in `../SKILL.md`.

## Fixing findings

For every finding above Low severity:

1. Decide whether the correct resolution is **unambiguous** from the codebase, tests, documentation, and selected diff.
2. If it is unambiguous, implement the smallest correct fix.
3. Add or update focused tests when they are necessary and their expected behavior is unambiguous.
4. Run the narrowest relevant formatter, linter, type checker, build, and tests.
5. If a command fails due to an existing unrelated issue, do not fix it unless it is clearly caused by the selected changes. Report it separately.

A fix is unambiguous only if all of the following are true:

- The intended behavior is established by existing code, tests, documentation, types, contracts, or explicit user instructions
- The fix does not introduce a new product or architectural decision
- The change is minimal and has no reasonable competing implementation with materially different behavior
- You can validate it with existing or clearly implied tests/checks

## Delegated edits

The main agent may delegate an accepted, unambiguous fix to an implementor
subagent on a cheaper model when the main agent has already decided the exact
change. Keep fixes needing investigation, design judgment, or root-cause
analysis in the main agent. Delegate only when the edit is clearly larger than
its brief (for example many call sites or repetitive test writing); make small
edits directly, since writing the brief costs more than the edit.

- **Model:** small tier (Haiku, Luna) at low or medium effort for mechanical,
  localized edits (rename, add a guard, update a call site, write a specified
  test); mid tier (Sonnet, Terra) at medium or high effort for multi-file but
  fully specified edits. See `../SKILL.md` Subagent models for tier mapping.
- **Brief:** finding ID, absolute repository path, exact files it may edit,
  the intended change and expected behavior, the absolute path to
  `review-standards.md`, and the narrowest check to run. Tell it to edit only the
  listed files, never touch Git state, stop and report instead of improvising
  when the brief does not fit the code, and return a short summary of edits.
- **Ownership:** run one implementor at a time, never while a critic is active.
  The main agent inspects the resulting diff, rejects or corrects out-of-scope or
  incorrect edits, and runs validation itself. Delegated edits count toward the
  same cycle and validation budgets as direct edits.

## Decisions requiring user input

When a finding cannot be resolved without a product, architectural, compatibility,
security, compliance, data, or performance decision, enter a **blocked decision
state**. This is a temporary pause in the review-fix loop, not completion of the task.

Before asking:

1. Continue reviewing all other selected changes and implement every independent,
   unambiguous Critical, High, or Medium fix.
2. Validate completed fixes within the main loop's attempt limit and record
   results or limitations before pausing.
3. Do not make changes whose correctness depends on the unresolved decision.
4. Do not report final completion while any finding above Low remains blocked.

Ask one concise decision question at a time. Include:

- Finding ID, severity, and affected file(s)
- Evidence and why this needs a decision
- Viable options and their trade-offs
- A clearly labelled recommendation
- The exact answer required to proceed

End the message with:

> **Review status: PAUSED — awaiting decision(s).**
> After you answer, I must resume this same iterative review-fix loop automatically.
> I must not treat the answer as task completion.

## Resumption protocol

When the user replies while the review status is `PAUSED`:

1. Treat the reply as an answer to the pending decision(s), unless the user
   explicitly changes scope or starts a different task.
2. Re-read the pending finding(s), the user's answer, the current Git diff,
   and any affected files that may have changed since the question was asked.
3. Record the decision and resume the active cycle in `SKILL.md`, preserving
   its counters. Apply the decision under this protocol. Check the cycle budget
   when a new cycle is needed, not merely because the user replied.
4. Continue through validation and the critic completion gate, or pause for
   another genuinely independent decision.

Never require the user to invoke this skill again after answering a pending question.
A user answer resumes the workflow; it does not establish completion. If another
cycle is required beyond the budget, report `NOT CONVERGED` per `SKILL.md`.
