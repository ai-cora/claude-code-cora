# Importing Claude Code Issues

Import existing issues from [anthropics/claude-code](https://github.com/anthropics/claude-code) to examine, analyze, or contribute to.

## Import a Single Issue

```bash
./scripts/import-issue <issue-number>
```

This creates a directory at `issues/<issue-number>-<slug>/` with:
- `ISSUE.md` - The issue content with frontmatter
- `README.md` - Overview template for your notes

If the issue already exists, it will tell you the path.

## After Importing

1. Review the ISSUE.md content
2. Add your analysis notes to README.md
3. Create reproduction scripts or test harnesses as needed
4. Document your findings and potential contributions
