# Card Aspect Ratio Fix - Implementation & Testing Plan

## Overview

This document describes the implementation and testing plan for fixing the card image aspect ratio distortion issue identified in **Issue #18** and analyzed in the Root Cause Analysis (RCA).

## Problem Summary

The `process_images.sh` script was forcing all Rider-Waite-Smith tarot cards to a 0.6 aspect ratio (1200x2000), causing 3-7% horizontal stretch. The canonical tarot aspect ratio is **11:19 (≈0.579)**, and authentic RWS cards have natural aspect ratios ranging from ~0.56 to 0.60.

## Implementation Completed

### 1. Updated `scripts/process_images.sh`

**Changes:**
- Removed `^` flag from all `-resize` commands (lines 25, 32, 39)
- Removed `-extent` commands entirely (lines 24, 33, 42)
- Changed resize strategy from `1200x2000^` to `x2000` (height-only scaling)
- Added comments explaining canonical 11:19 aspect ratio preservation

**Before:**
```bash
magick "$img" \
    -resize 1200x2000^ \      # Forces to cover dimensions (distorts)
    -gravity center \
    -extent 1200x2000 \       # Forces exact output size
    -quality 90 \
    -strip \
    "$PROCESSED_DIR/@3x/${basename}.png"
```

**After:**
```bash
# Canonical tarot aspect ratio is 11:19 (~0.579)
# We preserve original proportions to maintain authentic Rider-Waite artwork

# @3x (highest resolution) - height 2000px, width scales proportionally
magick "$img" \
    -resize x2000 \
    -quality 90 \
    -strip \
    "$PROCESSED_DIR/@3x/${basename}.png"
```

### 2. Updated Swift Files with Aspect Ratio References

**Files updated to use `11.0 / 19.0` instead of `0.6`:**
- `WristArcana/Components/CardImageView.swift` (line 36 - placeholder)
- `WristArcana/Views/CardDisplayView.swift` (line 26)
- `WristArcana/Views/HistoryDetailView.swift` (line 28)
- `WristArcana/Views/CardReferenceDetailView.swift` (line 18)

**Note:** `CardPreviewView.swift` already uses `11.0 / 19.0` from PR #17.

### 3. Created Validation Script

**New file:** `scripts/validate_aspect_ratios.sh`

**Features:**
- Checks all processed images in `@3x` folder
- Validates aspect ratios are within 0.55-0.60 range
- Reports deviations >2% from canonical 11:19 (0.579)
- Calculates average aspect ratio across all cards
- Provides color-coded output (✅, ⚠️, ❌)

**Usage:**
```bash
cd scripts
./validate_aspect_ratios.sh
```

### 4. Re-processed All Card Images

**Results:**
- All 78 cards re-processed successfully
- Aspect ratios now preserved from original artwork
- Sample verification:
  - `cups_01.png`: 1117x2000 (aspect: 0.5585) ✅
  - `major_00.png`: 1156x2000 (aspect: 0.578) ✅
  - `pentacles_01.png`: 1141x2000 (aspect: 0.5705) ✅
  - `wands_01.png`: 1200x2000 (aspect: 0.6) ✅
  - `swords_01.png`: 1200x2000 (aspect: 0.6) ✅

**Validation output:**
- Total images: 78
- All images within acceptable range (0.55-0.60)
- Average aspect ratio: ~0.579 (matches canonical 11:19)
- 34 cards show >2% deviation from perfect 0.579 (expected due to natural variation in original artwork)

## Testing Plan

### Automated Testing

#### 1. Image Validation Script
```bash
cd scripts
./validate_aspect_ratios.sh
```

**Expected:**
- ✅ All 78 images within 0.55-0.60 range
- Average aspect ratio ≈0.579
- No errors or corrupted files

#### 2. Build Verification
```bash
xcodebuild build \
  -project WristArcana/WristArcana.xcodeproj \
  -scheme "WristArcana Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 2 (49mm)' \
  CODE_SIGNING_ALLOWED=NO
```

**Expected:**
- Build succeeds
- No SwiftLint warnings
- No SwiftFormat issues

#### 3. Pre-commit Hooks
```bash
pre-commit run --all-files
```

**Expected:**
- SwiftFormat passes
- SwiftLint passes
- Xcode build passes

### Manual Testing

#### 1. Visual Inspection in Simulators

**Test on multiple devices:**
- Apple Watch Series 9 (41mm, 45mm)
- Apple Watch Series 10 (42mm, 46mm)
- Apple Watch Ultra 2 (49mm)
- Apple Watch SE (40mm, 44mm)

**Test scenarios:**
1. **Draw Card** → Card Preview
   - Card fills screen height
   - Card centered horizontally
   - No horizontal stretch/distortion
   - Characters/symbols appear proportional

2. **Card Detail View**
   - Card displays with correct proportions
   - No visual distortion
   - Aspect ratio matches preview

3. **History View** → History Detail
   - Historical card pulls display correctly
   - No aspect ratio mismatch with new cards

4. **Card Reference**
   - All 78 cards in reference view display correctly
   - Consistent proportions across all cards

#### 2. Comparative Visual Test

**Compare side-by-side:**
1. Open physical Rider-Waite tarot deck (or high-quality images)
2. Compare with cards in app
3. Verify proportions match authentic deck
4. Check for horizontal stretch (especially on characters, faces, vertical elements)

**Focus cards for comparison:**
- The Fool (major_00) - standing figure
- Cups 01 - vertical cup and hand
- Wands 01 - vertical wand
- Swords 01 - vertical sword
- The Tower (major_16) - vertical structure

#### 3. Placeholder Testing

**Test fallback placeholder:**
1. Temporarily rename a card image in Asset Catalog
2. Draw that card
3. Verify placeholder uses 11:19 aspect ratio (not 0.6)
4. Restore card image

### Regression Testing

#### 1. UI Tests (Existing)
```bash
xcodebuild test \
  -project WristArcana/WristArcana.xcodeproj \
  -scheme "WristArcana Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 2 (49mm)' \
  -only-testing:"WristArcana Watch AppUITests/CardPreviewFlowUITests"
```

**Expected:**
- All 6 CardPreviewFlow tests pass
- No regressions in card draw flow

#### 2. Note-Taking Flow
- Draw card → Add note → Verify card proportions maintained in note editor
- Check History with notes → Verify aspect ratios correct

#### 3. Multi-Delete Flow (PR #14)
- Test multi-select in History view
- Verify card thumbnails have correct aspect ratios

## Asset Import to Xcode

### Current Status
The processed images exist in `scripts/RWS_Cards_Processed/` but need to be imported to the Xcode Asset Catalog.

### Manual Import Process (If Needed)

**Note:** The existing Asset Catalog (`WristArcana/Resources/Assets.xcassets`) already contains card images. This fix **only updates the script** for future re-processing. The processed images in `scripts/RWS_Cards_Processed/` are NOT automatically added to the Asset Catalog.

**If you need to reimport:**
1. Open `WristArcana/WristArcana.xcodeproj` in Xcode
2. Navigate to `WristArcana/Resources/Assets.xcassets`
3. For each card (78 cards):
   - Locate the existing image set (e.g., `major_00`)
   - Drag `@1x`, `@2x`, `@3x` versions from `scripts/RWS_Cards_Processed/`
   - Replace existing images
   - Verify in Asset Catalog preview

**Important:** This is **not required** for this PR unless the Asset Catalog images are missing or corrupted.

### Automated Import Script (Future Enhancement)

An automated import script would require:
1. Parsing the `.xcassets` JSON structure
2. Programmatically updating image references
3. Handling Xcode project file modifications

This is complex and error-prone. The current workflow (manual import when needed) is safer for v1.0.

## Verification Checklist

Before considering this issue resolved:

- [x] `process_images.sh` updated to preserve aspect ratios
- [x] All 4 Swift files updated to use `11.0 / 19.0`
- [x] Validation script created and tested
- [x] All 78 cards re-processed successfully
- [x] Validation script confirms aspect ratios correct
- [ ] Build passes with no errors/warnings
- [ ] Pre-commit hooks pass
- [ ] Visual inspection on Ultra 2 confirms no distortion
- [ ] Spot-check on other simulators (Series 9, 10, SE)
- [ ] UI tests pass
- [ ] No regressions in card draw flow
- [ ] No regressions in note-taking flow

## Deployment Notes

### What Changes in Production

**Code changes:**
- 4 Swift view files (aspect ratio constants)
- 1 script file (image processing)
- 1 new script (validation)

**Asset changes:**
- None (unless manual reimport is performed)

### What Does NOT Change

**Assets in Xcode:**
- The Asset Catalog (`Assets.xcassets`) is **not modified** by this PR
- Existing card images remain in place
- This fix ensures **future** processing preserves aspect ratios

**If distorted images are currently in Assets:**
- They would need manual replacement (see Import Process above)
- User should verify if Asset Catalog images are distorted before deciding

## Rollback Plan

If issues are discovered after merge:

1. **Revert script changes:**
   ```bash
   git revert <commit-hash>
   ```

2. **Restore 0.6 aspect ratio:**
   ```bash
   # In all 4 Swift files, change:
   .aspectRatio(11.0 / 19.0, contentMode: .fit)
   # Back to:
   .aspectRatio(0.6, contentMode: .fit)
   ```

3. **Re-process with old script** (if needed)

## Future Enhancements

### 1. Automated CI Check
Add validation to GitHub Actions:
```yaml
- name: Validate card aspect ratios
  run: |
    cd scripts
    ./validate_aspect_ratios.sh
```

### 2. Unit Test for Aspect Ratio Constant
```swift
func test_canonicalTarotAspectRatio() {
    let aspect = 11.0 / 19.0
    XCTAssertEqual(aspect, 0.579, accuracy: 0.001)
}
```

### 3. Automated Asset Import Script
Create `scripts/import_to_xcode.sh` to programmatically update Asset Catalog.

### 4. Add Aspect Ratio to CLAUDE.md
Update project documentation to reference canonical 11:19 ratio (currently mentions 0.6 in multiple places).

## References

- **Issue:** #18
- **RCA:** `/tmp/rca_card_aspect_ratio.md`
- **Script:** `scripts/process_images.sh`
- **Validation:** `scripts/validate_aspect_ratios.sh`
- **Canonical Ratio:** 11:19 (≈0.579)
- **Acceptable Range:** 0.55-0.60 (accounts for natural variation in original RWS artwork)
