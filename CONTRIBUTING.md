# Contributing to Tarot Watch

Thank you for your interest in contributing to Tarot Watch! This document provides guidelines and standards to ensure high-quality, maintainable code that's welcoming to both human and AI collaborators.

---

## 📋 Table of Contents

- [Code of Conduct](#-code-of-conduct)
- [Getting Started](#-getting-started)
- [Development Workflow](#-development-workflow)
- [Coding Standards](#-coding-standards)
- [Testing Requirements](#-testing-requirements)
- [Commit Guidelines](#-commit-guidelines)
- [Pull Request Process](#-pull-request-process)
- [Architecture Principles](#-architecture-principles)

---

## 🤝 Code of Conduct

### Our Standards

- **Be Respectful:** Treat all contributors with respect and kindness
- **Be Constructive:** Provide helpful, actionable feedback
- **Be Inclusive:** Welcome contributors of all skill levels
- **Be Patient:** Remember everyone is learning and growing

### Not Tolerated

- Harassment, discrimination, or personal attacks
- Trolling, insulting comments, or political arguments
- Publishing others' private information
- Any conduct that creates an uncomfortable environment

**Enforcement:** Violations may result in temporary or permanent ban from the project.

---

## 🚀 Getting Started

### Prerequisites

Before contributing, ensure you have:

```bash
# Required
- Xcode 15.2+
- macOS 14.0+ (Sonoma)
- Git 2.30+

# Development Tools (install via Homebrew)
brew install swiftlint swiftformat pre-commit imagemagick
```

### First-Time Setup

```bash
# 1. Fork the repository on GitHub
# 2. Clone your fork
git clone https://github.com/Geoffe-Ga/wrist-arcana.git
cd wrist-arcana

# 3. Add upstream remote
git remote add upstream https://github.com/Geoffe-Ga/wrist-arcana.git

# 4. Install pre-commit hooks
pre-commit install

# 5. Download card images (if not present)
./scripts/download_rws_cards.sh
./scripts/process_images.sh

# 6. Run tests to verify setup
xcodebuild test -scheme WristArcana \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

### Understanding the Codebase

**Recommended Reading Order:**
1. `README.md` - Project overview and architecture
2. `WristArcana/Models/` - Start with data structures
3. `WristArcana/ViewModels/` - Business logic layer
4. `WristArcana/Views/` - UI implementation
5. `WristArcanaTests/` - Test patterns and examples

---

## 🔄 Development Workflow

### 1. Create a Feature Branch

```bash
# Always branch from develop
git checkout develop
git pull upstream develop

# Create feature branch (use conventional naming)
git checkout -b feature/add-card-meanings
git checkout -b fix/storage-warning-bug
git checkout -b refactor/extract-card-renderer
git checkout -b docs/update-architecture-guide
```

### 2. Make Your Changes

**Follow Test-Driven Development (TDD):**

```swift
// Step 1: Write failing test (RED)
func test_drawCard_savesToHistory() async throws {
    // Arrange
    mockRepository.decks = [TarotDeck.riderWaite]
    
    // Act
    await sut.drawCard()
    
    // Assert
    let pulls = try mockContext.fetch(FetchDescriptor<CardPull>())
    XCTAssertEqual(pulls.count, 1)
}

// Step 2: Implement minimum code to pass (GREEN)
func drawCard() async {
    let card = repository.getRandomCard(from: getCurrentDeck())
    let pull = CardPull(date: Date(), cardName: card.name, ...)
    modelContext.insert(pull)
}

// Step 3: Refactor while keeping tests green (REFACTOR)
func drawCard() async {
    isDrawing = true
    defer { isDrawing = false }
    
    do {
        let deck = repository.getCurrentDeck()
        let card = selectRandomCard(from: deck)
        try await saveToHistory(card: card, deck: deck)
    } catch {
        handleError(error)
    }
}
```

### 3. Verify Quality Checks

```bash
# Run before committing (pre-commit hook does this automatically)
swiftlint lint --strict        # Must pass with 0 warnings
swiftformat --lint .            # Must have no formatting issues
xcodebuild test -scheme WristArcana  # All tests must pass
```

### 4. Commit Your Changes

```bash
# Stage changes
git add .

# Commit (pre-commit hooks run automatically)
git commit -m "feat: add card meanings to CardDisplayView"

# If hooks fail, fix issues and try again
git commit -m "feat: add card meanings to CardDisplayView"
```

### 5. Push and Create Pull Request

```bash
# Push to your fork
git push origin feature/add-card-meanings

# Go to GitHub and create Pull Request
# - Target: upstream/develop (not main)
# - Fill out PR template completely
# - Link related issues
```

---

## 📐 Coding Standards

### Swift Style Guide

We follow [Apple's Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) with additional project-specific rules.

#### Naming Conventions

```swift
// Types: PascalCase
class CardDrawViewModel { }
struct TarotCard { }
enum ArcanaType { }

// Functions/Variables: camelCase
func drawRandomCard() { }
var isDrawing: Bool = false
let selectedDeck: TarotDeck

// Constants: camelCase (not UPPER_SNAKE_CASE)
let maxHistoryItems = 500
let storageWarningThreshold = 0.80

// Protocols: Descriptive noun + "Protocol" suffix
protocol DeckRepositoryProtocol { }
protocol StorageMonitorProtocol { }

// Enums for namespacing: PascalCase
enum AppConstants { }
enum Theme { }
```

#### Code Organization

**Use MARK comments for all types:**

```swift
// MARK: - Type Definition
final class CardDrawViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentCard: TarotCard?
    @Published var isDrawing: Bool = false
    
    // MARK: - Private Properties
    private let repository: DeckRepositoryProtocol
    private var drawnCardsThisSession: Set<UUID> = []
    
    // MARK: - Initialization
    init(repository: DeckRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    func drawCard() async {
        // Implementation
    }
    
    func dismissCard() {
        // Implementation
    }
    
    // MARK: - Private Methods
    private func selectRandomCard(from deck: TarotDeck) -> TarotCard {
        // Implementation
    }
}
```

#### Line Length & Formatting

```swift
// Maximum 120 characters per line
// Break long function calls/parameters:

// ❌ BAD
func createViewModel(repository: DeckRepositoryProtocol, storage: StorageMonitorProtocol, context: ModelContext) -> CardDrawViewModel {
    return CardDrawViewModel(repository: repository, storage: storage, context: context)
}

// ✅ GOOD
func createViewModel(
    repository: DeckRepositoryProtocol,
    storage: StorageMonitorProtocol,
    context: ModelContext
) -> CardDrawViewModel {
    return CardDrawViewModel(
        repository: repository,
        storage: storage,
        context: context
    )
}
```

#### Error Handling

```swift
// ✅ GOOD: User-facing errors
do {
    try await saveToHistory(card: card)
} catch {
    errorMessage = "Failed to save card. Please try again."
    print("⚠️ History save failed: \(error)")
}

// ❌ BAD: Technical jargon exposed to user
} catch {
    errorMessage = "SwiftData ModelContext insert operation threw exception"
}

// ✅ GOOD: Graceful degradation
func loadHistory() async {
    do {
        pulls = try modelContext.fetch(descriptor)
    } catch {
        print("⚠️ Failed to load history: \(error)")
        pulls = []  // Fallback to empty state
    }
}
```

#### Force Unwrapping

```swift
// ❌ NEVER in production code
let card = deck.cards.randomElement()!
let url = URL(string: imageURL)!

// ✅ GOOD: Safe unwrapping
guard let card = deck.cards.randomElement() else {
    throw DeckError.emptyDeck
}

if let url = URL(string: imageURL) {
    // Use url safely
}

// ✅ OK: In tests only
func test_drawCard_returnsCard() {
    let card = deck.cards.first!  // OK: Test will fail loudly if nil
    XCTAssertEqual(card.name, "The Fool")
}
```

#### Documentation

```swift
/// Draws a random card from the current deck and saves to history.
///
/// This method uses cryptographically secure randomization to ensure fairness.
/// Cards won't repeat within a session until all cards have been drawn.
///
/// - Throws: `DeckError.notFound` if no deck is available
/// - Note: Includes minimum 0.5s delay for UX anticipation
///
/// ## Example
/// ```swift
/// await viewModel.drawCard()
/// if let card = viewModel.currentCard {
///     print("Drew: \(card.name)")
/// }
/// ```
func drawCard() async throws {
    // Implementation
}
```

### SwiftUI Specific Guidelines

```swift
// ✅ GOOD: Extract complex views into components
struct DrawCardView: View {
    var body: some View {
        VStack {
            TitleHeader()
            CTAButton(action: drawCard)
            HistoryLink()
        }
    }
}

// ❌ BAD: Deeply nested view hierarchy
struct DrawCardView: View {
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("Tarot")
                    Text("Watch")
                }
            }
            Button { } label: {
                ZStack {
                    Circle()
                    Text("DRAW")
                }
            }
        }
    }
}

// ✅ GOOD: ViewModels own business logic
class CardDrawViewModel: ObservableObject {
    func drawCard() async {
        // All drawing logic here
    }
}

// ❌ BAD: Business logic in views
struct DrawCardView: View {
    var body: some View {
        Button("DRAW") {
            let card = deck.cards.randomElement()
            history.append(card)
            // NO! This belongs in ViewModel
        }
    }
}
```

---

## 🧪 Testing Requirements

### Coverage Thresholds (Enforced by CI)

| Layer | Minimum Coverage | Target |
|-------|-----------------|--------|
| **Models** | 100% | 100% |
| **ViewModels** | 90% | 95%+ |
| **Views** | 50% | 60%+ |
| **Utilities** | 95% | 100% |
| **Overall** | 80% | 85%+ |

### Test Organization

```
WristArcanaTests/
├── ModelTests/
│   ├── TarotCardTests.swift
│   ├── TarotDeckTests.swift
│   └── CardPullTests.swift
├── ViewModelTests/
│   ├── CardDrawViewModelTests.swift
│   ├── HistoryViewModelTests.swift
│   └── DeckSelectionViewModelTests.swift
├── UtilityTests/
│   ├── RandomGeneratorTests.swift
│   └── StorageMonitorTests.swift
└── Mocks/
    ├── MockDeckRepository.swift
    └── MockStorageMonitor.swift
```

### Test Structure (Arrange-Act-Assert)

```swift
func test_drawCard_savesToHistory() async throws {
    // MARK: - Arrange
    mockRepository.decks = [TarotDeck.riderWaite]
    let initialCount = try mockContext.fetch(FetchDescriptor<CardPull>()).count
    
    // MARK: - Act
    await sut.drawCard()
    
    // MARK: - Assert
    let pulls = try mockContext.fetch(FetchDescriptor<CardPull>())
    XCTAssertEqual(pulls.count, initialCount + 1)
    XCTAssertEqual(pulls.last?.cardName, sut.currentCard?.name)
}
```

### Naming Tests

```swift
// Pattern: test_methodName_condition_expectedResult

func test_drawCard_whenDeckHasCards_returnsRandomCard() { }
func test_drawCard_whenStorageFull_showsWarning() { }
func test_drawCard_afterDrawingAllCards_resetsSession() { }
func test_deleteHistory_whenItemExists_removesFromDatabase() { }
func test_loadHistory_whenDatabaseEmpty_returnsEmptyArray() { }
```

### Mock Objects

```swift
// ✅ GOOD: Protocol-based mocks
class MockDeckRepository: DeckRepositoryProtocol {
    var decks: [TarotDeck] = []
    var shouldThrowError = false
    
    func getCurrentDeck() throws -> TarotDeck {
        if shouldThrowError { throw DeckError.notFound }
        guard let deck = decks.first else { throw DeckError.notFound }
        return deck
    }
    
    func getRandomCard(from deck: TarotDeck) -> TarotCard {
        return deck.cards[0]  // Deterministic for testing
    }
}

// ❌ BAD: Subclassing concrete classes
class TestDeckRepository: DeckRepository {
    // Fragile, couples tests to implementation
}
```

### What to Test

**✅ DO Test:**
- All ViewModel public methods
- Error handling paths
- Edge cases (empty lists, nil values, boundary conditions)
- State transitions
- Business logic calculations
- Data transformations

**❌ DON'T Test:**
- SwiftUI framework behavior (Apple tests this)
- Third-party library internals
- Trivial getters/setters without logic
- Private implementation details

---

## 📝 Commit Guidelines

### Commit Message Format

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Types

- **feat:** New feature
- **fix:** Bug fix
- **docs:** Documentation only
- **style:** Formatting, missing semicolons, etc. (no code change)
- **refactor:** Code change that neither fixes a bug nor adds a feature
- **perf:** Performance improvement
- **test:** Adding or updating tests
- **chore:** Maintenance tasks, dependency updates

#### Examples

```bash
# Simple commit
git commit -m "feat: add card meanings to CardDisplayView"

# With scope
git commit -m "fix(history): resolve date formatting issue on 12-hour locales"

# With body and breaking change
git commit -m "refactor!: change DeckRepository protocol interface

BREAKING CHANGE: getCurrentDeck() now returns optional TarotDeck?
instead of throwing errors. Update all callers to use optional binding.

Affects: CardDrawViewModel, DeckSelectionViewModel"

# Multiple changes
git commit -m "feat: add storage warning system

- Implement StorageMonitor utility
- Add warning alert to HistoryView
- Update HistoryViewModel with pruning logic
- Add comprehensive tests for storage thresholds

Closes #42"
```

#### Commit Best Practices

- **One logical change per commit:** Don't mix refactoring with new features
- **Present tense:** "add feature" not "added feature"
- **Imperative mood:** "fix bug" not "fixes bug"
- **Keep subject under 72 characters**
- **Reference issues:** Use "Closes #123" or "Fixes #456"
- **Explain WHY, not WHAT:** The diff shows what changed; explain reasoning

---

## 🔀 Pull Request Process

### Before Opening a PR

**Checklist:**
- [ ] All tests pass locally
- [ ] Code coverage ≥80%
- [ ] SwiftLint produces 0 warnings
- [ ] SwiftFormat applied
- [ ] No `// TODO` or `// FIXME` comments (create issues instead)
- [ ] No force unwraps in production code
- [ ] Documentation updated (if public API changed)
- [ ] Screenshots added (if UI changed)

### PR Title Format

Use same format as commits:

```
feat: add daily card widget support
fix: resolve crash on empty history
docs: add architecture diagrams to README
```

### PR Description Template

```markdown
## Description
Brief summary of changes and motivation.

## Type of Change
- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality to break)
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] UI tests added/updated (if applicable)
- [ ] Manual testing completed on:
  - [ ] 41mm watch
  - [ ] 45mm watch
  - [ ] 49mm watch

## Screenshots (if UI changes)
| Before | After |
|--------|-------|
| ![](url) | ![](url) |

## Related Issues
Closes #123
Related to #456

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Tests cover new code
- [ ] No new warnings generated
- [ ] Documentation updated
```

### Review Process

1. **Automated Checks:** CI runs linting, tests, coverage
2. **Code Review:** Maintainer reviews code quality and design
3. **Feedback:** Address all review comments
4. **Approval:** Maintainer approves when ready
5. **Merge:** Squash and merge into develop branch

### Addressing Review Feedback

```bash
# Make changes based on feedback
git add .
git commit -m "refactor: extract card selection logic per review"

# Push updates
git push origin feature/add-card-meanings

# PR automatically updates
```

---

## 🏛️ Architecture Principles

### MVVM Pattern

**Views:**
- Zero business logic
- Only UI concerns (layout, styling, transitions)
- Observe ViewModels via `@Published` properties
- Pass user actions to ViewModels

**ViewModels:**
- All business logic
- Manage state with `@Published` properties
- Coordinate between Models and Views
- Protocol-based dependencies (for testing)
- Must be 100% unit testable

**Models:**
- Pure data structures
- Minimal logic (computed properties OK)
- Conform to `Codable`, `Identifiable` as needed
- No dependencies on UI frameworks

### Dependency Injection

**Always use protocol-based injection:**

```swift
// ✅ GOOD: Protocol in ViewModel
protocol DeckRepositoryProtocol {
    func getCurrentDeck() -> TarotDeck
}

class CardDrawViewModel: ObservableObject {
    private let repository: DeckRepositoryProtocol
    
    init(repository: DeckRepositoryProtocol) {
        self.repository = repository
    }
}

// Production
let viewModel = CardDrawViewModel(repository: DeckRepository())

// Testing
let viewModel = CardDrawViewModel(repository: MockDeckRepository())
```

### File Size Limits

- **Views:** Max 200 lines (split into components if larger)
- **ViewModels:** Max 300 lines (consider splitting responsibilities)
- **Files:** Max 500 lines (extract utilities/extensions)

### When to Add a New File

**Create a new file when:**
- Existing file exceeds size limits
- New responsibility/concern identified
- Reusable component extracted
- New feature module added

**Keep in same file when:**
- Tightly coupled (e.g., enum used only in one struct)
- Very small (< 30 lines)
- Extension adds 1-2 methods

---

## 🎨 UI/UX Guidelines

### watchOS Design Principles

1. **Glanceable:** Information at a glance, <2 seconds
2. **Actionable:** Primary action immediately accessible
3. **Responsive:** Instant feedback on all interactions
4. **Lightweight:** Minimal text, clear iconography

### Accessibility Requirements

```swift
// ✅ GOOD: Semantic accessibility labels
Button("Draw Card") {
    drawCard()
}
.accessibilityLabel("Draw a tarot card")
.accessibilityHint("Draws a random card from the deck")

Image(card.imageName)
    .accessibilityLabel("Tarot card: \(card.name)")

// ❌ BAD: Missing or unclear labels
Button("") {
    drawCard()
}
.accessibilityLabel("Button")  // Too generic
```

### Testing Accessibility

```bash
# Test with VoiceOver in Simulator
Xcode → Simulator → Accessibility Inspector
Settings → Accessibility → VoiceOver → On
```

---

## 🐛 Bug Reports

### Creating Good Bug Reports

**Include:**
1. **Description:** What happened vs. what should happen
2. **Steps to Reproduce:** Numbered list
3. **Expected Behavior:** What you expected
4. **Actual Behavior:** What actually happened
5. **Environment:** watchOS version, device model
6. **Screenshots/Videos:** If applicable
7. **Crash Logs:** If app crashed

**Template:**

```markdown
## Bug Description
Brief summary of the issue.

## Steps to Reproduce
1. Open app
2. Tap "DRAW" button
3. Swipe to view history
4. Notice incorrect date format

## Expected Behavior
Date should display in user's locale format (MM/DD/YYYY for US).

## Actual Behavior
Date displays as YYYY-MM-DD regardless of locale.

## Environment
- watchOS: 10.2
- Device: Apple Watch Series 9 (45mm)
- App Version: 1.0.0

## Screenshots
[Attach screenshot]

## Additional Context
Only occurs when system language is set to English (US).
```

---

## 💡 Feature Requests

### Proposing New Features

1. **Search existing issues** to avoid duplicates
2. **Create issue with detailed description**
3. **Explain the problem** it solves
4. **Provide use cases** and examples
5. **Consider alternatives** you've explored
6. **Discuss implementation** approach (optional)

**Template:**

```markdown
## Feature Request
Brief title of feature.

## Problem Statement
What problem does this solve? Why is it needed?

## Proposed Solution
How would this feature work?

## Alternatives Considered
What other solutions did you consider?

## Additional Context
Mockups, examples, related features.
```

---

## 📞 Getting Help

### Resources

- **Documentation:** Check README.md and inline code docs first
- **Issues:** Search existing issues for solutions
- **Discussions:** Use GitHub Discussions for questions
- **Code Review:** Request early feedback on drafts

### Asking Good Questions

**Include:**
- What you're trying to do
- What you've tried
- Error messages (full text)
- Relevant code snippets
- Your environment (Xcode version, etc.)

---

## 🎉 Recognition

Contributors will be:
- Listed in README.md acknowledgments
- Credited in release notes
- Added to CONTRIBUTORS.md (if significant contributions)

Thank you for helping make Tarot Watch better! 🙏

---

<p align="center">
  <sub>Last updated: 2025-01-15</sub>
</p>