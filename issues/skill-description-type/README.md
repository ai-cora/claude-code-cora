---
title: Skill Description Type Validation Bug
github_issue: https://github.com/anthropics/claude-code/issues/XXX
status: ready
severity: high
claude_code_version: 2.1.1
---

# Skill Description Type Validation Bug

**GitHub Issue**: https://github.com/anthropics/claude-code/issues/XXX   
**Status**: Ready to submit   
**Severity**: High   
**Claude Code Version**: 2.1.1

## Summary

Claude Code throws `TypeError: X.description.split is not a function` when a skill's YAML frontmatter has a `description` field that is an array instead of a string. The error corrupts the terminal UI and breaks the command palette.

![Error Screenshot](error-screenshot.png)

## Quick Reproduction

```bash
./minimal-repro.sh
# Then type /con to trigger the error
```

Or manually:
```bash
d=$(mktemp -d) && mkdir -p "$d/.claude/skills/bad"
echo -e "---\nname: bad\ndescription: [array]\n---\n# Bad" > "$d/.claude/skills/bad/SKILL.md"
cd "$d" && claude; rm -rf "$d"
```

## Files

| File | Description |
|------|-------------|
| [ISSUE.md](ISSUE.md) | Full GitHub issue text (copy/paste ready) |
| [minimal-repro.sh](minimal-repro.sh) | 5-line reproduction script |
| [test-harness.sh](test-harness.sh) | Interactive test with confirmation and cleanup |
| [suggested-fix.md](suggested-fix.md) | Detailed fix analysis |
| [error-screenshot.png](error-screenshot.png) | Screenshot showing UI corruption |

## Root Cause

Line 3061 in minified `cli.js` builds a Fuse.js search index:

```javascript
descriptionKey: X.description.split(" ").map((K)=>I47(K)).filter(Boolean)
```

This assumes `description` is always a string. YAML parses `[text]` as an array.

## Suggested Fix

Add Zod validation (consistent with existing codebase patterns):

```javascript
const skillFrontmatterSchema = z.object({
  name: z.string(),
  description: z.string().min(1, "Description must be a string"),
});

const parsed = skillFrontmatterSchema.safeParse(frontmatter);
if (!parsed.success) {
  console.warn(`Skipping skill ${filePath}: ${parsed.error.message}`);
  return null;
}
```
