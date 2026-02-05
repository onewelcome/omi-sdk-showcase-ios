# Project Setup Guides

This document provides consolidated project setup and structure guidelines for IntelliJ IDEA and Android Studio projects.

---

## Android Library Project Structure (ANDROID-PROJ)

### Project Organization

* ANDROID-PROJ-001 Module structure: Organize Android projects with the following structure:
  ```
  /
      settings.gradle (or settings.gradle.kts)
      build.gradle (or build.gradle.kts)
      gradle.properties
      /gradle
          /wrapper
              gradle-wrapper.properties
              gradle-wrapper.jar
      /library (or /app)
          build.gradle
          dependencies.gradle (optional - separate dependency management)
          proguard-rules.pro
          /src
              /main
                  /java (or /kotlin)
                  /res
                  AndroidManifest.xml
              /test
                  /java (or /kotlin)
              /androidTest
                  /java (or /kotlin)
      /docs (optional - documentation)
      /scripts (optional - build/deployment scripts)
  ```

* ANDROID-PROJ-002 Settings file: Use `settings.gradle` (Groovy) or `settings.gradle.kts` (Kotlin DSL) to define:
  - Root project name: `rootProject.name = 'ProjectName'`
  - Included modules: `include ':library'`, `include ':app'`
  - Plugin management and version catalogs (Gradle 7.0+)

* ANDROID-PROJ-003 Root build file: The root-level `build.gradle` should contain:
  - Buildscript dependencies (Gradle plugin, Kotlin plugin, etc.)
  - Repository configurations shared across all modules
  - Common tasks (clean, documentation generation, etc.)
  - Plugin application for multi-module concerns

### Gradle Configuration

* ANDROID-PROJ-004 Version catalogs: Use Gradle version catalogs (`gradle/libs.versions.toml`) for dependency management (Gradle 7.0+):
  ```toml
  [versions]
  compileSdk = "34"
  minSdk = "24"
  targetSdk = "34"
  kotlin = "1.9.22"
  
  [libraries]
  androidx-core = { module = "androidx.core:core-ktx", version = "1.12.0" }
  
  [plugins]
  android-library = { id = "com.android.library", version = "8.2.0" }
  kotlin-android = { id = "org.jetbrains.kotlin.android", version.ref = "kotlin" }
  ```

* ANDROID-PROJ-005 Gradle properties: Use `gradle.properties` for project-wide configuration:
  - JVM arguments: `org.gradle.jvmargs=-Xmx2048m`
  - Build optimizations: `org.gradle.caching=true`, `org.gradle.parallel=true`
  - Android options: `android.useAndroidX=true`, `android.enableJetifier=false`
  - Kotlin compilation: `kotlin.code.style=official`

* ANDROID-PROJ-006 Module build file: Each module's `build.gradle` should contain:
  - Plugin declarations using `plugins {}` block (preferred over `apply plugin`)
  - Android configuration in `android {}` block
  - Dependencies in `dependencies {}` block (or separate file)
  - Custom tasks and configurations specific to the module

### Android Library Module Configuration

* ANDROID-PROJ-007 Namespace: Always explicitly declare namespace in `build.gradle`:
  ```groovy
  android {
      namespace 'com.company.library'
      compileSdk 34
  }
  ```

* ANDROID-PROJ-008 SDK versions: Define SDK versions consistently:
  - `compileSdk`: Latest stable Android API level
  - `minSdk`: Minimum supported API level based on requirements
  - `targetSdk`: Latest stable Android API level
  - Version information: `versionCode` and `versionName` in `defaultConfig`

* ANDROID-PROJ-009 Build features: Enable only required build features:
  ```groovy
  buildFeatures {
      buildConfig = true          // For BuildConfig generation
      viewBinding = true          // For view binding (if needed)
      compose = false             // Only if using Jetpack Compose
  }
  ```

* ANDROID-PROJ-010 Java/Kotlin compatibility: Set appropriate language versions:
  ```groovy
  compileOptions {
      sourceCompatibility JavaVersion.VERSION_17
      targetCompatibility JavaVersion.VERSION_17
  }
  
  kotlinOptions {
      jvmTarget = "17"
      allWarningsAsErrors = true
      freeCompilerArgs += ['-java-parameters']
  }
  ```

### Build Variants and Flavors

* ANDROID-PROJ-011 Build types: Define build types for different build configurations:
  - `debug`: Debuggable, no optimization, for development
  - `release`: Optimized, signed, for production
  - Custom types (e.g., `unobfuscated`, `staging`): For specific testing scenarios

* ANDROID-PROJ-012 Product flavors: Use product flavors for variant dimensions:
  ```groovy
  flavorDimensions = ["environment", "target"]
  productFlavors {
      online {
          dimension "target"
      }
      offline {
          dimension "target"
      }
  }
  ```

* ANDROID-PROJ-013 Variant filtering: Filter out unwanted build variant combinations:
  ```groovy
  variantFilter { variant ->
      if (variant.name == "offlineRelease") {
          setIgnore(true)
      }
  }
  ```

* ANDROID-PROJ-014 Build config fields: Add custom BuildConfig fields:
  ```groovy
  buildConfigField("String", "API_URL", "\"https://api.example.com\"")
  buildConfigField("long", "VERSION_CODE", "${versionCode}")
  ```

### ProGuard and Code Obfuscation

* ANDROID-PROJ-015 Consumer ProGuard rules: Provide consumer ProGuard rules for library modules:
  ```groovy
  defaultConfig {
      consumerProguardFiles 'proguard-rules.pro'
  }
  ```

* ANDROID-PROJ-016 ProGuard configuration: Organize ProGuard rules by purpose:
  - `proguard-rules.pro`: Main rules file
  - `proguard-debug.pro`: Debug-specific rules
  - `proguard-release.pro`: Release-specific rules
  - Keep rules for reflection, serialization, and native methods

* ANDROID-PROJ-017 Obfuscation tools: When using DexGuard or R8:
  - Apply obfuscation configuration per build type
  - Store configuration files in module's `/obfuscation` directory
  - Configure mapping file locations for crash reporting

### Testing Configuration

* ANDROID-PROJ-018 Test build type: Specify which build type to use for tests:
  ```groovy
  testBuildType "unobfuscated"  // Use non-obfuscated build for testing
  ```

* ANDROID-PROJ-019 Test options: Configure test execution:
  ```groovy
  testOptions {
      unitTests.returnDefaultValues = true
      unitTests.includeAndroidResources = true
      animationsDisabled = true
  }
  ```

* ANDROID-PROJ-020 Test source sets: Organize test code properly:
  - `/src/test`: Unit tests (JVM)
  - `/src/androidTest`: Instrumented tests (Android device/emulator)
  - `/src/test/resources` or `/src/test/sampledata`: Test resources

* ANDROID-PROJ-021 Test logging: Enable detailed test output:
  ```groovy
  tasks.withType(Test).configureEach {
      testLogging {
          exceptionFormat "full"
          events "skipped", "passed", "failed"
          showStandardStreams true
      }
  }
  ```

### Code Coverage

* ANDROID-PROJ-022 JaCoCo integration: Configure JaCoCo for code coverage:
  - Create separate `jacoco.gradle` file for JaCoCo configuration
  - Apply to specific build types (typically unobfuscated/debug)
  - Generate unified reports for unit and instrumented tests

* ANDROID-PROJ-023 Coverage reports: Configure coverage report generation:
  ```groovy
  jacoco {
      toolVersion = "0.8.11"
  }
  
  tasks.register('jacocoTestReport', JacocoReport) {
      // Configure report generation
  }
  ```

### Dependency Management

* ANDROID-PROJ-024 Dependency organization: Organize dependencies logically:
  - Consider separate `dependencies.gradle` file for complex projects
  - Group by category (Android, Kotlin, Testing, etc.)
  - Use consistent dependency notation

* ANDROID-PROJ-025 Dependency configurations: Use appropriate dependency scopes:
  - `implementation`: Private dependencies (not exposed to consumers)
  - `api`: Public dependencies (exposed to library consumers)
  - `compileOnly`: Compile-time only (e.g., annotations)
  - `testImplementation`: Unit test dependencies
  - `androidTestImplementation`: Instrumented test dependencies

* ANDROID-PROJ-026 Local dependencies: Handle local AAR/JAR files:
  ```groovy
  repositories {
      flatDir {
          dirs 'libs', '../external-libs'
      }
  }
  
  dependencies {
      implementation(name: 'library-name', ext: 'aar')
  }
  ```

### Resource and Asset Management

* ANDROID-PROJ-027 Source sets: Configure source sets for different build variants:
  ```groovy
  sourceSets {
      main {
          java.srcDirs = ['src/main/java', 'src/main/kotlin']
          res.srcDirs = ['src/main/res']
      }
      test {
          resources.srcDirs += ['src/test/sampledata']
      }
  }
  ```

* ANDROID-PROJ-028 Packaging options: Configure packaging to avoid conflicts:
  ```groovy
  packagingOptions {
      exclude 'META-INF/LICENSE.txt'
      exclude 'META-INF/NOTICE.txt'
      exclude 'META-INF/MANIFEST.MF'
      
      jniLibs.keepDebugSymbols.add("**/lib*.so")
  }
  ```

### Documentation

* ANDROID-PROJ-029 Dokka integration: Use Dokka for Kotlin documentation:
  - Create separate `dokka.gradle` configuration file
  - Generate both HTML and Markdown documentation
  - Configure output directories (e.g., `APIDocs/`)

* ANDROID-PROJ-030 Documentation files: Maintain documentation alongside code:
  - `README.md`: Project overview and setup instructions
  - `module.md`: Module-level documentation for Dokka
  - `/docs`: Extended documentation, guides, and examples

### Lint and Code Quality

* ANDROID-PROJ-031 Lint configuration: Configure Android Lint:
  ```groovy
  lint {
      abortOnError true
      checkAllWarnings true
      warningsAsErrors false
      
      // Disable specific checks when necessary
      disable 'UnusedResources'
      
      // Generate reports
      xmlReport = true
      htmlReport = true
  }
  ```

* ANDROID-PROJ-032 Quality tools integration: Integrate code quality tools:
  - Detekt: Kotlin static analysis
  - Ktlint: Kotlin code style
  - SonarQube/SonarCloud: Comprehensive quality analysis
  - Android Studio inspections: Enable and configure

### Build Output Configuration

* ANDROID-PROJ-033 Output file naming: Configure consistent output names:
  ```groovy
  android.libraryVariants.configureEach { variant ->
      variant.outputs.configureEach { output ->
          outputFileName = "library-${variant.name}-${versionName}.aar"
      }
  }
  
  // For AAR tasks
  tasks.withType(BundleAar).tap {
      configureEach {
          archiveFileName = "library-${variantName}-${versionName}.aar"
      }
  }
  ```

* ANDROID-PROJ-034 Archive base name: Set consistent archive naming:
  ```groovy
  android {
      defaultConfig {
          base.archivesName = "library-name"
      }
  }
  ```

### Signing Configuration

* ANDROID-PROJ-035 Debug signing: Configure debug signing for development:
  ```groovy
  signingConfigs {
      debug {
          storeFile file("debug.keystore")
          keyAlias 'androiddebugkey'
          storePassword 'android'
          keyPassword 'android'
      }
  }
  ```

* ANDROID-PROJ-036 Release signing: Configure release signing securely:
  - Never commit release keystores to version control
  - Use environment variables or secure property files
  - Store passwords in `local.properties` (git-ignored)

### Custom Tasks

* ANDROID-PROJ-037 Task registration: Register custom Gradle tasks:
  ```groovy
  tasks.register('customTask', Copy) {
      group = "build"
      description = "Custom task description"
      
      // Task configuration
  }
  ```

* ANDROID-PROJ-038 Task dependencies: Set up task dependencies:
  ```groovy
  tasks.register('assembleAndCopy') {
      dependsOn 'assembleRelease'
      finalizedBy 'copyArtifacts'
  }
  ```

* ANDROID-PROJ-039 Cleanup tasks: Configure comprehensive cleanup:
  ```groovy
  tasks.register('cleanAll', Delete) {
      dependsOn clean
      delete rootProject.file('build-outputs')
      delete rootProject.file('docs/generated')
  }
  ```

---

## IntelliJ IDEA / Android Studio IDE Configuration (IDE-CONFIG)

### Project Files

* IDE-CONFIG-001 Version control: Include in version control:
  - `.gitignore`: Exclude build outputs, IDE-specific files, secrets
  - Include `.idea/codeStyles/` for shared code style
  - Include `.idea/inspectionProfiles/` for shared inspections
  - Exclude `.idea/workspace.xml`, `.idea/tasks.xml`, user-specific files

* IDE-CONFIG-002 .gitignore structure: Essential entries for Android projects:
  ```
  # Gradle
  .gradle/
  build/
  
  # Android
  *.apk
  *.aab
  *.aar
  local.properties
  
  # IDE
  .idea/*
  !.idea/codeStyles/
  !.idea/inspectionProfiles/
  *.iml
  
  # Secrets
  *.keystore
  *.jks
  secrets.properties
  ```

### Code Style

* IDE-CONFIG-003 Code style configuration: Use shared code style settings:
  - Export and commit `.idea/codeStyles/Project.xml`
  - Configure consistent indentation (spaces, not tabs)
  - Set line length limits (140 characters typical)
  - Configure import organization

* IDE-CONFIG-004 EditorConfig: Use `.editorconfig` for cross-IDE consistency:
  ```ini
  [*]
  charset = utf-8
  end_of_line = lf
  insert_final_newline = true
  trim_trailing_whitespace = true
  
  [*.{kt,kts}]
  indent_size = 4
  indent_style = space
  
  [*.{gradle,groovy}]
  indent_size = 4
  indent_style = space
  
  [*.{xml,yml,yaml}]
  indent_size = 2
  indent_style = space
  ```

### Inspections and Analysis

* IDE-CONFIG-005 Inspection profiles: Configure and share inspection profiles:
  - Export profile to `.idea/inspectionProfiles/Project_Default.xml`
  - Enable Kotlin-specific inspections
  - Configure severity levels (Error, Warning, Weak Warning)
  - Enable Android Lint integration

* IDE-CONFIG-006 Kotlin compiler warnings: Treat warnings as errors in development:
  ```groovy
  kotlinOptions {
      allWarningsAsErrors = true
  }
  ```

### Run Configurations

* IDE-CONFIG-007 Shared run configurations: Store common run configurations:
  - Place in `.idea/runConfigurations/` (XML format)
  - Include test configurations
  - Include build task configurations
  - Useful for standardizing team development

### SDK and Build Tools

* IDE-CONFIG-008 SDK configuration: Configure Android SDK consistently:
  - Use SDK Manager in Android Studio
  - Install required SDK platforms matching `compileSdk`
  - Install build tools matching Gradle configuration
  - Configure SDK location in `local.properties` (auto-generated, git-ignored)

* IDE-CONFIG-009 JDK configuration: Set project JDK:
  - Use JDK 17 for modern Android projects
  - Configure in File → Project Structure → SDK Location
  - Ensure Gradle uses same JDK version

### Gradle Configuration

* IDE-CONFIG-010 Gradle JVM: Configure Gradle JVM in IDE:
  - Settings → Build → Build Tools → Gradle
  - Set "Gradle JVM" to match project requirements (JDK 17+)
  - Enable "Download external annotations"

* IDE-CONFIG-011 Gradle build: Optimize Gradle builds in IDE:
  - Enable parallel builds
  - Enable configuration on demand
  - Configure build output directory if needed
  - Enable offline mode for faster builds when dependencies cached

### Plugins

* IDE-CONFIG-012 Essential Android Studio plugins:
  - Kotlin (bundled)
  - Android SDK (bundled)
  - Gradle (bundled)
  - Consider: Detekt, Ktlint, SonarLint for quality analysis

---

## Multi-Module Android Project (MULTI-MODULE)

### Structure

* MULTI-MODULE-001 Module organization: Structure multi-module projects:
  ```
  /
      settings.gradle
      /app (application module)
      /library (library module)
      /core (shared code module)
      /feature-x (feature module)
      /test-common (shared test utilities)
  ```

* MULTI-MODULE-002 Module dependencies: Declare inter-module dependencies:
  ```groovy
  dependencies {
      implementation project(':library')
      testImplementation project(':test-common')
  }
  ```

* MULTI-MODULE-003 Module isolation: Maintain proper module boundaries:
  - Use `implementation` to hide internal module dependencies
  - Use `api` only for dependencies that are part of module's public API
  - Avoid circular dependencies between modules

### Shared Configuration

* MULTI-MODULE-004 Convention plugins: Use convention plugins for shared configuration:
  - Create `buildSrc/` directory for build logic
  - Define common configurations as Gradle plugins
  - Apply to modules to ensure consistency

* MULTI-MODULE-005 Root project configuration: Share settings from root:
  - Define common repositories in root `build.gradle`
  - Share version catalog across all modules
  - Configure global tasks (clean, docs, etc.)

---

## Best Practices (BEST-PRACTICE)

* BEST-PRACTICE-001 Gradle wrapper: Always use Gradle wrapper:
  - Commit wrapper files to version control
  - Ensures consistent Gradle version across team
  - Update wrapper periodically: `./gradlew wrapper --gradle-version=X.Y.Z`

* BEST-PRACTICE-002 Incremental builds: Optimize for incremental builds:
  - Avoid tasks that always run (e.g., don't use `doLast { /* always executes */ }`)
  - Use Gradle's up-to-date checks
  - Leverage build cache when possible

* BEST-PRACTICE-003 Build scripts: Keep build scripts maintainable:
  - Extract complex logic to separate files
  - Use Kotlin DSL for better IDE support (`.gradle.kts`)
  - Comment complex configurations
  - Follow Gradle best practices

* BEST-PRACTICE-004 Version management: Manage versions consistently:
  - Use version catalog (preferred for Gradle 7+)
  - Keep versions in one place
  - Document version update reasoning

* BEST-PRACTICE-005 Security: Never commit secrets:
  - Use environment variables for CI/CD secrets
  - Use `local.properties` (git-ignored) for local secrets
  - Use separate release signing configuration
  - Scan for accidentally committed secrets

* BEST-PRACTICE-006 Documentation: Maintain comprehensive documentation:
  - README with setup instructions
  - Architecture documentation
  - API documentation (KDoc/Javadoc)
  - Changelog for version tracking

* BEST-PRACTICE-007 Continuous integration: Configure CI/CD:
  - Run tests on all commits
  - Generate and archive build artifacts
  - Run code quality checks (lint, detekt, etc.)
  - Track code coverage trends

* BEST-PRACTICE-008 Dependency updates: Keep dependencies current:
  - Regularly review and update dependencies
  - Test thoroughly after major updates
  - Use dependency update tools (e.g., Dependabot)
  - Monitor security advisories
