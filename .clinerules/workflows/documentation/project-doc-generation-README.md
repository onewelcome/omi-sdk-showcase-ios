# Unified Documentation Generation Workflow - Quick Start

**Workflow File:** `project-doc-generation.md`  
**Purpose:** Generate, maintain, and refine project documentation from codebase analysis

---

## Overview

This workflow automatically generates comprehensive project documentation by:
- 🔍 Analyzing your codebase structure and patterns
- 📝 Generating markdown documentation with proper structure
- 🔄 Maintaining docs synchronized with code changes
- 🌐 Creating OpenAPI specs from discovered APIs (if applicable)
- ✅ Following project-specific rules and conventions

---

## Quick Start

### Fresh Documentation Generation

```
1. Type: Run documentation generation workflow
2. Provide inputs when prompted:
   - Base doc path (default: docs)
   - Focus area (default: All)
   - OpenAPI path (default: Auto-discover)
   - Base commit (default: None)
   - Overwrite strategy (default: Ask)
3. Workflow will discover, plan, and generate all docs
```

### Update Existing Documentation

```
1. Type: Run documentation generation workflow
2. Select: Maintain (Update docs from code changes)
3. Choose mode:
   - Full Codebase Sync (comprehensive)
   - Incremental Update (targeted changes)
```

---

## What It Generates

- **Feature Documentation** → `docs/features/`
- **Architecture Docs** → `docs/`
- **Configuration Docs** → `docs/`
- **API Reference** → `docs/api-reference.md`
- **OpenAPI Spec** → `docs/openapi.json` (if APIs discovered)
- **Task Manifest** → `docs/docgen/tasks.json`

---

## Workflow Phases

1. **Rules & Bootstrap** - Establishes project rules (`.clinerules` or `docs/AIDOCS_CLINE_RULES.md`)
2. **Discovery & Planning** - Scans codebase and creates task manifest
3. **Execution** - Generates documentation files with anti-hallucination checks
4. **Maintenance** - Updates docs based on code changes

---

## Key Features

- **Smart Discovery:** Automatically identifies architecture, features, configs from code
- **Anti-Hallucination:** Verifies all entities against workspace before documenting
- **Newcomer-Focused:** Concise, scannable docs for onboarding
- **OpenAPI Generation:** Auto-creates API specs from discovered endpoints
- **Incremental Updates:** Surgical updates for changed code only
- **Quality Control:** Enforces structure with "Assumptions", "Open questions", "Last reviewed"

---

## Configuration Options

### Mode Selection

**Fresh Generation:**
- Creates new documentation from scratch
- Resets existing docs (optional)
- Full codebase analysis

**Maintenance:**
- **Full Codebase Sync:** Comprehensive audit against current code
- **Incremental Update:** Targeted updates based on git changes

### Input Parameters

| Parameter | Purpose | Default |
|-----------|---------|---------|
| Base Doc Path | Root folder for docs | `docs` |
| Focus Area | Keywords to prioritize | `All` |
| OpenAPI Path | Existing OpenAPI file | `Auto-discover` |
| Base Commit | Git hash for change detection | `None` |
| Overwrite Strategy | How to handle existing files | `Ask` |

---

## Document Structure

Every generated document includes:
- Clear purpose and scope
- Key components and responsibilities
- Configuration details
- **Footer (mandatory):**
  - Assumptions made
  - Open questions
  - Last reviewed: YYYY-MM-DD

---

## OpenAPI Generation

**Triggered when:**
1. No OpenAPI file provided/found
2. APIs discovered in repository
3. Repository contains public HTTP endpoints

**Features:**
- OpenAPI 3.0.3 compliant
- Uses `$ref` for schemas
- Meaningful schema names
- Security schemes defined
- No hallucinated endpoints

---

## Prerequisites

- **Git Repository:** Required for maintenance mode
- **Project Rules (Optional):**
  - `.clinerules` file (auto-loaded)
  - OR `docs/AIDOCS_CLINE_RULES.md` (manual load)

---

## Output Example

```
docs/
├── docgen/
│   └── tasks.json           # Generated task manifest
├── features/
│   ├── oauth-integration.md # Feature-specific docs
│   └── push-notifications.md
├── architecture-overview.md  # Standard docs
├── configuration.md
├── api-reference.md
└── openapi.json             # Auto-generated if APIs found
```

---

## Tips for Best Results

1. **Use Focus Area** - Narrow scope for large codebases (e.g., "Authentication")
2. **Leverage JSDoc** - Add code comments for better documentation accuracy
3. **Review tasks.json** - Verify proposed structure before execution
4. **Run Maintenance Regularly** - Keep docs synced (e.g., before releases)
5. **Provide OpenAPI Path** - Use existing spec if available to avoid regeneration

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Missing relationships | Dynamic dependencies may be incomplete - review manually |
| Complex flow | Workflow creates focused sub-flows automatically |
| OpenAPI not generated | Check if public HTTP endpoints exist in repository |

---

## For Full Documentation

See **`project-doc-generation.md`** for:
- Complete workflow phases and logic
- Detailed discovery heuristics
- Anti-hallucination rules
- OpenAPI generation rules
- Maintenance mode details
- Task manifest structure
- Advanced customization options

---

**Last Updated:** 2026-01-26  
**Type:** Cline Markdown Workflow  
**Audience:** Newcomers (onboarding focus)  
**Mode Required:** ACT MODE
