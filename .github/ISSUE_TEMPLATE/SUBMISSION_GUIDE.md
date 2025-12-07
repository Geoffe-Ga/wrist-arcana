# App Store Submission Guide - Quick Reference

This directory contains everything you need to submit WristArcana to the Apple App Store.

## 📁 Files in This Guide

1. **`app-store-submission-epic.md`** - Epic overview with all phases
2. **`app-store-1-pre-submission.md`** - Phase 1: Apple Developer enrollment & Xcode setup (10 pts)
3. **`app-store-2-assets.md`** - Phase 2: Screenshots & App Store copy (8 pts)
4. **`app-store-3-testing.md`** - Phase 3: Testing & code review (5 pts)
5. **`app-store-4-submission.md`** - Phase 4: Build, upload & submit (8 pts)

**Total Effort**: 31 Story Points (~2-4 weeks including review)

---

## 🚀 How to Use This Guide

### Option 1: Create Epic Issue (Recommended)

1. Go to GitHub: https://github.com/Geoffe-Ga/wrist-arcana/issues/new
2. Copy content from `app-store-submission-epic.md`
3. Paste into new issue
4. Title: `[EPIC] Submit WristArcana to Apple App Store`
5. Add labels: `epic`, `app-store`, `release`
6. Create issue

Then create 4 sub-issues (one for each phase) using the phase files.

### Option 2: Single Mega-Issue

If you prefer one giant checklist:

1. Combine all 4 phase files into one issue
2. Work through sequentially
3. Check off tasks as you complete them

### Option 3: Use as Reference Documentation

- Keep these files open while working
- Follow steps in order
- Don't create GitHub issues (just use locally)

---

## ⚡️ Quick Start (TL;DR)

**If you know what you're doing**, here's the condensed version:

### Phase 1: Setup (3-5 days)
- Enroll in Apple Developer Program ($99/year)
- Create app in App Store Connect
- Configure Xcode signing

### Phase 2: Assets (2-3 days)
- Screenshot app on 45mm, 41mm, 49mm, 40mm Apple Watch simulators
- Write App Store description & keywords
- Create privacy policy (even if "we don't collect data")

### Phase 3: Testing (2-3 days)
- Remove debug prints
- Test on multiple watch sizes
- VoiceOver audit
- Archive validation

### Phase 4: Submission (1-2 days + review time)
- Archive in Xcode
- Upload to App Store Connect
- Complete metadata
- Submit for review
- Wait 1-7 days
- Release!

---

## 📊 Current App Configuration

Based on `WristArcana/WristArcana.xcodeproj/project.pbxproj`:

```
App Name: WristArcana
Display Name: WristArcana
Bundle ID: com.creekmasons.WristArcana.watchkitapp
Version: 1.0.0
Build: 1
Platform: watchOS 10.0+
App Icon: WristArcanaWatchIcon2.png (1024x1024) ✅
Target: WristArcana Watch App
```

**Assets**:
- 78 Rider-Waite tarot cards in `Resources/Assets.xcassets/`
- App icon in `Resources/Assets.xcassets/AppIcon.appiconset/`
- Deck metadata in `Resources/DecksData.json`

**Architecture**:
- watchOS-only (no iOS companion) ✅
- SwiftUI + SwiftData
- 100% offline functionality ✅
- No data collection ✅

---

## ✅ Pre-Submission Checklist

Before starting Phase 1, verify:

- [ ] App is feature-complete
- [ ] All tests passing (156/156 unit tests) ✅
- [ ] Code coverage ≥50% (currently 53.60%) ✅
- [ ] SwiftLint + SwiftFormat passing ✅
- [ ] No critical bugs
- [ ] Ready to commit to $99/year Apple Developer Program

---

## 🎯 Estimated Timeline

| Phase | Time | What You'll Do |
|-------|------|----------------|
| **Phase 1** | 3-5 days | Apple enrollment (24-48h wait), Xcode config, test archive |
| **Phase 2** | 2-3 days | Create screenshots, write copy, privacy policy |
| **Phase 3** | 2-3 days | Code cleanup, testing, accessibility audit |
| **Phase 4** | 1-2 days | Archive, upload, submit |
| **Apple Review** | 1-7 days | Apple tests your app (you wait) |
| **Release** | 1 hour | Click "Release This Version" |

**Total**: 2-4 weeks from start to App Store

---

## 🆘 Need Help?

**Common Issues**:

1. **"I don't have $99 for Apple Developer Program"**
   - Unfortunately required for App Store submission. No workarounds.

2. **"I don't have a physical Apple Watch for testing"**
   - Simulator testing is sufficient. Apple reviewers test on real hardware.

3. **"My archive validation fails"**
   - See troubleshooting in `app-store-1-pre-submission.md` Step 5.3

4. **"I got rejected by Apple"**
   - See troubleshooting in `app-store-4-submission.md` Step 9.2
   - Most apps are rejected once. Fix issues and resubmit!

5. **"I need to change my bundle identifier"**
   - Do it before Phase 1 submission. After that, it's locked.

---

## 📚 External Resources

- [Apple Developer Portal](https://developer.apple.com)
- [App Store Connect](https://appstoreconnect.apple.com)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [watchOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/watchos)

---

## 💡 Pro Tips

1. **Start on a Friday**: Enroll in Apple Developer Program on Friday. Approval may come over weekend, so you can start Monday.

2. **Take screenshots early**: You can capture screenshots while working on other phases.

3. **Write description in Google Docs**: Easier to edit, get feedback, check character count.

4. **Test on physical watch if possible**: Catches performance issues simulators miss.

5. **Read App Store Review Guidelines**: Boring but important. Save you from rejection.

6. **Set release to "Manual"**: Gives you control over launch timing (vs automatic release).

7. **Announce before launch**: Build hype on Twitter/Reddit before submission.

8. **Prepare for rejection**: 99% of first-time submissions get rejected. Have a plan B (fix and resubmit).

---

## 🎓 What You'll Learn

By completing this guide, you will:
- ✅ Understand the complete iOS/watchOS app submission lifecycle
- ✅ Know how to navigate App Store Connect like a pro
- ✅ Master Xcode archiving and code signing
- ✅ Learn App Store Optimization (ASO) for discoverability
- ✅ Understand Apple's review process and guidelines
- ✅ Have published experience for your resume/portfolio

Plus: **You'll have a live app in the App Store!** 🎉

---

## 📝 Notes

- **Privacy**: WristArcana doesn't collect any data, but you still need a privacy policy URL. See Phase 2 for template.

- **Rider-Waite Deck**: Public domain (1909). Safe to use commercially. No copyright issues.

- **Pricing**: Recommended to launch free. Can add IAP later for additional decks.

- **Localization**: Start with English. Add other languages in v1.1+.

- **Marketing**: App Store is crowded. Plan promotion strategy (social media, Product Hunt, etc.).

---

Good luck! You've got this! 🚀

If you have questions, open an issue on GitHub:
https://github.com/Geoffe-Ga/wrist-arcana/issues
