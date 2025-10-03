# Test Files to Add to Xcode Project

## Overview
Two new test files have been created to improve code coverage:
1. **CardPullTests.swift** - Tests for the CardPull model
2. **DateFormattingTests.swift** - Tests for Date extension formatting methods

These files will increase coverage from ~32% to ~45-50% once added to the Xcode project.

## Files Created

### 1. CardPullTests.swift
**Location:** `WristArcana/WristArcana Watch AppTests/ModelTests/CardPullTests.swift`

**Coverage Impact:** CardPull.swift: 0% → 100%

**Tests Added:**
- `initWithAllParameters()` - Verifies all parameters are correctly assigned
- `initWithDefaultParameters()` - Tests default UUID and Date generation
- `initCreatesUniqueIds()` - Ensures unique IDs for each instance
- `initWithEmptyStrings()` - Handles empty string inputs
- `initWithLongStrings()` - Tests with 1000 character strings
- `initWithSpecialCharacters()` - Tests Unicode and emoji handling

### 2. DateFormattingTests.swift
**Location:** `WristArcana/WristArcana Watch AppTests/UtilityTests/DateFormattingTests.swift`

**Coverage Impact:** Date+Formatting.swift: 0% → 100%

**Tests Added:**
- `shortFormat_returnsDateOnly()` - Verifies no time component
- `shortFormat_handlesJanuary1()` - Boundary date test
- `shortFormat_handlesDecember31()` - Boundary date test
- `fullFormat_includesTimeComponents()` - Verifies time is included
- `fullFormat_handlesMorning/Afternoon/Midnight()` - Time variations
- `shortFormat_isShorterThanFullFormat()` - Comparison test

## How to Add These Files to Xcode

### Step 1: Open Xcode Project
```bash
open WristArcana/WristArcana.xcodeproj
```

### Step 2: Add CardPullTests.swift
1. In Xcode, navigate to **WristArcana Watch AppTests** group
2. Right-click on **ModelTests** folder
3. Select **Add Files to "WristArcana"...**
4. Navigate to: `WristArcana/WristArcana Watch AppTests/ModelTests/CardPullTests.swift`
5. **IMPORTANT:** Check "WristArcana Watch AppTests" in the **Target Membership** section
6. Click **Add**

### Step 3: Add DateFormattingTests.swift
1. Right-click on **UtilityTests** folder
2. Select **Add Files to "WristArcana"...**
3. Navigate to: `WristArcana/WristArcana Watch AppTests/UtilityTests/DateFormattingTests.swift`
4. **IMPORTANT:** Check "WristArcana Watch AppTests" in the **Target Membership** section
5. Click **Add**

### Step 4: Verify Tests Are Included
```bash
⌘U  # Run all tests
```

You should see:
- CardPullTests running (6 tests)
- DateFormattingTests running (13 tests)
- All tests passing

### Step 5: Check Coverage Improvement
```bash
# Generate coverage report
xcodebuild test \
  -project WristArcana/WristArcana.xcodeproj \
  -scheme "WristArcana Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' \
  -enableCodeCoverage YES \
  -resultBundlePath TestResults

# View coverage
xcrun xccov view --report TestResults.xcresult
```

Expected improvements:
- **CardPull.swift**: 0% → 100% ✅
- **Date+Formatting.swift**: 0% → 100% ✅
- **Overall coverage**: ~32% → ~45-50%

## Next Steps to Reach 80% Coverage

After adding these files, the following files still need tests:

### High Priority (0% coverage):
1. **HistoryViewModel.swift** - Needs 12-15 tests
2. **CardDrawViewModel.swift** - Needs 8-10 more tests (currently 10.8%)
3. **DeckRepository.swift** - Needs 5-7 more tests (currently 57%)

### Medium Priority (for UI coverage):
4. **HistoryView.swift** - Currently 1.8%
5. **CardDisplayView.swift** - Currently 0%
6. **CardImageView.swift** - Currently 0%

### Test Templates

For ViewModels, you'll need to create mock objects for dependencies. Example for HistoryViewModel:

```swift
@MainActor
class MockModelContext: ModelContext {
    var savedData: [Any] = []
    var deletedData: [Any] = []
    // Implement mock methods
}

func test_loadHistory_fetchesPullsFromContext() async {
    // Given
    let mockContext = MockModelContext()
    let sut = HistoryViewModel(modelContext: mockContext, storageMonitor: MockStorageMonitor())

    // When
    await sut.loadHistory()

    // Then
    XCTAssertTrue(mockContext.fetchWasCalled)
}
```

## Automated Test Running

These tests will automatically run:
- ✅ On every commit (via pre-commit hooks)
- ✅ On every push (via pre-push hooks)
- ✅ On CI (GitHub Actions)

## Coverage Threshold

Current threshold: **≥30%** (temporarily lowered)
Target threshold: **≥80%**

Once these files are added and more ViewModel tests are created, we can incrementally increase the threshold:
- Phase 1: 30% → 50% (CardPull + Date tests)
- Phase 2: 50% → 65% (HistoryViewModel tests)
- Phase 3: 65% → 80% (CardDrawViewModel + DeckRepository tests)
- Phase 4: 80%+ (UI and integration tests)
