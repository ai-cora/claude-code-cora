---
title: Skill Description Type Validation Bug
github_issue: null
status: ready
severity: high
claude_code_version: 2.1.1
---

# Skill Description Type Validation Bug

Claude Code throws `TypeError: X.description.split is not a function` when a skill's YAML frontmatter has a `description` field that is an array instead of a string. This corrupts the terminal UI and breaks the command palette.

**Status**: Ready to submit
**Severity**: High

## Files

| File | Description |
|------|-------------|
| [ISSUE.md](ISSUE.md) | Full GitHub issue text (copy/paste ready) |
| [minimal-repro.sh](minimal-repro.sh) | 5-line reproduction script |
| [test-harness.sh](test-harness.sh) | Interactive test with cleanup |
| [suggested-fix.md](suggested-fix.md) | Detailed fix analysis |
| [error-screenshot.png](error-screenshot.png) | Screenshot showing UI corruption |

## Quick Test

```bash
./minimal-repro.sh
# Then type /con to trigger the error
```

See [ISSUE.md](ISSUE.md) for full details, root cause analysis, and suggested fixes.
