# Common code generation rules

These rules apply to all programming languages unless explicitly overridden by language-specific rules. Each rule has a unique code for easy
reference.

**Important**: In addition to these common rules, always apply the [code-quality-rules.md](code-quality-rules.md) to prevent code smells


## Line length

* COM-005 Line length: Target a maximum line length appropriate to the project (e.g., 140 characters for Java/Kotlin, 100 characters for TypeScript/JavaScript). Do not auto-wrap long lines—break lines only where language rules require or readability demands.

## Naming conventions

* COMNC-001 Class names: Use PascalCase (UpperCamelCase) for class names (e.g., `UserService`, `CustomerOrder`); make names descriptive nouns or noun phrases.
* COMNC-002 Interface names: Use PascalCase for interface names (e.g., `Runnable`, `PaymentProcessor`, `User`); prefer descriptive nouns; do not use "I" prefix.
* COMNC-003 Method and function names: Use camelCase (lowerCamelCase) for method and function names (e.g., `getUserName()`, `calculateTotal()`); start with a verb or verb phrase.
* COMNC-004 Variable names: Use camelCase for variable names (e.g., `userName`, `itemCount`); use meaningful, descriptive names; avoid single-letter names except for loop counters or short-lived variables.
* COMNC-005 Constants: Use UPPER_SNAKE_CASE for compile-time or true constants (e.g., `MAX_SIZE`, `DEFAULT_TIMEOUT`); language-specific rules may define nuances for runtime constants or configuration objects.
* COMNC-006 Type parameters: Use single uppercase letters for simple generics (e.g., `T`, `E`, `K`, `V`) or descriptive PascalCase names for complex generics (e.g., `TRequest`, `TResponse`, `Item`).
* COMNC-007 Boolean naming: Prefix boolean variable, property, and function names with `is`, `has`, `can`, `should`, or similar (e.g., `isValid`, `hasPermission`, `canEdit`); avoid negative names like `isNotValid`.
* COMNC-008 Enum type names: Use PascalCase for enum type or class names (e.g., `DayOfWeek`, `OrderStatus`); enum member naming conventions are language-specific.

## Meta-rules

* META-001 Precedence: Language-specific rules take precedence over common rules when there is a conflict.
