# Review Standards

Shared criteria for the main agent, critics, and delegated implementors. The
workflow lives in `../SKILL.md`; do not execute it from this file.

## Safety and authority

- Do not discard, reset, stash, overwrite, or revert user changes.
- Do not amend commits, create commits, push branches, open pull requests, alter Git configuration, or change CI/CD configuration unless explicitly requested.
- Do not change lockfiles, generated files, snapshots, vendored code, migrations, public APIs, deployment configuration, or dependencies unless the required change is clearly necessary and within the requested scope.
- Do not make speculative changes or opportunistic refactors. Never silently broaden the selected scope.
- Do not invent business rules, API semantics, security requirements, compatibility guarantees, performance targets, or product decisions.
- Preserve backward compatibility unless the selected changes or documented project policy explicitly require breaking it.

## Review areas

Learn the repository's conventions first; prefer project-local instructions and
established patterns over generic preferences.

- **Correctness and regression risk:** logic, edge cases, nullability, error
  handling, concurrency, data loss, resource lifecycle, wrong assumptions; broken
  contracts between modules, clients, databases, files, queues, or external
  services; compatibility regressions; missing validation at trust boundaries;
  incomplete updates when a data model, interface, config field, or contract changes.
- **Architecture and maintainability:** separation of concerns, module
  boundaries, coupling, dependency direction, circular dependencies, leaky
  abstractions, naming, cohesion, readability, unnecessary complexity. Flag
  duplication only when it creates divergent behavior or material maintenance
  cost; duplication is acceptable when clearer and unlikely to evolve together.
- **Overengineering:** in the selected changes and session fixes, flag
  complexity the current requirements do not need: abstractions, interfaces, or
  factories with a single implementation; configuration, flags, or parameters for
  fixed values; generality or extension points for hypothetical use; extra
  layers, wrappers, or indirection; new dependencies or custom code where the
  standard library, platform, or an existing helper suffices; defensive handling
  of states the code's contracts rule out. Medium when it adds material
  maintenance cost or obscures behavior, otherwise Low. The fix is the simpler
  design the requirements support; never remove trust-boundary validation,
  error handling, security, or compatibility needed for correctness.
- **Documentation:** missing or stale docs for externally observable behavior,
  public APIs, configuration, deployment, non-obvious constraints, and
  surprising decisions. Comments that restate code are not useful.
- **QA and verification:** missing tests for changed behavior, especially
  boundaries and failure modes; flaky tests, weak assertions, implementation-detail
  tests, broken isolation; stale fixtures, mocks, contracts, snapshots, test data;
  lint, format, type, build, or test failures caused by the selected changes.
- **Security and operations:** secrets exposure, unsafe input handling,
  injection, insecure defaults, authorization mistakes, sensitive-data logging,
  unsafe deserialization; failure behavior, observability, config validation,
  retry and idempotency where relevant.

## Severity

- **Critical**: likely security vulnerability, data loss/corruption, outage, serious authorization failure, or severe regression
- **High**: clear functional defect, compatibility break, or major reliability issue likely to affect users or production
- **Medium**: meaningful maintainability, testability, documentation, robustness, or design issue that should be addressed before merging
- **Low**: minor clarity, style, or localized improvement with little practical risk
- **Info**: observation or optional improvement; not a finding requiring resolution

Only Critical, High, and Medium findings block completion. Findings above Low
need a concrete behavioral or maintenance consequence.

## Fix policy

Apply to every implementation:

- **DRY:** search existing helpers and relevant callers before editing. Reuse
  established behavior and fix shared root causes instead of patching each caller.
  Extract shared logic only for the same responsibility and lower maintenance
  cost; similar-looking code alone does not justify it.
- **KISS:** choose the simplest correct approach using existing code, standard
  library, or native facilities. Avoid speculative abstractions and flexibility.
- **Readability:** clear names, cohesive functions, explicit control flow,
  established patterns. Optimize for reading and changing the code, not for
  fewest lines.
- **Necessary comments:** explain non-obvious intent, invariants, constraints, or
  trade-offs only; update stale comments alongside fixes.

These priorities guide necessary fixes within scope; they do not authorize
unrelated cleanup or elevate stylistic preferences above Low.
