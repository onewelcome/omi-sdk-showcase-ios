# Unified Documentation Generation Workflow

## 0. Master Orchestration
**Purpose:** Orchestrate the end-to-end documentation generation process by intelligently detecting existing artifacts and routing to the correct phase.


### Workflow Logic

**Action:**
1. **Initialize:** Proceed to **Phase 1: Rules & Bootstrap** to ensure project rules are active.
2. **Mode Detection:**
   - Check if `docs/` directory or `docs/docgen/tasks.json` exists.
   - **If MISSING:** Auto-select **Fresh Generation**.
   - **If FOUND:** Call `ask_followup_question` with the `question` parameter set to:
     "Select mode:
     (1) **Fresh Generation** (Create new docs - Reset)
     (2) **Maintain** (Update docs from code changes)?"
3. **Branch Execution:**
   - **If Fresh Generation:** Proceed to **Phase 2: Discovery & Planning**, then **Phase 3: Execution**.
   - **If Maintain:** Proceed to **Phase 4: Maintenance**.

---

## Phase 1: Rules & Bootstrap (One-Time / Mandatory)
**Workflow Name:** `docgen.rules.bootstrap`

### User Action
Establish project rules.

**Location Strategy:**
1. Check if `.clinerules` file exists in the workspace root.
2. If yes, use `.clinerules` (automatically loaded by Cline).
3. If no, create/use `docs/AIDOCS_CLINE_RULES.md` (must be loaded manually before runs).

### Scope & Audience
- **Audience:** Newcomers (onboarding/ramp-up).
- **Exclude entirely:** SLA, SLO, observability, dashboards, alerts.

### Behavior
- Share/access the entire workspace.
- Do NOT enumerate API endpoints; if relevant, link to OpenAPI spec(s) briefly.
- Use code comments/JSDoc to improve accuracy and small examples (`@param`, `@returns`, `@throws`, `@example`, `@deprecated`).
- Short code excerpts only when clarifying; never include secrets.
- Do NOT invent entities. If unsure, record under “Open questions”.

### Style & Structure
- Concise, scannable, newcomer-focused.
- Prefer tables for configs, env vars, components.
- Use ONE Mermaid diagram only when it improves comprehension.
- Every doc MUST end with:
  - Assumptions made
  - Open questions
  - Last reviewed: YYYY-MM-DD

### OpenAPI Rules
- Target spec: OpenAPI 3.0.3
- Do NOT invent endpoints or parameters
- Prefer $ref schemas over inline objects
- Use meaningful schema names (no Model1, DataDTO)
- Security must be explicitly defined
- No environment-specific URLs
- No business logic in descriptions
- Validate JSON before final output

---

## Phase 2: Discovery & Planning
**Workflow Name:** `docgen.discovery.plan`

### Purpose
Discover real sub-topics from code, then materialize a tasks manifest.

### Required User Inputs (Prompted Interactively)

**Instruction:** Use `ask_followup_question` to collect the following inputs. You should combine these into a single question to minimize round-trips. Ensure the `question` parameter lists the inputs and their defaults clearly.

**Inputs to collect:**
1. **Base Doc path** (Optional)
   - *Description:* Root folder for documentation. Feature docs go into `{Base Doc path}/features/`.
   - *Default:* `docs`

2. **Focus Area** (Optional)
   - *Description:* Keywords to prioritize specific code (e.g., "Security").
   - *Default:* `All` (Scans entire workspace)

3. **OpenAPI Path** (Optional)
   - *Description:* Path to existing Swagger/OpenAPI file. If not provided or not found, the workflow will discover APIs from code and generate openapi.json in `{base_doc_path}/openapi.json`.
   - *Default:* `Auto-discover` (Scans for existing OpenAPI file, generates if missing and APIs are detected)

4. **Base Commit** (Optional)
   - *Description:* Git hash to limit discovery to changes since that commit.
   - *Default:* `None` (Scans current codebase state)

5. **Overwrite Strategy** (Optional)
   - *Description:* Action when a target file already exists.
   - *Options:* `Ask` (Prompt user), `Overwrite` (Replace silently), `Skip` (Keep existing).
   - *Default:* `Ask`

### Workflow Steps
**Step 1 — Evidence Discovery (Automated)**
Cline scans the workspace using heuristics (prioritizing 'focus_area' if provided):
- Architecture & Design (Patterns, Multitenancy, Proposals) → architecture
- Core Features (OAuth/OIDC, Mobile Auth, SAML, Web Hooks, Custom Authenticators) → authentication-security
- Configuration (Properties, Keystore, Logging, Admin UI, config/, .env*) → configuration-policies
- Development (Setup, DB, Tests & fixtures, SDK Flows, Error Handling) → development
- Deployment (Helm Charts, K8s, Environments, Release Process) → deployment-environments
- API Reference (Admin, Mobile, Error Codes, Tenants)  → api-reference, error-model
- Integration Guides (SSO, Third-party integrations) → integration-guide
- Security (Threat Models, Security Controls) → authentication-security
- Domain workflows → domain-workflows
- Feature flags (FF_*) → configuration-policies
- Jobs / workers / schedulers → operational-flows
- Data models & migrations → data-models
- Dev tooling (Makefile, scripts) → development
- JSDoc on exported symbols → reinforce related intent
- **API Endpoints** (if OpenAPI path not provided or not found):
  - Scan controllers, routers, route definitions, annotations, and OpenAPI/Swagger comments
  - Ignore internal, admin-only, or health-check endpoints
  - Identify for each public API:
    - HTTP method (GET, POST, PUT, DELETE, PATCH)
    - Path/route
    - Request model/schema
    - Response model/schema
    - Authentication/authorization mechanism
  - Output ONLY a structured API inventory (no OpenAPI generation yet)
  - **Skip rule**: Only discover APIs if repository contains HTTP endpoints
- ❗ No interpretation yet — evidence is tagged, not summarized.

**Step 2 — Sub-Topic Synthesis (Guarded)**
- **Sub-topics are synthesized only for intents with sufficient evidence.**:
- ***Start with Intent-Aware Defaults (applied per activated intent)***:
1. Purpose & Scope
2. When to Use / When Not to Use
3. Key Components & Responsibilities
4. Configuration / Flow
5. Operational Notes  
- **Expansion**: Add 2–6 new sub-topics (beyond defaults) ONLY if clear evidence exists.
- **Constraints**: Cap total to ~8–10 sections. Merge or rename conservatively.
- **Skip rule**: If an intent has insufficient evidence, no sub-topics are generated.

**Step 3 — Task Manifest Generation (Materialize)**

**File Path Determination Logic:**
1. **Features**: If the document describes a specific functional feature (e.g., OIDC, SAML, FIDO Registration/Reset, Custom Authenticators) OR is not a standard documentation category, set destination to: `{base_doc_path}/features/{topic_slug}.md`.
2. **Standard Docs**: If the document belongs to a standard category (Architecture, Configuration, Development, Deployment, API Reference, Integration Guides, etc.), set destination to: `{base_doc_path}/{topic_slug}.md`.

Write to `docs/docgen/tasks.json` (overwrite):
```json
{
  "config": { "overwrite_strategy": "{overwrite_strategy}" },
  "topic": { "title": "...", "path": "..." },
  "outline": [
    { "title": "...", "purpose": "...", "reader_outcomes": "..." }
  ],
  "tasks": [
    {
      "id": "architecture-overview",
      "title": "Architecture Overview",
      "intent": "architecture-overview",
      "write": { "mode": "write_file", "destination": "{base_doc_path}/architecture-overview.md", "subheading": "Architecture Overview" },
      "audience": "newcomers",
      "depth": { "min_words": 600, "min_tables": 1, "require_diagram": true, "min_examples": 1 },
      "required_sections": [ "Purpose & Scope",
        "Key Components",
        "Security Flow",
        "Operational Notes"],
      "use_jsdoc": true
    }
  ],
  "links": { "openapi": [] },
  "assumptions": [],
  "open_questions": []
}
```

---

## Phase 3: Execution
**Workflow Name:** `docgen.execute`

### Input
`docs/docgen/tasks.json`

### Responsibilities
- Deterministic writing.
- Anti-hallucination enforcement.
- Controlled file I/O.
- Quality & Tone Control.

### Rules
- **Respect Task Mode**: Follow `write.mode` (`append`, `overwrite`, or `write_file`) defined in `tasks.json`.
- **Summarize behavior**: Focus on high-level logic and data flow; do not just transliterate code to text.
- **Adjust tone**:
  - Audience 'newcomers': Educational, explain 'why', avoiding dense jargon.
  - Audience 'devs/ops': Technical, concise, focus on config, constraints, and edge cases.
- **Contextualization**: Link to relevant architecture or feature flags discovered in the planning phase.

### Step 1 — Pre-Generation Check (Mandatory)
Before generating any document:
1. **Check Existence:**
   - Check if the target file already exists.
   - **Nearby Name Check**: If target does not exist, check for existing files with similar names (fuzzy match) in the destination directory to avoid duplication.
2. **Apply Strategy:**
   - **If Exact File Exists**: Check `config.overwrite_strategy` from `tasks.json`.
     - **If 'Overwrite':** Proceed to overwrite immediately.
     - **If 'Skip':** Log "Skipped (Strategy)" and exit task.
     - **If 'Ask' (or undefined):** Call `ask_followup_question`: "File `[filename]` exists. Action? (1) **Override** (Replace), (2) **Update** (Merge), (3) **Ignore** (Skip)?"
   - **If Similar File Found**:
     - Call `ask_followup_question`: "Target `[filename]` not found, but similar file `[existing_filename]` exists. Action? (1) **Overwrite Existing** (Use `[existing_filename]`), (2) **Create New** (Create `[filename]`), (3) **Update Existing** (Merge into `[existing_filename]`), (4) **Ignore** (Skip)?"
     - *Note*: If 'Overwrite Existing' or 'Update Existing' is selected, update the task's destination path to the existing file.
   - **If No Match**: Proceed to Create New.
3. **Action:**
   - **Override/Overwrite:** Proceed to overwrite the file.
   - **Update:** Switch to **Phase 4: Maintenance** logic for this specific file.
   - **Ignore:** Skip this task.
   - **Create New:** Proceed with generation.

### Step 2 — Generation & Verification
For each task:
1. **Generate Content**:
   - Meet `depth` constraints (min_words, min_tables, min_examples).
   - Use `required_sections` in order.
   - Use JSDoc/comments for accuracy.
2. **Entity Verification (Anti-Hallucination)**:
   - **Verify**: Remove any env var, flag, or component name not found in the workspace.
   - **Log**: Add unverified items to **Open questions**.

### Step 3 — File I/O & Footer
1. **Write**: Execute the write operation (append or overwrite) as per task mode.
2. **Footer**: Ensure the doc ends with:
   - "Assumptions made"
   - "Open questions"
   - "Last reviewed: YYYY-MM-DD"
3. **Log**: Output `[task.id] OK → {destination}`.

### Step 4 — OpenAPI Generation (Conditional)
**Trigger**: Execute only if ALL of the following conditions are met:
1. No OpenAPI file was provided or found during Phase 2
2. API endpoints were discovered in the repository (API inventory exists from Phase 2)
3. The repository contains public HTTP endpoints

**Action**:
Using the discovered API inventory from Phase 2, generate an OpenAPI 3.0.3 specification.

**Generation Rules**:
- Create openapi.json at `{base_doc_path}/openapi.json`
- Do NOT invent endpoints, parameters, or fields beyond what was discovered
- Use $ref for all schemas (avoid inline object definitions)
- Use meaningful schema names based on actual model/class names (e.g., UserProfile, AuthRequest)
- Use generic, placeholder server URLs (e.g., `https://api.example.com` or `https://{environment}.example.com`)
- Define security schemes explicitly:
  - OAuth2 (with flows: authorizationCode, clientCredentials, etc.)
  - Bearer token
  - API Key
  - Basic Auth
- Keep endpoint descriptions concise and factual (extracted from code comments/JSDoc)
- Include discovered request/response schemas with proper types
- Validate JSON structure before writing to ensure valid OpenAPI 3.0.3 format
- Include only public endpoints (exclude internal, admin, health-check routes)

**Anti-Hallucination Controls**:
- Cross-reference all endpoints against discovered code artifacts
- Verify all schema fields exist in actual request/response models
- Add unverifiable endpoints or fields to **Open questions** instead of including them
- Log any assumptions made during schema inference

**Output**: 
- Write the validated OpenAPI JSON to `{base_doc_path}/openapi.json`
- Log: `OpenAPI generated → {base_doc_path}/openapi.json`
- Update `tasks.json` with `"links": { "openapi": ["{base_doc_path}/openapi.json"] }`

**Skip Logging**: If no APIs were discovered or conditions not met, log: `OpenAPI generation skipped (no public APIs discovered)`.

---

## Phase 4: Maintenance
<!-- Purpose: WF-4 (Maintain): Focuses on Synchronization. Its goal is to keep the documentation technically accurate and up-to-date with the latest code state (updating env vars, flags, components). -->
**Workflow Name:** `docgen.maintain`

### Purpose
Automatically update existing docs based on code changes or full codebase analysis.

### Mode Selection (Interactive)

**Instruction:** Use `ask_followup_question` to collect the maintenance mode selection.

**Question:**
"Select maintenance mode:
(1) **Full Codebase Sync** - Analyze entire current codebase and update all docs to reflect the current code state (comprehensive, slower, catches all drift)
(2) **Incremental Update** - Update docs based on code changes since base branch (targeted, faster, focused on recent changes)"

### Required / Optional Inputs
- `maintenance_mode`: full-sync | incremental (collected via prompt above)
- `base_commit` (optional, only for incremental mode)
- `output_mode`: write | dry-run (default: write)

---

## Maintenance Mode A: Full Codebase Sync

**Use Case:** Periodic documentation audits, unknown drift, ensuring complete accuracy against current code.

### Workflow Phases

1. **Current State Discovery**:
   - Scan the entire workspace (similar to Phase 2 discovery):
     - env vars (`.env*`, `config/`, docker/k8s/helm values)
     - feature flags (`FF_*`)
     - components (`src/**`, `services/**`)
     - jobs/queues/schedules (`jobs/`, `workers/`, CRON)
     - data model & migrations
     - dev scripts (`Makefile`, `package.json`)
     - API endpoints (controllers, routers)
     - tests
   - **Context Gathering**: Pull supporting context from code comments/JSDoc (`@summary`, `@param`, `@returns`, etc.).

2. **Documentation Inventory**:
   - Identify all existing documentation files in `docs/` directory.
   - Extract documented entities from existing docs (env vars, flags, components, APIs, etc.).

3. **Gap Analysis**:
   - **Compare**: Current codebase entities vs. documented entities.
   - **Identify**:
     - **Missing in docs**: New entities in code not documented.
     - **Outdated in docs**: Entities documented but no longer in code or changed.
     - **Mismatched**: Entities with different values/descriptions.
   - **Output**: Gap report per document.

4. **Doc Target Resolution**:
   - Match gaps to existing documentation files using heuristics:
     - Filename/heading similarity (e.g., "Configuration", "Key Components").
     - Service/package name matching.
     - Entity type matching (env vars → configuration docs, components → architecture docs).
   - **Fallback**: If no suitable doc exists, propose a new file based on existing docs structure.

5. **Surgical Updates**:
   - Update only the sections with gaps/drift.
   - **Content Guidelines**:
     - Add missing entities with descriptions inferred from code/comments.
     - Mark deprecated/removed entities with strikethrough or removal.
     - Update changed entities with current values/descriptions.
     - Tables for configs, env vars (added/removed/changed columns).
     - Tiny code excerpts only if clarifying (no secrets).
     - Update ONE Mermaid diagram if architecture/flow changed.
     - **Constraint**: Do NOT invent entities; if unverified, add to "Open questions".
   - **Footer**: Ensure each touched doc ends with updated "Assumptions made", "Open questions", and "Last reviewed: YYYY-MM-DD".

6. **Write or Preview**:
   - If `output_mode=dry-run`: Output preview of changes per file without writing.
   - If `output_mode=write`: Apply edits and write files.

### Summary Output
- **Docs touched**: List path + sections updated.
- **Gap Analysis**: 
  - Missing: X entities (list names)
  - Outdated: Y entities (list names)
  - Updated: Z entities (list names)
- **Notes**: OpenAPI referenced if paths changed.

---

## Maintenance Mode B: Incremental Update

**Use Case:** Active development, known changes, targeted updates based on recent code modifications.

### Workflow Phases

1. **Base Commit Resolution**: Auto-detect merge base.
   - Run: `git fetch --all --prune`
   - Logic:
     - If `refs/remote/origin/master` exists: `BASE=$(git merge-base HEAD origin/master)`
     - Else if `refs/remote/origin/main` exists: `BASE=$(git merge-base HEAD origin/main)`
     - Else if `base_commit` provided: `BASE={base_commit}`
     - Else: Ask ONE blocking question for the base hash.

2. **Change Signal Extraction**:
   - Run: `git --no-pager diff --name-status $BASE...HEAD` and `git --no-pager diff --unified=0 $BASE...HEAD`
   - **Extract Changed Entities** (Names only, no secrets):
     - env vars (`.env*`, `config/`, docker/k8s/helm values)
     - feature flags (`FF_*`)
     - components (`src/**`, `services/**`)
     - jobs/queues/schedules (`jobs/`, `workers/`, CRON)
     - data model & migrations
     - dev scripts (`Makefile`, `package.json`)
     - tests
   - **Context Gathering**: Pull supporting context from code comments/JSDoc (`@summary`, `@param`, `@returns`, etc.) where present.

3. **Doc Target Resolution**: Match changes → existing docs.
   - **Heuristics**:
     - Filename/heading similarity (e.g., "Key Components", "Configuration").
     - Nearest package/service name (infer topic file as `docs/topics/{service}.md` Or `docs/{service}.md` Or `docs/*` ).
     - Terms in existing docs that reference the changed entity names.
   - **Fallback**: If no suitable doc exists, propose a new topic/features file based on current docs location (infer topic file as `docs/topics/{service}.md` Or `docs/{service}.md` Or not exist use `docs/`).

4. **Surgical Updates**: Edit existing sections only.
   - **Content Guidelines**:
     - Bullet list of changes and their impact.
     - Tables where helpful (e.g., env vars added/removed).
     - Tiny code excerpts only if clarifying (no secrets).
     - Update ONE Mermaid diagram if flow changed.
     - **Constraint**: Do NOT invent entities; if unverified, add to "Open questions".
   - **Footer**: Ensure each touched doc ends with updated "Assumptions made", "Open questions", and "Last reviewed: YYYY-MM-DD".

5. **Write or Preview**:
   - If `output_mode=dry-run`: Output a preview diff per file (unified patch) without writing.
   - If `output_mode=write`: Apply edits and write the files.

### Summary Output
- **Docs touched**: List path + sections updated.
- **Entities Changed**: Env vars (added/removed/renamed), Flags, Components.
- **Git Range**: `$BASE...HEAD` (X commits)
- **Notes**: OpenAPI referenced if paths changed.
