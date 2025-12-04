---
name: Phase 3 - Final Testing & Code Review
about: Production-ready code audit and comprehensive testing
title: '[RELEASE] Phase 3: Final Testing & Code Review'
labels: ['release', 'app-store', 'phase-3', 'testing']
assignees: ''
---

# Phase 3: Final Testing & Code Review (5 Story Points)

**Parent Epic**: #TBD - App Store Submission
**Estimated Time**: 2-3 days

---

## 🎯 Goals

- Remove all debug code and logging
- Ensure production-ready error handling
- Comprehensive testing on simulator and device
- Accessibility audit
- App Store compliance review

---

## ✅ Checklist

### Step 1: Code Cleanup for Production

#### 1.1 Remove Debug Print Statements

Search for debug logging across the codebase:

```bash
cd ~/Projects/wrist-arcana/WristArcana
grep -r "print(" --include="*.swift" . | grep -v "//"
```

**Files to Review** (known to have debug prints):
- [ ] `ViewModels/HistoryViewModel.swift` - Lines 156-212 have extensive debug prints:
  ```swift
  print("🔍 DEBUG: Entering edit mode")  // Line 156
  print("🔍 DEBUG: Exiting edit mode")   // Line 163
  print("🔍 DEBUG: ========== deleteMultiplePulls() CALLED ==========")  // Line 186
  ```

**Action Required**:
- [ ] **Option 1 (Recommended)**: Remove all debug prints before submission
  ```bash
  # Create a backup first
  git checkout -b release/1.0-cleanup

  # Edit HistoryViewModel.swift and remove prints
  code WristArcana/ViewModels/HistoryViewModel.swift
  ```

- [ ] **Option 2**: Wrap in compilation flag (keeps for debugging):
  ```swift
  #if DEBUG
  print("🔍 DEBUG: ...")
  #endif
  ```

**Verify No Prints Remain**:
```bash
# This should return nothing:
grep -r "print(\"" --include="*.swift" WristArcana | grep -v "#if DEBUG" | grep -v "//"
```

- [ ] No debug prints remain in production code

#### 1.2 Review Error Messages for User-Friendliness

Check error handling across ViewModels:

- [ ] **CardDrawViewModel.swift** (line 62-64):
  ```swift
  errorMessage = "Failed to load deck"
  ```
  ✅ User-friendly message - OK

- [ ] **DeckSelectionViewModel.swift** (line 38):
  ```swift
  errorMessage = "Failed to load decks"
  ```
  ✅ User-friendly message - OK

- [ ] **HistoryViewModel.swift** (no user-facing errors):
  ✅ Silent failures with print statements - OK for v1.0

**All error messages are user-friendly**: ✅

#### 1.3 Remove Test/TODO Comments

Search for TODO and FIXME:
```bash
grep -r "TODO\|FIXME\|HACK\|XXX" --include="*.swift" WristArcana
```

- [ ] Review each TODO/FIXME
- [ ] Resolve or remove before submission
- [ ] Document deferred items in GitHub issues for v1.1

#### 1.4 Verify No Hardcoded Test Data

- [ ] **DecksData.json** contains real Rider-Waite deck (not test data) ✅
- [ ] No mock repositories in production build ✅
- [ ] All 78 cards present in Assets.xcassets ✅

Verify card count:
```bash
ls -1 WristArcana/Resources/Assets.xcassets/ | grep -c ".imageset"
```
Expected: 78 card images

---

### Step 2: Comprehensive Functional Testing

#### 2.1 Test on watchOS Simulator (Multiple Sizes)

**Test Matrix**:

**Apple Watch Ultra 2 (49mm)**:
- [ ] Launch app successfully
- [ ] Draw 5 consecutive cards (verify randomness)
- [ ] Add note to a reading
- [ ] Edit existing note
- [ ] Delete single reading
- [ ] Multi-select delete (3+ readings)
- [ ] Clear all history
- [ ] Browse card reference (all 78 cards load)
- [ ] No crashes or freezes

**Apple Watch Series 9 (45mm)**:
- [ ] Repeat all tests above

**Apple Watch Series 9 (41mm)**:
- [ ] Repeat all tests above

**Apple Watch SE (40mm)**:
- [ ] Repeat all tests above

#### 2.2 Test on Physical Apple Watch (If Available)

**Performance Validation**:
- [ ] App launches in < 3 seconds
- [ ] Card draw completes in < 1 second (after 0.5s animation)
- [ ] Scrolling in history is smooth (60fps)
- [ ] No lag when toggling multi-select
- [ ] Card images load instantly (local assets)

**Memory/Battery**:
- [ ] App doesn't cause watch to overheat
- [ ] Background usage is minimal
- [ ] No excessive battery drain

#### 2.3 Edge Case Testing

**Empty State Testing**:
- [ ] Fresh install: Main screen shows correctly
- [ ] No history: History tab shows empty state message
- [ ] No cards drawn yet: Reference tab still shows all 78 cards

**Data Persistence**:
- [ ] Draw 3 cards
- [ ] Force quit app (swipe up in dock)
- [ ] Relaunch app
- [ ] Verify 3 readings still in history ✅

**Session Boundary (No-Repeat Logic)**:
- [ ] Draw all 78 cards sequentially
- [ ] Verify no card repeats until all drawn
- [ ] On 79th draw, verify set resets (cards can repeat now)

**Storage Limits**:
- [ ] Create 100+ readings (use quick draws)
- [ ] Verify history limits to 100 displayed (per CLAUDE.md maxPullsToDisplay)
- [ ] Test pruning functionality

**Note Input**:
- [ ] Add very long note (500+ characters)
- [ ] Verify truncation in history row
- [ ] Add note with only whitespace → Should save as nil
- [ ] Add note with special characters: `@#$%^&*()_+-=[]{}|;:'"<>,.?/`

**Malformed JSON Handling** (should never happen in production):
- [ ] Verify app doesn't crash if DecksData.json is corrupt (error handling in CardRepository)

---

### Step 3: Accessibility Audit

#### 3.1 Enable VoiceOver Testing

**On Simulator**:
- [ ] Open Settings app on watch
- [ ] **Accessibility** → **VoiceOver** → Enable
- [ ] Or use shortcut: Triple-click Digital Crown

**On Physical Watch**:
- [ ] Open Watch app on iPhone
- [ ] **Accessibility** → **VoiceOver** → Enable

#### 3.2 VoiceOver Navigation Test

Navigate through app using only VoiceOver:
- [ ] Main screen: "DRAW button, button" is announced
- [ ] Card display: Card name is announced ("The Fool, The Magician...")
- [ ] History items: Date and card name announced
- [ ] Tab bar: "Draw, History, Reference" tabs announced
- [ ] Buttons: All buttons have descriptive labels

**Known Accessibility Labels** (from codebase):
- [ ] Verify these exist in code:
  ```swift
  .accessibilityLabel("Draw a tarot card")
  .accessibilityHint("Draws a random card from the deck")
  .accessibilityLabel("Tarot card: \(card.name)")
  ```

#### 3.3 Dynamic Type Testing

Test with larger text sizes:

**On Simulator**:
- [ ] Settings → **Accessibility** → **Larger Text**
- [ ] Drag slider to maximum size
- [ ] Relaunch WristArcana
- [ ] Verify text scales appropriately
- [ ] Verify no text truncation on main screens
- [ ] Verify buttons remain tappable

**Supported Text Sizes**:
- [ ] Default (100%)
- [ ] Medium (130%)
- [ ] Large (160%)
- [ ] Accessibility XXL (235%)

#### 3.4 Color Contrast (Verify in Code)

- [ ] Text on backgrounds meets WCAG AA standards (4.5:1 for normal text)
- [ ] Card meanings are readable (currently white text on semi-transparent background)
- [ ] History dates are readable

**Use Accessibility Inspector** (Mac):
- [ ] Xcode → **Open Developer Tool** → **Accessibility Inspector**
- [ ] Run app in simulator
- [ ] Click **Audit** → Run Accessibility Audit
- [ ] Fix any warnings (aim for 0 warnings)

---

### Step 4: Performance Validation

#### 4.1 Instruments Profiling

**Memory Leaks**:
```bash
# Run in Release mode
xcodebuild -scheme "WristArcana Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 2 (49mm)' \
  -configuration Release \
  build
```

- [ ] In Xcode: **Product** → **Profile** (⌘I)
- [ ] Select **Leaks** instrument
- [ ] Record for 2-3 minutes while using app
- [ ] **Expected**: 0 memory leaks ✅

**Time Profiler**:
- [ ] Profile again with **Time Profiler**
- [ ] Draw 10 cards
- [ ] Verify card draw time < 100ms (excluding 0.5s animation)
- [ ] Verify view transitions < 50ms

#### 4.2 App Size Validation

```bash
# Check IPA size (should be < 50MB for watchOS app)
xcodebuild archive \
  -scheme "WristArcana Watch App" \
  -destination 'generic/platform=watchOS' \
  -archivePath ~/Desktop/WristArcana.xcarchive
```

- [ ] Archive size: _____ MB
- [ ] **Target**: < 50 MB (watchOS apps should be small)
- [ ] If too large, investigate asset compression

**Asset Optimization** (if needed):
```bash
# Check image sizes
cd WristArcana/Resources/Assets.xcassets
find . -name "*.png" -exec du -h {} \; | sort -h
```

- [ ] All card images are optimized (< 100KB each recommended)

---

### Step 5: App Store Compliance Review

#### 5.1 Apple Watch Guidelines Checklist

**App Store Review Guidelines Compliance**:

- [ ] **2.3.8** - No "Coming Soon" features
- [ ] **2.5.13** - No references to other platforms (Android, etc.)
- [ ] **3.1.1** - No in-app purchases (v1.0 is free) ✅
- [ ] **4.0** - Design follows watchOS HIG ✅
- [ ] **5.1.1** - Privacy policy URL provided ✅
- [ ] **5.1.2** - No data collection without consent ✅ (we don't collect any)

**watchOS-Specific Requirements**:

- [ ] **App is fully functional on Apple Watch alone** ✅
  - No iOS companion required ✅
  - All features work offline ✅

- [ ] **Uses native watchOS UI** ✅
  - SwiftUI for watchOS ✅
  - Standard navigation patterns ✅

- [ ] **Optimized for quick interactions** ✅
  - Card draw is fast (< 1 second)
  - Main actions on home screen

- [ ] **Respects watchOS limitations** ✅
  - No large downloads
  - Minimal background usage
  - Efficient battery usage

#### 5.2 Content & Intellectual Property

- [ ] **Rider-Waite Tarot Deck**:
  - Published 1909, artwork by Pamela Colman Smith
  - **Public domain** ✅ (copyright expired)
  - Safe to use commercially ✅

- [ ] No copyrighted material (music, fonts, other imagery):
  - ✅ All code is original or properly licensed
  - ✅ SwiftUI (Apple framework) - OK to use

- [ ] App name "WristArcana" is:
  - [ ] Not trademarked by another company (search USPTO.gov)
  - [ ] Available on App Store (search before submission)

#### 5.3 Privacy & Data Handling

**Privacy Manifest** (watchOS 10+ requirement):

- [ ] Verify `PrivacyInfo.xcprivacy` exists (or not needed for simple apps)
- [ ] Since WristArcana uses only SwiftData (local storage), no API declarations needed ✅

**Permissions**:
- [ ] No camera access ✅
- [ ] No microphone access ✅
- [ ] No location access ✅
- [ ] No health data access ✅
- [ ] No contacts access ✅

**Data Usage**:
- [ ] All data stored locally via SwiftData ✅
- [ ] No analytics frameworks ✅
- [ ] No advertising frameworks ✅
- [ ] No third-party SDKs ✅

#### 5.4 Metadata Accuracy

Verify App Store listing matches app:
- [ ] Screenshots show actual app (not mockups) ✅
- [ ] Description doesn't promise features not in app ✅
- [ ] Keywords are relevant (no spam keywords) ✅

---

### Step 6: Pre-Submission Validation

#### 6.1 Test Production Archive Build

**Build Release Configuration**:
- [ ] In Xcode: **Product** → **Scheme** → **Edit Scheme**
- [ ] Set **Run** configuration to **Release**
- [ ] Run on simulator
- [ ] **Verify**: No debug prints appear in console
- [ ] **Verify**: App behaves identically to Debug build
- [ ] Set back to **Debug** when done testing

#### 6.2 Create Final Archive

- [ ] In Xcode: **Product** → **Destination** → **Any watchOS Device (arm64)**
- [ ] **Product** → **Clean Build Folder** (hold Option key)
- [ ] **Product** → **Archive**
- [ ] Wait for archive to complete
- [ ] **Window** → **Organizer** → **Archives**

#### 6.3 Validate Archive (Pre-Upload Check)

- [ ] Select your archive
- [ ] Click **"Validate App"**
- [ ] Select your **Team**
- [ ] **App Store Connect** distribution
- [ ] Accept defaults (Automatically manage signing)
- [ ] Wait for validation (2-5 minutes)

**Expected Validation Checks**:
- [ ] ✅ Code signing valid
- [ ] ✅ Bundle identifier matches App Store Connect
- [ ] ✅ App icon present (1024x1024)
- [ ] ✅ No missing frameworks
- [ ] ✅ Deployment target compatible (watchOS 10.0+)
- [ ] ✅ No invalid entitlements

**If Validation Fails**:
- [ ] Read error message carefully
- [ ] Common fixes:
  - Bundle ID mismatch: Update in Xcode or App Store Connect
  - Missing icon: Check `Assets.xcassets/AppIcon.appiconset/`
  - Code signing issues: Re-enable "Automatically manage signing"

#### 6.4 Final Checklist Before Upload

**Code Quality**:
- [ ] All debug prints removed or wrapped in `#if DEBUG`
- [ ] No TODO/FIXME comments for critical issues
- [ ] Error messages are user-friendly
- [ ] No hardcoded test data

**Testing**:
- [ ] Tested on 4 watch sizes (49mm, 45mm, 41mm, 40mm)
- [ ] Tested on physical watch (if available)
- [ ] No crashes or freezes
- [ ] All features work as expected
- [ ] Edge cases handled gracefully

**Accessibility**:
- [ ] VoiceOver navigation works
- [ ] Dynamic Type scaling works
- [ ] Color contrast is sufficient
- [ ] All buttons have accessibility labels

**Performance**:
- [ ] No memory leaks
- [ ] Card draw < 1 second
- [ ] App size < 50 MB
- [ ] Smooth scrolling/animations

**Compliance**:
- [ ] Follows watchOS HIG
- [ ] No App Store guideline violations
- [ ] Privacy policy URL is live
- [ ] Support URL is live
- [ ] Rider-Waite deck is public domain

**Archive**:
- [ ] Archive validates successfully
- [ ] Bundle ID matches App Store Connect
- [ ] Version is 1.0.0, Build is 1

---

## 🎓 What You've Learned

After completing Phase 3, you now know:
- ✅ How to prepare production-ready code (removing debug prints, test data)
- ✅ Comprehensive testing strategies for watchOS apps
- ✅ Accessibility testing with VoiceOver and Dynamic Type
- ✅ Performance profiling with Xcode Instruments
- ✅ App Store compliance requirements
- ✅ How to validate an archive before submission

---

## ➡️ Next Steps

Once all checkboxes are complete:
- [ ] Mark Phase 3 as **Done**
- [ ] Move to **Phase 4: Build, Archive & Submission**

---

## 📚 Reference Links

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [watchOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/watchos)
- [Accessibility for watchOS](https://developer.apple.com/accessibility/watchos/)
- [Xcode Instruments](https://developer.apple.com/documentation/instruments)
- [Privacy Manifest Documentation](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files)

---

## 🆘 Troubleshooting

**Q: Archive validation fails with "Invalid Swift Support"**
- A: Clean build folder and try again. Or: Build Settings → Always Embed Swift Standard Libraries → NO

**Q: App crashes on physical watch but not simulator**
- A: Check for memory issues. Profile with Instruments → Allocations. Reduce image sizes if needed.

**Q: VoiceOver doesn't announce button labels**
- A: Add `.accessibilityLabel()` modifiers to all interactive elements

**Q: How do I know if my app follows HIG?**
- A: Review [watchOS HIG](https://developer.apple.com/design/human-interface-guidelines/watchos) checklist. Key: native navigation, quick interactions, glanceable info.

**Q: My archive is too large (> 50MB)**
- A: Compress card images. Use PNG compression tools like ImageOptim. Target: < 50KB per image.

**Q: Can I skip VoiceOver testing?**
- A: Technically yes, but Apple reviewers may test with VoiceOver. Better to catch issues now!
