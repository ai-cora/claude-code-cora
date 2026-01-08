#!/bin/bash
# Minimal reproduction for Claude Code skill description crash
read -p "Opens Claude with bad skill - type /con to crash. Continue? [Y/n] " -n 1 -r; echo
[[ $REPLY =~ ^[Nn]$ ]] && exit 0
d=$(mktemp -d) && mkdir -p "$d/.claude/skills/bad"
echo -e "---\nname: bad\ndescription: [array]\n---\n# Bad" > "$d/.claude/skills/bad/SKILL.md"
cd "$d" && claude; rm -rf "$d"
