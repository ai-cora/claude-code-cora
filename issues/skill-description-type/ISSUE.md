# GitHub Issue: anthropics/claude-code

## Title
CLI throws TypeError when skill description is not a string

## Labels
`bug`

## Body

### Description

Claude Code CLI throws an unhandled exception when a skill's YAML frontmatter has a `description` field that isn't a string. The error corrupts the terminal UI (multiple input prompts appear) and breaks command palette functionality until the malformed skill is removed.

![Error Screenshot](error-screenshot.png)

### Steps to Reproduce

1. Create a skill file `~/.claude/skills/test-skill/SKILL.md`:
```yaml
---
name: test-skill
description: [This is parsed as an array, not a string]
---

# Test Skill
```

2. Start Claude Code
3. Type `/con` (start typing a slash command to trigger fuzzy search)
4. TypeError is thrown and UI becomes corrupted

### Error Message

```
TypeError: X.description.split is not a function
    at file:///Users/admin/.nvm/versions/node/v22.21.1/lib/node_modules/@anthropic-ai/claude-code/cli.js:3061:27343
    at Array.map (<anonymous>)
    at cN0 (file:///Users/admin/.nvm/versions/node/v22.21.1/lib/node_modules/@anthropic-ai/claude-code/cli.js:3061:27231)
    at file:///Users/admin/.nvm/versions/node/v22.21.1/lib/node_modules/@anthropic-ai/claude-code/cli.js:3064:14351
```

### Root Cause Analysis

In the minified `cli.js` at line 3061, position ~27343, the code builds a Fuse.js search index:

```javascript
descriptionKey:X.description.split(" ").map((K)=>I47(K)).filter(Boolean)
```

This assumes `description` is always a string. In YAML, square brackets `[...]` denote an array, so:

```yaml
description: [TODO: Write description]  # Parsed as array, not string!
```

This is an easy mistake to make because text with brackets can look syntactically correct.

### Quick Reproduction

```bash
# Create temp project with malformed skill, run claude, cleanup on exit
d=$(mktemp -d) && mkdir -p "$d/.claude/skills/bad"
echo -e "---\nname: bad\ndescription: [array]\n---\n# Bad" > "$d/.claude/skills/bad/SKILL.md"
cd "$d" && claude; rm -rf "$d"
# Then type /con to trigger error
```

**Full reproduction scripts available:**
- [minimal-repro.sh](https://github.com/ai-cora/claude-code/blob/master/issues/skill-description-type/minimal-repro.sh) - Quick 5-line reproduction
- [test-harness.sh](https://github.com/ai-cora/claude-code/blob/master/issues/skill-description-type/test-harness.sh) - Interactive test with cleanup

### Suggested Fix

The codebase already uses Zod for schema validation extensively. Adding validation during skill load would be consistent with existing patterns:

**Option 1: Early Validation (Recommended)**

Add Zod schema validation when parsing skill frontmatter:

```javascript
const skillFrontmatterSchema = z.object({
  name: z.string().min(1),
  description: z.string().min(1, "Description must be a string"),
  // ...
});

const parsed = skillFrontmatterSchema.safeParse(frontmatter);
if (!parsed.success) {
  console.warn(`Skipping skill ${filePath}: ${parsed.error.message}`);
  return null;
}
```

**Option 2: Defensive Coercion**

Simple fix at the search index builder:

```javascript
// Before
descriptionKey: X.description.split(" ").map(...)

// After
descriptionKey: String(X.description || "").split(" ").map(...)
```

Option 1 is better because it validates early and provides clear error messages pointing to the problematic file.

### Impact

- **Severity**: High - Command palette breaks and UI becomes corrupted
- **Scope**: Any user who creates a skill with accidentally malformed YAML
- **Discoverability**: Low - The error message doesn't indicate which skill file is problematic

### Workaround

Quote the description in the YAML frontmatter:
```yaml
description: "Text with [brackets] needs quotes"
```

### Environment

- Claude Code version: 2.1.1
- Node.js: v22.21.1
- OS: macOS 15.3 (Darwin 25.2.0)
