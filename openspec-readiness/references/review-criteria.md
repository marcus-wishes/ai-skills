# Review Criteria

Apply criteria relevant to the target change. The goal is implementation
readiness, not maximal documentation. Never manufacture concerns to exercise a
category, invent requirements for theoretical completeness, or demand detail,
machinery, or abstraction the change does not materially need; never remove
complexity necessary for correctness.

## Areas

1. **Requirements completeness:** happy path, failure and validation behavior,
   relevant edge cases, state transitions, interaction with existing behavior,
   explicit scope and needed non-goals, observable behavior, compatibility,
   acceptance criteria. When relevant: retries, idempotency, concurrency,
   transactions, ordering, partial failure, recovery, authn/authz, privacy,
   persistence, migration, rollback, lifecycle, timeouts, cancellation,
   performance, rate limits, observability, deployment constraints.
2. **Architectural fit:** respects existing boundaries, layering, dependency
   direction, domain concepts, patterns, and module/state/data ownership. Flag
   parallel architectural paths without sufficient reason and new patterns where
   a suitable established one exists.
3. **Reuse:** explicitly search for existing services, validators, helpers,
   repositories, state machines, serialization, clients, adapters, error
   translation, authorization, configuration, and test utilities the change may
   duplicate. Recommend reuse only for the same responsibility or domain
   meaning. Prefer one authoritative implementation of important business rules.
4. **Simplicity:** challenge each new module, service, interface, abstraction,
   data structure, queue, worker, cache, table, dependency, config layer, event,
   or indirection: is it needed for current requirements? Prefer fewer concepts
   for the same behavior. Flag designs and tasks that would lead to an
   overengineered implementation: single-implementation interfaces, configuration
   for fixed values, extension points for hypothetical needs, or custom code
   where the standard library, platform, or an existing helper suffices.
5. **Ownership and boundaries:** explicit owner and mutators of important state;
   where rules, validation, persistence, external integration, error translation,
   and retries live; which component is authoritative and which coordinates.
   Avoid multiple writable representations of one state without explicit sync.
6. **Coupling and cohesion:** no needless cross-module knowledge, bidirectional
   or circular dependencies, feature logic in infrastructure, shared mutable
   state, leaked implementation details, overly broad interfaces, or scattered
   orchestration.
7. **Control flow:** clear entry points, orchestration, state transitions,
   failure propagation, deliberate retry placement, owned async work, no hidden
   side effects or events obscuring business flow.
8. **Data model and state:** authoritative representation, invariants,
   lifecycle, nullability, defaults, uniqueness, mutation, deletion, retention,
   serialization, versioning — low-level schema detail only where it affects
   architecture or safety.
9. **Interfaces and contracts:** APIs, events, messages, commands, schemas,
   config and persistence interfaces: naming, responsibility, input/output/error
   semantics, compatibility, versioning, ownership. Contracts should expose
   domain intent, not incidental structure.
10. **Failure modes:** validation and dependency failures, partial failure,
    retryable vs non-retryable, timeout, cancellation, inconsistent state,
    malformed input, conflicts, duplicates, rollback or compensation.
11. **Security:** authentication assumptions, authorization ownership,
    privilege boundaries, untrusted input, secrets, data exposure, tenant/user
    isolation, secure defaults.
12. **Concurrency and consistency:** races, lost updates, duplicate work,
    ordering, atomicity, transaction boundaries, locks, stale reads, retries after
    partial success — required where incorrect behavior is otherwise likely.
13. **Migration and compatibility** (persisted data, APIs, events, config):
    forward migration, backward and mixed-version compatibility, rollout order,
    rollback, data conversion, transitional cleanup, deprecation, old consumers.
14. **Operations:** logs, metrics, tracing, error reporting, diagnosis, rollout
    visibility, failure detection — only with material operational value.
15. **Performance:** scale, complexity, query patterns, N+1, memory, network
    calls, caching, batching, hot paths, cleanup — only where important limits
    or known hot paths are plausibly affected.
16. **Testability:** business behavior, boundaries, observable behavior,
    failure paths, and migrations are testable without excessive setup or
    implementation knowledge; no abstraction solely to enable mocking.
17. **Readability and maintainability:** an engineer who did not design it can
    answer: where does this behavior live, who owns this state, where is this
    rule enforced, what calls what, how does failure propagate, where would a
    future change belong. Few moving parts, local changes, no scattered rules.
18. **Plan completeness:** `tasks.md` realizes proposal, specs, and design,
    including implementation, tests, schema, migration, compatibility, config,
    cleanup and removal of superseded logic, observability, docs, flags,
    rollout, rollback, and validation where required. Tasks leave no
    architectural decisions open and have objectively checkable completion.

## Finding classification

Classify each material finding as exactly one of:

- **BLOCKER:** a human or product decision, external dependency, missing fact,
  or irreconcilable architectural choice prevents safe implementation readiness.
- **REQUIRED:** the change is not implementation ready without correction.
- **RECOMMENDED:** implementation could proceed, but a competent senior system
  architect should change this first because it materially improves
  correctness, simplicity, readability, maintainability, consistency,
  architectural fit, testability, reuse, or operational safety.
- **OPTIONAL:** a possible improvement or preference that does not materially
  affect readiness. OPTIONAL findings do not prevent readiness.

Never classify stylistic preferences as RECOMMENDED.
