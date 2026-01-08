#!/bin/bash
# Test harness for Claude Code skill description type validation bug
# GitHub Issue: https://github.com/anthropics/claude-code/issues/XXX
#
# Bug: Claude Code calls .split(" ") on description without type validation,
# crashing when skill YAML has description as array instead of string.

set -e

SCRIPT_NAME=$(basename "$0")

usage() {
    cat << EOF
Reproduce Claude Code crash when skill description is not a string.

Usage: $SCRIPT_NAME [-h|--help]

Creates a temp project with a malformed skill (description as array),
launches Claude interactively, and the crash occurs when you access
the command palette by typing /

The test cleans up automatically on exit.

See: https://github.com/anthropics/claude-code/issues/XXX
EOF
}

# Handle help
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
    exit 0
fi

# Confirmation prompt
echo "=== Claude Code Skill Description Bug Test ==="
echo ""
echo "This will:"
echo "  1. Create temp directory with malformed skill"
echo "  2. Launch Claude Code interactively"
echo "  3. Clean up temp directory on exit"
echo ""
echo "When Claude starts, type / to trigger the crash."
echo ""
read -p "Continue? [Y/n] " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Aborted."
    exit 0
fi

# Create temporary project directory
TEST_PROJECT=$(mktemp -d)
SKILL_DIR="$TEST_PROJECT/.claude/skills/test-skill"
mkdir -p "$SKILL_DIR"

# Cleanup on exit
cleanup() {
    rm -rf "$TEST_PROJECT"
    echo ""
    echo "=== Cleaned up: $TEST_PROJECT ==="
}
trap cleanup EXIT

echo ""
echo "=== Test Environment ==="
echo "TEST_PROJECT: $TEST_PROJECT"
echo ""

# Create malformed skill file with array description
cat > "$SKILL_DIR/SKILL.md" << 'SKILL_EOF'
---
name: test-skill
description: [This is parsed as an array, not a string]
---

# Test Skill

This skill has an invalid description (array instead of string).
SKILL_EOF

echo "=== Created Malformed Skill ==="
cat "$SKILL_DIR/SKILL.md"
echo ""

# Change to test project directory
cd "$TEST_PROJECT"

echo "=== Launching Claude Code ==="
echo ""
echo "To trigger the crash:"
echo "  1. Accept the trust dialog if shown"
echo "  2. Type /con (start typing a slash command)"
echo "  3. The crash occurs during fuzzy search"
echo ""
echo "Press Ctrl+C when done"
echo ""

claude --debug
