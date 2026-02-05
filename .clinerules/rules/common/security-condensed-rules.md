# Security Rules (Condensed)

**For complete Android-specific security rules, see [../../security/android-sdk-security.md](../../security/android-sdk-security.md)**

**For OWASP references, see [../../security/owasp-reference.md](../../security/owasp-reference.md)**

---

## Input/Output
- **Server-side validation only**. Normalize to UTF-8, then validate. Use allowlist, reject invalid. Validate type/length/format.
- **Context encoding**: HTML entities, JS encoding, URL encoding, attribute encoding, CSS encoding.
- **Parameterized queries**: Never concatenate SQL. Use typed parameters. PreparedStatement, not string building.
- **No shell exec**: Use system APIs directly. Never eval/exec with untrusted data. No user input in dynamic includes.
- **Disable XXE** in XML parsers.

## Auth & Password
- **Server-side auth only**. Require auth for non-public. Use frameworks (Spring Security, Passport.js). Centralize logic. Fail securely.
- **Hash passwords**: bcrypt/scrypt/Argon2. Never MD5/SHA-1/SHA-256 for passwords. Never plaintext/encoded.
- **POST for credentials**. Never GET params. Validate before auth.
- **Generic error messages** to prevent enumeration.
- **Account lockout** after failures. Min 12+ char passwords. Enforce complexity.
- **Secure password reset**: Time-limited, one-time tokens. Force change of temp passwords.
- **Prevent password reuse**.

## Sessions
- **Use framework sessions**. Server-gen with CSPRNG. Cryptographically unpredictable.
- **Set HttpOnly, Secure, SameSite** flags. Restrictive domain/path.
- **Logout invalidates** server-side session.
- **Renew session ID** after login/privilege change/HTTP→HTTPS upgrade.
- **Never expose session IDs** in URLs/logs/errors.
- **Inactivity timeout**. HTTPS for all authenticated ops.
- **CSRF tokens** for state changes.

## Access Control
- **Server-side authorization only**. Centralized logic. Deny by default.
- **Enforce on every request**. Validate direct object refs.
- **Least privilege**. Isolate admin functions.
- **Rate limit** abuse. Server-side business logic only.

## Crypto
- **≥112-bit**: AES-128+, RSA-2048+, ECC-224+, SHA-256+.
- **Never**: DES, MD5, SHA-1 (signatures), RC4, ECB mode.
- **CSPRNG only**: Never Math.random(), java.util.Random, rand().
- **PBKDF for passwords**: PBKDF2/bcrypt/scrypt/Argon2 + salt (≥128-bit) + high iterations.
- **Unique IVs/nonces**. Never reuse with same key.
- **Single-purpose keys**. RSA: OAEP (encrypt), PSS (sign). Never raw.
- **MACs**: HMAC-SHA-256. Constant-time comparison.
- **Encrypt-then-MAC** or use AEAD (GCM).
- **Protect all secrets**. Fail securely on crypto errors.

## TLS
- **TLS 1.2+** only. Never SSL/TLS 1.0/1.1.
- **Strong ciphers**: Disable NULL/DES/RC4/MD5/export. Use AEAD (AES-GCM).
- **PFS**: ECDHE/DHE.
- **Validate certs**: expiry, hostname, chain, revocation.
- **No TLS downgrade**.

## Errors & Logging
- **Generic user errors**. Never expose stack traces/SQL/paths/system details.
- **Custom error handlers**. Log detailed info server-side only.
- **Clean up resources** on errors. Deny on error for security checks.
- **Log**: auth attempts, authz failures, validation failures, tampering, admin actions.
- **Never log**: passwords, session IDs, API keys, credit cards, secrets.
- **Log context** (user, time, IP, action) without secrets.
- **Sanitize log entries** (prevent injection). Protect log integrity (hashes/secure storage).

## Secrets
- **Never hardcode** secrets in code.
- **Use KMS/Vault/Secret Manager**. No env vars for secrets.
- **Never log secrets**. No client-side secrets.
- **Remove sensitive comments** before deployment.

## Memory (C/C++/Native)
- **Initialize all variables** (especially pointers/arrays).
- **Validate buffer sizes**. Bounds checking. Handle NULL termination.
- **Prevent buffer overflows** in loops.
- **Free memory properly** (including error paths). Overwrite sensitive data before freeing.
- **Avoid unsafe native APIs**. Use non-executable stack.

## Files
- **Validate paths** (no `..`). Use allowlist for file IDs/names.
- **Validate type by content** (magic numbers), not extension.
- **Limit sizes**. Require auth for uploads.
- **Store outside webroot**. No executable uploads. Remove execute permissions.
- **Generate safe filenames**. Scan for malware.
- **Close files/sockets/streams explicitly**.

## Dependencies
- **Official repos only**. Verify checksums/hashes.
- **Keep updated**. Remove unused deps.
- **Scan for vulns** (CVSS > 4). Secure update mechanisms with signatures.

## Concurrency
- **Use locking** for race conditions. Protect shared resources. Thread-safe security ops.

## Data Protection
- **Encrypt sensitive data** at rest. Protect temp/cached data.
- **No sensitive data in URLs/GET params**.
- **Disable autocomplete** on sensitive forms. Disable caching for sensitive pages.
- **Prevent source code access**. Secure deletion support.

## APIs
- **Auth required** (non-public). **Rate limit**. **Validate all inputs** (params, headers, body).
- **Proper CORS** (no wildcard for authed APIs). **API versioning**.

## Web Headers
**HSTS**, **X-Frame-Options** (DENY/SAMEORIGIN), **X-Content-Type-Options** (nosniff), **CSP**, **Referrer-Policy**. Remove server version headers.

## Language-Specific

### JavaScript/TypeScript
Never eval()/Function()/setTimeout with strings. Use strict mode. Avoid `any` (use `unknown`). Minimize type assertions/non-null assertions.

### Python
Never pickle untrusted data. Never eval()/exec(). Use subprocess with list args, not shell=True. Use defusedxml. Use tempfile.mkstemp().

### Java/Kotlin
Never deserialize untrusted data. Disable XXE. Use PreparedStatement. Use SecureRandom, not Random. Use try-with-resources.

### .NET/C#
Use parameterized queries/Entity Framework. Use AntiXssEncoder. Use anti-forgery tokens. Disable DTD processing. Use SecureString for sensitive data.

### C/C++
Use safe functions (strncpy/snprintf, not strcpy/sprintf). Bounds checking. Initialize all variables. Validate array indices. Prevent use-after-free. Non-executable stack.

### Go
No exec.Command("sh", "-c", cmd). Use crypto/rand, not math/rand. Defer resource cleanup. Check all error returns.

## Regex & Misc
- **Prevent ReDoS** (test with large inputs). **Set timeouts**.
- **Minimize privilege elevation**. Drop privileges ASAP.
- **Prefer managed code**. Remove debug code before deployment.
- **No dynamic redirects** from user input.
