# Git & GitHub preferences

- Never add Claude as co-author in commits (no `Co-Authored-By` line)
- Never mention Claude as co-author or generator in PR descriptions or issue content
- Do not push, commit, or modify anything on GitHub autonomously. Only do so when explicitly asked by the user. The user prefers to handle git push, commit, and GitHub operations manually most of the time.

# graphify

- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.

# Working preferences

- In plan mode, when I ask questions, answer them in the chat first and update the plan file. Open the plan view (ExitPlanMode) only when I ask to see the plan.

# Shell

- `rm` is aliased to `rm -i` and `cat` to `bat` in my shell, and Claude Code tool shells load these aliases. Use `command rm` and `command cat` in tool calls and scripts, an interactive `rm -i` hangs without a terminal.
