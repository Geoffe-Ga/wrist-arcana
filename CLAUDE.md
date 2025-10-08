# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Wrist Arcana** is a production-ready tarot card reading application for watchOS built with SwiftUI and SwiftData. The app features cryptographically secure card draws, persistent history tracking, intelligent storage management, and a complete offline experience with locally bundled Rider-Waite deck imagery.

**Technology Stack:**
- **Language:** Swift 5.9+
- **Framework:** SwiftUI for watchOS 10.0+
- **Persistence:** SwiftData (not Core Data)
- **Architecture:** MVVM with protocol-based dependency injection
- **Testing:** XCTest for unit tests, XCUITest for UI automation

## Repository Directory Overview

- `WristArcana/` – Open this Xcode project to work on the app. Key subfolders include:
  - `Views/` – SwiftUI tab roots plus supporting flows (card list/detail, draw experience, note editor) that stay presentation-only.
  - `ViewModels/` – MVVM layer exposing async business logic, storage coordination, and protocol-driven dependencies for testing.
  - `Models/` – Tarot domain types, SwiftData models, and repositories that hydrate decks from JSON and persist history entries.
  - `Components/` – Shared UI primitives (CTA button, card artwork renderer, flow layout) reused across views.
  - `Configuration/` – Centralized theme palette, typography, and UX constants.
  - `Utilities/` – Supporting services (random generator, storage monitor, sanitizer, extensions) consumed by view models and tests.
  - `Resources/` – Bundled deck JSON and asset catalog with card art/complications.
  - `WristArcanaApp.swift` – Scene entry point that configures the shared SwiftData container.
  - `WristArcana Watch AppTests/` & `WristArcana Watch AppUITests/` – Swift Testing suites and UI test scaffolding.
- `scripts/` – Automation for card art download/processing and simulator datastore inspection.
- `prompts/` – Historical product briefs and bug analyses for AI collaborators.
- `TEST_FILES_TO_ADD.md` – Pending assets/data checklist.
- Root documentation (`README.md`, `CONTRIBUTING.md`, `AGENTS.md`) – Onboarding information for human and AI contributors.

## Build and Test Commands

### Building the Project
```bash
# Open the project
open WristArcana/WristArcana.xcodeproj

# Build from command line
xcodebuild build \
  -scheme WristArcana \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

### Running Tests
```bash
# Run all tests with coverage
xcodebuild test \
  -scheme WristArcana \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' \
  -enableCodeCoverage YES

# View coverage report
xcodebuild test \
  -scheme WristArcana \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' \
  -enableCodeCoverage YES \
  -resultBundlePath TestResults.xcresult && \
  open TestResults.xcresult
```

### Code Quality Tools
```bash
# Run SwiftLint (strict mode, must pass with 0 warnings)
swiftlint lint --strict

# Apply SwiftFormat
swiftformat .

# Verify SwiftFormat compliance
swiftformat --lint .

# Run pre-commit hooks manually
pre-commit run --all-files
```

### Image Asset Processing
```bash
# Download Rider-Waite cards from sacred-texts.com (~5 min)
./scripts/download_rws_cards.sh

# Process images for watchOS (requires ImageMagick)
brew install imagemagick
./scripts/process_images.sh

# Verify all 78 cards are present
ls -1 scripts/RWS_Cards_Processed/@3x | wc -l  # Should output 78
```

## Architecture Overview

### MVVM Pattern with Protocol-Based Dependency Injection

The app follows a strict MVVM architecture where:

- **Models** contain pure data structures with minimal logic
- **ViewModels** own ALL business logic and coordinate between models and views
- **Views** are pure SwiftUI with zero business logic, only presentation concerns
- **Protocols** enable dependency injection for 100% testable ViewModels

```
┌─────────────────────────────────────────────────────┐
│                      Views                          │
│              (SwiftUI Declarative UI)               │
└─────────────────┬───────────────────────────────────┘
                  │ @Published / @State
                  ▼
┌─────────────────────────────────────────────────────┐
│                   ViewModels                        │
│        (Business Logic + State Management)          │
└─────────────────┬───────────────────────────────────┘
                  │ Protocol Injection
                  ▼
┌─────────────────────────────────────────────────────┐
│        Models + Repositories + Utilities            │
│   (Data Layer + Domain Logic + Cross-Cutting)       │
└─────────────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│            SwiftData + Asset Catalog                │
│         (Persistence + Local Resources)             │
└─────────────────────────────────────────────────────┘
```

### Key Architectural Decisions

1. **Local Assets Only (Critical)**
   - ALL 78 card images MUST be loaded from local Asset Catalog
   - NO network calls permitted - app must function 100% offline
   - Apple rejects watchOS apps that require connectivity for core features
   - Images stored in `WristArcana/Resources/Assets.xcassets/`

2. **SwiftData Over Core Data**
   - Type-safe, Swift-native syntax reduces boilerplate by ~40%
   - Easier testing with in-memory model containers
   - Requires watchOS 10.0+ (acceptable for 2025 target)
   - Model container initialized in `WristArcanaApp.swift` with `.modelContainer(for: [CardPull.self])`

3. **Protocol-Based Dependency Injection**
   - Enables 100% unit testable ViewModels without modifying production code
   - All dependencies (repositories, storage monitors) use protocol contracts
   - Example: `DeckRepositoryProtocol`, `StorageMonitorProtocol`
   - Mock implementations in test target for deterministic testing

4. **Cryptographic Randomization**
   - Uses `SystemRandomNumberGenerator()` for CSPRNG-quality randomness
   - Fisher-Yates shuffle algorithm ensures uniform card distribution
   - Statistical validation tests verify fairness

5. **Intelligent Storage Management**
   - Monitors device storage with 80% capacity threshold
   - Proactive user alerts before capacity issues arise
   - Automatic pruning suggestions for old history entries
   - Limits history queries to 100 most recent pulls for performance

## Project Structure

```
WristArcana/
├── WristArcana/
│   ├── WristArcanaApp.swift          # App entry point, SwiftData container setup
│   ├── Models/                       # Data models (100% coverage expected)
│   │   └── CardPull.swift           # SwiftData model for history persistence
│   ├── ViewModels/                   # Business logic (95%+ coverage required)
│   │   ├── CardDrawViewModel.swift  # Card drawing, randomization, history saving
│   │   ├── HistoryViewModel.swift   # History fetching, deletion, pruning
│   │   └── DeckSelectionViewModel.swift  # Future: multi-deck support
│   ├── Views/                        # SwiftUI interfaces (60%+ coverage)
│   │   ├── ContentView.swift        # Main navigation view
│   │   ├── DrawCardView.swift       # Primary screen with DRAW button
│   │   ├── CardDisplayView.swift    # Full-screen card display with meanings
│   │   └── HistoryView.swift        # Scrollable history list
│   ├── Components/                   # Reusable UI components
│   │   ├── CardImageView.swift      # Optimized local image loading
│   │   ├── CTAButton.swift          # Styled DRAW button with gradient
│   │   └── HistoryRow.swift         # Individual history item
│   ├── Utilities/                    # Helper utilities (100% coverage)
│   │   ├── RandomGenerator.swift    # Cryptographically secure RNG wrapper
│   │   ├── StorageMonitor.swift     # Storage capacity monitoring
│   │   └── Extensions/              # Swift extensions for Date, Image, etc.
│   ├── Resources/
│   │   ├── Assets.xcassets/         # 78 card images (@1x, @2x, @3x variants)
│   │   │   └── RiderWaite/         # Rider-Waite deck images
│   │   └── DecksData.json           # Card metadata (names, meanings, arcana types)
│   └── Configuration/
│       ├── AppConstants.swift       # App-wide constants (storage thresholds, limits)
│       └── Theme.swift              # Color schemes, typography, spacing
├── WristArcanaTests/                 # Unit tests (80%+ overall coverage required)
├── WristArcanaUITests/               # UI automation tests
└── scripts/                          # Development automation
    ├── download_rws_cards.sh        # Downloads 78 cards from sacred-texts.com
    └── process_images.sh            # Optimizes images for watchOS (@1x/@2x/@3x)
```

## Development Workflow

### Test-Driven Development (TDD) - MANDATORY

All features MUST follow the Red-Green-Refactor cycle:

1. **Red:** Write failing test first
2. **Green:** Write minimum code to pass test
3. **Refactor:** Clean up while keeping tests green
4. **Verify:** Run full test suite to ensure no regressions

**Coverage Requirements (CI enforced):**
- Overall: ≥80% code coverage (CI fails below this)
- Models: 100% (pure logic, trivial to test)
- ViewModels: 95%+ (core business logic must be bulletproof)
- Views: 60%+ (UI tests, lower due to SwiftUI complexity)
- Utilities: 100% (reusable code must be tested)

### Code Quality Standards

**Pre-commit hooks run automatically on every commit:**
- SwiftLint validation (strict mode, 0 warnings)
- SwiftFormat application (auto-fixes formatting)
- Affected unit tests (must all pass)
- Build verification

**SwiftLint Configuration (`.swiftlint.yml`):**
- Line length: 120 characters max
- Function body: 50 lines max
- Type body: 300 lines max
- File length: 500 lines max
- Cyclomatic complexity: 10 warning, 15 error

**Naming Conventions:**
- Types: `PascalCase` (e.g., `CardDrawViewModel`, `TarotCard`)
- Functions/Variables: `camelCase` (e.g., `drawRandomCard()`, `isDrawing`)
- Constants: `camelCase` with descriptive names (e.g., `maxHistoryItems`)
- Protocols: Descriptive noun + `Protocol` suffix (e.g., `DeckRepositoryProtocol`)
- Enums for namespacing: `PascalCase` (e.g., `AppConstants`, `Theme`)

**Code Organization (Use MARK comments):**
```swift
// MARK: - Type Definition
// MARK: - Published Properties
// MARK: - Private Properties
// MARK: - Initialization
// MARK: - Public Methods
// MARK: - Private Methods
```

### Git Commit Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation only
- `style:` Formatting (no code change)
- `refactor:` Code restructuring
- `perf:` Performance improvement
- `test:` Adding/updating tests
- `chore:` Maintenance, dependencies

**Examples:**
```bash
feat: add cryptographic randomization to card draws
fix(history): resolve date formatting on 12-hour locales
test: add comprehensive CardDrawViewModel test suite
refactor: extract card selection logic to utility
```

## Critical Implementation Details

### SwiftData Model Container Setup

The app uses SwiftData for persistence. The model container is configured in `WristArcanaApp.swift`:

```swift
@main
struct WristArcanaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [CardPull.self])
    }
}
```

**Important:** When creating ViewModels that need `ModelContext`, access it via `@Environment(\.modelContext)` in views and inject into ViewModels during initialization.

### Cryptographic Randomization

Card draws MUST use `SystemRandomNumberGenerator()` for fairness:

```swift
var generator = SystemRandomNumberGenerator()
let card = deck.cards.randomElement(using: &generator)
```

**Session-based No-Repeat Logic:**
- Track drawn cards in `Set<UUID>` within ViewModel
- When all 78 cards drawn, reset the set
- Ensures each card appears once before repeating

### Storage Monitoring Threshold

Storage warnings trigger at 80% capacity:

```swift
// In StorageMonitor
private let warningThreshold: Double = 0.80

func isNearCapacity() -> Bool {
    let usedPercentage = Double(used) / Double(total)
    return usedPercentage > warningThreshold
}
```

### Image Asset Loading

**Critical:** Images are loaded ONLY from local Asset Catalog:

```swift
// Correct approach
Image(uiImage: UIImage(named: card.imageName)!)
    .resizable()
    .aspectRatio(contentMode: .fit)

// NEVER use remote URLs
// Image(url: URL(string: "https://..."))  // ❌ FORBIDDEN
```

**Asset Naming Convention:**
- Major Arcana: `major_00` through `major_21`
- Minor Arcana: `wands_01`, `cups_ace`, `swords_king`, `pentacles_queen`

### DecksData.json Structure

Card metadata is loaded from `Resources/DecksData.json`:

```json
{
  "decks": [
    {
      "id": "rider-waite-smith",
      "name": "Rider-Waite",
      "cards": [
        {
          "id": "rw-major-00",
          "name": "The Fool",
          "imageName": "major_00",
          "arcana": "major",
          "number": 0,
          "upright": "New beginnings, optimism, trust in life",
          "reversed": "Recklessness, taken advantage of, inconsideration"
        }
        // ... 77 more cards
      ]
    }
  ]
}
```

### Multi-Deck Architecture (Future Feature)

The app is architected for multiple decks via IAP, but this is HIDDEN in v1.0:

```swift
// In AppConstants.swift
enum FeatureFlags {
    static let multiDeckEnabled = false  // Set to true when IAP ready
}

// Conditionally show deck selection UI
if FeatureFlags.multiDeckEnabled {
    NavigationLink("Change Deck") {
        DeckSelectionView(...)
    }
}
```

**DeckSelectionViewModel and DeckSelectionView exist but are not exposed in navigation.**

## Testing Strategy

### Mock Pattern for Protocol-Based Dependencies

All ViewModels depend on protocols, not concrete types:

```swift
// Production
class DeckRepository: DeckRepositoryProtocol { ... }

// Testing
class MockDeckRepository: DeckRepositoryProtocol {
    var decks: [TarotDeck] = []
    var shouldThrowError = false

    func getCurrentDeck() throws -> TarotDeck {
        if shouldThrowError { throw DeckError.notFound }
        return decks.first ?? TarotDeck.riderWaite
    }
}
```

### Test Organization (Arrange-Act-Assert)

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

### UI Test Example

```swift
func test_drawCard_displaysCardSuccessfully() {
    // Given
    let drawButton = app.buttons["DRAW"]
    XCTAssertTrue(drawButton.exists)

    // When
    drawButton.tap()

    // Then
    let cardImage = app.images.firstMatch
    XCTAssertTrue(cardImage.waitForExistence(timeout: 2))
}
```

## Performance Optimization

**Key Performance Targets:**
- Card draw time: <100ms
- View transitions: <50ms
- Image display: <16ms (instant from Asset Catalog)

**Memory Management:**
- Aggressive image unloading after card dismissal
- Limit history queries to 100 most recent pulls
- Use SwiftData predicates for efficient database fetches

**Animation:**
- 60fps transitions using SwiftUI's GPU acceleration
- Minimum 0.5s delay on card draws for UX anticipation/suspense

## Accessibility Requirements

All interactive elements MUST have accessibility labels:

```swift
Button("Draw Card") { drawCard() }
    .accessibilityLabel("Draw a tarot card")
    .accessibilityHint("Draws a random card from the deck")

Image(card.imageName)
    .accessibilityLabel("Tarot card: \(card.name)")
```

**Test with VoiceOver:**
- Xcode → Simulator → Accessibility Inspector
- Settings → Accessibility → VoiceOver → On

## Common Pitfalls to Avoid

1. **Never use force unwrap (`!`) in production code** (OK in tests only)
2. **Never use remote URLs for images** - App Store rejection guaranteed
3. **Never put business logic in views** - Belongs in ViewModels
4. **Never skip TDD** - Write tests first, then implementation
5. **Never commit with SwiftLint warnings** - Pre-commit hooks enforce this
6. **Never use Core Data** - This project uses SwiftData exclusively
7. **Never expose multi-deck UI in v1.0** - Feature flag is disabled

## Troubleshooting

### Tests Failing
```bash
# Clean build folder
xcodebuild clean

# Delete derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Rebuild and test
xcodebuild test -scheme WristArcana \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

### SwiftLint Errors
```bash
# Auto-fix what's possible
swiftlint --fix

# Check remaining issues
swiftlint lint --strict
```

### Missing Images
```bash
# Re-run image processing scripts
./scripts/download_rws_cards.sh
./scripts/process_images.sh

# Manually import to Xcode Asset Catalog:
# Open WristArcana/Resources/Assets.xcassets
# Drag RWS_Cards_Processed folder structure into catalog
```

### Pre-commit Hooks Not Running
```bash
# Reinstall hooks
pre-commit uninstall
pre-commit install

# Test hooks
pre-commit run --all-files
```

## Additional Resources

- **README.md** - Comprehensive project documentation for portfolio/hiring managers
- **CONTRIBUTING.md** - Detailed coding standards, PR process, testing requirements
- **prompts/kickoff.md** - Original complete development specification
- **Apple WatchOS Guidelines** - https://developer.apple.com/design/human-interface-guidelines/watchos
- **SwiftData Documentation** - https://developer.apple.com/documentation/swiftdata
- **Conventional Commits** - https://www.conventionalcommits.org/
