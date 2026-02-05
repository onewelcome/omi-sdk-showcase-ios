# Code Quality Rules (Condensed)

**Full version:** [code-quality-rules.md](../code-quality-rules.md)

These rules prevent code smells and quality issues. Apply in addition to common and language-specific rules.

---

## Complexity Limits (Critical) ⭐

| Rule | Metric | Limit | Why |
|------|--------|-------|-----|
| CQ-001 | Cyclomatic complexity | <15 | Hard to test/maintain |
| CQ-002 | Cognitive complexity | <15 | Hard to understand |
| CQ-003 | Nesting depth | ≤3 | Readability |
| CQ-004 | Return statements | ≤3 | Control flow clarity |
| CQ-005 | Boolean operators | ≤3 | Extract to named vars |

## Size Limits

| Rule | Element | Limit |
|------|---------|-------|
| CQ-006 | Method/function | <50 lines |
| CQ-007 | Class/file | <500 lines |
| CQ-008 | Parameters | ≤4 params |
| CQ-009 | Constructor params | ≤5 params |
| CQ-010 | Anonymous class/lambda | <20 lines |

## Duplication (Zero Tolerance) ⭐

- **CQ-011**: No code duplication ≥3 lines
- **CQ-012**: No duplicated string literals (except "", "0", "1")
- **CQ-013**: Watch for similar code blocks - refactor

## Maintainability ⭐

| Rule | Avoid | Use Instead |
|------|-------|-------------|
| CQ-014 | Magic numbers (except -1,0,1,2) | Named constants |
| CQ-015 | Magic strings | Named constants/enums |
| CQ-016 | TODO without tracking | Create issue or complete |
| CQ-017 | Commented-out code | Delete (version control exists) |
| CQ-018 | Dead code | Remove unused elements |
| CQ-019 | Unused imports | Remove all |

## Error Handling (Critical) ⭐⭐⭐

- **CQ-020**: **NEVER empty catch blocks** - log at minimum ⭐
- **CQ-021**: Catch specific exceptions, not generic `Exception`
- **CQ-022**: **NO exceptions in `finally`** blocks
- **CQ-023**: Include original exception when wrapping

## Conditional Logic

- **CQ-024**: No identical then/else branches
- **CQ-025**: Prefer positive conditions over negations
- **CQ-026**: Don't compare booleans to true/false (`if (x)` not `if (x == true)`)
- **CQ-027**: Simplify - `condition ? true : false` → `condition`
- **CQ-028**: Switch statements - handle all cases or default

## Naming & Documentation

- **CQ-029**: Descriptive, intention-revealing names
- **CQ-030**: Avoid single-letter names (except i/j/k in loops)
- **CQ-031**: Minimum 2 chars for vars, 3 for methods
- **CQ-032**: Document all public APIs (Javadoc/JSDoc/XML)
- **CQ-033**: Comment WHY, not WHAT (code should be self-documenting)

## Resources (Critical) ⭐⭐

- **CQ-034**: Always close resources (files, streams, connections)
- **CQ-035**: Ensure cleanup even in errors (try-with-resources/using/finally)

## Concurrency

- **CQ-036**: Document thread safety guarantees
- **CQ-037**: Prefer immutable objects for thread safety

## Testing

- **CQ-038**: Meaningful test coverage (business logic, edge cases, errors)
- **CQ-039**: Tests independent - no shared state, any order
- **CQ-040**: Descriptive test names
- **CQ-041**: One behavior per test, appropriate assertions

## Security ⭐⭐⭐

**See [SECURITY_RULES.md](../SECURITY_RULES.md) for all security rules**

## Performance

- **CQ-046**: Don't recalculate invariants in loops
- **CQ-047**: StringBuilder for string concatenation in loops
- **CQ-048**: Pre-size collections when size known
- **CQ-049**: Don't prematurely optimize - write clear code first

## Design Principles

- **CQ-050**: Single Responsibility - one reason to change
- **CQ-051**: Dependency Injection over direct instantiation
- **CQ-052**: Favor composition over inheritance
- **CQ-053**: Open/Closed - open for extension, closed for modification
- **CQ-054**: Interface Segregation - focused, specific interfaces

## Meta-Rules

- **CQ-META-001**: Explain rule suppressions in comments
- **CQ-META-002**: Track technical debt - don't let it accumulate
- **CQ-META-003**: Use as code review checklist

---

## Quick Violations Checklist

**Before committing, verify NO:**
- [ ] Methods >50 lines or complexity >15
- [ ] Empty catch blocks
- [ ] Magic numbers/strings
- [ ] Commented-out code
- [ ] Dead code or unused imports
- [ ] Code duplication ≥3 lines
- [ ] Resources not properly closed
- [ ] Generic exception catching
- [ ] Identical if/else branches
- [ ] Single-letter variable names (except loops)

**Verify ALL:**
- [ ] Public APIs documented
- [ ] Specific exception types caught
- [ ] Resources use try-with-resources/using
- [ ] Tests independent and descriptive
- [ ] Complex conditions extracted to named vars/methods
- [ ] Security rules applied (no hardcoded secrets, parameterized queries)

---

## Priority Guide

**P0 - Critical (Must Fix):**
- Empty catch blocks (CQ-020)
- Resource leaks (CQ-034, CQ-035)
- Generic exception catching in production (CQ-021)
- Hardcoded credentials (Security rules)
- SQL injection vulnerabilities (Security rules)

**P1 - High (Should Fix):**
- Cyclomatic complexity >15 (CQ-001, CQ-002)
- Code duplication (CQ-011)
- Magic numbers/strings (CQ-014, CQ-015)
- Dead code (CQ-017, CQ-018)
- Methods >50 lines (CQ-006)

**P2 - Medium (Fix When Refactoring):**
- Nesting >3 levels (CQ-003)
- >4 parameters (CQ-008)
- Missing documentation (CQ-032)
- Non-descriptive names (CQ-029)

**P3 - Low (Nice to Have):**
- Commented code (CQ-017)
- TODO comments (CQ-016)
- Single-letter names outside loops (CQ-030)

For complete rules with detailed explanations and examples, see [code-quality-rules.md](../code-quality-rules.md)
