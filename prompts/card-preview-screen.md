# Card Preview Screen Implementation Plan

## Status: ✅ READY FOR IMPLEMENTATION

This plan has been **validated against the actual codebase** (as of 2025-11-24). All architectural assumptions have been confirmed, and implementation-specific details have been updated with references to actual code.

### Quick Reference for GitHub Issues

| Issue | Scope | LOC | Dependencies | Est. Time |
|-------|-------|-----|--------------|-----------|
| #1 | Create CardPreviewView.swift | ~60 | None | 2-3h |
| #2 | Update DrawCardView navigation | ~20 | Issue #1 | 1-2h |
| #3 | Add UI tests | ~100 | Issues #1, #2 | 2-3h |
| #4 | Manual testing & polish | N/A | Issues #1-3 | 1-2h |

**Total Estimated Effort:** 4-6 hours core implementation + 2-3 hours testing = **6-9 hours total**

---

## Overview

Add an intermediary full-screen card preview view that appears immediately after drawing a card, before the detailed CardDisplayView. This provides a more progressive disclosure of information and gives users control over whether they want additional card details.

**Current Implementation Status:**
- ✅ CardDrawViewModel saves to history immediately (CardDrawViewModel.swift:64)
- ✅ CardPull model has optional `note` field (CardPull.swift:19)
- ✅ CardDisplayView supports adding/editing notes (CardDisplayView.swift:43-86)
- ✅ CardImageView component exists and can be reused (Components/CardImageView.swift)
- ❌ CardPreviewView does NOT exist (needs to be created)
- ❌ DrawCardView uses single sheet presentation (needs nested sheets)

## User Flow

```
DrawCardView (DRAW button)
    ↓ (tap DRAW → card saved to history immediately)
CardPreviewView (full-height card image only)
    ↓ (tap card OR tap Detail button)
CardDisplayView (card + name + meaning + notes)
    ↓ (tap Done → dismisses both sheets)
DrawCardView
```

**Alternative exit from CardPreviewView:**
```
CardPreviewView
    ↓ (tap Done button → card already saved to history)
DrawCardView (skip CardDisplayView entirely)
```

**Key behaviors:**
- ✅ Card is saved to history **immediately when drawn** (before any sheets appear)
- ✅ Done on CardDisplayView returns **directly to DrawCardView** (not to CardPreviewView)
- ✅ Done on CardPreviewView also returns to DrawCardView
- ✅ History persistence happens regardless of which Done button is pressed

## Architecture Changes

### Navigation State Management

**✅ ACTUAL Current state in DrawCardView (DrawCardView.swift:20-22):**
```swift
@State private var showingCard = false          // Controls CardDisplayView sheet
@State private var pendingNotePull: CardPull?   // For note-taking workflow
@State private var showNoteEditor = false       // Controls NoteEditorView sheet
```

**New state structure (RECOMMENDED):**
```swift
@State private var showingPreview = false       // Controls CardPreviewView sheet
@State private var showingDetail = false        // Controls CardDisplayView sheet
@State private var pendingNotePull: CardPull?   // Keep existing note workflow
@State private var showNoteEditor = false       // Keep existing note editor
```

**Note:** The `navigationPath` approach is NOT recommended. The nested sheet approach matches the existing codebase pattern and is simpler for this use case.

### View Hierarchy

**✅ ACTUAL Current (DrawCardView.swift:73-92):**
```
DrawCardView
  ├─ .sheet(showingCard) → CardDisplayView
  └─ .sheet(showNoteEditor) → NoteEditorView
```

**New (RECOMMENDED):**
```
DrawCardView
  ├─ .sheet(showingPreview) → CardPreviewView
  │    └─ .sheet(showingDetail) → CardDisplayView
  └─ .sheet(showNoteEditor) → NoteEditorView (unchanged)
```

**Important:** The note editor sheet workflow should remain unchanged. It's triggered by `onChange(of: showingCard)` (line 93) and works correctly with the existing flow.

## Component Specifications

### 1. CardPreviewView (New Component)

**❌ DOES NOT EXIST - NEEDS TO BE CREATED**

**Location:** `WristArcana/Views/CardPreviewView.swift`

**Purpose:** Display only the card image in full-screen format with minimal chrome

**UI Elements:**
- Full-height card image (maximized for watch screen) - REUSE CardImageView component
- Toolbar with two buttons:
  - **Left:** "Done" button → dismisses to DrawCardView
  - **Right:** "Detail" button (info.circle icon) → presents CardDisplayView

**Interactions:**
- Tap card image → presents CardDisplayView
- Tap Done → dismisses preview, returns to DrawCardView
- Tap Detail → presents CardDisplayView over preview

**Implementation (DEFINITIVE - matches existing patterns):**
```swift
//
//  CardPreviewView.swift
//  WristArcana
//
//  Created by Geoff Gallinger on [DATE]
//

import SwiftUI

struct CardPreviewView: View {
    // MARK: - Properties

    let card: TarotCard
    let onDismiss: () -> Void
    let onShowDetail: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Full-height card image (tappable)
            Button(action: self.onShowDetail) {
                CardImageView(imageName: self.card.imageName, cardName: self.card.name)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(0.6, contentMode: .fit)
            }
            .buttonStyle(.plain)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    self.onDismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button {
                    self.onShowDetail()
                } label: {
                    Image(systemName: "info.circle")
                }
                .accessibilityLabel("Show card details")
                .accessibilityHint("Opens detailed view with card meaning and description")
            }
        }
        .background(Color.black.opacity(0.9))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Card preview for \(self.card.name). Tap to view detailed meaning.")
    }
}

#Preview {
    NavigationStack {
        CardPreviewView(
            card: TarotCard(
                name: "The Fool",
                imageName: "major_00",
                suit: .majorArcana,
                number: 0,
                upright: "New beginnings, optimism, trust in life",
                reversed: "Recklessness, taken advantage of, inconsideration",
                keywords: ["New Beginnings", "Optimism", "Trust"]
            ),
            onDismiss: {},
            onShowDetail: {}
        )
    }
}
```

**Key implementation notes:**
1. Uses `self.` prefix consistently (matches CardDisplayView.swift pattern)
2. Includes MARK comments for organization (matches all View files)
3. Reuses existing CardImageView component (Components/CardImageView.swift)
4. Includes accessibility labels (matches CardDisplayView.swift:99-100)
5. Includes #Preview (standard in all View files)
6. Uses `.plain` buttonStyle to make card tappable without visual button chrome

### 2. Updated DrawCardView

**✅ ACTUAL Current Implementation (DrawCardView.swift:52-64, 73-92):**

The current implementation directly shows CardDisplayView after drawing a card. The DRAW button action is:
```swift
CTAButton(
    title: "DRAW",
    isLoading: viewModel.isDrawing,
    action: {
        Task {
            await viewModel.drawCard()
            if viewModel.currentCard != nil {
                self.showingCard = true  // Line 60
            }
        }
    }
)
```

And the sheet presentation is:
```swift
.sheet(isPresented: self.$showingCard) {  // Line 73
    if let card = viewModel?.currentCard {
        let dismissCard: () -> Void = {
            self.showingCard = false
            self.viewModel?.dismissCard()
        }

        CardDisplayView(
            card: card,
            cardPull: self.viewModel?.currentCardPull,
            onAddNote: makeAddNoteHandler(...),
            onDismiss: dismissCard
        )
    }
}
```

**REQUIRED Changes (DEFINITIVE):**

1. **Change state variable names (DrawCardView.swift:20):**
   ```swift
   // OLD:
   @State private var showingCard = false

   // NEW:
   @State private var showingPreview = false
   @State private var showingDetail = false
   ```

2. **Update DRAW button action (DrawCardView.swift:56-63):**
   ```swift
   // OLD:
   action: {
       Task {
           await viewModel.drawCard()
           if viewModel.currentCard != nil {
               self.showingCard = true
           }
       }
   }

   // NEW:
   action: {
       Task {
           await viewModel.drawCard()
           if viewModel.currentCard != nil {
               self.showingPreview = true  // Changed from showingCard
           }
       }
   }
   ```

3. **Replace sheet presentation (DrawCardView.swift:73-92):**
   ```swift
   // NEW IMPLEMENTATION:
   .sheet(isPresented: self.$showingPreview) {
       if let card = viewModel?.currentCard {
           let dismissCard: () -> Void = {
               self.showingPreview = false
               self.viewModel?.dismissCard()
           }

           CardPreviewView(
               card: card,
               onDismiss: dismissCard,
               onShowDetail: {
                   self.showingDetail = true
               }
           )
           .sheet(isPresented: self.$showingDetail) {
               CardDisplayView(
                   card: card,
                   cardPull: self.viewModel?.currentCardPull,
                   onAddNote: makeAddNoteHandler(
                       stageNote: { pull in
                           self.pendingNotePull = pull
                       },
                       dismissCard: {
                           // Dismiss BOTH sheets
                           self.showingDetail = false
                           self.showingPreview = false
                           self.viewModel?.dismissCard()
                       }
                   ),
                   onDismiss: {
                       // Dismiss BOTH sheets, return directly to DrawCardView
                       self.showingDetail = false
                       self.showingPreview = false
                       self.viewModel?.dismissCard()
                   }
               )
           }
       }
   }
   ```

4. **Update onChange handler (DrawCardView.swift:93-103):**
   ```swift
   // OLD:
   .onChange(of: self.showingCard) { _, isShowingCard in
       guard !isShowingCard, ...
   }

   // NEW (need to track EITHER sheet dismissing):
   .onChange(of: self.showingPreview) { _, isShowing in
       guard !isShowing, !self.showingDetail,
             let histViewModel = self.historyViewModel,
             let pull = drainPendingNotePull(&self.pendingNotePull)
       else {
           return
       }

       histViewModel.startAddingNote(to: pull)
       self.showNoteEditor = true
   }
   ```

**CRITICAL:** The note editor workflow must check that BOTH sheets are dismissed before showing the note editor, otherwise it may conflict with nested sheet presentation.

### 3. CardDisplayView - NO CHANGES REQUIRED

**✅ ACTUAL Current Implementation (CardDisplayView.swift):**

CardDisplayView is already correctly implemented with:
- Card image display (line 24-27)
- Card name and meaning (lines 30-41)
- Note section with Add/Edit functionality (lines 43-86)
- Done button in toolbar (lines 92-97)
- Proper accessibility labels (lines 99-100)

**No code changes needed** to CardDisplayView itself. The behavioral change (dismissing both sheets) is handled entirely in DrawCardView's callbacks.

**Navigation behavior:**
- **From CardPreviewView:** User taps Done → dismisses only preview sheet → back to DrawCardView
- **From CardDisplayView:** User taps Done → dismisses BOTH sheets simultaneously → back to DrawCardView (not back to preview)

This dual-dismissal behavior is implemented by setting both `showingDetail = false` AND `showingPreview = false` in the onDismiss callback (see DrawCardView changes above).

## UI/UX Considerations

### Visual Design

**CardPreviewView styling:**
- **Background:** Dark (`.black.opacity(0.9)`) to make card pop
- **Card size:** As large as possible while maintaining aspect ratio (0.6)
- **Padding:** Minimal (8-12pt) to maximize card visibility
- **Animation:** Smooth sheet presentation (default watchOS behavior)

**Toolbar layout:**
```
┌─────────────────────────────┐
│ Done              [i] Detail│  ← Toolbar
├─────────────────────────────┤
│                             │
│        ┌───────┐            │
│        │       │            │
│        │ CARD  │            │  ← Tappable card image
│        │ IMAGE │            │
│        │       │            │
│        └───────┘            │
│                             │
└─────────────────────────────┘
```

### Interaction Patterns

1. **Primary action (tap card):** Most users will tap the card itself to see details
2. **Secondary action (Detail button):** Provides explicit control for users who prefer buttons
3. **Exit action (Done):** Allows users to dismiss without seeing full details

### History Persistence

**✅ ALREADY CORRECTLY IMPLEMENTED (CardDrawViewModel.swift:109-123)**

The card is saved to the history database **immediately when drawn**, not when the user taps Done.

**Actual implementation in CardDrawViewModel.drawCard():**
```swift
func drawCard() async {
    // ... randomization logic ...

    self.currentCard = card
    self.drawnCardsThisSession.insert(card.id)

    // Save to history IMMEDIATELY (line 64)
    try await self.saveToHistory(card: card, deck: deck)

    // ... storage check, haptic feedback ...
}

private func saveToHistory(card: TarotCard, deck: TarotDeck) async throws {
    let pull = CardPull(
        date: Date(),
        cardName: card.name,
        deckName: deck.name,
        cardImageName: card.imageName,
        cardDescription: card.upright
    )

    self.modelContext.insert(pull)
    try self.modelContext.save()

    // Store reference for note-taking (line 122)
    self.currentCardPull = pull
}
```

**This means:**
- ✅ Tapping Done on CardPreviewView → card is **already saved** to history
- ✅ Tapping Done on CardDisplayView → card is **already saved** to history
- ✅ Even if user dismisses immediately, the card appears in History tab
- ✅ The `currentCardPull` is stored for note-taking workflow

**No changes needed** - this implementation is already correct and matches the plan's requirements.

### Notes Feature Impact

**✅ ALREADY CORRECTLY IMPLEMENTED**

The notes functionality is already implemented exactly as the plan requires:

**1. CardPull model (CardPull.swift:19):**
```swift
@Model
final class CardPull {
    @Attribute(.unique) var id: UUID
    var date: Date
    var cardName: String
    var deckName: String
    var cardImageName: String
    var cardDescription: String
    var note: String?  // ✅ Already optional

    // ✅ Convenience properties already exist
    var hasNote: Bool { ... }
    var truncatedNote: String? { ... }
}
```

**2. CardDisplayView note handling (CardDisplayView.swift:43-86):**
```swift
// ✅ Already conditionally shows note section
if let pull = cardPull, onAddNote != nil {
    // ... shows existing note if present ...
    if let note = pull.note, !note.isEmpty {
        Text(note)
        Button("Edit Note") { onAddNote?(pull) }  // ✅ Already says "Edit"
    } else {
        Button("Add Note") { onAddNote?(pull) }   // ✅ Already says "Add"
    }
}
```

**3. DrawCardView note workflow (DrawCardView.swift:83-121):**
- ✅ Uses `makeAddNoteHandler` to stage note for editing
- ✅ Uses `onChange(of: showingCard)` to trigger NoteEditorView
- ✅ Properly updates existing CardPull record via HistoryViewModel

**Current flow (ALREADY CORRECT):**
1. User draws card → CardPull saved immediately with `note = nil`
2. User views CardDisplayView → sees "Add Note" button
3. User taps "Add Note" → CardDisplayView calls `onAddNote(pull)`
4. onAddNote handler dismisses CardDisplayView, stages pull in `pendingNotePull`
5. onChange detects sheet dismissal → presents NoteEditorView
6. User saves note → HistoryViewModel updates the existing CardPull record

**No changes needed** - the note workflow is already implemented correctly and will work seamlessly with the CardPreviewView addition. The only requirement is to update the onChange handler to check that both sheets are dismissed (see DrawCardView changes above).

### Accessibility

**✅ Already included in CardPreviewView implementation above (lines 148-154)**

The CardPreviewView implementation includes proper accessibility labels:
- Container accessibility label with card name
- Detail button accessibility label and hint
- Follows existing patterns from CardDisplayView.swift:99-100

All accessibility requirements are met in the proposed implementation.

## State Management

### ViewModel Changes

**✅ CardDrawViewModel (CardDrawViewModel.swift:16-17):**

No changes needed. The existing published properties are already sufficient:
```swift
@Published var currentCard: TarotCard?
@Published var currentCardPull: CardPull?
```

These properties are used by both CardPreviewView and CardDisplayView.

### State Flow Diagram

```
┌─────────────────────────────────────────────────────┐
│ DrawCardView                                        │
│   currentCard = nil                                 │
│   showingPreview = false                            │
│   showingDetail = false                             │
└──────────────────┬──────────────────────────────────┘
                   │ User taps DRAW
                   ↓ await viewModel.drawCard()
┌─────────────────────────────────────────────────────┐
│ DrawCardView                                        │
│   currentCard = TarotCard(...)                      │
│   showingPreview = true  ← Triggers sheet           │
│   showingDetail = false                             │
└──────────────────┬──────────────────────────────────┘
                   │ Sheet presents
                   ↓
┌─────────────────────────────────────────────────────┐
│ CardPreviewView (as sheet)                          │
│   Showing full card image                           │
└──────────────────┬──────────────────────────────────┘
                   │ User taps card OR Detail button
                   ↓ onShowDetail()
┌─────────────────────────────────────────────────────┐
│ DrawCardView                                        │
│   currentCard = TarotCard(...)                      │
│   showingPreview = true                             │
│   showingDetail = true  ← Triggers nested sheet     │
└──────────────────┬──────────────────────────────────┘
                   │ Sheet presents over preview
                   ↓
┌─────────────────────────────────────────────────────┐
│ CardDisplayView (as nested sheet)                   │
│   Showing card + name + meaning                     │
└──────────────────┬──────────────────────────────────┘
                   │ User taps Done
                   ↓ onDismiss() sets showingDetail = false AND showingPreview = false
┌─────────────────────────────────────────────────────┐
│ DrawCardView                                        │
│   currentCard = nil (via dismissCard())             │
│   showingPreview = false                            │
│   showingDetail = false                             │
│   Both sheets dismissed simultaneously              │
└─────────────────────────────────────────────────────┘

Alternative path (from CardPreviewView):
┌─────────────────────────────────────────────────────┐
│ CardPreviewView (as sheet)                          │
│   Showing full card image                           │
└──────────────────┬──────────────────────────────────┘
                   │ User taps Done (on preview)
                   ↓ onDismiss() sets showingPreview = false
┌─────────────────────────────────────────────────────┐
│ DrawCardView                                        │
│   currentCard = nil (via dismissCard())             │
│   showingPreview = false                            │
│   showingDetail = false                             │
└─────────────────────────────────────────────────────┘
```

## Testing Requirements

### Unit Tests

**CardPreviewView tests:** (if using ViewInspector)
- Verify card image is displayed
- Verify Done button exists and is accessible
- Verify Detail button exists and is accessible
- Verify onDismiss callback is triggered
- Verify onShowDetail callback is triggered

### UI Tests

**New test file:** `WristArcanaUITests/CardPreviewFlowUITests.swift`

```swift
func test_drawCard_showsPreviewFirst() {
    // Given
    app.buttons["DRAW"].tap()

    // Then - Preview appears (not detail view)
    let cardImage = app.images.firstMatch
    XCTAssertTrue(cardImage.waitForExistence(timeout: 2))

    // Verify no text descriptions (that's detail view)
    XCTAssertFalse(app.staticTexts.matching(identifier: "cardMeaning").firstMatch.exists)
}

func test_previewScreen_tapCard_showsDetail() {
    // Given
    app.buttons["DRAW"].tap()
    let cardImage = app.images.firstMatch
    XCTAssertTrue(cardImage.waitForExistence(timeout: 2))

    // When
    cardImage.tap()

    // Then - Detail view appears with card name
    let cardName = app.staticTexts.containing(
        NSPredicate(format: "label CONTAINS[c] 'The'")
    ).firstMatch
    XCTAssertTrue(cardName.waitForExistence(timeout: 2))
}

func test_previewScreen_tapDetailButton_showsDetail() {
    // Given
    app.buttons["DRAW"].tap()

    // When
    app.buttons["Detail"].tap()

    // Then
    let cardName = app.staticTexts.containing(
        NSPredicate(format: "label CONTAINS[c] 'The'")
    ).firstMatch
    XCTAssertTrue(cardName.waitForExistence(timeout: 2))
}

func test_previewScreen_tapDone_returnsToDraw() {
    // Given
    app.buttons["DRAW"].tap()
    XCTAssertTrue(app.images.firstMatch.waitForExistence(timeout: 2))

    // When
    app.buttons["Done"].tap()

    // Then - Back to draw screen
    XCTAssertTrue(app.buttons["DRAW"].exists)
    XCTAssertFalse(app.images.firstMatch.exists)
}

func test_detailView_tapDone_returnsToDraw() {
    // Given
    app.buttons["DRAW"].tap()
    XCTAssertTrue(app.images.firstMatch.waitForExistence(timeout: 2))

    // When - Go to detail
    app.buttons["Detail"].tap()
    XCTAssertTrue(app.staticTexts.firstMatch.waitForExistence(timeout: 2))

    // When - Dismiss detail (should go directly back to draw, not preview)
    app.buttons["Done"].firstMatch.tap()

    // Then - Back at draw screen, NOT preview screen
    XCTAssertTrue(app.buttons["DRAW"].waitForExistence(timeout: 2))
    XCTAssertFalse(app.images.firstMatch.exists, "Should not show preview after dismissing detail")
}

func test_cardSavedToHistory_evenWithImmediateDismiss() {
    // Given - Start with empty history
    app.tabBars.buttons["History"].tap()
    let historyCount = app.tables.cells.count

    // When - Draw card and immediately dismiss
    app.tabBars.buttons["Draw"].tap()
    app.buttons["DRAW"].tap()
    XCTAssertTrue(app.images.firstMatch.waitForExistence(timeout: 2))
    app.buttons["Done"].tap()  // Dismiss without viewing details

    // Then - Card should be in history
    app.tabBars.buttons["History"].tap()
    XCTAssertEqual(app.tables.cells.count, historyCount + 1, "Card should be saved to history even when dismissed immediately")
}
```

## Implementation Checklist

### Core Implementation (REQUIRED)
- [ ] **Create CardPreviewView.swift** in `WristArcana/Views/`
  - Use the exact implementation from lines 106-175 above
  - Includes proper MARK comments, accessibility labels, and #Preview

- [ ] **Update DrawCardView.swift state variables** (line 20)
  - Rename `showingCard` to `showingPreview`
  - Add new `showingDetail` state variable

- [ ] **Update DrawCardView.swift DRAW button** (lines 56-63)
  - Change `showingCard = true` to `showingPreview = true`

- [ ] **Replace DrawCardView.swift sheet presentation** (lines 73-92)
  - Replace entire `.sheet(isPresented: $showingCard)` block
  - Use nested sheet implementation from lines 262-301 above
  - Ensure both onAddNote and onDismiss dismiss BOTH sheets

- [ ] **Update DrawCardView.swift onChange handler** (lines 93-103)
  - Change to watch `showingPreview` instead of `showingCard`
  - Add guard condition `!self.showingDetail` to prevent conflicts

### Testing (REQUIRED for PR approval)
- [ ] **Manual Testing**
  - [ ] Draw card → CardPreviewView appears with card image only
  - [ ] Tap card image in preview → CardDisplayView appears
  - [ ] Tap Detail button in preview → CardDisplayView appears
  - [ ] Tap Done on CardPreviewView → returns to DrawCardView
  - [ ] Tap Done on CardDisplayView → returns directly to DrawCardView (skips preview)
  - [ ] Draw card → immediately tap Done → verify card saved to history
  - [ ] Draw card → view detail → tap Add Note → verify note editor appears
  - [ ] Test VoiceOver navigation through all screens

- [ ] **UI Tests** (create `CardPreviewFlowUITests.swift`)
  - Use test implementations from lines 389-476 as starting point
  - [ ] `test_drawCard_showsPreviewFirst()`
  - [ ] `test_previewScreen_tapCard_showsDetail()`
  - [ ] `test_previewScreen_tapDetailButton_showsDetail()`
  - [ ] `test_previewScreen_tapDone_returnsToDraw()`
  - [ ] `test_detailView_tapDone_returnsToDraw()`
  - [ ] `test_cardSavedToHistory_evenWithImmediateDismiss()`

- [ ] **Device Testing**
  - [ ] Test on Apple Watch Series 9 (45mm) - primary target
  - [ ] Test on Apple Watch Series 9 (41mm) - small screen
  - [ ] Test on Apple Watch Ultra (49mm) - large screen
  - [ ] Verify animations are smooth (60fps) during sheet transitions
  - [ ] Verify dark mode appearance

### Code Quality (REQUIRED for PR approval)
- [ ] **Run SwiftLint** - must pass with 0 warnings
  ```bash
  swiftlint lint --strict
  ```

- [ ] **Run SwiftFormat** - must be compliant
  ```bash
  swiftformat --lint .
  ```

- [ ] **Build succeeds**
  ```bash
  xcodebuild build -scheme WristArcana \
    -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
  ```

- [ ] **All tests pass**
  ```bash
  xcodebuild test -scheme WristArcana \
    -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
  ```

### Documentation (OPTIONAL - for later)
- [ ] Update project README.md with new navigation flow diagram
- [ ] Update CONTRIBUTING.md if any new patterns introduced
- [ ] Consider adding screenshots to prompts/ for future reference

### NOTES:
- **CardPull model** - NO CHANGES NEEDED (already has optional note field)
- **CardDisplayView** - NO CHANGES NEEDED (handles callbacks from DrawCardView)
- **CardDrawViewModel** - NO CHANGES NEEDED (already saves immediately)
- **HistoryViewModel** - NO CHANGES NEEDED (already updates existing records)

## Alternative: Navigation Stack Approach

**Note:** While the sheet-based approach matches the existing architecture, an alternative would be to use `NavigationStack`:

```swift
NavigationStack {
    DrawCardView()
}

// In DrawCardView
.navigationDestination(isPresented: $showingPreview) {
    CardPreviewView(...)
        .navigationDestination(isPresented: $showingDetail) {
            CardDisplayView(...)
        }
}
```

**Pros:**
- More natural "forward" navigation feel
- Back button automatically provided
- Less state management

**Cons:**
- Changes existing modal sheet paradigm
- Less dramatic visual presentation (no blur effect)
- May feel less "special" for card draws

**Recommendation:** Stick with sheet-based approach for consistency with existing design.

## UX Benefits

1. **Progressive disclosure:** User sees the card immediately without text clutter
2. **User control:** Choose to see details or dismiss quickly
3. **Visual focus:** Full-screen card creates dramatic reveal moment
4. **Flexibility:** Two paths to detail view (tap card or button) accommodates different preferences
5. **Efficiency:** Power users can quickly dismiss without reading descriptions

## Technical Notes

### watchOS Sheet Behavior

- Sheets automatically apply blur to underlying content
- Nested sheets supported but use sparingly (max 2 levels deep)
- Each sheet has independent toolbar
- Dismissal animation is automatic and system-managed

### Performance Considerations

- Card image already loaded in DrawCardView, so preview appears instantly
- No additional network requests or heavy computation
- Nested sheets may briefly show both views during transition (acceptable)

### Future Enhancements

- [ ] Add swipe gesture on CardPreviewView to show detail (in addition to tap)
- [ ] Add card rotation/zoom interaction in preview
- [ ] Consider adding "reversed" indicator in preview if that feature is implemented
- [ ] Add animation when card first appears (subtle scale-up effect)

---

## Summary

This plan introduces `CardPreviewView` as an intermediary screen between card draw and card details, providing:
- Clean visual focus on the drawn card
- User choice between quick dismiss or detailed view
- Consistent navigation patterns using nested sheets
- Improved progressive disclosure of information

**✅ VALIDATED AGAINST ACTUAL CODEBASE (2025-11-24)**

### What Already Exists (No Changes Needed)
- CardDrawViewModel saves cards to history immediately ✅
- CardPull model has optional note field ✅
- CardDisplayView supports add/edit notes ✅
- CardImageView component can be reused ✅
- Note-taking workflow works correctly ✅

### What Needs to Be Built
1. **New file:** CardPreviewView.swift (~60 lines)
2. **Modify:** DrawCardView.swift (4 specific changes to ~20 lines)
3. **New file:** CardPreviewFlowUITests.swift (~100 lines)

### Estimated Effort
- **Core implementation:** 2-3 hours
- **Testing:** 2-3 hours
- **Total:** 4-6 hours

### GitHub Issues Breakdown (RECOMMENDED)

**Issue #1: Create CardPreviewView component**
- Scope: Create new CardPreviewView.swift file
- Lines of code: ~60
- Dependencies: None (uses existing CardImageView)
- Acceptance criteria: Component builds, preview renders correctly

**Issue #2: Update DrawCardView navigation flow**
- Scope: Modify DrawCardView.swift for nested sheets
- Lines of code: ~20 modifications
- Dependencies: Issue #1 (CardPreviewView must exist)
- Acceptance criteria: Cards show preview first, then detail on tap

**Issue #3: Add UI tests for CardPreviewView flow**
- Scope: Create CardPreviewFlowUITests.swift
- Lines of code: ~100
- Dependencies: Issue #1, Issue #2
- Acceptance criteria: All 6 tests pass on 3 device sizes

**Issue #4: Manual testing and polish**
- Scope: VoiceOver testing, device testing, animations
- Dependencies: Issue #1, Issue #2, Issue #3
- Acceptance criteria: Smooth animations, accessible, works on all sizes

The implementation requires minimal changes to existing code and maintains the established MVVM architecture.
