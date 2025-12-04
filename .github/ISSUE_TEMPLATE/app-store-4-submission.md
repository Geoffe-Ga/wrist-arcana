---
name: Phase 4 - Build, Archive & Submission
about: Final build, upload to App Store Connect, and submission for review
title: '[RELEASE] Phase 4: Build, Archive & Submission'
labels: ['release', 'app-store', 'phase-4']
assignees: ''
---

# Phase 4: Build, Archive & Submission (8 Story Points)

**Parent Epic**: #TBD - App Store Submission
**Estimated Time**: 1-2 days + 1-7 days Apple review

---

## 🎯 Goals

- Create production archive
- Upload to App Store Connect
- Complete final metadata
- Submit for Apple review
- Monitor review process
- Release to App Store

---

## ✅ Checklist

### Step 1: Pre-Archive Preparation

#### 1.1 Version Number Verification

- [ ] Open Xcode project: `WristArcana/WristArcana.xcodeproj`
- [ ] Select **WristArcana Watch App** target
- [ ] Click **General** tab
- [ ] Verify version info:
  ```
  Version: 1.0.0 (Marketing Version)
  Build: 1 (Current Project Version)
  ```

**Version Numbering Guidelines**:
- **Marketing Version** (1.0.0): What users see in App Store
  - Format: `MAJOR.MINOR.PATCH`
  - First release: `1.0.0` ✅
- **Build Number** (1): Internal version for Apple
  - Must increment for each upload
  - First upload: `1` ✅
  - If you re-upload: change to `2`, `3`, etc.

#### 1.2 Clean State

Remove any build artifacts:
```bash
cd ~/Projects/wrist-arcana
rm -rf WristArcana/build
rm -rf WristArcana/DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/WristArcana-*
```

- [ ] Build artifacts cleaned

#### 1.3 Git Commit Production Code

**Tag the release**:
```bash
git add .
git commit -m "chore: prepare for App Store submission v1.0.0

- Removed debug print statements
- Verified all 78 cards present
- Completed accessibility audit
- Production-ready code

Ready for App Store submission.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

git tag -a v1.0.0 -m "App Store Submission v1.0.0"
git push origin main --tags
```

- [ ] Code committed and tagged
- [ ] Pushed to GitHub

---

### Step 2: Create Archive

#### 2.1 Select Destination

- [ ] In Xcode: **Product** → **Destination** → **Any watchOS Device (arm64)**
  - ⚠️ **CRITICAL**: Must select "Any watchOS Device", NOT simulator
  - If you only see simulators, connect a physical watch via iPhone (or ignore and archive anyway - Xcode will handle it)

#### 2.2 Select Release Scheme (Verify)

- [ ] **Product** → **Scheme** → **Edit Scheme**
- [ ] Select **Archive** in left sidebar
- [ ] Verify **Build Configuration** is **Release**
- [ ] Click **Close**

#### 2.3 Create Archive

- [ ] **Product** → **Clean Build Folder** (hold ⌥ Option key to see this)
- [ ] **Product** → **Archive**
- [ ] Wait for archive process (2-10 minutes depending on Mac speed)

**Expected Console Output**:
```
Building... (progress bar)
Archive succeeded
```

**If Build Fails**:
<details>
<summary>Common build errors and fixes</summary>

**Error**: "No code signing identities found"
- **Fix**: Xcode → Preferences → Accounts → Download Manual Profiles

**Error**: "Provisioning profile doesn't include signing certificate"
- **Fix**: Enable "Automatically manage signing" in target settings

**Error**: "Bundle identifier has already been used"
- **Fix**: This is OK! It means your bundle ID is registered. Continue.

**Error**: "Build input file cannot be found: DecksData.json"
- **Fix**: Xcode → Project Navigator → Right-click DecksData.json → Show in Finder → Re-add to project

**Error**: "SwiftLint/SwiftFormat failures"
- **Fix**: Run locally first:
  ```bash
  swiftlint lint --strict
  swiftformat --lint .
  ```

</details>

#### 2.4 Verify Archive in Organizer

- [ ] **Window** → **Organizer** (or opens automatically)
- [ ] Select **Archives** tab
- [ ] Verify your archive appears:
  ```
  WristArcana Watch App
  Version 1.0.0 (1)
  [Today's date and time]
  ```

- [ ] Archive is visible in Organizer ✅

---

### Step 3: Validate Archive (Final Check)

#### 3.1 Run Validation

- [ ] In Organizer, select your archive
- [ ] Click **"Validate App"** button
- [ ] Select your **Team** (Apple Developer account)
- [ ] Click **Next**

#### 3.2 Validation Options

**Distribution Method**:
- [ ] Select **"App Store Connect"**
- [ ] Click **Next**

**Destination**:
- [ ] Select **"Upload"** (submit for review)
- [ ] Click **Next**

**App Store Connect Distribution Options**:
- [ ] **Upload your app's symbols to receive symbolicated reports**: ✅ Checked
- [ ] **Manage Version and Build Number**: ⬜ Unchecked (we manage manually)
- [ ] Click **Next**

**Signing**:
- [ ] **Automatically manage signing**: ✅ Checked (recommended)
- [ ] Or select your distribution certificate if manual
- [ ] Click **Next**

#### 3.3 Wait for Validation

- [ ] Progress bar: "Verifying..."
- [ ] Wait 2-5 minutes

**Validation Checks**:
- Code signing
- Bundle identifier
- Icon assets
- Deployment target
- Entitlements
- Binary size
- Symbol validation

#### 3.4 Validation Results

**Success** ✅:
```
Validation successful.
No issues found.
```

- [ ] Click **Done**
- [ ] Ready to distribute!

**Failure** ❌:
- [ ] Read error message carefully
- [ ] Fix issue (see Phase 3 troubleshooting)
- [ ] Re-archive and validate again

---

### Step 4: Upload to App Store Connect

#### 4.1 Distribute Archive

- [ ] In Organizer, select your archive
- [ ] Click **"Distribute App"** button
- [ ] Select **"App Store Connect"**
- [ ] Click **Next**

#### 4.2 Upload Options (Same as Validation)

- [ ] **Upload your app's symbols**: ✅
- [ ] **Manage Version and Build Number**: ⬜
- [ ] Click **Next**
- [ ] **Automatically manage signing**: ✅
- [ ] Click **Next**

#### 4.3 Review Archive Contents

- [ ] Verify summary:
  ```
  App: WristArcana
  Version: 1.0.0
  Build: 1
  Bundle ID: com.creekmasons.WristArcana.watchkitapp
  Platform: watchOS
  SDK: watchOS 10.x
  ```

- [ ] Click **Upload**

#### 4.4 Wait for Upload

- [ ] Progress: "Uploading..."
- [ ] Wait 5-15 minutes (depending on connection speed)

**What's Being Uploaded**:
- App binary (~5-30 MB)
- Debug symbols (dSYM files)
- Bitcode (if enabled)
- Asset catalog

**Expected Result**:
```
Upload successful.
Your app has been uploaded to App Store Connect.
```

- [ ] Click **Done**

---

### Step 5: Process Build in App Store Connect

#### 5.1 Wait for Processing

- [ ] Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
- [ ] Sign in
- [ ] **My Apps** → **WristArcana**
- [ ] Click **"App Store"** tab
- [ ] Look for **"Processing"** status

**Processing Time**: 5-60 minutes (usually ~15 minutes)

**Status Changes**:
1. **Upload Received** - Just arrived
2. **Processing** - Apple is analyzing your binary
3. **Ready to Submit** - Processing complete ✅

- [ ] Refresh page every 5-10 minutes
- [ ] Wait for **"Ready to Submit"** status

#### 5.2 Verify Build Appears

Once processing completes:
- [ ] Scroll to **"Build"** section
- [ ] You should see:
  ```
  Build 1.0.0 (1)
  Uploaded: [Today's date]
  Status: Ready to Submit
  ```

**If No Build Appears After 60 Minutes**:
- [ ] Check email for rejection notice
- [ ] Common issues:
  - Missing export compliance info
  - Invalid icon
  - Code signing error
- [ ] Fix and re-upload

---

### Step 6: Complete App Store Connect Metadata

#### 6.1 Select Build for This Version

- [ ] In **App Store Connect** → **WristArcana** → **1.0 Prepare for Submission**
- [ ] Scroll to **"Build"** section
- [ ] Click **"+ Add Build"** or **"Select Build"**
- [ ] Choose **Build 1.0.0 (1)**
- [ ] Click **Done**

**Export Compliance** (May appear):
- [ ] **Does your app use encryption?**
  - Answer: **NO** (WristArcana doesn't transmit any data)
- [ ] Click **Save**

#### 6.2 Verify All Metadata (Double-Check)

Go through each section and verify it's complete:

**App Information**:
- [ ] Name: WristArcana ✅
- [ ] Subtitle: [Your subtitle] ✅
- [ ] Primary Language: English (U.S.) ✅

**Pricing and Availability**:
- [ ] Price: Free ✅
- [ ] Availability: All territories ✅

**App Privacy**:
- [ ] Click **"Edit"** next to **App Privacy**
- [ ] **Do you collect data from this app?**: **No**
- [ ] Click **Save**

**Category**:
- [ ] Primary: Lifestyle (or Entertainment) ✅
- [ ] Secondary: (optional) ✅

**Age Rating**:
- [ ] 4+ ✅

**App Store Version Information**:
- [ ] Screenshots uploaded (all watch sizes) ✅
- [ ] Description written ✅
- [ ] Keywords entered (≤100 chars) ✅
- [ ] Support URL ✅
- [ ] Privacy Policy URL ✅

**App Review Information**:
- [ ] Contact info (name, phone, email) ✅
- [ ] Sign-in required: No ✅
- [ ] Notes for reviewer ✅

**Version Information**:
- [ ] Copyright: © 2024 [Your Name] ✅
- [ ] Release option: **Manually release this version** (recommended for first release)
  - Gives you control over when it goes live
  - Alternative: **Automatically release** (goes live immediately after approval)

#### 6.3 Save All Changes

- [ ] Click **"Save"** at top right
- [ ] Verify no validation errors appear

---

### Step 7: Submit for Review

#### 7.1 Final Pre-Submission Checklist

Review these one last time:

**Required**:
- [ ] At least one build selected ✅
- [ ] Screenshots for at least 2 watch sizes ✅
- [ ] Description ✅
- [ ] Keywords ✅
- [ ] Support URL ✅
- [ ] Privacy policy URL ✅
- [ ] Contact info ✅
- [ ] Age rating ✅
- [ ] Category ✅

**Optional but Recommended**:
- [ ] Promotional text (can update without review)
- [ ] Marketing URL
- [ ] Notes for reviewer

#### 7.2 Submit to App Store

- [ ] Click **"Add for Review"** button (top right)
- [ ] Or **"Submit for Review"** if button says that

**Confirmation Dialog**:
- [ ] Review submission details
- [ ] **Advertising Identifier (IDFA)**: Does your app use IDFA?
  - Answer: **NO** (WristArcana has no ads/tracking)
- [ ] **Export Compliance**: Already answered (No encryption)
- [ ] Click **"Submit"**

#### 7.3 Submission Confirmation

**Success! 🎉**

You should see:
```
Status: Waiting for Review

Your app has been submitted for review.
```

- [ ] You'll receive confirmation email: "Your submission was successful"
- [ ] **Status**: Waiting for Review

---

### Step 8: Monitor Review Process

#### 8.1 Review Status Timeline

**Typical Timeline** (can vary):
1. **In Review**: 0-48 hours (Apple is reviewing)
2. **Pending Developer Release**: 0-24 hours (approved, waiting for you to release)
3. **Ready for Sale**: Live on App Store! 🎉

**Or (if issues)**:
1. **Metadata Rejected**: Fix metadata, resubmit (no new build needed)
2. **Rejected**: Fix issues, upload new build, resubmit

#### 8.2 Track Status Changes

**Email Notifications**:
- [ ] **"Your app status is In Review"** - Reviewers are testing your app
- [ ] **"Your app status is Pending Developer Release"** - APPROVED! 🎉
- [ ] **"Your app status is Ready for Sale"** - Live on App Store!

**Or Rejection**:
- [ ] **"Your app status is Rejected"** - See Resolution Center for details

**App Store Connect**:
- [ ] Check status anytime: **My Apps** → **WristArcana** → **App Store** tab

#### 8.3 Respond to Review Questions (If Any)

Reviewers may ask questions via **Resolution Center**:

- [ ] Go to **App Store Connect** → **WristArcana**
- [ ] Check **"Resolution Center"** tab (if active)
- [ ] Read reviewer's question
- [ ] Respond within 48 hours with clear explanation
- [ ] Example questions:
  - "How do we access [feature]?"
  - "What is the purpose of [permission]?"
  - "Can you explain [functionality]?"

**Response Template**:
```
Thank you for reviewing WristArcana.

[Answer their question clearly and specifically]

To test the feature:
1. [Step by step instructions]
2. [Include screenshots if helpful]

Please let me know if you need any additional information.

Best regards,
[Your Name]
```

---

### Step 9: Handle Approval or Rejection

#### 9.1 If Approved ✅

**Pending Developer Release**:
- [ ] Go to **App Store Connect** → **WristArcana**
- [ ] Status: **"Pending Developer Release"**
- [ ] **You have 90 days to release it**

**Release the App**:
- [ ] Click **"Release This Version"** button
- [ ] Confirm release
- [ ] App status changes to **"Processing for App Store"**
- [ ] Wait 10-30 minutes

**App Goes Live**:
- [ ] Status: **"Ready for Sale"** 🎉
- [ ] Search App Store on iPhone/Apple Watch: "WristArcana"
- [ ] Your app appears in search results!

**Celebrate! 🎊**
- [ ] Download your own app
- [ ] Share on social media (Twitter, Reddit r/watchOSBeta, etc.)
- [ ] Email friends/family
- [ ] Update README with App Store badge

#### 9.2 If Rejected ❌

**Don't Panic!** Most apps are rejected at least once.

**Read Rejection Reason**:
- [ ] Go to **Resolution Center** in App Store Connect
- [ ] Read Apple's feedback carefully
- [ ] Common reasons:
  - Crashes during review
  - Misleading metadata
  - Missing functionality shown in screenshots
  - Privacy issues
  - Guideline violations

**Fix Issues**:

**Metadata-Only Issues**:
- [ ] Fix metadata (description, screenshots, etc.)
- [ ] Click **"Submit for Review"** again
- [ ] No new build needed

**Code Issues**:
- [ ] Fix bugs in code
- [ ] Increment **Build Number** to `2`
  - Xcode → General → Build: `2`
- [ ] **Product** → **Archive**
- [ ] Validate and upload new build
- [ ] Select new build in App Store Connect
- [ ] Resubmit for review

**Response to Reviewer** (if needed):
- [ ] Go to **Resolution Center**
- [ ] Click **"Reply"**
- [ ] Explain what you fixed
- [ ] Click **"Resubmit"**

---

### Step 10: Post-Launch Checklist

#### 10.1 Verify App Store Listing

- [ ] Search "WristArcana" in App Store
- [ ] Download app on your Apple Watch
- [ ] Verify:
  - [ ] Name correct
  - [ ] Icon correct
  - [ ] Screenshots correct
  - [ ] Description correct
  - [ ] "Get" button works (downloads and installs)

#### 10.2 Update Repository

**Add App Store Badge to README**:

```markdown
# WristArcana

[![Download on the App Store](https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg)](https://apps.apple.com/app/idYOUR_APP_ID)

[Rest of README...]
```

**Find Your App ID**:
- [ ] App Store Connect → WristArcana → **App Information**
- [ ] Copy **Apple ID** (numeric ID like `1234567890`)
- [ ] Update README link: `https://apps.apple.com/app/id1234567890`

**Create Release on GitHub**:
```bash
# Create release notes
cat > RELEASE_NOTES_1.0.0.md << 'EOF'
# WristArcana 1.0.0 - Initial Release 🎉

First release of WristArcana on the Apple App Store!

## Features

- 🃏 Complete 78-card Rider-Waite tarot deck
- 🔮 Cryptographically secure random card draws
- 📖 Upright and reversed meanings for every card
- 📚 Reading history with personal notes
- 🗂️ Card reference library
- ⌚️ Standalone Apple Watch app (no iPhone required)
- 🔒 100% offline, privacy-first design

## Download

[Download on the App Store](https://apps.apple.com/app/id1234567890)

## What's Next?

Follow development at https://github.com/Geoffe-Ga/wrist-arcana

Upcoming features (v1.1+):
- Additional tarot decks (via In-App Purchase)
- Reading spreads (3-card, Celtic Cross)
- Export reading history
- Accessibility improvements

---

Built with ❤️ using SwiftUI and SwiftData
EOF

git add README.md RELEASE_NOTES_1.0.0.md
git commit -m "docs: add App Store release v1.0.0"
git push origin main
```

- [ ] Go to GitHub → **Releases** → **Draft a new release**
- [ ] Tag: `v1.0.0`
- [ ] Title: `WristArcana 1.0.0 - Initial App Store Release`
- [ ] Description: Paste from `RELEASE_NOTES_1.0.0.md`
- [ ] Click **"Publish release"**

#### 10.3 Marketing & Promotion

**Announce Your App**:
- [ ] Twitter/X: "Just launched WristArcana on the App Store! 🔮⌚️ [link]"
- [ ] Reddit r/watchOSBeta: "Released my first watchOS app..."
- [ ] Hacker News Show HN: "Show HN: WristArcana – Tarot readings on Apple Watch"
- [ ] Product Hunt: Submit your app
- [ ] Personal blog/website

**Optional**:
- [ ] Create landing page (GitHub Pages, Carrd.co)
- [ ] Make demo video for social media
- [ ] Reach out to tech bloggers/YouTubers

#### 10.4 Monitor Analytics

**App Store Connect Analytics**:
- [ ] Go to **App Store Connect** → **WristArcana** → **Analytics**
- [ ] Track:
  - Downloads
  - Impressions
  - Conversion rate
  - Crash reports (hopefully 0!)
  - Ratings & reviews

**Respond to Reviews**:
- [ ] Check reviews regularly (App Store Connect or App Store on iPhone)
- [ ] Reply to reviews (thank users, address issues)

---

## 🎓 What You've Learned

After completing Phase 4, you now know:
- ✅ How to create a production archive in Xcode
- ✅ How to validate and upload to App Store Connect
- ✅ How to complete App Store metadata
- ✅ How to submit an app for Apple review
- ✅ How to handle approval/rejection
- ✅ How to release an app to the App Store
- ✅ Post-launch best practices

**You shipped an app! 🚀**

---

## ➡️ Next Steps (Post-Launch)

- [ ] Monitor crash reports and user feedback
- [ ] Plan v1.1 features (see GitHub Issues for backlog)
- [ ] Consider localizing to other languages
- [ ] Add In-App Purchases for additional decks
- [ ] Build TestFlight beta testing program for future releases

---

## 📚 Reference Links

- [App Store Connect Guide](https://developer.apple.com/app-store-connect/)
- [Submitting Your App](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)
- [App Review Process](https://developer.apple.com/app-store/review/)
- [Marketing Resources](https://developer.apple.com/app-store/marketing/)
- [App Analytics](https://developer.apple.com/app-store-connect/analytics/)

---

## 🆘 Troubleshooting

**Q: Upload stuck at "Uploading..." for hours**
- A: Cancel and retry. Or: Check network connection, try different WiFi, or upload from terminal using `xcrun altool`

**Q: "This action could not be completed" during upload**
- A: Sign out of Xcode accounts, restart Xcode, sign back in, retry

**Q: Build doesn't appear in App Store Connect after processing**
- A: Check email for rejection. Or: Wait 24 hours and contact Apple Support

**Q: App stuck "In Review" for > 7 days**
- A: Normal for first apps. Contact App Store Review support after 10 days.

**Q: Rejected for "2.1 - Performance: App Completeness"**
- A: App crashed during review. Check crash logs in App Store Connect → TestFlight → Crashes. Fix and resubmit.

**Q: Rejected for "4.0 - Design"**
- A: Doesn't follow watchOS HIG. Review guidelines, improve UI/UX, resubmit.

**Q: How long until my app appears in search?**
- A: 1-2 hours after "Ready for Sale" status. May take 24 hours to rank well.

**Q: Can I update metadata (description, screenshots) after release?**
- A: Yes! You can update anytime, but changes require new app review.

**Q: How do I submit an update (v1.1)?**
- A: Increment version to `1.1.0`, increment build to `2`, archive, upload, submit. Same process!

---

## 🎉 Congratulations!

You've successfully submitted WristArcana to the Apple App Store!

Whether approved on first try or after a rejection, you've completed the full App Store submission process and learned invaluable skills for iOS/watchOS development.

**Your app is now available to millions of Apple Watch users worldwide. Amazing work! 🌟**

---

**Total Epic Progress**:
- [x] Phase 1: Pre-Submission Setup
- [x] Phase 2: Asset Creation & Content
- [x] Phase 3: Final Testing & Code Review
- [x] Phase 4: Build, Archive & Submission
- [x] **App Submitted for Review**
- [ ] **App Approved** (pending)
- [ ] **App Live on App Store** (pending)

Keep this issue open until your app is live, then close with a celebratory comment! 🎊
