# Repository-Specific LLM Generation Workflow

## Purpose
Generate a lean, AI-friendly `llms.txt` index file for a code repository that enables efficient navigation and discovery of documentation without containing the documentation itself.

---

## Phase 0: Guidelines & Principles

### Embedded Guidelines Reference

The `llms.txt` file must adhere to these core principles:

#### Key Principles
1. **Index, Not Documentation**: The file is a table of contents, not a content repository
2. **Lean & Focused**: Brief descriptions with links to actual documentation files
3. **Modular Documentation**: Link to multiple topic-specific files rather than monolithic documents
4. **Quick Lookup**: Organized structure for efficient AI navigation

#### File Specifications
- **Location**: Repository root as `llms.txt`
- **Format**: Markdown
- **Size Target**: Keep under 500 lines; link to external docs for comprehensive content

#### Content Rules
✅ **DO Include:**
- Repository name and brief purpose
- Technology stack summary
- Organized documentation index
- API specification links
- Critical setup/configuration info
- External resource links (Confluence, etc.)

❌ **DO NOT Include:**
- Full README content (link to it instead)
- Complete documentation inline (use references)
- Auto-generated content (link to generation source)
- Extensive code examples (link to example files)
- Credentials or secrets
- Change logs (link to CHANGELOG.md)

#### Link Format
Use relative paths for repository files:
```markdown
- [Setup Guide](docs/setup.md) - Brief description of content
- [API Reference](docs/api/reference.md) - What you'll find here
```

---

## Phase 1: Initialization & Discovery

### Step 1.1 — Repository Context Detection
**Purpose**: Understand the repository structure and type.

**Action:**
1. **Scan Repository Root**:
   - Check for `README.md`, `package.json`, `pom.xml`, `setup.py`, `Cargo.toml`, `go.mod`, etc.
   - Identify primary programming language and framework
   - Detect repository type indicators:
     - **Microservice**: Kubernetes manifests, Helm charts, Dockerfile, service configurations
     - **Library**: Package metadata (npm, Maven, PyPI), no deployment configs
     - **UI Application**: Frontend frameworks (React, Angular, Vue), build tools
     - **Infrastructure**: Terraform files, CloudFormation, Ansible playbooks

2. **Technology Stack Detection**:
   - Extract primary language(s)
   - Identify frameworks (Spring Boot, Express, Flask, etc.)
   - Detect infrastructure tools (K8s, Docker, Helm)
   - Note database systems (PostgreSQL, MongoDB, etc.)

3. **Repository Name & Purpose**:
   - Extract repository name from `.git/config` or workspace name
   - Read first paragraph of README.md for project description (if exists)

**Output**: Repository profile with type, tech stack, and purpose.

---

### Step 1.2 — Documentation Discovery
**Purpose**: Locate existing documentation structure.

**Action:**
1. **Check for Documentation Directory**:
   - Look for `docs/`, `documentation/`, `wiki/`, `.ai/` directories
   - If found, set `{doc_path}` to discovered path
   - If multiple found, prioritize: `docs/` > `.ai/` > `documentation/` > `wiki/`

2. **Scan for Key Documentation Files**:
   - README.md
   - CONTRIBUTING.md
   - CHANGELOG.md
   - LICENSE
   - OpenAPI/Swagger files (`openapi.json`, `openapi.yaml`, `swagger.json`, `swagger.yaml`)
   - Architecture docs (`docs/architecture/`, `docs/design/`)
   - API docs (`docs/api/`, `docs/api-reference/`)
   - Development guides (`docs/development/`, `docs/dev/`)
   - Deployment docs (`docs/deployment/`, `docs/deploy/`)

3. **External Resources Detection**:
   - Scan for references to Confluence, Backstage, Jira, monitoring dashboards
   - Check README.md, CONTRIBUTING.md, and .ai/ files for external links
   - Look for CI/CD pipeline references (GitHub Actions, GitLab CI, Jenkins)

**Output**: 
- Documentation path (`{doc_path}`)
- List of discovered documentation files
- External resource URLs

---

## Phase 2: Documentation Prerequisite Check

### Step 2.1 — Validate Documentation Exists
**Purpose**: Ensure documentation is available before creating index.

**Action:**
1. **Check Documentation Completeness**:
   - Verify `{doc_path}` directory exists and contains markdown files
   - Count markdown files in documentation directory (excluding README.md at root)
   - **Threshold**: Minimum 3 markdown files required for meaningful index

2. **Apply Prerequisites**:
   - **If Documentation Insufficient** (< 3 markdown files):
     ```
     ⚠️ Documentation is missing or incomplete.
     
     The llms.txt file requires existing documentation to index.
     
     Action Required:
     1. Run the docGen-workflow.md to generate comprehensive documentation
     2. Once documentation generation is complete, re-run this workflow
     
     Would you like to:
     (1) Exit and run docGen-workflow.md first
     (2) Continue anyway (creates minimal llms.txt)
     ```
     - Use `ask_followup_question` with options above
     - If option (1): Exit workflow with instructions
     - If option (2): Continue with warning flag

   - **If Documentation Exists**: Proceed to Phase 3

**Output**: Validation status and decision to proceed or exit.

---

## Phase 3: User Configuration

### Step 3.1 — Gather User Inputs
**Purpose**: Collect configuration for llms.txt generation.

**Action:**
Use `ask_followup_question` to collect the following inputs in a single question:

**Question:**
```
Configure llms.txt generation:

1. **Repository Type** (Auto-detected: {detected_type})
   - Options: Microservice, Library, UI Application, Infrastructure, Other
   - Default: {detected_type}

2. **Documentation Path** 
   - Default: {discovered_path or "docs"}

3. **Project Summary** (Brief 1-2 sentence description)
   - Auto-extracted from README: "{extracted_summary}"
   - You can edit or use as-is

4. **External Resources** (Optional)
   - Confluence links, Backstage URLs, monitoring dashboards
   - Format: URL|Description, URL|Description
   - Example: https://confluence.company.com/page|Architecture Docs

5. **Overwrite Strategy** (if llms.txt exists)
   - Options: Ask, Overwrite, Merge, Skip
   - Default: Ask

Please provide your configuration (use defaults by pressing Enter):
```

**Inputs:**
- `repository_type`: Microservice | Library | UI Application | Infrastructure | Other
- `doc_path`: Path to documentation directory (default: "docs")
- `project_summary`: Brief description (auto-extracted from README)
- `external_resources`: Optional list of external links
- `overwrite_strategy`: Ask | Overwrite | Merge | Skip

**Output**: User configuration object.

---

## Phase 4: Content Generation

### Step 4.1 — Pre-Generation Check
**Purpose**: Handle existing llms.txt file.

**Action:**
1. **Check Existence**: Look for `llms.txt` in repository root
2. **Apply Strategy**:
   - **If file exists**:
     - If `overwrite_strategy == "Skip"`: Exit workflow with message
     - If `overwrite_strategy == "Overwrite"`: Proceed to overwrite
     - If `overwrite_strategy == "Merge"`: Read existing, merge with new content
     - If `overwrite_strategy == "Ask"`: Prompt user with `ask_followup_question`:
       ```
       llms.txt already exists in repository root.
       
       Action?
       (1) Overwrite - Replace with newly generated content
       (2) Merge - Combine existing with new discoveries
       (3) Skip - Keep existing file unchanged
       ```
   - **If file does not exist**: Proceed to Step 4.2

**Output**: Decision to proceed, skip, overwrite, or merge.

---

### Step 4.2 — Generate Repository Header
**Purpose**: Create project summary section.

**Action:**
Generate the header section:

```markdown
# {Repository Name}

> {Project Summary from config or README}

## Project Summary
{Expanded description including:}
- Core purpose/functionality: {from README or user input}
- Primary technology stack: {detected languages and frameworks}
- Architecture type: {repository_type from config}
- Key integrations: {detected dependencies or services}
```

**Anti-Hallucination Controls**:
- Use only discovered information from repository scan
- Do NOT invent features or capabilities not evidenced in code/docs
- Mark uncertain information with "Note: Verify this information"

**Output**: Header section string.

---

### Step 4.3 — Generate Documentation Index
**Purpose**: Create organized index of documentation files.

**Action:**
1. **Categorize Documentation Files**:
   - Map discovered files to standard categories:
     - **Getting Started**: README.md, setup guides, quickstart
     - **Architecture & Design**: architecture/, design/, proposals/
     - **Development**: development/, testing/, debugging/, contributing
     - **Deployment**: deployment/, kubernetes/, helm/, ci-cd/
     - **API Reference**: api/, api-reference/, endpoints/
     - **Integration Guides**: integration/, integrations/
     - **Configuration**: configuration/, config/, properties/
     - **Features**: features/, specific functionality docs

2. **Generate Documentation Sections**:
   For each category with discovered files:
   ```markdown
   ### {Category Name}
   - [{File Title}]({relative_path}) - {Brief description from first heading or 5-10 word summary}
   ```

3. **Description Generation Rules**:
   - Read first 2-3 lines of each markdown file
   - Extract purpose from first heading or paragraph
   - Create 5-10 word description
   - Do NOT invent content not present in file
   - If unclear, use generic description: "Documentation for {topic}"

4. **Link Validation**:
   - Verify each file path exists before including
   - Use relative paths from repository root
   - Skip broken or missing files
   - Log skipped files for user review

**Template Selection by Repository Type**:

**Microservice Template Structure:**
```markdown
## Documentation

### Getting Started
- Links to README, setup, prerequisites

### Architecture & Design
- Links to architecture, data models, integrations

### Development
- Links to build, testing, debugging

### Deployment
- Links to Kubernetes, Helm, environments

### API Reference
- Links to API docs, endpoints, specifications

### Configuration
- Links to properties, environment variables
```

**Library Template Structure:**
```markdown
## Documentation

### Getting Started
- Links to README, installation, quickstart

### API Reference
- Links to API documentation, method references

### Development
- Links to contribution guide, testing, examples

### Integration Examples
- Links to example projects, tutorials
```

**UI Application Template Structure:**
```markdown
## Documentation

### Getting Started
- Links to README, development setup

### Development
- Links to component guide, state management, styling

### Deployment
- Links to build process, deployment guides

### Testing
- Links to unit tests, E2E tests
```

**Infrastructure Template Structure:**
```markdown
## Documentation

### Getting Started
- Links to README, prerequisites

### Architecture
- Links to infrastructure design, modules

### Deployment
- Links to deployment procedures, environments

### Troubleshooting
- Links to common issues, debugging
```

**Output**: Documentation index section string.

---

### Step 4.4 — Generate API Specifications Section
**Purpose**: Link to API definition files.

**Action:**
1. **Scan for API Specification Files**:
   - Look for: `openapi.json`, `openapi.yaml`, `swagger.json`, `swagger.yaml`
   - Check locations: root, `docs/`, `api/`, `spec/`

2. **Generate Section** (if API specs found):
   ```markdown
   ## API Specifications
   - OpenAPI/Swagger: [{filename}]({relative_path})
   ```

3. **Skip if Not Found**: Do not create this section if no API specs exist

**Output**: API specifications section string (or empty if not applicable).

---

### Step 4.5 — Generate External Resources Section
**Purpose**: Link to external documentation.

**Action:**
1. **Compile External Resources**:
   - Use user-provided external resources from config
   - Add discovered external links from README/docs
   - Validate URL format (basic check)

2. **Generate Section** (if external resources exist):
   ```markdown
   ## External Resources
   - [{Description}]({URL})
   - [{Description}]({URL})
   ```

3. **Skip if None**: Do not create this section if no external resources

**Output**: External resources section string (or empty if not applicable).

---

### Step 4.6 — Generate Module Documentation Section (Optional)
**Purpose**: Link to module-specific documentation.

**Action:**
1. **Detect Modules**:
   - Check for monorepo structure (multiple subdirectories with own README.md)
   - Scan for: `packages/`, `modules/`, `services/`, `apps/`
   - Identify module names from directory structure

2. **Generate Section** (if modules found):
   ```markdown
   ## Module Documentation
   - [{Module Name}]({module_path}/README.md) - {Brief module purpose}
   ```

3. **Skip if Not Applicable**: Omit for single-module repositories

**Output**: Module documentation section string (or empty if not applicable).

---

### Step 4.7 — Assemble Complete llms.txt
**Purpose**: Combine all sections into final file.

**Action:**
1. **Assemble Sections**:
   - Combine header, documentation index, API specs, external resources, modules
   - Ensure proper markdown formatting
   - Add blank lines between sections

2. **Size Validation**:
   - Count lines in assembled content
   - **If > 500 lines**:
     - Trim least important sections (modules, external resources)
     - Consolidate documentation categories
     - Use more concise descriptions
     - If still > 500 lines, warn user and ask to review

3. **Final Quality Checks**:
   - Verify markdown syntax
   - Ensure all internal links are relative paths
   - Check no duplicate sections
   - Validate no secrets or credentials included

**Output**: Complete llms.txt content string.

---

## Phase 5: File Writing & Validation

### Step 5.1 — Write llms.txt to Repository Root
**Purpose**: Create or update the llms.txt file.

**Action:**
1. **Determine Write Mode**:
   - If `overwrite_strategy == "Overwrite"` or new file: Use `write_to_file`
   - If `overwrite_strategy == "Merge"`: Read existing, combine content, use `replace_in_file`

2. **Write File**:
   - Write to: `{repository_root}/llms.txt`
   - Use absolute path for file writing

3. **Log Operation**:
   ```
   ✅ llms.txt generated → {repository_root}/llms.txt
   - Total lines: {line_count}
   - Documentation files indexed: {file_count}
   - Categories: {category_count}
   ```

**Output**: File written successfully.

---

### Step 5.2 — Post-Generation Validation
**Purpose**: Verify quality and completeness.

**Action:**
1. **Validation Checks**:
   - Confirm file exists at repository root
   - Verify file size is appropriate (< 500 lines ideal)
   - Check all links point to existing files (sample check)

2. **Generate Validation Report**:
   ```
   📊 Validation Report:
   - File size: {line_count} lines (Target: < 500)
   - Documentation files linked: {file_count}
   - External resources: {external_count}
   - Broken links detected: {broken_count}
   ```

3. **If Issues Detected**:
   - List broken links for user to fix
   - Suggest optimizations if file too large
   - Recommend missing documentation categories

**Output**: Validation report.

---

## Phase 6: Summary & Next Steps

### Step 6.1 — Present Summary
**Purpose**: Inform user of completion and provide guidance.

**Action:**
Generate completion summary:

```
✅ Repository-Specific LLM Index Generated Successfully

📁 Output File: {repository_root}/llms.txt

📊 Summary:
- Repository Type: {repository_type}
- Documentation Path: {doc_path}
- Files Indexed: {file_count}
- Categories: {category_list}
- Total Lines: {line_count}

🔍 Key Sections:
{list_of_major_sections}

📝 Next Steps:
1. Review llms.txt for accuracy
2. Verify all links are correct
3. Add any missing external resources manually
4. Commit llms.txt to version control
5. Update when documentation structure changes

💡 Maintenance Tips:
- Update llms.txt when adding new major documentation
- Review quarterly or during major releases
- Keep descriptions concise (5-10 words)
- Maintain relative paths for portability

🤖 AI Assistant Usage:
AI assistants will now be able to:
- Quickly discover repository documentation structure
- Navigate to specific documentation efficiently
- Understand project architecture and tech stack
- Access API specifications and external resources
```

**Output**: Summary presented to user.

---

## Appendix: Templates

### Microservice Template (Full Example)
```markdown
# [Service Name]

> Multi-tenant microservice for [brief purpose]

## Project Summary
[Purpose], built with [tech stack], deployed on [platform]. Provides [key capabilities].

## Documentation

### Getting Started
- [README.md](README.md) - Project overview and quick start
- [Local Setup](docs/setup.md) - Development environment setup

### Architecture & Design
- [Service Architecture](docs/architecture.md) - System design and components
- [Database Schema](docs/database.md) - Data models and relationships

### Development
- [Building](docs/build.md) - Build and compilation process
- [Testing](docs/testing.md) - Unit and integration testing

### Deployment
- [Kubernetes](docs/kubernetes.md) - K8s deployment configuration
- [Environments](docs/environments.md) - Environment-specific settings

## API Specifications
- [OpenAPI Spec](openapi.json) - Complete API reference

## Important Notes
- **Stack**: [key technologies]
- **Local URL**: http://localhost:[port]/[path]
- **Authentication**: [auth method]
```

### Library Template (Full Example)
```markdown
# [Library Name]

> [Type] library for [purpose]

## Project Summary
Provides [capabilities] for [use case]. Built with [tech stack].

## Documentation
- [README.md](README.md) - Overview and installation
- [Getting Started](docs/getting-started.md) - First steps and examples
- [API Reference](docs/api-reference.md) - Complete API documentation
- [Examples](docs/examples.md) - Usage examples and tutorials
- [Migration Guide](docs/migration.md) - Upgrading between versions

## Important Notes
- **Languages**: [supported languages]
- **Latest Version**: [version]
- **Package Manager**: [npm/maven/pip coordinates]
```

### UI Application Template (Full Example)
```markdown
# [UI App Name]

> [Framework] application for [purpose]

## Project Summary
[Description], built with [framework/libraries].

## Documentation

### Getting Started
- [README.md](README.md) - Project overview
- [Development Setup](docs/setup.md) - Local development environment

### Development
- [Component Guide](docs/components.md) - UI component library
- [State Management](docs/state.md) - State management patterns
- [Styling Guide](docs/styling.md) - CSS/styling conventions

### Deployment
- [Build Process](docs/build.md) - Production build configuration
- [Deployment](docs/deployment.md) - Deployment procedures

## Important Notes
- **Stack**: [framework, libraries]
- **Dev Server**: http://localhost:[port]
```

### Infrastructure Template (Full Example)
```markdown
# [Infrastructure Project]

> Infrastructure as code for [purpose]

## Documentation
- [README.md](README.md) - Project overview
- [Architecture](docs/architecture.md) - Infrastructure design
- [Terraform Modules](docs/modules.md) - Reusable modules
- [Deployment Guide](docs/deployment.md) - Deployment procedures
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions

## Important Notes
- **Provider**: [AWS/GCP/Azure]
- **Managed Resources**: [key resources]
- **Terraform Version**: [version]
```

---

## Anti-Hallucination Controls

Throughout the workflow, enforce these controls:

1. **Verification-First Approach**:
   - Only include files/links that exist in the repository
   - Verify paths before adding to llms.txt
   - Remove any unverified references

2. **Evidence-Based Descriptions**:
   - Extract descriptions from actual file content
   - Do not invent features or capabilities
   - Use generic descriptions if file content unclear

3. **Conservative Technology Detection**:
   - Only list technologies evidenced in code/configs
   - Do not assume frameworks without proof
   - Mark uncertain detections as "Detected: Verify"

4. **Link Validation**:
   - Test all internal links exist
   - Flag broken links for user review
   - Do not include speculative documentation paths

5. **Size Constraints**:
   - Enforce 500-line limit
   - Trim verbose descriptions
   - Link to content rather than including it

---

## Maintenance Guidelines

### When to Update llms.txt
- New major documentation files added
- Documentation structure changes significantly
- API specifications updated
- Key external resources change URLs
- Project architecture evolves

### Review Frequency
- Review quarterly or during major releases
- Update after significant refactoring
- Validate links are current

### Version Control
- Commit llms.txt with descriptive messages
- Review in PRs when documentation structure changes
- Keep synchronized with actual documentation
