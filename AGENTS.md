# Agent Functions and Conventions

This document outlines conventions and guidelines for AI agents working with this codebase.

## Report File Naming Convention

**All generated reports must end with `_REPORT.md`**

This ensures that all AI-generated reports are automatically ignored by git (via `.gitignore` pattern `*_REPORT.md`) and do not clutter the repository.

### Examples:
- ✅ `DUPLICATE_FUNCTIONS_REPORT.md` - Correct naming
- ✅ `CHERRY_PICK_GUIDE_REPORT.md` - Correct naming  
- ✅ `CODE_ANALYSIS_REPORT.md` - Correct naming
- ❌ `CHERRY_PICK_GUIDE.md` - Incorrect (will be tracked by git)
- ❌ `duplicate-functions.md` - Incorrect (will be tracked by git)

### Rationale:
- Keeps the repository clean by excluding temporary/generated analysis files
- Allows agents to generate reports without worrying about committing them
- Makes it easy to identify which files are agent-generated reports
- Prevents accidental commits of analysis documents

### Implementation:
The `.gitignore` file contains:
```gitignore
# Report files
*_REPORT.md
```

Any file matching this pattern will be ignored by git.

## When to Use This Convention

Use the `_REPORT.md` suffix for:
- Code analysis reports
- Duplicate function/alias detection reports
- Cherry-pick guides
- Code review summaries
- Any other AI-generated analysis or documentation that is temporary or generated

Do NOT use this suffix for:
- Permanent documentation (use regular `.md` extension)
- User-facing guides (use regular `.md` extension)
- Project documentation (use regular `.md` extension)

## Agent Guidelines

When generating reports or analysis documents:
1. Always use the `_REPORT.md` suffix
2. Include a clear, descriptive name before `_REPORT.md`
3. The file will automatically be ignored by git
4. Files can be safely deleted or regenerated as needed
