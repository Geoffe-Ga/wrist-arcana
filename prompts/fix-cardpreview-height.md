# Fix CardPreviewView Height Issue

## Problem Statement

**Observed on:** Apple Watch Ultra 2
**Issue:** Large black bar (same width as card) occludes the blurred background of the Draw button beneath the card preview.

**Expected Behavior:** Card should fill the full height of the display responsively across all Apple Watch models (Series 9, Series 10, Ultra 2, SE).

## Current Implementation

**File:** `WristArcana/Views/CardPreviewView.swift` (lines 19-49)

```swift
var body: some View {
    VStack(spacing: 0) {
        Button(action: self.onShowDetail) {
            CardImageView(imageName: self.card.imageName, cardName: self.card.name)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(0.6, contentMode: .fit)  // ⚠️ .fit leaves gaps
        }
        .buttonStyle(.plain)
    }
    .toolbar { ... }
    .background(Color.black.opacity(0.9))
}
```

## Root Cause Analysis

1. **VStack not expanding:** The `VStack` lacks `.frame(maxWidth:maxHeight:)` modifiers to fill available space
2. **ContentMode .fit:** `.aspectRatio(0.6, contentMode: .fit)` scales the card to fit *within* bounds, leaving vertical/horizontal gaps
3. **No safe area handling:** Sheet presentation may respect safe areas, preventing true full-screen display
4. **Background placement:** Background applied to VStack, not the actual card container

## Proposed Solutions

### Option 1: Force VStack Full Height (Simplest)

Add frame modifiers to ensure VStack expands to fill sheet:

```swift
var body: some View {
    VStack(spacing: 0) {
        Button(action: self.onShowDetail) {
            CardImageView(imageName: self.card.imageName, cardName: self.card.name)
                .aspectRatio(11.0/19.0, contentMode: .fit)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)  // ← Button expands
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)      // ← VStack expands
    .background(Color.black.opacity(0.9))
    .toolbar { ... }
}
```

**Pros:** Minimal change, maintains existing structure
**Cons:** May still have gaps if sheet doesn't fill screen

---

### Option 2: Use GeometryReader for Responsive Sizing (Recommended)

Calculate optimal card size based on screen dimensions:

```swift
var body: some View {
    GeometryReader { geometry in
        VStack(spacing: 0) {
            Button(action: self.onShowDetail) {
                CardImageView(imageName: self.card.imageName, cardName: self.card.name)
                    .frame(
                        width: geometry.size.height * (11.0/19.0),  // Calculate width from height
                        height: geometry.size.height
                    )
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.9))
    }
    .ignoresSafeArea(edges: .bottom)  // Extend to bottom edge
    .toolbar { ... }
}
```

**Pros:** Guarantees card fills height, responsive to all watch sizes
**Cons:** More complex, requires geometry calculations

---

### Option 3: ZStack with Center Positioning

Remove VStack, use ZStack to center card with full-screen background:

```swift
var body: some View {
    ZStack {
        Color.black.opacity(0.9)
            .ignoresSafeArea()

        Button(action: self.onShowDetail) {
            CardImageView(imageName: self.card.imageName, cardName: self.card.name)
                .aspectRatio(11.0/19.0, contentMode: .fit)
                .frame(maxHeight: .infinity)
        }
        .buttonStyle(.plain)
    }
    .toolbar { ... }
}
```

**Pros:** Clean structure, background guaranteed full-screen
**Cons:** May still have horizontal gaps on wider displays (Ultra)

---

## Recommended Approach

**Use Option 2 (GeometryReader)** for maximum control and responsiveness:

1. Replace VStack with GeometryReader
2. Calculate card width from screen height using canonical 11/19 ratio
3. Apply `.ignoresSafeArea(edges: .bottom)` to fill bottom edge
4. Keep toolbar in safe area for tap target accessibility

## Implementation Checklist

- [ ] Update `CardPreviewView.swift` body with GeometryReader approach
- [ ] Change aspect ratio from `0.6` to `11.0/19.0` (canonical tarot ratio)
- [ ] Add `.ignoresSafeArea(edges: .bottom)` for full-height display
- [ ] Test on simulators:
  - [ ] Apple Watch Series 9 (41mm)
  - [ ] Apple Watch Series 9 (45mm)
  - [ ] Apple Watch Series 10 (42mm)
  - [ ] Apple Watch Series 10 (46mm)
  - [ ] Apple Watch Ultra 2 (49mm)
  - [ ] Apple Watch SE (40mm)
  - [ ] Apple Watch SE (44mm)
- [ ] Verify no regression in tap targets (card image, Done button, info button)
- [ ] Run UI tests to ensure navigation still works
- [ ] Check VoiceOver accessibility with new layout

## Testing Scenarios

1. **Draw card** → Preview should fill full height with no black bars
2. **Rotate crown** → Verify no scroll behavior (should be fixed layout)
3. **Tap card** → Should navigate to detail view
4. **Tap Done** → Should return to draw screen
5. **Tap info button** → Should navigate to detail view

## Edge Cases

- **Very narrow cards (Ace, single figures):** Should center with equal side margins
- **Very tall cards (The Tower, vertical compositions):** Should fill height, may crop width slightly
- **Ultra 2 wider display:** Card should center with equal side margins, no stretching

## Related Issues

- Issue #18: Card aspect ratio distortion (must fix in conjunction)
- PR #17: CardPreviewView implementation (where this bug was introduced)

## Success Criteria

✅ Card fills full height on all Apple Watch models
✅ No black bars visible behind card
✅ Background blur remains visible in margins
✅ Toolbar buttons remain accessible
✅ Card maintains canonical 11/19 aspect ratio (no distortion)
✅ UI tests pass without modification
