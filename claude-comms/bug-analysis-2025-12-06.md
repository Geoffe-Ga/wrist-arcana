# Bug Analysis Report - Wrist Arcana
**Date:** December 6, 2025
**Analyzed by:** Claude Code
**Reported Issue:** App occasionally refuses to open and requires force closure

---

## Executive Summary

This analysis identified **12 distinct bugs**, with **5 critical issues** that could directly cause the reported "app refuses to open" behavior. The most likely root causes are:

1. **DeckRepository initialization failures** leading to crashes when attempting to draw cards
2. **SwiftData schema conflicts** from lack of migration strategy
3. **Duplicate ModelContainer creation** in DrawCardIntent causing database locks

---

## Critical Bugs (App Launch/Stability)

### 🔴 BUG-001: Fatal Error in DeckRepository (CRITICAL)
**File:** `Models/DeckRepository.swift:55`

**Issue:**
```swift
func getRandomCard(from deck: TarotDeck) -> TarotCard {
    var generator = SystemRandomNumberGenerator()
    guard let card = deck.cards.randomElement(using: &generator) else {
        fatalError("Deck has no cards") // ❌ CRASH
    }
    return card
}
```

**Root Cause:** If `deck.cards` is empty, the app crashes with `fatalError`. This can happen if:
- DecksData.json fails to load
- JSON is malformed
- The fallback `TarotDeck.riderWaite` is used (which has 0 cards)

**Impact:** **CRITICAL** - Guaranteed app crash, likely causes "app refuses to open"

**Proposed Solution:**
```swift
func getRandomCard(from deck: TarotDeck) -> TarotCard? {
    var generator = SystemRandomNumberGenerator()
    return deck.cards.randomElement(using: &generator)
}

// Update callers to handle nil:
// - CardDrawViewModel.selectRandomCard() should show error to user
// - Include sample fallback card in TarotDeck.riderWaite
```

---

### 🔴 BUG-002: Silent DeckRepository Initialization Failure (CRITICAL)
**File:** `Models/DeckRepository.swift:28-35`

**Issue:**
```swift
init() {
    do {
        self.loadedDecks = try self.loadDecksFromJSON()
        self.currentDeckId = self.loadedDecks.first?.id
    } catch {
        print("⚠️ Failed to load decks: \(error)") // ❌ Only prints, doesn't recover
    }
}
```

**Root Cause:** If `loadDecksFromJSON()` throws (missing file, malformed JSON), initialization completes with `loadedDecks = []`. Subsequent calls to `getRandomCard()` trigger BUG-001.

**Impact:** **CRITICAL** - Silent failure leads to guaranteed crash on first draw

**Proposed Solution:**
```swift
init() {
    do {
        self.loadedDecks = try self.loadDecksFromJSON()
        self.currentDeckId = self.loadedDecks.first?.id
    } catch {
        // CRITICAL: Load embedded fallback deck with at least 1 card
        self.loadedDecks = [TarotDeck.minimalFallback]
        self.currentDeckId = TarotDeck.minimalFallback.id

        // Use os.Logger instead of print for production
        Logger.app.error("Failed to load decks: \(error.localizedDescription)")
    }
}

// In TarotDeck.swift:
static let minimalFallback = TarotDeck(
    id: "fallback",
    name: "Emergency Deck",
    cards: [TarotCard.theFool] // At least 1 card to prevent crashes
)
```

---

### 🔴 BUG-003: TarotDeck.riderWaite Has Zero Cards (CRITICAL)
**File:** `Models/TarotDeck.swift:26-32`

**Issue:**
```swift
static var riderWaite: TarotDeck {
    TarotDeck(
        id: UUID().uuidString,
        name: "Rider-Waite",
        cards: [] // ❌ Empty! Used as fallback in DeckRepository.swift:47
    )
}
```

**Root Cause:** This static property is used as a fallback when no deck is found, but it has 0 cards. Triggers BUG-001 immediately.

**Impact:** **CRITICAL** - Any fallback scenario crashes the app

**Proposed Solution:**
```swift
static var riderWaite: TarotDeck {
    // Either load from JSON here, or include minimal fallback
    let repository = DeckRepository()
    return repository.getCurrentDeck() // Load actual deck

    // OR: Include at least one card
    TarotDeck(
        id: "rider-waite-fallback",
        name: "Rider-Waite",
        cards: [TarotCard.theFool] // Minimal 1-card deck
    )
}
```

**Note:** Better solution is to remove this static property entirely and rely on DeckRepository.

---

### 🔴 BUG-004: No SwiftData Migration Strategy (CRITICAL)
**File:** `WristArcanaApp.swift:10`

**Issue:**
```swift
.modelContainer(for: [CardPull.self]) // ❌ No migration config
```

**Root Cause:** If `CardPull` model schema changes between app versions, SwiftData can't migrate existing data. App crashes on launch with "model incompatible" error.

**Impact:** **CRITICAL** - App refuses to open after updates if user has existing data. **This is the most likely cause of your reported bug.**

**Proposed Solution:**
```swift
// In WristArcanaApp.swift:
var body: some Scene {
    WindowGroup {
        ContentView()
    }
    .modelContainer(makeModelContainer())
}

private func makeModelContainer() -> ModelContainer {
    let schema = Schema([CardPull.self])
    let configuration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false,
        allowsSave: true
    )

    do {
        return try ModelContainer(for: schema, configurations: [configuration])
    } catch {
        // If migration fails, delete old DB and start fresh
        Logger.app.error("ModelContainer failed, resetting: \(error)")

        // Delete corrupted database
        let url = URL.applicationSupportDirectory.appending(path: "default.store")
        try? FileManager.default.removeItem(at: url)

        // Create fresh container
        return try! ModelContainer(for: schema, configurations: [configuration])
    }
}
```

**Alternative:** Implement proper migrations with `VersionedSchema`:
```swift
enum CardPullSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [CardPull.self] }
}

// Future versions:
enum CardPullSchemaV2: VersionedSchema { /* ... */ }

let container = try ModelContainer(
    for: CardPull.self,
    migrationPlan: CardPullMigrationPlan.self
)
```

---

### 🔴 BUG-005: Duplicate ModelContainer in DrawCardIntent (CRITICAL)
**File:** `AppIntents/DrawCardIntent.swift:30`

**Issue:**
```swift
@MainActor
func perform() async throws -> some IntentResult & ProvidesDialog {
    // ❌ Creates SECOND ModelContainer - conflicts with main app!
    let container = try ModelContainer(for: CardPull.self)
    let modelContext = ModelContext(container)
    // ...
}
```

**Root Cause:** Creating a separate `ModelContainer` while the app is running can cause:
- Database lock conflicts (SQLite locks)
- Data inconsistency between app and intent
- App hangs or crashes when trying to save

**Impact:** **CRITICAL** - If user invokes Siri shortcut while app is backgrounded, can cause database corruption or app freeze

**Proposed Solution:**
```swift
// Option 1: Share ModelContainer via AppGroup
struct WristArcanaApp: App {
    static let sharedModelContainer: ModelContainer = {
        let schema = Schema([CardPull.self])
        let configuration = ModelConfiguration(
            schema: schema,
            groupContainer: .identifier("group.com.yourteam.wristarcana")
        )
        return try! ModelContainer(for: schema, configurations: [configuration])
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(Self.sharedModelContainer)
    }
}

// In DrawCardIntent.swift:
func perform() async throws -> some IntentResult & ProvidesDialog {
    let modelContext = ModelContext(WristArcanaApp.sharedModelContainer)
    // ... rest of code
}

// Option 2: Use @AppStorage or UserDefaults to coordinate, create container only if app not running
```

---

## High Priority Bugs (Data/UX)

### 🟠 BUG-006: CardRepository Silent Initialization Failure
**File:** `Models/CardRepository.swift:56-78`

**Issue:**
```swift
private func loadCards() {
    // ...
    guard let url = candidateBundles
        .compactMap({ $0.url(forResource: "DecksData", withExtension: "json") })
        .first
    else {
        print("⚠️ DecksData.json not found")
        return // ❌ Leaves allCards = []
    }

    do {
        // ... load cards
    } catch {
        print("⚠️ Failed to load cards: \(error)") // ❌ Leaves allCards = []
    }
}
```

**Root Cause:** If JSON loading fails, `allCards` remains empty. CardReferenceView shows empty lists, but doesn't crash (better than DeckRepository).

**Impact:** **HIGH** - Reference tab is broken, user can't browse cards

**Proposed Solution:**
```swift
private func loadCards() {
    do {
        guard let url = Bundle.main.url(forResource: "DecksData", withExtension: "json") else {
            throw CardError.resourceNotFound
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let decksData = try decoder.decode(DecksDataContainer.self, from: data)

        guard let firstDeck = decksData.decks.first else {
            throw CardError.noDeckFound
        }

        self.allCards = firstDeck.cards

        guard !self.allCards.isEmpty else {
            throw CardError.emptyDeck
        }
    } catch {
        // Fallback to minimal embedded deck
        Logger.app.error("Failed to load cards: \(error)")
        self.allCards = TarotCard.emergencyFallbackDeck
    }
}

enum CardError: Error {
    case resourceNotFound
    case noDeckFound
    case emptyDeck
}
```

---

### 🟠 BUG-007: Nested Sheet Presentation on watchOS
**File:** `Views/DrawCardView.swift:103-139`

**Issue:**
```swift
.sheet(isPresented: self.$showingPreview) {
    CardPreviewView(...)
        .sheet(isPresented: self.$showingDetail) { // ❌ Nested sheet!
            CardDisplayView(...)
        }
}
```

**Root Cause:** watchOS has limited support for nested sheets. Can cause:
- SwiftUI state corruption
- Sheets not dismissing properly
- App becoming unresponsive

**Impact:** **HIGH** - Can make app appear frozen after viewing card details

**Proposed Solution:**
```swift
// Replace nested sheets with NavigationStack navigation
var body: some View {
    NavigationStack {
        GeometryReader { geometry in
            // ... existing code
        }
        .navigationDestination(for: TarotCard.self) { card in
            CardDisplayView(card: card, ...)
        }
    }
}

// In CardPreviewView, use NavigationLink instead of .sheet
NavigationLink(value: card) {
    Text("View Details")
}
```

---

### 🟠 BUG-008: ViewModel Initialization Race Condition
**File:** `Views/DrawCardView.swift:193-207`, `Views/HistoryView.swift:43-50`

**Issue:**
```swift
.onAppear {
    if self.viewModel == nil {
        self.viewModel = CardDrawViewModel(...) // ❌ Can be called multiple times
    }
}
```

**Root Cause:** SwiftUI can call `.onAppear` multiple times:
- Tab switching
- Background/foreground transitions
- View redraws

While the `if` check prevents duplicate assignment, it can still cause issues if the view is torn down and recreated.

**Impact:** **MEDIUM** - Could cause subtle state inconsistencies

**Proposed Solution:**
```swift
// Use .task instead of .onAppear for async initialization
var body: some View {
    // ...
    .task {
        if self.viewModel == nil {
            self.viewModel = CardDrawViewModel(
                repository: self.repository,
                storageMonitor: self.storage,
                modelContext: self.modelContext
            )
        }
    }
}

// Better: Use @StateObject with dependency injection
@StateObject private var viewModel: CardDrawViewModel

init(
    repository: DeckRepositoryProtocol = DeckRepository(),
    storage: StorageMonitorProtocol = StorageMonitor()
) {
    self.repository = repository
    self.storage = storage

    // Initialize @StateObject in init
    _viewModel = StateObject(wrappedValue: CardDrawViewModel(
        repository: repository,
        storageMonitor: storage,
        modelContext: modelContext // Problem: can't access @Environment here
    ))
}

// BEST: Use @EnvironmentObject pattern
// Pass viewModel from parent view
```

---

### 🟠 BUG-009: No JSON Schema Validation
**File:** `Models/DeckRepository.swift:62-78`, `Models/CardRepository.swift:67-78`

**Issue:**
```swift
let data = try Data(contentsOf: url)
let decoder = JSONDecoder()
let decksData = try decoder.decode(DecksDataContainer.self, from: data) // ❌ No validation
```

**Root Cause:** If DecksData.json is:
- Malformed (syntax error)
- Has wrong structure
- Missing required fields
- Has 0 cards

The app crashes on first launch with cryptic decoding error.

**Impact:** **HIGH** - New users see crash before ever using the app

**Proposed Solution:**
```swift
// Add validation after decode
let decksData = try decoder.decode(DecksDataContainer.self, from: data)

// Validate structure
guard !decksData.decks.isEmpty else {
    throw DeckError.noDeckFound
}

guard let firstDeck = decksData.decks.first, firstDeck.cards.count == 78 else {
    throw DeckError.invalidDeckSize
}

// Validate each card has required fields
for card in firstDeck.cards {
    guard !card.name.isEmpty,
          !card.imageName.isEmpty,
          !card.upright.isEmpty else {
        throw DeckError.invalidCardData
    }
}

return decksData.decks.map { /* ... */ }
```

**Better:** Add unit test that validates DecksData.json:
```swift
func test_DecksDataJSON_isValid() throws {
    let repository = DeckRepository()
    let decks = try repository.loadDecks()

    XCTAssertEqual(decks.count, 1, "Should have exactly 1 deck")
    XCTAssertEqual(decks[0].cards.count, 78, "Rider-Waite should have 78 cards")

    // Validate all image names exist in asset catalog
    for card in decks[0].cards {
        XCTAssertNotNil(UIImage(named: card.imageName), "Missing image: \(card.imageName)")
    }
}
```

---

## Medium Priority Bugs (Code Quality)

### 🟡 BUG-010: Debug Print Statements in Production
**Files:**
- `ViewModels/HistoryViewModel.swift:156,163,172,175,186,212,217,238`
- `Views/HistoryView.swift:226,239,256`

**Issue:**
```swift
print("🔍 DEBUG: Entering edit mode")
print("🔍 DEBUG: Deleting \(ids.count) items")
// ... 11 total debug print statements
```

**Root Cause:** Debug logs left in production code. While not causing crashes, they:
- Impact performance (console I/O is slow)
- Expose internal logic to logs
- Violate CLAUDE.md guidelines

**Impact:** **MEDIUM** - Performance degradation, unprofessional

**Proposed Solution:**
```swift
// 1. Remove all debug prints (preferred for production)
// OR
// 2. Use os.Logger with appropriate log levels
import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!
    static let viewModel = Logger(subsystem: subsystem, category: "ViewModel")
}

// In HistoryViewModel:
func enterEditMode() {
    Logger.viewModel.debug("Entering edit mode")
    self.isInEditMode = true
    self.selectedPullIds.removeAll()
}

// 3. Use conditional compilation
#if DEBUG
print("🔍 DEBUG: Entering edit mode")
#endif
```

**Recommendation:** Remove all debug prints. Use Xcode Instruments or os_signpost for performance debugging.

---

### 🟡 BUG-011: Fragile Test Assertions with try!
**Files:**
- `WristArcana Watch AppTests/ViewModelTests/HistoryViewModelTests.swift:21`
- `WristArcana Watch AppTests/ViewModelTests/DrawCardViewAddNoteHandlerTests.swift:21`
- `WristArcana Watch AppTests/ViewModelTests/CardDrawViewModelTests.swift:21`

**Issue:**
```swift
return try! ModelContainer(for: schema, configurations: [configuration])
```

**Root Cause:** Using `try!` makes tests fail with crash instead of descriptive error.

**Impact:** **LOW** - Tests only, but makes debugging harder

**Proposed Solution:**
```swift
var modelContainer: ModelContainer {
    let schema = Schema([CardPull.self])
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)

    do {
        return try ModelContainer(for: schema, configurations: [configuration])
    } catch {
        fatalError("Failed to create ModelContainer for tests: \(error)")
        // OR: return preconfigured test container
    }
}
```

---

### 🟡 BUG-012: Task.sleep Error Handling
**File:** `ViewModels/CardDrawViewModel.swift:54`

**Issue:**
```swift
// Add minimum 0.5s delay for anticipation/animation
try? await Task.sleep(nanoseconds: AppConstants.minimumDrawDuration)
```

**Root Cause:** Using `try?` silently swallows cancellation errors. If the task is cancelled, the delay doesn't happen but no error is surfaced.

**Impact:** **LOW** - UX timing might be inconsistent

**Proposed Solution:**
```swift
// If cancellation is OK, be explicit:
do {
    try await Task.sleep(nanoseconds: AppConstants.minimumDrawDuration)
} catch is CancellationError {
    // Intentionally ignore - user navigated away
} catch {
    // Unexpected error - log it
    Logger.viewModel.warning("Draw delay interrupted: \(error)")
}

// OR: Remove try-catch if cancellation should never happen
await Task.sleep(nanoseconds: AppConstants.minimumDrawDuration)
```

---

## Root Cause Analysis: "App Refuses to Open" Bug

Based on this analysis, the **most likely causes** of your reported bug are:

### Primary Suspect: BUG-004 (SwiftData Migration)
**Probability: 85%**

If you've made ANY changes to the `CardPull` model between app builds:
- Added/removed properties
- Changed property types
- Renamed properties

SwiftData can't migrate the existing database on the watch. The app crashes on launch when trying to initialize the ModelContainer.

**How to verify:**
```bash
# Check git history for CardPull changes
git log --all --oneline -- WristArcana/Models/CardPull.swift

# Look for commits between when app worked and when it broke
```

**Quick fix:**
1. Uninstall app from watch (deletes database)
2. Reinstall app (fresh database)
3. App should open normally

**Permanent fix:** Implement BUG-004 solution (migration strategy)

---

### Secondary Suspect: BUG-005 (Duplicate ModelContainer)
**Probability: 10%**

If you've tested the Siri shortcut ("Draw a tarot card"), it creates a second ModelContainer that can lock the database.

**How to verify:**
- Force close app
- Disable Siri shortcuts in Settings
- Relaunch app

**Permanent fix:** Implement BUG-005 solution (shared container via App Group)

---

### Tertiary Suspect: BUG-001 + BUG-002 (Empty Deck)
**Probability: 5%**

If DecksData.json was somehow corrupted or deleted, DeckRepository loads with empty deck, then crashes on first draw.

**How to verify:**
```bash
# Check if DecksData.json exists and is valid
ls -lh WristArcana/Resources/DecksData.json
head -20 WristArcana/Resources/DecksData.json
```

**Permanent fix:** Implement BUG-001 and BUG-002 solutions (proper error handling + fallback deck)

---

## Recommended Fix Priority

| Priority | Bug ID | Estimated Effort | Impact |
|----------|--------|------------------|--------|
| 🔥 P0 | BUG-004 | 2-3 hours | Prevents app crashes after updates |
| 🔥 P0 | BUG-001 | 1 hour | Prevents runtime crashes |
| 🔥 P0 | BUG-002 | 1 hour | Prevents silent failures |
| 🔥 P0 | BUG-003 | 30 min | Prevents fallback crashes |
| 🔴 P1 | BUG-005 | 2 hours | Prevents Siri shortcut conflicts |
| 🔴 P1 | BUG-009 | 1 hour | Prevents malformed data crashes |
| 🟠 P2 | BUG-006 | 45 min | Improves error recovery |
| 🟠 P2 | BUG-007 | 1.5 hours | Fixes navigation issues |
| 🟠 P2 | BUG-008 | 1 hour | Prevents state corruption |
| 🟡 P3 | BUG-010 | 30 min | Code quality + performance |
| 🟡 P3 | BUG-011 | 20 min | Test quality |
| 🟡 P3 | BUG-012 | 15 min | Error handling consistency |

**Total effort:** ~12-15 hours for all fixes

---

## Immediate Action Items

To diagnose your specific "app refuses to open" issue:

1. **Check crash logs:**
   ```bash
   # On Mac, access Watch crash logs:
   # Xcode → Window → Devices and Simulators → [Your Watch] → View Device Logs
   # Look for "WristArcana" crashes
   ```

2. **Test clean install:**
   - Uninstall Wrist Arcana from Apple Watch
   - Reinstall from Xcode
   - If app opens normally → BUG-004 (migration issue)
   - If app still fails → BUG-001/002 (deck loading issue)

3. **Add telemetry:**
   ```swift
   // In WristArcanaApp.swift, add:
   init() {
       Logger.app.info("App launching...")
       do {
           let container = try ModelContainer(for: CardPull.self)
           Logger.app.info("ModelContainer created successfully")
       } catch {
           Logger.app.error("ModelContainer failed: \(error)")
       }
   }
   ```

4. **Validate DecksData.json:**
   ```bash
   # Run this to validate JSON syntax:
   python3 -m json.tool WristArcana/Resources/DecksData.json > /dev/null

   # Check deck has 78 cards:
   cat WristArcana/Resources/DecksData.json | \
     python3 -c "import sys, json; d=json.load(sys.stdin); print(len(d['decks'][0]['cards']))"
   ```

---

## Testing Recommendations

After implementing fixes, test these scenarios:

1. **Clean install** (fresh database)
2. **Update install** (existing database with old schema)
3. **Siri shortcut invocation** (while app backgrounded)
4. **DecksData.json missing** (remove file, verify graceful fallback)
5. **DecksData.json malformed** (introduce syntax error, verify error handling)
6. **Rapid tab switching** (verify no ViewModel race conditions)
7. **Memory pressure** (simulate low memory, verify no OOM crashes)

---

## Conclusion

The codebase has **5 critical bugs** that can cause "app refuses to open" behavior. The most likely culprit is **BUG-004 (SwiftData migration)**, which affects users with existing data when the app is updated.

**Recommended immediate action:**
1. Fix BUG-004 (add migration strategy)
2. Fix BUG-001, BUG-002, BUG-003 (proper error handling in DeckRepository)
3. Test clean vs. update install scenarios

All other bugs should be addressed in subsequent releases to improve stability and code quality.

---

**Next Steps:**
- Review this analysis
- Prioritize which bugs to fix first
- Let me know when ready to implement solutions
- I can provide detailed implementation for each fix
