# Repository LLM Context Generation - Quick Start

**Workflow File:** `repo-llms-generation.md`  
**Purpose:** Generate optimized LLM context files for AI-assisted development

---

## Overview

This workflow generates comprehensive context files that help LLMs understand your repository by:
- 📂 Analyzing repository structure and organization
- 🧠 Creating optimized context for AI tools (Cursor, GitHub Copilot, Claude, etc.)
- 🎯 Focusing on relevant code patterns and architecture
- 📝 Generating structured summaries for better AI responses

---

## Quick Start

```
1. Type: /repo-llms-generation.md
2. Workflow analyzes your repository
3. Generates context files automatically
4. Use generated files with your AI tools
```

---

## What It Generates

Typical output structure:
```
.llms/
├── codebase-summary.md       # High-level repository overview
├── architecture.md            # System architecture and patterns
├── key-files.md              # Important files and their purposes
├── dependencies.md           # External and internal dependencies
└── conventions.md            # Coding standards and practices
```

---

## Key Features

- **Smart Analysis:** Identifies important patterns, conventions, and architecture
- **Optimized for LLMs:** Structured format that AI tools can easily understand
- **Focused Context:** Highlights relevant information, filters noise
- **Multiple Formats:** Supports various LLM tools and contexts
- **Incremental Updates:** Can update existing context as code evolves

---

## Use Cases

1. **Onboarding AI Tools:** Help Cursor/Copilot understand your codebase
2. **Code Reviews:** Provide context for AI-assisted reviews
3. **Documentation:** Auto-generate repository understanding
4. **New Developer Onboarding:** Quick codebase orientation
5. **Cross-Project Understanding:** Share context between related projects

---

## Configuration Options

| Option | Purpose | Default |
|--------|---------|---------|
| Output Directory | Where to store context files | `.llms/` |
| Analysis Depth | How deep to analyze | `standard` |
| Include Patterns | File patterns to include | `src/**` |
| Exclude Patterns | File patterns to exclude | `node_modules/`, `build/` |
| Format | Output format | `markdown` |

---

## Prerequisites

- Git repository
- Read access to codebase
- Sufficient disk space for context files

---

## Integration with AI Tools

### Cursor
```
1. Generate context files
2. Open Cursor in repository
3. Cursor automatically reads .llms/ context
4. Enhanced code suggestions and understanding
```

### GitHub Copilot
```
1. Generate context files
2. Reference context in comments
3. Copilot provides better suggestions
```

### Claude/ChatGPT
```
1. Generate context files
2. Upload/paste relevant context files
3. Ask questions about codebase
4. Get informed responses
```

---

## Tips for Best Results

1. **Regular Updates:** Regenerate after major changes
2. **Focus Areas:** Specify important modules for deeper analysis
3. **Exclude Build Artifacts:** Keep context focused on source code
4. **Review Generated Files:** Verify accuracy before sharing
5. **Version Control:** Consider adding `.llms/` to Git for team sharing

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Large context files | Increase exclusion patterns or reduce depth |
| Missing important files | Check include patterns |
| Outdated context | Regenerate after code changes |
| AI tool not using context | Verify file location and format |

---

## For Full Documentation

See **`repo-llms-generation.md`** for:
- Complete workflow logic
- Advanced configuration options
- Custom format templates
- Integration details for specific tools
- Best practices for different project types
- Performance optimization tips

---

**Last Updated:** 2026-01-26  
**Type:** Cline Markdown Workflow  
**Purpose:** LLM Context Generation  
**Mode Required:** ACT MODE
