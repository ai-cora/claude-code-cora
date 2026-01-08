# Creating Issues for Claude Code

This guide covers how to create and organize issues for submission to [anthropics/claude-code](https://github.com/anthropics/claude-code).

## Before Creating an Issue

1. Pull the latest upstream: `git -C upstream/claude-code pull`
2. **Check for duplicates**: Search existing issues for similar problems
   ```bash
   gh issue list --repo anthropics/claude-code --search "your keywords" --state all
   ```
3. Review the issue templates in `upstream/claude-code/.github/ISSUE_TEMPLATE/`
4. Choose the appropriate template for your issue type

### Issue Templates

| Template | Use For |
|----------|---------|
| bug_report.yml | Bugs and unexpected behavior |
| feature_request.yml | New feature suggestions |
| documentation.yml | Documentation issues |
| model_behavior.yml | Claude model behavior issues |

## Directory Structure

Each issue should be in its own directory under `issues/`:

```
issues/
└── issue-name/
    ├── README.md           # Quick overview and file index
    ├── ISSUE.md            # Full issue text (copy/paste ready)
    ├── minimal-repro.sh    # Minimal reproduction script
    └── ...                 # Supporting files (screenshots, test harnesses, etc.)
```

## YAML Frontmatter

Both README.md and ISSUE.md should have YAML frontmatter for metadata tracking.

### ISSUE.md frontmatter

```yaml
---
title: Issue title
target_repo: anthropics/claude-code
github_issue: null  # Updated after submission
labels: [bug]
status: ready  # draft, ready, submitted
---
```

### README.md frontmatter

```yaml
---
title: Issue title
github_issue: null
status: ready
severity: high
claude_code_version: 2.1.1
---
```

## Workflow

1. Create issue directory: `mkdir -p issues/your-issue-name`
2. Create README.md with quick overview and frontmatter
3. Create ISSUE.md with full issue content matching upstream template
4. Add reproduction scripts and supporting files
5. Submit to anthropics/claude-code using `gh issue create`
6. Update frontmatter with the GitHub issue URL

---

*Update this document if upstream templates change.*
