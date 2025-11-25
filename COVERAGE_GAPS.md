# Code Coverage Gaps

**Current Overall Coverage: 53.60%**
**Minimum Threshold: 50%** (CI enforced)
**Target Goal: 60%+**

Status: ✅ **PASSING** - Above 50% threshold! (+3.60% buffer)

## Critical Gaps (Business Logic - HIGH PRIORITY)

### 1. CardRepository.swift (93.33% - ACTUAL)
**Missing: 5/75 lines**
- Error handling paths for JSON decoding/bundle loading failures
- Status: Complex to test without refactoring (requires mocking Bundle/FileManager)
- Priority: Low (error paths are defensive code, not core business logic)

### 2. ~~DeckSelectionViewModel.swift~~ ✅ **COMPLETED (0% → 100%)**
**All 20 lines now covered with 14 comprehensive tests**
- ✅ `init()` method - handles success, errors, empty decks
- ✅ `loadDecks()` method - populate, update, error handling
- ✅ `selectDeck()` method - updates ID, allows nil, multiple changes
- ✅ Integration test - full load-select-reload workflow
- Status: **100% coverage achieved**

### 3. ~~HistoryViewModel.swift~~ ✅ **SIGNIFICANTLY IMPROVED (0% → 95.48%)**
**190/199 lines covered with 49 comprehensive tests**
- ✅ Multi-select functionality (enterEditMode, exitEditMode, toggleSelection) - 23 new tests
- ✅ History management (loadHistory, deletePull, pruneOldestPulls)
- ✅ Note management (startAddingNote, saveNote, deleteNote)
- ✅ Storage monitoring integration
- Missing: 9 lines (mostly edge cases in saveNote/deleteMultiplePulls)
- Status: **95%+ coverage achieved**

### 4. CardDrawViewModel.swift (94.94% - ACTUAL)
**Missing: 4/79 lines**
- Minimal gaps in edge case handling
- Status: Near-complete coverage, remaining gaps are minor

### 5. CTAButton.swift (96.15% - ACTUAL, NOT 40%)
**Missing: 2/52 lines**
- Minor SwiftUI body getter branches
- Status: Excellent coverage for a UI component

### 6. HistoryRow.swift (0% - ACTUAL, NOT 50%)
**Missing: 113/113 lines**
- Pure SwiftUI component with note display, truncation, accessibility
- Status: UI component - low priority for unit tests, should use UI tests

## Medium Priority (UI Components - Target 60%)

### 5. DrawCardView.swift (70.69% → 75%+)
**Missing: 148/505 lines (mostly UI closures)**
- Card preview modal display logic
- Card detail sheet presentation
- Note editor sheet presentation
- Storage warning alert
- Status: Some closures need UI tests, some can be unit tested

## Low Priority (Pure UI Code - Target 30-40%)

These are SwiftUI View body getters with minimal business logic. Coverage via UI tests is sufficient:

- CardListView.swift (0/61) - UI only
- CardReferenceDetailView.swift (0/266) - UI only
- CardReferenceView.swift (0/178) - UI only
- FlowLayout.swift (0/60) - Layout helper
- CardImageView.swift (0/71) - Image component
- NoteEditorView.swift (0/155) - UI only
- HistoryView.swift (3/587) - UI only
- CardPreviewView.swift (0/119) - UI only
- HistoryDetailView.swift (0/160) - UI only
- MainView.swift (0/122) - UI only
- ContentView.swift (0/36) - App root view
- DeckSelectionView.swift (0/71) - UI only

## Summary

**Recent Achievements:**
1. ~~**DeckSelectionViewModel** (0% → 100%)~~ ✅ **COMPLETED** - 14 tests, 20 lines (+0.55%)
2. ~~**HistoryViewModel multi-select** (0% → 95.48%)~~ ✅ **COMPLETED** - 23 tests, 46 lines (+1.28%)
3. **Overall Coverage: 49.54% → 53.60%** ✅ **PASSING 50% THRESHOLD** (+4.06%)

**To reach 60% goal (medium-term):**
1. **DrawCardView UI closures** (70.69% → 80%) - ~50 lines (~1.39%)
2. **Component UI tests** (HistoryRow, CTAButton, CardImageView) - ~150 lines (~4.17%)
3. **StorageMonitor edge cases** (79.49% → 90%) - ~4 lines (~0.11%)
4. **ViewModel edge cases** (CardDrawViewModel, HistoryViewModel) - ~13 lines (~0.36%)

**Path to 60% = Current (53.60%) + Component Tests (~4.17%) + Edge Cases (~1.86%) = ~59.63%**

**Note:** Remaining ~0.40% can come from minor improvements across all categories or accepting 59.6% as "close enough" given diminishing returns on UI test coverage.

## Already at 100% Coverage ✓

**Models:**
- CardPull.swift ✓ (21/21 lines)

**ViewModels:**
- CardReferenceViewModel.swift ✓ (22/22 lines)
- DeckSelectionViewModel.swift ✓ (20/20 lines) - **NEW** from this PR

**Views:**
- WristArcanaApp.swift ✓ (9/9 lines)
- ContentView.swift ✓ (3/3 lines)
- MainView.swift ✓ (51/51 lines)

**Utilities:**
- RandomGenerator.swift ✓ (5/5 lines)
- Date+Formatting.swift ✓ (12/12 lines)
- NoteInputSanitizer.swift ✓ (42/42 lines)

## Near-Perfect Coverage (95%+) ✓

**ViewModels (Business Logic):**
- HistoryViewModel.swift - 95.48% (190/199 lines) - **IMPROVED** from 0% this PR
- CardDrawViewModel.swift - 94.94% (75/79 lines)

**Components:**
- CTAButton.swift - 96.15% (50/52 lines)

**Models:**
- CardRepository.swift - 93.33% (70/75 lines)
