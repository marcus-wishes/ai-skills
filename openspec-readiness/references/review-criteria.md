# Review Criteria

Apply all criteria that are relevant to the target OpenSpec change.

Do not manufacture concerns merely to exercise every category.

The goal is implementation readiness, not maximal documentation.

## 1. Requirements completeness

Determine whether intended behavior is sufficiently defined.

Check:

- happy-path behavior
- failure behavior
- validation behavior
- relevant edge cases
- state transitions
- interactions with existing behavior
- explicit scope
- explicit non-goals where ambiguity would otherwise exist
- externally observable behavior
- compatibility requirements
- acceptance criteria

When relevant, examine:

- retries
- idempotency
- concurrency
- transactions
- ordering
- partial failure
- recovery
- authorization
- authentication
- security boundaries
- privacy
- persistence
- migration
- rollback
- lifecycle behavior
- resource ownership
- timeouts
- cancellation
- performance constraints
- rate limits
- observability
- deployment constraints
- backwards compatibility
- API compatibility
- data compatibility

Do not invent requirements solely for theoretical completeness.

Require detail only when it materially affects correct implementation.

## 2. Architectural fit

Determine whether the proposed design integrates naturally with the existing
system.

Check:

- existing architectural boundaries
- existing layering
- dependency direction
- existing domain concepts
- established patterns
- module ownership
- state ownership
- data ownership
- public interfaces
- extension points
- integration mechanisms

Flag designs that create a parallel architectural path without sufficient
reason.

Avoid introducing a new pattern when the repository already has a suitable
established one.

Consistency is valuable unless the existing pattern itself is clearly
inappropriate for the change.

## 3. DRY and reuse

Explicitly search the repository for functionality the proposed change might
duplicate.

Check for:

- existing domain services
- existing validators
- existing helpers
- existing repositories
- existing data access patterns
- existing state machines
- existing serialization logic
- existing API clients
- existing adapters
- existing error translation
- existing authorization logic
- existing configuration
- existing test utilities

Recommend reuse only when the reused concept has the same responsibility or
domain meaning.

Do not force unrelated concepts into a shared abstraction merely to reduce
line count.

Prefer one authoritative implementation of important business rules.

## 4. Simplicity

Challenge every additional concept introduced by the design.

For each new:

- module
- service
- class
- interface
- abstraction
- data structure
- queue
- worker
- cache
- database table
- dependency
- configuration layer
- event
- factory
- adapter
- indirection

ask whether it is necessary for the current requirements.

If the same behavior can be implemented more clearly with fewer concepts,
prefer the simpler design.

Do not remove complexity necessary for correctness.

## 5. Ownership and boundaries

The design should make important ownership explicit.

Determine:

- who owns each important piece of state
- who may mutate it
- where business rules are enforced
- where validation occurs
- which component is authoritative
- which component coordinates workflows
- where persistence responsibility lives
- where external integration boundaries live
- where errors are translated
- where retries occur when relevant

Avoid designs where responsibilities are spread across multiple layers without
clear ownership.

Avoid multiple writable representations of the same logical state unless a
synchronization strategy is explicit.

## 6. Coupling and cohesion

Prefer cohesive components with clear responsibilities.

Check for:

- unnecessary cross-module knowledge
- bidirectional dependencies
- circular dependencies
- feature logic leaking into unrelated infrastructure
- shared mutable state
- implementation details exposed through public interfaces
- overly broad interfaces
- orchestration scattered across unrelated components

Prefer narrow, explicit dependencies.

## 7. Control flow

An implementer should be able to understand the main execution path.

Check whether:

- entry points are clear
- orchestration is clear
- state transitions are understandable
- failure propagation is defined
- retries are placed deliberately
- asynchronous work has clear ownership
- callbacks or events do not obscure important business flow
- hidden side effects are minimized

Reject clever control flow that provides little concrete benefit.

## 8. Data model and state

When the change affects data or state, evaluate:

- authoritative representation
- invariants
- lifecycle
- nullability
- defaults
- uniqueness
- indexing where relevant
- mutation rules
- migration
- backwards compatibility
- deletion behavior
- retention behavior
- synchronization
- serialization
- versioning

Do not require low-level schema detail unless it materially affects architecture
or implementation safety.

## 9. Interfaces and contracts

Review affected:

- APIs
- internal interfaces
- events
- messages
- commands
- function boundaries
- schemas
- configuration contracts
- persistence interfaces

Check:

- naming
- responsibility
- input semantics
- output semantics
- error semantics
- compatibility
- versioning where relevant
- ownership

Prefer contracts that expose domain intent rather than incidental
implementation structure.

## 10. Error handling and failure modes

Determine whether meaningful failures are intentionally handled.

Check:

- validation failures
- dependency failures
- partial failure
- retryable versus non-retryable failure
- timeout
- cancellation
- inconsistent state
- unavailable dependencies
- malformed external input
- conflict
- duplicate requests
- rollback or compensation where applicable

Do not require elaborate failure machinery where simple propagation is
sufficient.

## 11. Security and authorization

When relevant, determine whether the design makes security boundaries clear.

Check:

- authentication assumptions
- authorization ownership
- privilege boundaries
- validation of untrusted input
- secret handling
- data exposure
- tenant or user isolation
- permission checks
- secure defaults

Do not add security machinery unrelated to the actual change.

## 12. Concurrency and consistency

When relevant, examine:

- race conditions
- lost updates
- duplicate work
- ordering assumptions
- atomicity
- transaction boundaries
- idempotency
- lock ownership
- eventual consistency
- stale reads
- retries after partial success

Require explicit treatment when incorrect behavior would otherwise be likely.

## 13. Migration and compatibility

When the change affects persisted data, APIs, events, configuration, or other
contracts, check:

- forward migration
- backward compatibility
- mixed-version behavior
- rollout order
- rollback
- data conversion
- cleanup of transitional state
- deprecation
- old clients or consumers

Do not require migration machinery when nothing persistent or externally
consumed changes.

## 14. Observability and operations

When operational behavior matters, examine:

- logs
- metrics
- tracing
- meaningful error reporting
- supportability
- operational diagnosis
- rollout visibility
- failure detection

Do not require observability additions that provide no material operational
value.

## 15. Performance and resource behavior

When relevant, evaluate:

- expected scale
- algorithmic complexity
- query patterns
- N+1 behavior
- memory use
- network calls
- caching
- batching
- latency-sensitive paths
- resource cleanup

Avoid speculative optimization.

Require performance design only when the change plausibly affects important
limits or known hot paths.

## 16. Testability

The proposed architecture should be straightforward to test.

Check whether:

- important business behavior can be tested directly
- boundaries can be exercised without excessive setup
- tests do not require inappropriate knowledge of implementation details
- externally visible behavior has coverage planned
- important failure paths have coverage planned
- migrations have verification where relevant
- regressions can be detected

Do not introduce abstraction solely to enable mocking if a simpler testing
strategy exists.

## 17. Readability

Review the likely implementation from the perspective of an engineer who did
not design it.

Prefer designs where:

- concepts have obvious names
- responsibilities are local
- important behavior is discoverable
- control flow is predictable
- invariants have one owner
- data ownership is clear
- abstractions map to meaningful concepts
- unnecessary indirection is absent

Ask:

- Where does this behavior live?
- Who owns this state?
- Where is this rule enforced?
- What calls what?
- How does failure propagate?
- Where would a future change belong?

If these answers would be difficult to discover, improve the design.

## 18. Maintainability

Prefer designs where:

- there are few moving parts
- important responsibilities are explicit
- changes remain local
- coupling is limited
- domain rules are not scattered
- implementation details do not leak unnecessarily
- abstractions have a clear purpose
- future engineers can reason about behavior without extensive archaeology

Ask:

"If this implementation breaks six months from now, how difficult will it be
for an engineer unfamiliar with this change to find the relevant behavior and
understand it?"

## 19. Implementation plan completeness

Verify that `tasks.md` accurately realizes the proposal, specifications, and
design.

Check for missing work involving:

- implementation
- tests
- schema changes
- migration
- compatibility
- configuration
- cleanup
- removal of superseded logic
- observability
- documentation where required
- feature flags where required
- rollout
- rollback
- validation

Tasks should not require the implementer to make unresolved architectural
decisions.

Tasks should be concrete enough that completion can be objectively determined.

## Finding classification

Classify each material finding as exactly one of:

### BLOCKER

A human decision, product decision, external dependency, missing fact, or
irreconcilable architectural choice prevents safe implementation readiness.

### REQUIRED

The change is not implementation ready without correction.

### RECOMMENDED

Implementation could proceed, but a competent senior system architect should
change this before implementation because it materially improves correctness,
simplicity, readability, maintainability, consistency, architectural fit,
testability, reuse, or operational safety.

### OPTIONAL

A possible improvement or preference that does not materially affect
implementation readiness.

OPTIONAL findings do not prevent readiness.

Do not classify stylistic preferences as RECOMMENDED.
