---
name: App Store Submission Epic
about: Complete guide for submitting WristArcana to the Apple App Store
title: '[EPIC] Submit WristArcana to Apple App Store'
labels: ['epic', 'app-store', 'release']
assignees: ''
---

# 🚀 Epic: Submit WristArcana to Apple App Store

**Estimated Total Effort**: 31 Story Points
**Estimated Time**: 2-4 weeks (including Apple review time)
**Prerequisites**: WristArcana watchOS app is feature-complete and tested

---

## 📋 Epic Overview

This epic tracks the complete end-to-end process of submitting the WristArcana watchOS tarot card reading app to the Apple App Store. This is designed for a **first-time App Store submission**, with detailed step-by-step instructions assuming no prior knowledge.

### What We're Shipping
- **App Name**: WristArcana
- **Platform**: watchOS 10.0+ (watch-only, no iOS companion)
- **Category**: Lifestyle / Entertainment
- **Type**: Free app (no IAP in v1.0)
- **Bundle ID**: `com.creekmasons.WristArcana.watchkitapp`
- **Current Version**: 1.0.0 (Build 1)

---

## 🎯 Sub-Issues

This epic is broken down into 4 sequential sub-issues:

### ✅ Phase 1: Pre-Submission Setup (10 pts)
**Issue**: #TBD - [Pre-Submission Setup](./app-store-1-pre-submission.md)
- [ ] Apple Developer Program enrollment ($99/year)
- [ ] App Store Connect account setup
- [ ] Create App ID and Bundle Identifier
- [ ] Xcode project configuration for watchOS-only app
- [ ] Code signing & provisioning profiles

**Estimated Time**: 3-5 days (includes Apple approval wait time)

---

### 🎨 Phase 2: Asset Creation & Content (8 pts)
**Issue**: #TBD - [Asset Creation & Content](./app-store-2-assets.md)
- [ ] App Store screenshots (multiple Apple Watch sizes)
- [ ] App icon validation (already exists: `WristArcanaWatchIcon2.png`)
- [ ] App Store listing copy (title, subtitle, description, keywords)
- [ ] Privacy policy & support URL
- [ ] Marketing materials (optional: preview video)

**Estimated Time**: 2-3 days

---

### 🧪 Phase 3: Final Testing & Code Review (5 pts)
**Issue**: #TBD - [Final Testing & Code Review](./app-store-3-testing.md)
- [ ] Remove debug code & logging
- [ ] Test on physical Apple Watch device
- [ ] Accessibility audit (VoiceOver, Dynamic Type)
- [ ] Performance validation
- [ ] App Store compliance review (no hardcoded URLs, proper error messages)

**Estimated Time**: 2-3 days

---

### 📦 Phase 4: Build, Archive & Submission (8 pts)
**Issue**: #TBD - [Build, Archive & Submission](./app-store-4-submission.md)
- [ ] Create archive in Xcode
- [ ] Validate archive (automated checks)
- [ ] Upload to App Store Connect
- [ ] Complete metadata in App Store Connect
- [ ] Submit for review
- [ ] Monitor review status & respond to feedback
- [ ] Release to App Store

**Estimated Time**: 1-2 days + 1-7 days for Apple review

---

## 📊 Progress Tracking

- [ ] Phase 1: Pre-Submission Setup
- [ ] Phase 2: Asset Creation & Content
- [ ] Phase 3: Final Testing & Code Review
- [ ] Phase 4: Build, Archive & Submission
- [ ] **App Approved** ✅
- [ ] **Live on App Store** 🎉

---

## 🚨 Common Rejection Reasons to Avoid

Based on Apple's App Store Review Guidelines, watch out for:

1. **Privacy Issues**
   - Missing privacy policy (WristArcana doesn't collect data, but still need a simple statement)
   - Not handling permissions properly

2. **Incomplete Features**
   - Crashes on launch
   - Core functionality broken
   - "Coming Soon" features

3. **Metadata Issues**
   - Screenshots don't match actual app
   - Misleading description
   - Copyrighted content (Rider-Waite deck is public domain ✅)

4. **watchOS-Specific**
   - Requires companion iOS app to function (WristArcana is standalone ✅)
   - Poor performance on Apple Watch
   - Doesn't follow watchOS HIG

---

## 📚 Resources

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [watchOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/watchos)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [TestFlight Documentation](https://developer.apple.com/testflight/) (optional for beta testing)

---

## 🎓 Learning Outcomes

By completing this epic, you will:
- ✅ Understand the complete App Store submission process
- ✅ Know how to configure Xcode for production releases
- ✅ Learn App Store Connect workflows
- ✅ Gain experience with Apple's review process
- ✅ Have a published app in the App Store!

---

## 💡 Notes

- **Pricing**: Free (can add IAP later for additional decks)
- **Availability**: Worldwide (consider localizing to Spanish/French in future)
- **Age Rating**: 4+ (no objectionable content)
- **Rider-Waite Deck**: Public domain, safe to use commercially ✅
