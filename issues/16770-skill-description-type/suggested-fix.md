# Suggested Fix for Skill Description Type Validation

## Root Cause

In the minified `cli.js` at line 3061, around character position 27343:

```javascript
descriptionKey:X.description.split(" ").map((K)=>I47(K)).filter(Boolean)
```

This code assumes `X.description` is always a string and calls `.split()` without validation.

## Problem

When a skill's YAML frontmatter contains:
```yaml
description: [This is an array]
```

YAML parses this as an array, not a string. Calling `.split()` on an array throws:
```
TypeError: X.description.split is not a function
```

## Suggested Fix

### Option 1: Type Coercion (Simple)

Before building the Fuse.js search index, coerce description to string:

```javascript
// Before (crashes on arrays)
descriptionKey: X.description.split(" ").map((K)=>I47(K)).filter(Boolean)

// After (handles any type)
descriptionKey: String(X.description || "").split(" ").map((K)=>I47(K)).filter(Boolean)
```

### Option 2: Validation During Skill Load (Recommended)

Add Zod schema validation when loading skill frontmatter. The codebase already uses Zod extensively:

```javascript
// Skill frontmatter schema
const skillFrontmatterSchema = z.object({
  name: z.string().min(1, "Name is required"),
  description: z.string().min(1, "Description must be a non-empty string"),
  // ... other fields
});

// When loading skill
const parsed = skillFrontmatterSchema.safeParse(frontmatter);
if (!parsed.success) {
  console.warn(`Skipping skill ${filePath}: ${parsed.error.message}`);
  return null;
}
```

### Option 3: Graceful Fallback

Skip malformed skills rather than crashing:

```javascript
// In skill loading code
if (typeof skill.description !== 'string') {
  console.warn(`Skill ${skill.name} has invalid description type (${typeof skill.description}), skipping`);
  continue;
}
```

## Recommended Approach

Option 2 is recommended because:
1. Validates early (at skill load time, not search index time)
2. Provides clear error messages pointing to the problematic file
3. Consistent with existing Zod validation patterns in the codebase
4. Prevents one bad skill from breaking the entire CLI

## Files to Modify

Based on the minified code analysis, the fix should be applied in:
- Skill frontmatter parsing (where YAML is parsed)
- Possibly also defensively in the Fuse.js index builder

The source files are not publicly available, but the team can identify them by searching for:
- `description.split(" ")` in the search index code
- Skill frontmatter parsing using `gray-matter` or similar
