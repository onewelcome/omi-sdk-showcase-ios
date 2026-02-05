# YAML and JSON code generation rules

Each rule has a unique code. See [common-rules.md](common-rules.md) for baseline rules that apply across all languages. Use those Common
rules first, then apply the YAML and JSON common rules below, and finally the language-specific rules. If a language-specific rule conflicts
with a common rule, the language-specific rule takes precedence.

## Usage guidance for Cline Assistant

* When generating new YAML or JSON files, format and structure output to comply with Common rules (see [common-rules.md](common-rules.md)),
  YAML and JSON common rules, and the relevant language section below (YAML or JSON).
* Ensure proper indentation, spacing, and structure per the language rules.
* Validate that generated files conform to YAML 1.2 or JSON specifications.
* For configuration files, prefer YAML for human readability; prefer JSON for machine-to-machine communication or when strict parsing is
  required.

## YAML and JSON common rules

These rules apply to both YAML and JSON. The Language-specific sections below may provide extensions or overrides.

### Common formatting rules

* YAJS-001 Indentation: Use 2 spaces for indentation; never use tabs; maintain consistent indentation throughout the document.
* YAJS-002 Line length: Target a maximum line length of 140 characters.
* YAJS-003 Key-value spacing: Do not add a space before colons; add one space after colons in key-value pairs.
* YAJS-004 Property alignment: Do not align property values in columns; keep natural spacing for better diff readability.
* YAJS-005 Empty line indentation: Do not keep indents on empty lines.
* YAJS-006 Null values: Use lowercase `null` for null values; omit keys/properties with null values when the schema allows optional
  fields.
* YAJS-007 Boolean values: Use lowercase `true` and `false` for boolean values.
* YAJS-008 Trailing commas: Do not use trailing commas; neither YAML nor JSON specifications support them.

### Common naming conventions

* YAJS-NC-001 File names: Use lowercase with hyphens for file names (e.g., `config.yaml`, `config.json`).
* YAJS-NC-002 Boolean naming: Prefix boolean keys/properties with `is`, `has`, `enable`, or similar when it improves clarity; be
  consistent within the project.
* YAJS-NC-003 Environment-specific files: Use suffixes to indicate environment (e.g., `config-dev.yaml`, `config-prod.json`).

### Common code quality rules

* YAJS-CQ-001 Schema validation: Validate against schemas when available; use schema validation tools to catch errors early and provide
  documentation.
* YAJS-CQ-002 Avoid deep nesting: Limit nesting depth to 4-5 levels; deeply nested structures are hard to read and maintain; consider
  restructuring when nesting becomes excessive.
* YAJS-CQ-003 Sensitive data: Do not hardcode sensitive information (passwords, API keys, tokens) in configuration files; use
  environment variables, secret management systems, or encrypted values; clearly mark where sensitive values should be injected.
* YAJS-CQ-004 File size: Keep configuration files reasonably sized; large files are hard to maintain and may cause performance issues;
  split large configurations into multiple files when appropriate.

## YAML-specific rules

These rules apply only to YAML. They extend or override the common rules above.

### YAML formatting rules

* YAML-001 Style baseline: Follow YAML 1.2 specification; prefer readable, human-friendly formatting.
* YAML-002 Continuation indent: Use 4 spaces for continuation indent when needed (extends YAJS-001).
* YAML-003 Line length handling: Break long values using YAML multiline string syntax (literal `|` or folded `>`) when appropriate (extends
  YAJS-002).
* YAML-004 Sequence formatting: Do not place sequence items on a new line after the parent key; use an inline format for short sequences;
  auto-insert sequence marker (`-`) when adding items.
* YAML-005 Mapping formatting: Do not place mapping on a new line after the parent key for single-line mappings; use block style for
  multi-property objects.
* YAML-006 Sequence value indentation: Indent sequence values relative to the sequence marker; maintain consistent indentation for nested
  structures.
* YAML-007 Comments: Do not auto-add a space after comment markers (`#`) on reformat; allow comments to start at the first column; preserve
  line breaks and existing comment formatting.
* YAML-008 Collection literals: Use spaces within flow-style braces and brackets (e.g., `{ key: value }` and `[ item1, item2 ]`); prefer
  block style for complex structures.
* YAML-009 Blank lines: Keep line breaks as written; use blank lines to separate logical sections (extends YAJS-005).
* YAML-010 Quotes: Use quotes only when necessary (for special characters, leading/trailing spaces, or type preservation); prefer double
  quotes when quoting is needed; avoid unnecessary quoting of simple strings and numbers.
* YAML-011 Anchors and aliases: Use anchors (`&anchor`) and aliases (`*anchor`) for repeated structures to maintain DRY principle; place
  anchor definitions before their first use.
* YAML-012 Multiline strings: Use literal block scalar (`|`) for multiline strings where line breaks should be preserved; use folded block
  scalar (`>`) for long text that should be wrapped; choose `|-` or `>-` to strip final newline when appropriate.
* YAML-013 Null values: Prefer explicit `null` over tilde (`~`) or empty values for clarity (extends YAJS-006).
* YAML-014 Boolean values: Avoid alternative representations (`yes`, `no`, `on`, `off`) for consistency and clarity (extends YAJS-007).
* YAML-015 Document markers: Use document start marker (`---`) for multi-document files; omit document start marker for single-document
  files unless required by the tool or convention; use document end marker (`...`) only when necessary.
* YAML-016 Trailing commas: Ensure no trailing commas in flow-style collections (extends YAJS-008).
* YAML-017 Complex keys: Avoid complex keys (keys that are not simple strings); use explicit mappings when keys must be complex; prefer
  restructuring data to use simple string keys.
* YAML-018 Type tags: Avoid explicit type tags (e.g., `!!str`, `!!int`) unless absolutely necessary; rely on YAML's implicit type
  inference.

### YAML naming conventions

* YAMLNC-001 File extensions: Prefer `.yaml` extension over `.yml` for consistency, unless project conventions dictate otherwise (extends
  YAJS-NC-001).
* YAMLNC-002 Keys: Use snake_case for configuration keys (e.g., `database_host`, `max_connections`); be consistent within a file or project;
  for Kubernetes and similar tools, follow the tool's convention (often camelCase or kebab-case).
* YAMLNC-003 Boolean keys: Use snake_case with prefixes (e.g., `is_active`, `enable_logging`) (extends YAJS-NC-002).
* YAMLNC-004 Nested structure: Use clear, hierarchical key names; avoid overly deep nesting (limit to 4-5 levels); consider flattening with
  compound keys when deep nesting reduces readability.

### YAML code quality rules

In addition to the general [code-quality-rules.md](code-quality-rules.md) and YAML and JSON common quality rules above, apply these
YAML-specific quality rules:

* YAMLCQ-001 Schema validation: Validate YAML against schemas when available (e.g., Kubernetes resource definitions, OpenAPI, CloudFormation
  templates) (extends YAJS-CQ-001).
* YAMLCQ-002 Consistent style: Use consistent style throughout a file (block style vs. flow style); prefer block style for configuration
  files for better readability; use flow style only for short, inline collections.
* YAMLCQ-003 Anchor management: Use anchors and aliases for repeated values to maintain DRY principle; ensure anchors are defined before
  use; use meaningful anchor names that indicate their purpose.
* YAMLCQ-004 Avoid tab characters: Never use tab characters in YAML; tabs have ambiguous meaning and can cause parsing errors; always use
  spaces for indentation.
* YAMLCQ-005 Explicit document separation: In multi-document YAML files, always use document separator (`---`) to clearly delimit documents;
  consider using document end marker (`...`) for clarity in multi-document files.
* YAMLCQ-006 Avoid complex types: Keep data types simple; avoid using YAML's complex features (complex keys, set types, custom tags) unless
  necessary; simpler YAML is more portable across parsers.
* YAMLCQ-007 String safety: Quote strings that might be misinterpreted (e.g., strings starting with `#`, strings that look like numbers or
  booleans, version numbers like `1.0`); be explicit to avoid parsing ambiguity.
* YAMLCQ-008 File size: Keep YAML files under 1000 lines; split large configurations and use includes or references where the tool supports
  it (extends YAJS-CQ-004).
* YAMLCQ-009 Comment documentation: Use comments to document complex configurations, non-obvious values, or important constraints; explain
  why, not what; keep comments up to date with the configuration.
* YAMLCQ-010 Version compatibility: Be aware of YAML version differences (1.1 vs. 1.2); test with the YAML parser version used by your
  tools; avoid features that differ between versions (e.g., boolean handling, octal numbers).
* YAMLCQ-011 Consistent indentation: Maintain consistent indentation throughout the file; inconsistent indentation is a common source of
  YAML parsing errors; use linters to enforce consistency.
* YAMLCQ-012 Merge keys: Use merge keys (`<<`) carefully; they can make configurations hard to understand; document their use clearly;
  consider explicit duplication if it improves clarity.
* YAMLCQ-013 Empty values: Be explicit about empty values; distinguish between empty string (`""`), null, and omitted keys; each has
  different semantics depending on the consuming tool.

## JSON-specific rules

These rules apply only to JSON. They extend or override the common rules above.

### JSON formatting rules

* JSON-001 Style baseline: Follow JSON specification (RFC 8259); ensure all generated JSON is valid and parseable.
* JSON-002 Continuation indent: Use 4 spaces for continuation indent when needed (extends YAJS-001).
* JSON-003 Line length handling: Split long arrays and objects across multiple lines (extends YAJS-002).
* JSON-004 Object wrapping: Wrap object properties on separate lines (split_into_lines); place each property on its own line for objects
  with multiple properties; allow a single-line format for simple objects with one or two short properties.
* JSON-005 Array wrapping: Wrap array elements on separate lines (split_into_lines) for arrays with multiple elements or complex elements;
  allow a single-line format for short arrays with primitive values.
* JSON-006 Comma spacing: Do not add a space before commas; add one space after commas in arrays and objects (e.g., `"a", "b"` not `"a","b"`
  or `"a" ,"b"`).
* JSON-007 Trailing commas: JSON specification does not allow trailing commas in arrays or objects (extends YAJS-008).
* JSON-008 Collection spacing: Do not add spaces within braces or brackets (e.g., `{"key": "value"}` and `["item"]` not `{ "key": "value" }`
  or `[ "item" ]`).
* JSON-009 Quotes: Always use double quotes for strings and property names; never use single quotes; escape special characters properly (
  `\"`, `\\`, `\n`, `\t`, etc.).
* JSON-010 Blank lines: Do not keep blank lines in code; minimize blank lines to maintain a compact, parseable structure; blank lines may be
  added in human-edited JSON for readability but should be removed on formatting.
* JSON-011 Line breaks: Keep line breaks as written for human readability; do not wrap long lines automatically; split arrays and objects
  logically at property/element boundaries.
* JSON-012 Numbers: Do not quote numeric values; use a proper JSON number format; avoid leading zeros for decimal numbers (use `0.5` not
  `.5`); represent integers without decimal points.
* JSON-013 Booleans: Do not quote boolean values (extends YAJS-007).
* JSON-014 Null values: Do not quote null values; omit null properties when the schema allows optional fields and null has no semantic
  meaning (extends YAJS-006).
* JSON-015 Unicode: Prefer UTF-8 encoding; escape Unicode characters using `\uXXXX` notation only when necessary for compatibility or when
  targeting ASCII-only environments.
* JSON-016 Root element: Ensure JSON documents have a single root element (object or array); do not create multiple root elements.
* JSON-017 Comments: Standard JSON does not support comments; for configuration files requiring comments, consider JSONC (JSON with
  Comments) or JSON5, or use a separate documentation file; never include comments in standard JSON that will be parsed by strict parsers.

### JSON naming conventions

* JSONNC-001 File extensions: Use `.json` extension; for JSONC files, use `.jsonc` extension (extends YAJS-NC-001).
* JSONNC-002 Property names: Use camelCase for property names in general-purpose JSON (e.g., `firstName`, `maxConnections`,
  `isActive`); for configuration files, follow the tool's convention (e.g., `snake_case` for some tools, `camelCase` for others,
  `kebab-case` for CSS-like configurations).
* JSONNC-003 Boolean properties: Use camelCase with prefixes (e.g., `isActive`, `hasPermission`, `enableLogging`) (extends YAJS-NC-002).
* JSONNC-004 Array properties: Use plural nouns for array properties (e.g., `users`, `items`, `configurations`); make it clear the property
  contains multiple values.
* JSONNC-005 Consistency: Maintain consistent naming conventions throughout a JSON file or related set of files; follow existing conventions
  in a project or established schemas (e.g., OpenAPI, JSON Schema).
* JSONNC-006 Environment-specific files: Use suffixes or subdirectories to organize environment-specific configurations (e.g.,
  `config.dev.json`, `config.prod.json` or `config/dev.json`, `config/prod.json`) (extends YAJS-NC-003).
* JSONNC-007 Schema files: Use `.schema.json` suffix for JSON Schema files (e.g., `user.schema.json`, `config.schema.json`).

### JSON code quality rules

In addition to the general [code-quality-rules.md](code-quality-rules.md) and YAML and JSON common quality rules above, apply these
JSON-specific quality rules:

* JSONCQ-001 Schema validation: Define and validate against JSON Schema for structured data; use JSON Schema to document the expected
  structure and validate at runtime or in CI/CD (extends YAJS-CQ-001).
* JSONCQ-002 Consistent formatting: Use consistent formatting throughout a file or project; automate formatting with tools like Prettier;
  consistent formatting improves readability and reduces diff noise.
* JSONCQ-003 Property order: Order properties logically (e.g., required properties first, then optional; or alphabetically for large
  objects); consistent ordering improves readability and makes it easier to find properties.
* JSONCQ-004 Avoid comments in standard JSON: Do not include comments in standard JSON files that will be parsed by strict parsers; if
  comments are needed, use JSONC, JSON5, or document externally; many tools do not support comments in JSON.
* JSONCQ-005 Semantic null vs. omission: Understand when to use `null` vs. omitting a property; null indicates an explicit absence of value;
  omission may indicate the property is not applicable; follow the schema or API contract.
* JSONCQ-006 File size: Keep JSON files reasonably sized; for large datasets, consider pagination, streaming, or splitting into multiple
  files (extends YAJS-CQ-004).
* JSONCQ-007 Numeric precision: Be aware of numeric precision limitations; JSON parsers may have different handling of large integers or
  floating-point precision; use strings for huge integers (e.g., IDs over 53 bits) or precise decimal values when necessary.
* JSONCQ-008 Array homogeneity: Keep array elements homogeneous (same type and structure); heterogeneous arrays are harder to process and
  validate; use objects with type discriminators if different types are needed.
* JSONCQ-009 Avoid redundancy: Do not duplicate information; use references or IDs to link related data; redundancy causes maintenance
  issues and data consistency problems.
* JSONCQ-010 String encoding: Ensure proper UTF-8 encoding; properly escape special characters; be aware of Unicode normalization issues;
  test it with international characters if the data may contain them.
* JSONCQ-011 Empty collections: Represent empty arrays as `[]` and empty objects as `{}`; do not use null for empty collections unless the
  schema specifically requires it; distinguish between "no items" and "not present".
* JSONCQ-012 Boolean representation: Use boolean type (`true`/`false`), not strings (`"true"`/`"false"`) or numbers (`1`/`0`); proper types
  enable better validation and make the data self-documenting.
* JSONCQ-013 Version management: For configuration files or API responses, consider including a version field to support evolution and
  backward compatibility; document changes between versions.
* JSONCQ-014 Minimal whitespace in production: For production JSON (especially API responses), consider minimizing whitespace to reduce
  bandwidth; for configuration files and development, prioritize readability with proper formatting.
* JSONCQ-015 Avoid language-specific types: Do not use language-specific types or representations (e.g., JavaScript Date objects, Python
  tuples); use standard JSON types and ISO formats for dates (ISO 8601); JSON should be language-agnostic.
* JSONCQ-016 Error handling: When generating JSON from code, handle serialization errors gracefully; test with edge cases (null, undefined,
  circular references, non-serializable types); validate before sending.
* JSONCQ-017 Consistent type usage: Keep property types consistent; if a property is a string in one object, it should be a string in all
  objects; inconsistent types cause parsing errors and confusion.
* JSONCQ-018 Document expected structure: For complex JSON structures, provide examples and documentation; consider using JSON Schema to
  formally document the structure; good documentation prevents misuse and errors.

## Meta and conflict resolution

* META-001 Application order: Apply Common rules (from [common-rules.md](common-rules.md)) first, then YAML and JSON common rules 
  (YAJS-* rules), then YAML or JSON-specific rules. If a language-specific rule conflicts with a common rule, the language-specific rule
  takes precedence.
* META-002 Tool-specific conventions: When generating YAML or JSON for specific tools (e.g., Kubernetes, Docker Compose, OpenAPI,
  package.json), follow the tool's conventions and requirements even if they differ from these general rules.
* META-003 Human vs. machine: Prioritize human readability for configuration files (YAML preferred); prioritize compactness and strict
