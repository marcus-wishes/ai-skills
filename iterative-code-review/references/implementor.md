# Implementor Protocol

The main agent implements fixes, validates results, and adjudicates critic
findings. Read the shared scope, safety rules, review standards, and severity
definitions in `../SKILL.md` before applying this protocol. The review-fix loop
and completion gate remain authoritative there.

## Fix policy

Apply these priorities to every implementation, not just the review:

- **DRY:** search existing helpers and relevant callers before editing. Reuse
  established behavior and fix shared root causes instead of patching each caller.
  Extract shared logic only when it represents the same responsibility and
  reduces maintenance cost; similar-looking code alone does not justify it.
- **KISS:** choose the simplest correct approach using existing code, standard
  library, or native facilities. Avoid speculative abstractions and flexibility.
- **Maintainability and readability:** prefer clear names, cohesive functions,
  explicit control flow, and established patterns. Optimize for ease of reading
  and changing the code, not the fewest characters or lines.
- **Necessary comments:** explain non-obvious intent, invariants, constraints,
  or trade-offs where clear code alone cannot communicate them. Update stale
  comments alongside fixes; do not narrate obvious operations.

These priorities guide necessary fixes within scope; they do not authorize
unrelated cleanup or elevate stylistic preferences above Low severity.

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
   its counters. Apply the decision under this Fix policy. Check the cycle budget
   when a new cycle is needed, not merely because the user replied.
4. Continue through validation and the critic completion gate, or pause for
   another genuinely independent decision.

Never require the user to invoke this skill again after answering a pending question.
A user answer resumes the workflow; it does not establish completion. If another
cycle is required beyond the budget, report `NOT CONVERGED` per `SKILL.md`.
