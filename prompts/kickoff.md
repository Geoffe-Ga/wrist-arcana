# Tarot Card App for watchOS - Complete Development Specification

## Executive Summary
This document provides comprehensive specifications for building a production-ready tarot card reading application for watchOS. The app features card drawing with cryptographic randomization, pull history with intelligent persistence management, and a clean, intuitive interface optimized for the Apple Watch form factor. The MVP ships with the Rider-Waite deck (78 cards) and includes architecture for future deck expansion via in-app purchases.

## Architecture & System Design

### Architecture Pattern: MVVM (Model-View-ViewModel)
**Rationale:** MVVM provides clear separation of concerns, testability, and integrates seamlessly with SwiftUI's declarative paradigm. The reactive nature of MVVM aligns perfectly with SwiftUI's state management.

### Key Architectural Decisions

1. **No Backend Required**
   - All data stored locally using SwiftData (modern Core Data replacement)
   - Card images bundled in app assets (local only, no remote URLs)
   - Zero server costs, offline-first functionality
   - Scales to device storage limits only

2. **SwiftData for Persistence**
   - Type-safe, Swift-native persistence layer
   - Automatic CloudKit sync capability (optional future feature)
   - Query performance optimized for watch constraints
   - Automatic schema migration support

3. **Local Asset Management Strategy**
   - All 78 card images bundled in Asset Catalog with compression
   - Instant loading (<16ms) for smooth animations
   - Multiple resolution support (@1x, @2x, @3x)
   - Dark mode compatible assets
   - **CRITICAL:** No remote URLs - Apple requires offline functionality for watchOS

4. **Randomization Engine**
   - Cryptographically secure random number generation using SystemRandomNumberGenerator
   - Fisher-Yates shuffle algorithm for deck randomization
   - Seeded randomization for reproducibility in tests

5. **Revenue Model: Freemium with IAP**
   - Base app: FREE with Rider-Waite deck included
   - Future deck packs: $1.99-$3.99 each (IAP)
   - Architecture supports multi-deck, UI hidden in MVP

### System Constraints & Optimizations

- **Memory Management:** Aggressive image unloading after card display
- **Storage Management:** Automatic history pruning at 80% capacity threshold with user notification
- **Performance Targets:** <100ms card draw time, <50ms view transitions, <16ms image display
- **Battery Efficiency:** Minimize CPU usage, no background processing, no network requests

## Project File Structure

```
WristArcana/
├── WristArcana.xcodeproj/
├── WristArcana/
│   ├── WristArcanaApp.swift              # App entry point, SwiftData container setup
│   ├── Info.plist                        # App configuration, permissions
│   │
│   ├── Models/                           # Data models and business logic
│   │   ├── TarotCard.swift              # Card model (id, name, deck, meanings)
│   │   ├── TarotDeck.swift              # Deck model (id, name, cards, thumbnail)
│   │   ├── CardPull.swift               # SwiftData model for history (date, card, deck)
│   │   └── DeckRepository.swift         # Deck data source, card lookup logic
│   │
│   ├── ViewModels/                       # Business logic & state management
│   │   ├── CardDrawViewModel.swift      # Draw logic, randomization, history saving
│   │   ├── DeckSelectionViewModel.swift # Deck switching (hidden in MVP, ready for IAP)
│   │   └── HistoryViewModel.swift       # History fetching, storage management, pruning
│   │
│   ├── Views/                            # SwiftUI views
│   │   ├── MainView.swift               # Root view with navigation
│   │   ├── DrawCardView.swift           # Main screen with large DRAW CTA button
│   │   ├── CardDisplayView.swift        # Full-screen card with scrollable name
│   │   ├── DeckSelectionView.swift      # Deck picker (hidden in v1.0, code ready)
│   │   └── HistoryView.swift            # Scrollable list of past pulls
│   │
│   ├── Components/                       # Reusable UI components
│   │   ├── CardImageView.swift          # Optimized local image loading component
│   │   ├── CTAButton.swift              # Styled DRAW button component
│   │   └── HistoryRow.swift             # Individual history item view
│   │
│   ├── Utilities/                        # Helper functions & extensions
│   │   ├── RandomGenerator.swift        # Cryptographically secure RNG
│   │   ├── StorageMonitor.swift         # Storage usage tracking, warning system
│   │   └── Extensions/
│   │       ├── Date+Formatting.swift    # Date display helpers
│   │       └── Image+Loading.swift      # Image optimization utilities
│   │
│   ├── Resources/                        # Static resources
│   │   ├── Assets.xcassets/             # All images, colors, symbols
│   │   │   ├── Decks/
│   │   │   │   └── RiderWaite/         # Rider-Waite deck images (78 cards)
│   │   │   └── AppIcon.appiconset/     # App icon
│   │   └── DecksData.json               # Deck metadata (names, meanings, card order)
│   │
│   └── Configuration/                    # App configuration
│       ├── AppConstants.swift           # Constants (storage limits, thresholds)
│       └── Theme.swift                  # Color scheme, typography, spacing
│
├── WristArcanaTests/                      # Unit tests (80%+ coverage required)
│   ├── ModelTests/
│   │   ├── TarotCardTests.swift
│   │   ├── CardPullTests.swift
│   │   └── DeckRepositoryTests.swift
│   ├── ViewModelTests/
│   │   ├── CardDrawViewModelTests.swift
│   │   ├── DeckSelectionViewModelTests.swift
│   │   └── HistoryViewModelTests.swift
│   └── UtilityTests/
│       ├── RandomGeneratorTests.swift
│       └── StorageMonitorTests.swift
│
├── WristArcanaUITests/                    # UI tests
│   ├── DrawFlowUITests.swift            # End-to-end draw flow
│   ├── DeckSelectionUITests.swift       # Deck switching tests (for future)
│   └── HistoryUITests.swift             # History viewing tests
│
├── scripts/                              # Development scripts
│   ├── download_rws_cards.sh            # Download Rider-Waite from sacred-texts
│   ├── process_images.sh                # Optimize and resize for watchOS
│   └── verify_assets.sh                 # Verify all 78 images present
│
├── .github/                              # GitHub Actions CI/CD
│   └── workflows/
│       ├── ci.yml                       # Run on every PR
│       └── release.yml                  # App Store deployment
│
├── .swiftlint.yml                        # Swift linting rules
├── .swiftformat                          # Code formatting rules
├── .pre-commit-config.yaml               # Pre-commit hooks configuration
├── .gitignore                            # Git ignore patterns
├── README.md                             # Project documentation (portfolio-ready)
├── CONTRIBUTING.md                       # Development guidelines
└── ATTRIBUTIONS.md                       # Image sources and licenses
```

### File Structure Rationale

- **Models/**: Pure data structures with minimal logic, easily testable, 100% coverage expected
- **ViewModels/**: All business logic isolated from views, 100% unit testable, 95%+ coverage required
- **Views/**: Pure SwiftUI, no business logic, only presentation, 60%+ coverage
- **Components/**: DRY principle, reusable across views
- **Utilities/**: Cross-cutting concerns, dependency-injectable
- **Resources/**: Clear separation of code and assets
- **scripts/**: Automation for repeatable tasks

## Image Asset Preparation (COMPLETE BEFORE AI AGENT)

### CRITICAL: Local Assets Only

**All card images MUST be bundled locally in the app. No remote URLs.**

**Why Local Only:**
- ✅ Apple requires offline functionality for watchOS apps
- ✅ Instant card display (<16ms) vs 2-8 second network load
- ✅ Better battery life (no network requests)
- ✅ Professional, polished user experience
- ✅ No dependency on external servers
- ❌ Apps using remote images for core functionality will be rejected by App Store

### Image Download Scripts

**Save these scripts to your project root before starting:**

#### download_rws_cards.sh
```bash
#!/bin/bash
# Download complete Rider-Waite-Smith deck from sacred-texts.com
# These images are in the public domain (published pre-1923)

set -e
DOWNLOAD_DIR="RWS_Cards_Raw"
mkdir -p "$DOWNLOAD_DIR"

echo "📥 Downloading Rider-Waite-Smith deck (78 cards)..."

# Major Arcana (0-21)
echo "🎴 Downloading Major Arcana..."
for i in {0..21}; do
    padded=$(printf "%02d" $i)
    echo "  Card $i..."
    curl -s -o "$DOWNLOAD_DIR/major_$padded.jpg" \
        "https://www.sacred-texts.com/tarot/pkt/img/ar$padded.jpg"
    sleep 0.3
done

# Minor Arcana - Wands
echo "🎴 Downloading Wands..."
for i in {1..10}; do
    padded=$(printf "%02d" $i)
    curl -s -o "$DOWNLOAD_DIR/wands_$padded.jpg" \
        "https://www.sacred-texts.com/tarot/pkt/img/wa$padded.jpg"
    sleep 0.3
done
curl -s -o "$DOWNLOAD_DIR/wands_page.jpg" "https://www.sacred-texts.com/tarot/pkt/img/wapa.jpg"
curl -s -o "$DOWNLOAD_DIR/wands_knight.jpg" "https://www.sacred-texts.com/tarot/pkt/img/wakn.jpg"
curl -s -o "$DOWNLOAD_DIR/wands_queen.jpg" "https://www.sacred-texts.com/tarot/pkt/img/waqu.jpg"
curl -s -o "$DOWNLOAD_DIR/wands_king.jpg" "https://www.sacred-texts.com/tarot/pkt/img/waki.jpg"

# Minor Arcana - Cups
echo "🎴 Downloading Cups..."
for i in {1..10}; do
    padded=$(printf "%02d" $i)
    curl -s -o "$DOWNLOAD_DIR/cups_$padded.jpg" \
        "https://www.sacred-texts.com/tarot/pkt/img/cu$padded.jpg"
    sleep 0.3
done
curl -s -o "$DOWNLOAD_DIR/cups_page.jpg" "https://www.sacred-texts.com/tarot/pkt/img/cupa.jpg"
curl -s -o "$DOWNLOAD_DIR/cups_knight.jpg" "https://www.sacred-texts.com/tarot/pkt/img/cukn.jpg"
curl -s -o "$DOWNLOAD_DIR/cups_queen.jpg" "https://www.sacred-texts.com/tarot/pkt/img/cuqu.jpg"
curl -s -o "$DOWNLOAD_DIR/cups_king.jpg" "https://www.sacred-texts.com/tarot/pkt/img/cuki.jpg"

# Minor Arcana - Swords
echo "🎴 Downloading Swords..."
for i in {1..10}; do
    padded=$(printf "%02d" $i)
    curl -s -o "$DOWNLOAD_DIR/swords_$padded.jpg" \
        "https://www.sacred-texts.com/tarot/pkt/img/sw$padded.jpg"
    sleep 0.3
done
curl -s -o "$DOWNLOAD_DIR/swords_page.jpg" "https://www.sacred-texts.com/tarot/pkt/img/swpa.jpg"
curl -s -o "$DOWNLOAD_DIR/swords_knight.jpg" "https://www.sacred-texts.com/tarot/pkt/img/swkn.jpg"
curl -s -o "$DOWNLOAD_DIR/swords_queen.jpg" "https://www.sacred-texts.com/tarot/pkt/img/swqu.jpg"
curl -s -o "$DOWNLOAD_DIR/swords_king.jpg" "https://www.sacred-texts.com/tarot/pkt/img/swki.jpg"

# Minor Arcana - Pentacles
echo "🎴 Downloading Pentacles..."
for i in {1..10}; do
    padded=$(printf "%02d" $i)
    curl -s -o "$DOWNLOAD_DIR/pentacles_$padded.jpg" \
        "https://www.sacred-texts.com/tarot/pkt/img/pe$padded.jpg"
    sleep 0.3
done
curl -s -o "$DOWNLOAD_DIR/pentacles_page.jpg" "https://www.sacred-texts.com/tarot/pkt/img/pepa.jpg"
curl -s -o "$DOWNLOAD_DIR/pentacles_knight.jpg" "https://www.sacred-texts.com/tarot/pkt/img/pekn.jpg"
curl -s -o "$DOWNLOAD_DIR/pentacles_queen.jpg" "https://www.sacred-texts.com/tarot/pkt/img/pequ.jpg"
curl -s -o "$DOWNLOAD_DIR/pentacles_king.jpg" "https://www.sacred-texts.com/tarot/pkt/img/peki.jpg"

echo "✅ Downloaded 78 cards to $DOWNLOAD_DIR"
echo "📝 Next: Run process_images.sh to optimize for watchOS"
```

#### process_images.sh
```bash
#!/bin/bash
# Resize and optimize images for watchOS Asset Catalog
# Requires: brew install imagemagick

set -e
DOWNLOAD_DIR="RWS_Cards_Raw"
PROCESSED_DIR="RWS_Cards_Processed"

echo "🎨 Processing images for watchOS (3 resolutions)..."

mkdir -p "$PROCESSED_DIR/@1x"
mkdir -p "$PROCESSED_DIR/@2x"
mkdir -p "$PROCESSED_DIR/@3x"

for img in "$DOWNLOAD_DIR"/*.jpg; do
    basename=$(basename "$img" .jpg)
    echo "  Processing $basename..."
    
    # @3x: 1200x2000px
    magick "$img" -resize 1200x2000^ -gravity center -extent 1200x2000 \
        -quality 85 -strip "$PROCESSED_DIR/@3x/${basename}.png"
    
    # @2x: 800x1333px
    magick "$img" -resize 800x1333^ -gravity center -extent 800x1333 \
        -quality 85 -strip "$PROCESSED_DIR/@2x/${basename}.png"
    
    # @1x: 400x666px
    magick "$img" -resize 400x666^ -gravity center -extent 400x666 \
        -quality 85 -strip "$PROCESSED_DIR/@1x/${basename}.png"
done

echo "✅ Processed $(ls -1 "$PROCESSED_DIR/@3x" | wc -l | xargs) images"
echo "📦 Total size: $(du -sh "$PROCESSED_DIR" | cut -f1)"
echo "🎯 Ready for Xcode Asset Catalog import"
```

### Image Preparation Workflow

**BEFORE running the AI agent, complete these steps (10 minutes total):**

```bash
# 1. Make scripts executable
chmod +x scripts/download_rws_cards.sh scripts/process_images.sh

# 2. Download all 78 cards (~5 minutes)
./scripts/download_rws_cards.sh

# 3. Process for watchOS (~3 minutes, requires ImageMagick)
brew install imagemagick  # If not installed
./scripts/process_images.sh

# 4. Import to Xcode (manual step after project creation)
# - Open WristArcana/Resources/Assets.xcassets
# - Drag entire RWS_Cards_Processed folder structure into Asset Catalog
# - Xcode will auto-detect @1x, @2x, @3x variants
```

### DecksData.json Structure

Create this file in `WristArcana/Resources/DecksData.json`:

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
        },
        {
          "id": "rw-major-01",
          "name": "The Magician",
          "imageName": "major_01",
          "arcana": "major",
          "number": 1,
          "upright": "Manifestation, resourcefulness, power",
          "reversed": "Manipulation, poor planning, untapped talents"
        }
        // ... continue for all 78 cards
        // Minor Arcana naming: wands_01, wands_02, ..., wands_10, wands_page, wands_knight, wands_queen, wands_king
        // Repeat pattern for: cups_*, swords_*, pentacles_*
      ]
    }
  ]
}
```

## CI/CD, Testing & Pre-commit Setup

### Required Tools Installation

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install development tools
brew install swiftlint swiftformat pre-commit

# Initialize pre-commit in project
cd WristArcana
pre-commit install
```

### Pre-commit Configuration (.pre-commit-config.yaml)

```yaml
repos:
  - repo: local
    hooks:
      - id: swiftlint
        name: SwiftLint
        entry: swiftlint lint --strict
        language: system
        types: [swift]
        pass_filenames: false
        
      - id: swiftformat
        name: SwiftFormat
        entry: swiftformat --lint .
        language: system
        types: [swift]
        pass_filenames: false
        
      - id: swift-test
        name: Swift Tests
        entry: bash -c 'xcodebuild test -scheme WristArcana -destination "platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)" -enableCodeCoverage YES'
        language: system
        pass_filenames: false
        stages: [commit]
```

### SwiftLint Configuration (.swiftlint.yml)

```yaml
included:
  - WristArcana
  - WristArcanaTests

excluded:
  - Pods
  - WristArcana/Resources
  
disabled_rules:
  - trailing_whitespace
  
opt_in_rules:
  - empty_count
  - explicit_init
  - closure_spacing
  - redundant_nil_coalescing
  - sorted_imports
  - vertical_whitespace_closing_braces
  
line_length: 120
function_body_length: 50
type_body_length: 300
file_length: 500

identifier_name:
  min_length: 2
  max_length: 50
  
cyclomatic_complexity:
  warning: 10
  error: 15
```

### SwiftFormat Configuration (.swiftformat)

```
--swiftversion 5.9
--indent 4
--maxwidth 120
--wraparguments before-first
--wrapcollections before-first
--closingparen balanced
--decimalgrouping 3
--exponentgrouping disabled
--fractiongrouping disabled
--hexgrouping 4
--octalgrouping 4
--binarygrouping 4
--stripunusedargs closure-only
--self insert
--importgrouping testable-bottom
--commas inline
--trimwhitespace always
```

### GitHub Actions CI/CD (.github/workflows/ci.yml)

```yaml
name: CI

on:
  pull_request:
    branches: [ main, develop ]
  push:
    branches: [ main, develop ]

jobs:
  lint:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      
      - name: Install SwiftLint
        run: brew install swiftlint
        
      - name: SwiftLint
        run: swiftlint lint --strict
        
  format:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      
      - name: Install SwiftFormat
        run: brew install swiftformat
        
      - name: Check formatting
        run: swiftformat --lint .
        
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.2.app
        
      - name: Build and Test
        run: |
          xcodebuild test \
            -scheme WristArcana \
            -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' \
            -enableCodeCoverage YES \
            -resultBundlePath TestResults
            
      - name: Code Coverage
        run: |
          xcrun xccov view --report --json TestResults.xcresult > coverage.json
          COVERAGE=$(jq '.lineCoverage' coverage.json)
          echo "Code Coverage: $COVERAGE"
          if (( $(echo "$COVERAGE < 0.80" | bc -l) )); then
            echo "❌ Coverage below 80% threshold"
            exit 1
          fi
          echo "✅ Coverage meets 80% requirement"
          
      - name: Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.json
```

### Testing Strategy: Test-Driven Development (TDD)

**Mandatory Approach: Red-Green-Refactor**

1. **Write failing test** (Red) - Test must fail initially
2. **Write minimum code to pass** (Green) - Simplest implementation
3. **Refactor for quality** (Refactor) - Clean up while tests pass
4. **Run full suite** (Verify) - Ensure no regressions

**Coverage Requirements (Non-Negotiable):**
- **Overall:** 80% minimum code coverage - CI fails below this
- **Models:** 100% coverage (pure logic, trivial to test)
- **ViewModels:** 95%+ coverage (core business logic must be tested)
- **Views:** 60%+ coverage (UI tests, lower expectation due to complexity)
- **Utilities:** 100% coverage (reusable code must be bulletproof)

**Test Organization Pattern:**

```swift
// Example: CardDrawViewModelTests.swift
import XCTest
@testable import WristArcana

final class CardDrawViewModelTests: XCTestCase {
    // MARK: - System Under Test
    var sut: CardDrawViewModel!
    var mockRepository: MockDeckRepository!
    var mockStorage: MockStorageMonitor!
    var mockContext: ModelContext!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockRepository = MockDeckRepository()
        mockStorage = MockStorageMonitor()
        mockContext = ModelContext(ModelContainer.preview)
        sut = CardDrawViewModel(
            repository: mockRepository,
            storage: mockStorage,
            context: mockContext
        )
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        mockStorage = nil
        mockContext = nil
        super.tearDown()
    }
    
    // MARK: - Drawing Tests
    func test_drawCard_whenDeckHasCards_returnsRandomCard() async throws {
        // Given
        let deck = TarotDeck.riderWaite
        mockRepository.decks = [deck]
        
        // When
        await sut.drawCard()
        
        // Then
        XCTAssertNotNil(sut.currentCard)
        XCTAssertTrue(deck.cards.contains(where: { $0.id == sut.currentCard?.id }))
    }
    
    func test_drawCard_savesToHistory() async throws {
        // Given
        mockRepository.decks = [TarotDeck.riderWaite]
        
        // When
        await sut.drawCard()
        
        // Then
        let pulls = try mockContext.fetch(FetchDescriptor<CardPull>())
        XCTAssertEqual(pulls.count, 1)
        XCTAssertEqual(pulls.first?.cardName, sut.currentCard?.name)
    }
    
    func test_drawCard_usesCryptographicRandomization() async throws {
        // Given
        mockRepository.decks = [TarotDeck.riderWaite]
        var drawnCards: Set<UUID> = []
        
        // When - Draw 10 cards
        for _ in 0..<10 {
            await sut.drawCard()
            if let card = sut.currentCard {
                drawnCards.insert(card.id)
            }
        }
        
        // Then - Should have drawn at least 8 unique cards (very high probability)
        XCTAssertGreaterThan(drawnCards.count, 7, "Randomization appears non-random")
    }
    
    // MARK: - Edge Cases
    func test_drawCard_whenStorageFull_showsWarning() async throws {
        // Given
        mockStorage.isNearCapacity = true
        mockRepository.decks = [TarotDeck.riderWaite]
        
        // When
        await sut.drawCard()
        
        // Then
        XCTAssertTrue(sut.showsStorageWarning)
    }
    
    func test_drawCard_whenNoDecksAvailable_throwsError() async {
        // Given
        mockRepository.decks = []
        
        // When/Then
        do {
            await sut.drawCard()
            XCTFail("Should have thrown error")
        } catch {
            XCTAssertTrue(error is DeckError)
        }
    }
}
```

**Mock Pattern for Dependencies:**

```swift
// MockDeckRepository.swift in Tests target
class MockDeckRepository: DeckRepositoryProtocol {
    var decks: [TarotDeck] = []
    var shouldFail = false
    
    func getAllDecks() throws -> [TarotDeck] {
        if shouldFail { throw DeckError.loadFailed }
        return decks
    }
    
    func getDeck(by id: UUID) throws -> TarotDeck {
        guard let deck = decks.first(where: { $0.id == id }) else {
            throw DeckError.notFound
        }
        return deck
    }
}
```

## Complete Coding Prompt for AI Agent

### Context Setting

You are building a professional, production-ready tarot card reading application for watchOS using SwiftUI and SwiftData. This app must be performant, maintainable, follow Apple's Human Interface Guidelines for watchOS, and demonstrate senior-level software engineering practices suitable for a portfolio project.

### Core Requirements

**Technology Stack:**
- **Language:** Swift 5.9+
- **Framework:** SwiftUI (watchOS 10.0+ target)
- **Persistence:** SwiftData (not Core Data)
- **Architecture:** MVVM with protocol-based dependency injection
- **Testing:** XCTest for unit tests, XCUITest for UI tests
- **Minimum watchOS version:** 10.0

**Development Constraints:**
- All images MUST be loaded from local Asset Catalog (no network calls)
- App MUST function 100% offline
- Zero backend/server dependencies
- All tests MUST pass before any code commit
- Code coverage MUST be ≥80%

### Feature Implementation Details

#### 1. Data Models

**TarotCard (Codable Struct):**
```swift
struct TarotCard: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String           // "The Fool", "Ace of Cups"
    let imageName: String      // "major_00", "cups_ace"
    let arcana: ArcanaType     // .major or .minor
    let number: Int?           // 0-21 for major, 1-14 for minor
    let upright: String        // Upright meaning
    let reversed: String       // Reversed meaning (future feature)
    
    enum ArcanaType: String, Codable {
        case major
        case minor
    }
}
```

**TarotDeck (SwiftData Model):**
```swift
@Model
final class TarotDeck {
    @Attribute(.unique) var id: UUID
    var name: String
    var cards: [TarotCard]  // All 78 cards embedded
    
    init(id: UUID = UUID(), name: String, cards: [TarotCard]) {
        self.id = id
        self.name = name
        self.cards = cards
    }
    
    // Helper computed property
    var cardCount: Int { cards.count }
}
```

**CardPull (SwiftData Model for History):**
```swift
@Model
final class CardPull {
    @Attribute(.unique) var id: UUID
    var date: Date
    var cardName: String
    var deckName: String
    var cardImageName: String
    
    init(id: UUID = UUID(), date: Date, cardName: String, deckName: String, cardImageName: String) {
        self.id = id
        self.date = date
        self.cardName = cardName
        self.deckName = deckName
        self.cardImageName = cardImageName
    }
}
```

#### 2. Deck Repository

**Protocol-Based Design for Testability:**

```swift
protocol DeckRepositoryProtocol {
    func loadDecks() throws -> [TarotDeck]
    func getCurrentDeck() -> TarotDeck
    func getRandomCard(from deck: TarotDeck) -> TarotCard
}

final class DeckRepository: DeckRepositoryProtocol {
    private var loadedDecks: [TarotDeck] = []
    private var currentDeckId: UUID?
    
    // Load from DecksData.json on initialization
    init() {
        do {
            self.loadedDecks = try loadDecksFromJSON()
            self.currentDeckId = loadedDecks.first?.id
        } catch {
            print("⚠️ Failed to load decks: \(error)")
        }
    }
    
    private func loadDecksFromJSON() throws -> [TarotDeck] {
        guard let url = Bundle.main.url(forResource: "DecksData", withExtension: "json") else {
            throw DeckError.fileNotFound
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let decksData = try decoder.decode(DecksDataContainer.self, from: data)
        return decksData.decks.map { TarotDeck(id: UUID(), name: $0.name, cards: $0.cards) }
    }
    
    func loadDecks() throws -> [TarotDeck] {
        return loadedDecks
    }
    
    func getCurrentDeck() -> TarotDeck {
        guard let currentId = currentDeckId,
              let deck = loadedDecks.first(where: { $0.id == currentId }) else {
            return loadedDecks[0]  // Fallback to first deck
        }
        return deck
    }
    
    func getRandomCard(from deck: TarotDeck) -> TarotCard {
        return deck.cards.randomElement(using: &SystemRandomNumberGenerator())!
    }
}

enum DeckError: Error {
    case fileNotFound
    case loadFailed
    case notFound
}

// Helper struct for JSON decoding
private struct DecksDataContainer: Codable {
    let decks: [DeckData]
}

private struct DeckData: Codable {
    let id: String
    let name: String
    let cards: [TarotCard]
}
```

#### 3. Card Drawing System

**CardDrawViewModel:**

```swift
@MainActor
final class CardDrawViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentCard: TarotCard?
    @Published var isDrawing: Bool = false
    @Published var showsStorageWarning: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let repository: DeckRepositoryProtocol
    private let storageMonitor: StorageMonitorProtocol
    private let modelContext: ModelContext
    private var drawnCardsThisSession: Set<UUID> = []
    
    // MARK: - Initialization
    init(
        repository: DeckRepositoryProtocol,
        storageMonitor: StorageMonitorProtocol,
        modelContext: ModelContext
    ) {
        self.repository = repository
        self.storageMonitor = storageMonitor
        self.modelContext = modelContext
    }
    
    // MARK: - Public Methods
    func drawCard() async {
        isDrawing = true
        errorMessage = nil
        
        // Add minimum 0.5s delay for anticipation/animation
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        do {
            let deck = repository.getCurrentDeck()
            let card = selectRandomCard(from: deck)
            
            currentCard = card
            drawnCardsThisSession.insert(card.id)
            
            // Save to history
            try await saveToHistory(card: card, deck: deck)
            
            // Check storage
            if storageMonitor.isNearCapacity() {
                showsStorageWarning = true
            }
            
            // Haptic feedback
            WKInterfaceDevice.current().play(.click)
            
        } catch {
            errorMessage = "Failed to draw card. Please try again."
        }
        
        isDrawing = false
    }
    
    func dismissCard() {
        currentCard = nil
    }
    
    func acknowledgeStorageWarning() {
        showsStorageWarning = false
    }
    
    // MARK: - Private Methods
    private func selectRandomCard(from deck: TarotDeck) -> TarotCard {
        // If all cards drawn this session, reset
        if drawnCardsThisSession.count >= deck.cards.count {
            drawnCardsThisSession.removeAll()
        }
        
        // Get undrawn cards
        let availableCards = deck.cards.filter { !drawnCardsThisSession.contains($0.id) }
        
        // Use cryptographically secure randomization
        var generator = SystemRandomNumberGenerator()
        return availableCards.randomElement(using: &generator)!
    }
    
    private func saveToHistory(card: TarotCard, deck: TarotDeck) async throws {
        let pull = CardPull(
            date: Date(),
            cardName: card.name,
            deckName: deck.name,
            cardImageName: card.imageName
        )
        
        modelContext.insert(pull)
        try modelContext.save()
    }
}
```

**Random Number Generation Utility:**

```swift
// RandomGenerator.swift
protocol RandomGeneratorProtocol {
    func randomCard(from cards: [TarotCard]) -> TarotCard?
}

final class CryptoRandomGenerator: RandomGeneratorProtocol {
    func randomCard(from cards: [TarotCard]) -> TarotCard? {
        guard !cards.isEmpty else { return nil }
        var generator = SystemRandomNumberGenerator()
        return cards.randomElement(using: &generator)
    }
}
```

#### 4. History Management System

**HistoryViewModel:**

```swift
@MainActor
final class HistoryViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var pulls: [CardPull] = []
    @Published var showsPruningAlert: Bool = false
    
    // MARK: - Private Properties
    private let modelContext: ModelContext
    private let storageMonitor: StorageMonitorProtocol
    private let maxPullsToDisplay = 100
    
    // MARK: - Initialization
    init(modelContext: ModelContext, storageMonitor: StorageMonitorProtocol) {
        self.modelContext = modelContext
        self.storageMonitor = storageMonitor
        Task {
            await loadHistory()
        }
    }
    
    // MARK: - Public Methods
    func loadHistory() async {
        let descriptor = FetchDescriptor<CardPull>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            pulls = try modelContext.fetch(descriptor)
                .prefix(maxPullsToDisplay)
                .map { $0 }
        } catch {
            print("⚠️ Failed to load history: \(error)")
        }
    }
    
    func deletePull(_ pull: CardPull) {
        modelContext.delete(pull)
        try? modelContext.save()
        Task {
            await loadHistory()
        }
    }
    
    func checkStorageAndPruneIfNeeded() async {
        if storageMonitor.isNearCapacity() {
            showsPruningAlert = true
        }
    }
    
    func pruneOldestPulls(count: Int = 50) async {
        let descriptor = FetchDescriptor<CardPull>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        
        do {
            let oldestPulls = try modelContext.fetch(descriptor).prefix(count)
            oldestPulls.forEach { modelContext.delete($0) }
            try modelContext.save()
            await loadHistory()
            showsPruningAlert = false
        } catch {
            print("⚠️ Failed to prune history: \(error)")
        }
    }
}
```

**Storage Monitor:**

```swift
protocol StorageMonitorProtocol {
    func isNearCapacity() -> Bool
    func getAvailableStorage() -> Int64
    func getUsedStorage() -> Int64
}

final class StorageMonitor: StorageMonitorProtocol {
    private let warningThreshold: Double = 0.80  // 80% capacity
    
    func isNearCapacity() -> Bool {
        let available = getAvailableStorage()
        let used = getUsedStorage()
        let total = available + used
        
        guard total > 0 else { return false }
        
        let usedPercentage = Double(used) / Double(total)
        return usedPercentage > warningThreshold
    }
    
    func getAvailableStorage() -> Int64 {
        do {
            let attributes = try FileManager.default.attributesOfFileSystem(
                forPath: NSHomeDirectory()
            )
            if let freeSpace = attributes[.systemFreeSize] as? Int64 {
                return freeSpace
            }
        } catch {
            print("⚠️ Failed to get storage info: \(error)")
        }
        return 0
    }
    
    func getUsedStorage() -> Int64 {
        do {
            let attributes = try FileManager.default.attributesOfFileSystem(
                forPath: NSHomeDirectory()
            )
            if let totalSpace = attributes[.systemSize] as? Int64,
               let freeSpace = attributes[.systemFreeSize] as? Int64 {
                return totalSpace - freeSpace
            }
        } catch {
            print("⚠️ Failed to get storage info: \(error)")
        }
        return 0
    }
}
```

#### 5. SwiftUI Views

**MainView (Root Navigation):**

```swift
struct MainView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DrawCardView()
                .tag(0)
            
            HistoryView()
                .tag(1)
        }
        .tabViewStyle(.page)
    }
}
```

**DrawCardView (Main Screen with CTA):**

```swift
struct DrawCardView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: CardDrawViewModel
    @State private var showingCard = false
    
    init() {
        let repository = DeckRepository()
        let storage = StorageMonitor()
        let context = // Get from environment
        _viewModel = StateObject(wrappedValue: CardDrawViewModel(
            repository: repository,
            storageMonitor: storage,
            modelContext: context
        ))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // App Title
            Text("Tarot")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundStyle(.purple)
            
            Spacer()
            
            // Main CTA Button
            CTAButton(
                title: "DRAW",
                isLoading: viewModel.isDrawing,
                action: {
                    Task {
                        await viewModel.drawCard()
                        showingCard = true
                    }
                }
            )
            .frame(width: 140, height: 140)
            
            Spacer()
        }
        .sheet(isPresented: $showingCard) {
            if let card = viewModel.currentCard {
                CardDisplayView(card: card) {
                    showingCard = false
                    viewModel.dismissCard()
                }
            }
        }
        .alert("Storage Warning", isPresented: $viewModel.showsStorageWarning) {
            Button("OK") {
                viewModel.acknowledgeStorageWarning()
            }
        } message: {
            Text("Your card history is using significant storage. Consider deleting old readings.")
        }
    }
}
```

**CTAButton Component:**

```swift
struct CTAButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 5)
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}
```

**CardDisplayView (Full-Screen Card):**

```swift
struct CardDisplayView: View {
    let card: TarotCard
    let onDismiss: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Card Image
                CardImageView(imageName: card.imageName, cardName: card.name)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(0.6, contentMode: .fit)
                    .padding(.top, 20)
                
                // Card Name
                Text(card.name)
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Meaning (Optional display)
                Text(card.upright)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    onDismiss()
                }
            }
        }
    }
}
```

**CardImageView Component:**

```swift
struct CardImageView: View {
    let imageName: String
    let cardName: String
    
    var body: some View {
        if let image = UIImage(named: imageName) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(8)
        } else {
            // Fallback placeholder
            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(0.6, contentMode: .fit)
                    .cornerRadius(8)
                
                VStack {
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    
                    Text(cardName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
        }
    }
}
```

**HistoryView:**

```swift
struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: HistoryViewModel
    
    init() {
        let storage = StorageMonitor()
        let context = // Get from environment
        _viewModel = StateObject(wrappedValue: HistoryViewModel(
            modelContext: context,
            storageMonitor: storage
        ))
    }
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.pulls.isEmpty {
                    ContentUnavailableView(
                        "No Readings Yet",
                        systemImage: "sparkles",
                        description: Text("Tap DRAW to get your first card reading")
                    )
                } else {
                    ForEach(viewModel.pulls) { pull in
                        HistoryRow(pull: pull)
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            viewModel.deletePull(viewModel.pulls[index])
                        }
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                EditButton()
            }
        }
        .task {
            await viewModel.checkStorageAndPruneIfNeeded()
        }
        .alert("Storage Full", isPresented: $viewModel.showsPruningAlert) {
            Button("Delete Oldest 50") {
                Task {
                    await viewModel.pruneOldestPulls(count: 50)
                }
            }
            Button("Cancel", role: .cancel) {
                viewModel.showsPruningAlert = false
            }
        } message: {
            Text("Your card history is full. Delete old readings to free up space?")
        }
    }
}
```

**HistoryRow Component:**

```swift
struct HistoryRow: View {
    let pull: CardPull
    
    var body: some View {
        HStack(spacing: 12) {
            // Card thumbnail
            CardImageView(imageName: pull.cardImageName, cardName: pull.cardName)
                .frame(width: 40, height: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(pull.cardName)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(pull.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
```

#### 6. App Configuration

**AppConstants.swift:**

```swift
enum AppConstants {
    static let maxHistoryItems = 500
    static let storageWarningThreshold = 0.80
    static let minimumDrawDuration: UInt64 = 500_000_000  // 0.5 seconds in nanoseconds
    static let defaultDeckId = "rider-waite-smith"
}
```

**Theme.swift:**

```swift
enum Theme {
    enum Colors {
        static let primaryGradient = LinearGradient(
            colors: [.purple, .blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let cardBackground = Color(uiColor: .systemBackground)
    }
    
    enum Fonts {
        static let title = Font.system(size: 32, weight: .bold, design: .serif)
        static let cardName = Font.system(size: 20, weight: .semibold, design: .serif)
        static let body = Font.system(size: 14, weight: .regular)
    }
    
    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }
}
```

**WristArcanaApp.swift (Entry Point):**

```swift
import SwiftUI
import SwiftData

@main
struct WristArcanaApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(for: [CardPull.self])
    }
}
```

### Code Quality Standards

**Naming Conventions (Strictly Enforced):**
- **Types:** `PascalCase` - `CardDrawViewModel`, `TarotCard`
- **Variables/Functions:** `camelCase` - `drawRandomCard()`, `isDrawing`
- **Constants:** `camelCase` with descriptive names - `maxHistoryItems`
- **Protocols:** Descriptive nouns ending in `Protocol` - `DeckRepositoryProtocol`
- **Enums for namespacing:** `PascalCase` - `AppConstants`, `Theme`

**Code Organization (Use MARK Comments):**

```swift
// MARK: - Type Definition
class CardDrawViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentCard: TarotCard?
    
    // MARK: - Private Properties
    private let repository: DeckRepositoryProtocol
    
    // MARK: - Initialization
    init(repository: DeckRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    func drawCard() async { }
    
    // MARK: - Private Methods
    private func saveToHistory(_ card: TarotCard) { }
}
```

**Error Handling (Mandatory):**
- All `async` operations wrapped in `do-catch`
- User-facing error messages (no technical jargon)
- Errors logged to console with context: `print("⚠️ Context: \(error)")`
- Graceful degradation (show cached data if load fails)
- Never use force unwrap (`!`) except in tests or after explicit nil checks

**Performance Optimizations:**
- Use `@MainActor` for ViewModel UI updates
- Lazy load images using SwiftUI's `Image` (built-in caching)
- Limit history queries to 100 most recent pulls
- Use efficient SwiftData fetch descriptors with sorting
- Background tasks for heavy operations (none needed in this app)

**Accessibility:**
- All interactive elements have accessibility labels
- Meaningful labels: `.accessibilityLabel("Draw a tarot card")`
- Proper button roles and hints
- VoiceOver tested on all screens

### Multi-Deck Architecture (Future-Ready, Hidden in MVP)

**Deck Selection (Build but Hide):**

```swift
struct DeckSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    let decks: [TarotDeck]
    @Binding var selectedDeckId: UUID
    
    var body: some View {
        List(decks) { deck in
            Button(action: {
                selectedDeckId = deck.id
            }) {
                HStack {
                    Text(deck.name)
                    Spacer()
                    if deck.id == selectedDeckId {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
        .navigationTitle("Select Deck")
    }
}
```

**Feature Flag Pattern:**

```swift
// In AppConstants.swift
enum FeatureFlags {
    static let multiDeckEnabled = false  // Set to true when IAP ready
}

// In DrawCardView, conditionally show:
if FeatureFlags.multiDeckEnabled {
    NavigationLink("Change Deck") {
        DeckSelectionView(decks: decks, selectedDeckId: $selectedDeckId)
    }
}
```

### Testing Requirements

**Test Coverage Checklist:**

- [ ] **Models:** 100% coverage
  - [ ] TarotCard equality and Codable
  - [ ] TarotDeck card access
  - [ ] CardPull persistence
  
- [ ] **ViewModels:** 95%+ coverage
  - [ ] CardDrawViewModel: draw, save, errors
  - [ ] HistoryViewModel: load, delete, prune
  - [ ] All error paths tested
  
- [ ] **Utilities:** 100% coverage
  - [ ] RandomGenerator produces varied output
  - [ ] StorageMonitor threshold calculations
  
- [ ] **UI Tests:** Key flows only
  - [ ] Draw card end-to-end
  - [ ] View history
  - [ ] Delete history item

**Example UI Test:**

```swift
final class DrawFlowUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func test_drawCard_displaysCardSuccessfully() {
        // Given
        let drawButton = app.buttons["DRAW"]
        XCTAssertTrue(drawButton.exists)
        
        // When
        drawButton.tap()
        
        // Then
        let cardImage = app.images.firstMatch
        XCTAssertTrue(cardImage.waitForExistence(timeout: 2))
        
        // Verify card name appears
        let cardName = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'The'")).firstMatch
        XCTAssertTrue(cardName.exists)
    }
    
    func test_drawMultipleCards_showsDifferentCards() {
        // Draw 5 cards and verify variety
        var cardNames: Set<String> = []
        
        for _ in 0..<5 {
            app.buttons["DRAW"].tap()
            sleep(1)
            
            let cardName = app.staticTexts.firstMatch.label
            cardNames.insert(cardName)
            
            app.buttons["Done"].tap()
            sleep(1)
        }
        
        // Should have at least 4 unique cards (allowing 1 repeat)
        XCTAssertGreaterThan(cardNames.count, 3)
    }
}
```

### Development Workflow (TDD Mandatory)

**Step-by-Step Process:**

1. **Create failing test**
```swift
func test_drawCard_savesToHistory() async throws {
    // This test will fail initially
    await sut.drawCard()
    XCTAssertEqual(mockContext.insertedObjects.count, 1)
}
```

2. **Write minimum implementation**
```swift
func drawCard() async {
    let card = repository.getRandomCard(from: getCurrentDeck())
    currentCard = card
    
    let pull = CardPull(date: Date(), cardName: card.name, deckName: "Rider-Waite", cardImageName: card.imageName)
    modelContext.insert(pull)
}
```

3. **Run test - should pass**

4. **Refactor for quality**
```swift
func drawCard() async {
    isDrawing = true
    defer { isDrawing = false }
    
    do {
        let deck = repository.getCurrentDeck()
        let card = selectRandomCard(from: deck)
        currentCard = card
        try await saveToHistory(card: card, deck: deck)
    } catch {
        errorMessage = "Failed to draw card"
    }
}
```

5. **Run full suite - all tests must pass**

**Commit Message Format:**
```
feat: add card drawing with history persistence

- Implement CardDrawViewModel with random selection
- Add history saving to SwiftData
- Include storage monitoring
- Tests: 12 passing, coverage 98%
```

### Documentation Requirements

**README.md Structure:**

```markdown
# Tarot Watch - Mystical Readings on Your Wrist

> A beautifully crafted tarot card reading app for Apple Watch, featuring the classic Rider-Waite deck with intelligent history management and offline functionality.

## ✨ Features

- 🎴 **Complete Rider-Waite Deck** - All 78 cards with authentic imagery
- 🔮 **Instant Card Draws** - Cryptographically secure randomization
- 📖 **Reading History** - Track your spiritual journey
- 💾 **Intelligent Storage** - Automatic space management
- ⚡ **100% Offline** - No internet required
- 🌙 **Dark Mode** - Optimized for day and night use

## 📱 Screenshots

[Add screenshots here]

## 🏗️ Architecture

**Pattern:** MVVM with Protocol-Based Dependency Injection

**Key Technologies:**
- SwiftUI for declarative UI
- SwiftData for persistence
- XCTest for comprehensive testing
- GitHub Actions for CI/CD

**Project Structure:**
```
WristArcana/
├── Models/          # Data models
├── ViewModels/      # Business logic
├── Views/           # SwiftUI views
├── Components/      # Reusable UI
└── Utilities/       # Helpers
```

## 🚀 Getting Started

### Prerequisites

- Xcode 15.2+
- macOS 14.0+
- watchOS 10.0+ Simulator or Device

### Installation

1. Clone the repository
```bash
git clone https://github.com/Geoffe-Ga/wrist-arcana.git
cd wrist-arcana
```

2. Install development tools
```bash
brew install swiftlint swiftformat pre-commit
pre-commit install
```

3. Open project
```bash
open WristArcana.xcodeproj
```

4. Build and run (⌘R)

## 🧪 Testing

Run all tests:
```bash
xcodebuild test -scheme WristArcana \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

View coverage:
```bash
xcodebuild test -scheme WristArcana \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' \
  -enableCodeCoverage YES
```

Current coverage: **85%**

## 🎨 Adding New Decks

1. Prepare 78 card images (400x666px @1x)
2. Add to `Assets.xcassets/Decks/YourDeck/`
3. Update `DecksData.json`:
```json
{
  "id": "your-deck-id",
  "name": "Your Deck Name",
  "cards": [...]
}
```
4. Enable multi-deck UI by setting `FeatureFlags.multiDeckEnabled = true`

## 📄 License

MIT License - See LICENSE file for details

## 🙏 Attributions

Card images sourced from Sacred Texts (public domain)
- Rider-Waite-Smith Tarot: https://sacred-texts.com/tarot/pkt/

## 👨‍💻 Author

[Geoff Gallinger] - [An Agentic Development](https://blog.aptitude.guru)

*Built as a portfolio project demonstrating senior-level iOS/watchOS development*
```

**Inline Code Documentation:**

```swift
/// Draws a random card from the current deck and saves to history.
///
/// This method ensures no card repeats within a session until all cards are drawn.
/// Uses cryptographically secure randomization for fairness.
///
/// - Throws: `DeckError` if deck is unavailable or save fails
/// - Note: Includes minimum 0.5s delay for UX anticipation
func drawCard() async throws {
    // Implementation
}
```

### Final Checklist (All Must Pass)

**Before considering the project complete:**

- [ ] All 78 card images present in Asset Catalog
- [ ] `DecksData.json` complete with all card metadata
- [ ] All unit tests pass (0 failures)
- [ ] All UI tests pass (0 failures)
- [ ] Code coverage ≥80% verified
- [ ] SwiftLint: 0 warnings, 0 errors
- [ ] SwiftFormat: All files formatted
- [ ] Pre-commit hooks installed and passing
- [ ] CI pipeline green on GitHub
- [ ] README complete with screenshots
- [ ] ATTRIBUTIONS.md lists image sources
- [ ] App runs on Watch Simulator without crashes
- [ ] Tested on 41mm, 45mm, 49mm watch sizes
- [ ] Dark mode appearance verified
- [ ] VoiceOver labels added and tested
- [ ] No force unwraps in production code
- [ ] No `// TODO` comments remaining
- [ ] Git history clean (meaningful commit messages)
- [ ] No SwiftData migration warnings
- [ ] Storage monitoring alerts work correctly
- [ ] History deletion works
- [ ] Draw button provides haptic feedback
- [ ] Card animations smooth (no jank)
- [ ] All images load instantly (<16ms)

### Success Criteria

**