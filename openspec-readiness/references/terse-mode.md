# Terse Mode

Cut token use by writing tersely in internal text. Rules are self-contained;
if a `caveman` skill is available, follow its levels instead.

## Levels

- **Ultra** (scratch reasoning, notes to self): drop articles, filler, and
  pleasantries; fragments and abbreviations are fine.
- **Caveman** (critic report, subagent prompts, main-agent status/adjudication
  notes, final user report): drop articles and filler, keep full words for
  technical terms. Short sentences or fragments.

Use ultra only where no one else must parse the text. A subagent's report is
read by another agent that must verify it, so use caveman there.

## Never terse

Write normal prose for everything that persists or is consumed as an artifact:

- spec/design/proposal/task text, code, tests, comments, documentation
- commit messages and PR text
- error messages, security warnings, and anything the user must act on safely
  or that would be ambiguous if shortened

Terse mode governs chat and handoffs only, never file contents.

## Keep verbatim

Never abbreviate or reword machine-read or defined terms: verdict lines
(`VERDICT: ...`), severity labels, state names, `Location:`/`Evidence:` field
names, file paths, identifiers, commands, and quoted code. Findings keep their
full evidence: terse wording must not drop the concrete consequence.
