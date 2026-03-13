---
name: create-skill
description: Use when the user wants to create a new Claude Code skill (global or project-specific). Guides the full skill authoring process including naming, structure, frontmatter, and file creation.
disable-model-invocation: true
argument-hint: "[describe the skill to create, scope, and optionally a name]"
---

# Create Skill

You are helping create a new Claude Code skill. The user has requested:

**$ARGUMENTS**

## Step 1: Fetch best practices

Before doing anything else, fetch the official skill authoring best practices:

```
https://code.claude.com/docs/en/skills.md
```

Read and internalize the guidance there — especially:
- Frontmatter fields (`name`, `description`, `disable-model-invocation`, `argument-hint`, `context`, `allowed-tools`)
- File structure: `skills/<skill-name>/SKILL.md` with optional supporting files
- Description field rules: starts with "Use when...", third-person, no workflow summary
- Token efficiency: keep SKILL.md concise; move heavy reference to separate files

## Step 2: Clarify scope and naming

From the user's request, determine:

**Scope** — where should the skill live?
- **Global** (`~/.claude/skills/<name>/SKILL.md`): available in all projects
- **Project-specific** (`.claude/skills/<name>/SKILL.md`): current project only
- If the request says "global" or "personal", use `~/.claude/skills/`
- If it says "project" or "project-specific", use `.claude/skills/` in the current working directory
- If unclear, ask the user

**Name** — pick a good skill name:
- Lowercase letters, numbers, hyphens only (max 64 chars)
- Verb-first or gerund form preferred: `review-pr`, `generating-websites`, `check-coverage`
- If the user asked you to come up with a name, propose one and explain your reasoning

## Step 3: Design the skill

Plan the skill content before writing:

1. **What does it do?** One sentence.
2. **When should it trigger?** (for `description` field — triggering conditions only, no workflow summary)
3. **Should it be manually invoked only?** If it has side effects, creates files, or the user should control timing → add `disable-model-invocation: true`
4. **Does it need arguments?** If yes, include `argument-hint` and use `$ARGUMENTS` in content
5. **Does it need special tools?** Add `allowed-tools` if so
6. **Should it run in a subagent?** Add `context: fork` for isolated tasks with no need for conversation history

## Step 4: Create the skill files

Create the directory and `SKILL.md`. Structure:

```
<scope>/skills/<skill-name>/
├── SKILL.md           # Required — main instructions
├── reference.md       # Optional — heavy reference docs (100+ lines)
└── examples/          # Optional — example outputs or templates
```

**SKILL.md template:**

```markdown
---
name: skill-name
description: Use when [specific triggering conditions — no workflow summary]
---

# Skill Title

Brief overview of what this skill does (1-2 sentences).

## Instructions

[The actual instructions Claude should follow when this skill is invoked]
```

Keep `SKILL.md` under 500 lines. If reference material is large, put it in a separate file and link to it from `SKILL.md`.

## Step 5: Verify

After creating the files, confirm:
- [ ] Skill directory and `SKILL.md` created at the correct path
- [ ] YAML frontmatter is valid (only supported fields used)
- [ ] `description` starts with "Use when..." and describes triggering conditions only
- [ ] Name uses only lowercase letters, numbers, hyphens
- [ ] Instructions are clear and actionable
- [ ] Tell the user the skill name and how to invoke it (`/skill-name`)
