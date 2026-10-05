#!/usr/bin/env sh

ln -sfn "$(pwd)/iterative-code-review" ~/.agents/skills/iterative-code-review
ln -sfn "$(pwd)/openspec-readiness" ~/.agents/skills/openspec-readiness
ln -sfn "$(pwd)/state-confidence" ~/.agents/skills/state-confidence
ln -sfn "$(pwd)/iterative-code-review" ~/.claude/skills/iterative-code-review
ln -sfn "$(pwd)/openspec-readiness" ~/.claude/skills/openspec-readiness
ln -sfn "$(pwd)/state-confidence" ~/.claude/skills/state-confidence

echo "Skills installed successfully"