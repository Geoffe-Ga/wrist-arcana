# Code Coverage Gaps

**Current Overall Coverage: 49.54%**
**Minimum Threshold: 50%** (CI enforced)
**Target Goal: 60%+**

Status: ✅ Just below threshold - need +0.46% to pass pre-push hook

## Critical Gaps (Business Logic - HIGH PRIORITY)

### 1. CardRepository.swift (96% → 100%)
**Missing: 3 lines in `loadCards()` method**
- Lines 20-23: Error handling path for JSON decoding failure
- Status: Need test for malformed JSON input

### 2. ~~DeckSelectionViewModel.swift~~ ✅ **COMPLETED (0% → 100%)**
**All 45 lines now covered with 14 comprehensive tests**
- ✅ `init()` method - handles success, errors, empty decks
- ✅ `loadDecks()` method - populate, update, error handling
- ✅ `selectDeck()` method - updates ID, allows nil, multiple changes
- ✅ Integration test - full load-select-reload workflow
- Status: **100% coverage achieved** (PR #24)

### 3. CTAButton.swift (40% → 80%+)
**Missing: 9/15 lines**
- Loading state rendering path
- Body getter branches for disabled/loading states
- Status: Need component tests for loading state

### 4. HistoryRow.swift (50% → 80%+)
**Missing: 28/56 lines**
- Note display path
- Conditional rendering of truncated note
- Accessibility labels
- Status: Need component tests for note display

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

**To reach 50% threshold (immediate priority):**
1. ~~**DeckSelectionViewModel** (0% → 100%)~~ ✅ **COMPLETED** (+1.53%)
2. **CardRepository error handling** (96% → 100%) - 3 lines (~0.08%)

**To reach 60% goal (medium-term):**
1. **CTAButton loading state** (40% → 80%) - 9 lines (~0.25%)
2. **HistoryRow note display** (50% → 80%) - 14 lines (~0.39%)
3. **DrawCardView closures** (70% → 80%) - 50 lines (~1.39%)
4. **Additional component tests** - ~100 lines (~2.78%)

**Path to 60% = Current (49.54%) + High Priority (0.72%) + Component Tests (4.81%)**

## Already at 100% Coverage ✓

- CardPull.swift ✓
- WristArcanaApp.swift ✓
- CardReferenceViewModel.swift ✓
- RandomGenerator.swift ✓
- Date+Formatting.swift ✓
- CardDrawViewModel.swift ✓
- HistoryViewModel.swift ✓
- DeckSelectionViewModel.swift ✓ (NEW - PR #24)
- TarotCard.swift ✓
- TarotDeck.swift ✓
- DeckRepository.swift (96%, needs error case) ✓
- StorageMonitor.swift ✓
- NoteInputSanitizer.swift ✓
