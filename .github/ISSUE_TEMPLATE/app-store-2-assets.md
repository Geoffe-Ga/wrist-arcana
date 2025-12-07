---
name: Phase 2 - Asset Creation & Content
about: Create App Store screenshots, copy, and marketing materials
title: '[RELEASE] Phase 2: Asset Creation & Content'
labels: ['release', 'app-store', 'phase-2', 'design']
assignees: ''
---

# Phase 2: Asset Creation & Content (8 Story Points)

**Parent Epic**: #TBD - App Store Submission
**Estimated Time**: 2-3 days

---

## 🎯 Goals

- Create required App Store screenshots
- Write compelling App Store listing copy
- Prepare privacy policy and support materials
- Validate all assets meet Apple's requirements

---

## ✅ Checklist

### Step 1: Create App Store Screenshots

#### 1.1 Required Screenshot Sizes

Apple requires screenshots for **multiple Apple Watch sizes**. You must provide at least:

**Required Sizes**:
- [ ] **45mm** (Apple Watch Series 7/8/9, Ultra): **396 × 484 pixels**
- [ ] **41mm** (Apple Watch Series 7/8/9): **352 × 430 pixels**

**Recommended (for broader compatibility)**:
- [ ] **49mm** (Apple Watch Ultra 2): **410 × 502 pixels**
- [ ] **40mm** (Apple Watch SE, Series 4-6): **324 × 394 pixels**

> 📝 **Note**: You need **3-10 screenshots** per device size showing different app screens.

#### 1.2 Plan Your Screenshot Content

Choose screens that showcase WristArcana's best features:

**Recommended Screenshot Set** (in order):
1. **Main Screen** - "DRAW" button with mystical background
2. **Card Display** - Beautiful card image with meanings visible
3. **History View** - List of past readings
4. **Card Reference** - Browse all 78 cards
5. **Note Feature** - Add personal insights to readings
6. **Multi-Delete** - Manage history efficiently

#### 1.3 Capture Screenshots Using Xcode Simulator

**Setup**:
```bash
cd ~/Projects/wrist-arcana
open WristArcana/WristArcana.xcodeproj
```

**For Each Watch Size**:

**45mm (Apple Watch Series 9 - Most Important)**:
- [ ] In Xcode: **Product** → **Destination** → **Apple Watch Series 9 (45mm)**
- [ ] Run app (▶️)
- [ ] Navigate to each screen you want to capture
- [ ] Capture screenshot:
  - **Method 1 (Simulator)**: Click simulator → **Device** → **Screenshot** → **Save**
  - **Method 2 (Keyboard)**: With simulator focused, press **Cmd + S**
- [ ] Screenshots save to Desktop as: `Apple Watch Series 9 (45mm) - 2024-12-03 at 15.30.45.png`

**41mm (Apple Watch Series 9)**:
- [ ] Repeat above steps with **Apple Watch Series 9 (41mm)** destination

**49mm (Apple Watch Ultra 2)**:
- [ ] Repeat above steps with **Apple Watch Ultra 2 (49mm)** destination

**40mm (Apple Watch SE)**:
- [ ] Repeat above steps with **Apple Watch SE (40mm) (2nd generation)** destination

#### 1.4 Organize Screenshots

Create a folder structure:
```bash
mkdir -p ~/Desktop/WristArcana-AppStore-Assets/Screenshots/{45mm,41mm,49mm,40mm}
```

- [ ] Move screenshots to appropriate folders
- [ ] Rename files descriptively:
  ```
  01-main-screen.png
  02-card-display.png
  03-history-view.png
  04-card-reference.png
  05-note-feature.png
  ```

#### 1.5 Verify Screenshot Requirements

For EACH screenshot:
- [ ] **Format**: PNG or JPEG (PNG recommended for quality)
- [ ] **Color Space**: RGB (not CMYK)
- [ ] **No transparency**
- [ ] **Exact dimensions** (see 1.1 above - Apple is strict!)
- [ ] **No status bar showing time/battery** (simulator screenshots are clean ✅)
- [ ] **Show actual app content** (no mockups or graphics)

#### 1.6 Optional: Add Marketing Frames (Advanced)

If you want to make screenshots more polished:

- [ ] Use a tool like [Apple Frames](https://www.figma.com/community/file/788721659242809539) (Figma)
- [ ] Or [Previewed.app](https://previewed.app/) (Mac app, paid)
- [ ] Add watch frame around screenshots
- [ ] Add text overlays like "Draw Your Card", "Track Your Readings"

> ⚠️ **Warning**: Keep text minimal. Apple may reject if screenshots are too "marketing-y" and don't show real UI.

---

### Step 2: App Store Listing Copy

#### 2.1 App Name
- [ ] **Primary Name**: `WristArcana`
  - Character limit: 30 characters
  - Shows in App Store search results
  - ✅ Current: 11 characters (good!)

- [ ] **Subtitle** (optional but recommended):
  - Character limit: 30 characters
  - Examples:
    - `Tarot Readings on Your Wrist`
    - `Daily Tarot Card Readings`
    - `Your Personal Tarot Deck`
  - Choose one and save it in a text file

#### 2.2 Description (Long)

Write a compelling description (4000 character limit):

**Template to customize**:
```markdown
Discover the wisdom of tarot with WristArcana, your personal tarot card reading companion for Apple Watch.

✨ FEATURES

• 78 Complete Rider-Waite Tarot Deck - The classic deck beloved by tarot readers worldwide
• Cryptographically Secure Randomization - Each draw is truly random using Apple's secure random generator
• Instant Readings - Draw a card and receive upright and reversed meanings instantly
• Reading History - Track your spiritual journey with automatic history saving
• Personal Notes - Add reflections and insights to each reading
• Offline First - All 78 cards stored locally, no internet required
• Beautiful Card Images - High-quality Rider-Waite artwork optimized for Apple Watch
• Card Reference Library - Browse and learn all 78 cards anytime
• Privacy Focused - Your readings stay on your device, no data collected

🔮 PERFECT FOR

• Daily guidance and reflection
• Learning tarot card meanings
• Quick spiritual check-ins
• Building a personal tarot practice
• Meditation and mindfulness

📖 ABOUT THE DECK

The Rider-Waite tarot deck is the most recognized tarot deck in the world, featuring rich symbolism and archetypal imagery. WristArcana includes all 22 Major Arcana cards (The Fool through The World) and all 56 Minor Arcana cards (Wands, Cups, Swords, and Pentacles).

⌚️ APPLE WATCH OPTIMIZED

Designed specifically for watchOS with an intuitive interface that feels natural on your wrist. No iPhone companion app required - WristArcana runs entirely on your Apple Watch.

🌙 START YOUR JOURNEY

Whether you're a tarot beginner or experienced reader, WristArcana brings the ancient art of tarot reading to your wrist. Draw your card, reflect on its meaning, and unlock new insights every day.

Download WristArcana today and discover what the cards reveal.
```

- [ ] Customize this template for your voice
- [ ] Save to: `~/Desktop/WristArcana-AppStore-Assets/app-description.txt`
- [ ] Verify character count: [Online Counter](https://wordcounter.net/)

#### 2.3 Keywords (Critical for Discovery!)

You get **100 characters** (comma-separated, no spaces):

**Recommended Keywords**:
```
tarot,tarot cards,card reading,divination,spiritual,oracle,fortune,mystical,rider waite,major arcana,meditation,mindfulness,daily guidance,spirituality
```

**Optimization Tips**:
- [ ] Don't repeat words from your app name (Apple auto-includes those)
- [ ] Use singular forms (Apple matches plurals automatically)
- [ ] No spaces after commas (saves characters!)
- [ ] Research competitors: Search "tarot" in App Store, see what keywords they rank for

**Your Keywords** (100 chars max):
- [ ] Draft keywords: `_________________________________`
- [ ] Character count: ___ / 100
- [ ] Save to: `~/Desktop/WristArcana-AppStore-Assets/keywords.txt`

#### 2.4 Promotional Text (Optional)

This appears ABOVE your description and can be updated without app review:

**Example** (170 character limit):
```
New in Version 1.0: Complete 78-card Rider-Waite deck, reading history, personal notes, and offline access. Start your tarot journey today! 🔮
```

- [ ] Write promotional text: `_________________________________`
- [ ] Save to assets folder

---

### Step 3: Privacy Policy & Support

#### 3.1 Privacy Policy

Even though WristArcana **doesn't collect any data**, Apple requires a privacy policy URL.

**Option 1: Simple GitHub Pages Policy (Recommended)**

- [ ] Create file: `~/Desktop/WristArcana-AppStore-Assets/privacy-policy.md`

**Template**:
```markdown
# WristArcana Privacy Policy

**Last Updated**: December 3, 2024

## Overview

WristArcana ("the App") respects your privacy. This policy explains how we handle your information.

## Data Collection

**We do not collect any personal data.**

The App operates entirely offline on your Apple Watch. All data (card readings, history, notes) is stored locally on your device using Apple's SwiftData framework.

## What We Don't Collect

- Personal information (name, email, location)
- Usage analytics or statistics
- Device identifiers
- Crash reports (unless you opt-in via iOS system settings)
- Any data transmitted to servers (we don't have servers)

## Data Storage

All your tarot readings and notes are stored:
- **Locally on your Apple Watch**
- Synced via iCloud (if you have iCloud enabled for the app)
- Never transmitted to our servers (because we don't have any)

## Third-Party Services

The App does not use any third-party analytics, advertising, or tracking services.

## Your Rights

You can delete all app data at any time by:
1. Deleting the WristArcana app from your Apple Watch
2. Using the "Clear All History" feature in the app

## Children's Privacy

The App does not knowingly collect any information from anyone, including children under 13.

## Changes to This Policy

We may update this policy occasionally. The "Last Updated" date will reflect any changes.

## Contact

For questions about this privacy policy, contact:
- Email: [your-email@example.com]
- GitHub: https://github.com/Geoffe-Ga/wrist-arcana

---

**Simple Version**: WristArcana doesn't collect any data. Everything stays on your device. That's it.
```

- [ ] Customize email address
- [ ] Save as `privacy-policy.md`

**Publishing the Policy**:

**Option A: GitHub Pages (Free)**
- [ ] Create new repo: `wristarcana-privacy` (or add to existing repo)
- [ ] Enable GitHub Pages in repo Settings
- [ ] Upload `privacy-policy.md`
- [ ] Access via: `https://yourusername.github.io/wristarcana-privacy/privacy-policy.html`

**Option B: Simple HTML Page (Any Web Host)**
- [ ] Convert markdown to HTML
- [ ] Upload to any web hosting (Netlify, Vercel, your personal site)

**Option C: Use a Privacy Policy Generator**
- [ ] [Privacy Policy Generator](https://app-privacy-policy-generator.firebaseapp.com/)
- [ ] Answer questions (select "No" for all data collection)
- [ ] Download HTML
- [ ] Host somewhere

**Final Step**:
- [ ] Privacy Policy URL: `_________________________________`
- [ ] Verify URL is publicly accessible
- [ ] Save URL to assets folder

#### 3.2 Support URL

Where users can get help:

**Options**:
1. **GitHub Issues** (Recommended for open-source):
   - URL: `https://github.com/Geoffe-Ga/wrist-arcana/issues`
   - ✅ Already exists!

2. **Create Support Page**:
   - Similar to privacy policy, create `support.md` or `faq.md`
   - Host on GitHub Pages

3. **Email Support**:
   - URL: `mailto:your-email@example.com`
   - Less professional but works

**Your Support URL**:
- [ ] Support URL: `_________________________________`
- [ ] Test the URL to make sure it works

#### 3.3 Marketing URL (Optional)

Link to your app's website or landing page:

**Quick Options**:
- [ ] Use GitHub repo: `https://github.com/Geoffe-Ga/wrist-arcana`
- [ ] Or skip (not required)

---

### Step 4: App Store Connect Metadata Upload

#### 4.1 Log Into App Store Connect
- [ ] Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
- [ ] Click **"My Apps"** → **WristArcana**

#### 4.2 Select Version 1.0
- [ ] In left sidebar, click **"App Store"** tab
- [ ] You should see "1.0 Prepare for Submission"
- [ ] Click on **"1.0 Prepare for Submission"**

#### 4.3 Upload Screenshots

For **each watch size**:
- [ ] Scroll to **"Apple Watch Screenshots"** section
- [ ] Click **"Apple Watch Series 9 (45mm)"** (or first size)
- [ ] Drag and drop 3-10 screenshots
- [ ] **Order matters!** First screenshot is most important (shows in search)
- [ ] Repeat for all watch sizes (45mm, 41mm, 49mm, 40mm)

#### 4.4 Fill Out Description
- [ ] Scroll to **"Description"** section
- [ ] Paste your description from Step 2.2
- [ ] Verify formatting looks good (no markdown!)
- [ ] **Promotional Text**: Paste promotional text (optional)

#### 4.5 Add Keywords
- [ ] Scroll to **"Keywords"** section
- [ ] Paste your keywords (comma-separated, no spaces)
- [ ] Verify character count: ≤ 100

#### 4.6 Support & Privacy URLs
- [ ] Scroll to **"Support URL"**: Paste support URL
- [ ] **Marketing URL** (optional): Paste or leave blank
- [ ] **Privacy Policy URL**: Paste privacy policy URL

#### 4.7 Category & Subcategory
- [ ] **Primary Category**: Lifestyle (or Entertainment)
- [ ] **Secondary Category** (optional): Entertainment (or Health & Fitness)

#### 4.8 Age Rating
- [ ] Click **"Edit"** next to Rating
- [ ] Answer questionnaire (all "None" for WristArcana):
  - Cartoon/Fantasy Violence: None
  - Realistic Violence: None
  - Sexual Content: None
  - Profanity: None
  - Horror: None
  - Alcohol/Drugs: None
  - Gambling: None
  - Made for Kids: No
- [ ] **Result**: 4+ (Everyone)
- [ ] Click **"Done"**

#### 4.9 Pricing & Availability
- [ ] In left sidebar, click **"Pricing and Availability"**
- [ ] **Price**: Free (or set price if paid app)
- [ ] **Availability**: All territories (or select specific countries)
- [ ] Click **"Save"**

---

### Step 5: App Review Information

Apple reviewers need to test your app:

#### 5.1 Contact Information
- [ ] Scroll to **"App Review Information"**
- [ ] **First Name**: Your first name
- [ ] **Last Name**: Your last name
- [ ] **Phone Number**: Your phone (Apple may call if issues during review)
- [ ] **Email**: Your email (for review updates)

#### 5.2 Demo Account (If Required)
- [ ] **Sign-in Required**: No (WristArcana doesn't need login ✅)
- [ ] Leave demo account fields blank

#### 5.3 Notes for Reviewer
- [ ] **Notes** (optional but helpful):

**Example**:
```
WristArcana is a standalone Apple Watch app for tarot card readings.

Key Features to Test:
1. Tap "DRAW" on main screen to draw a random tarot card
2. View card meanings (upright and reversed)
3. Navigate to "History" tab to see past readings
4. Tap on a reading to add personal notes
5. Use "Select" button to multi-delete readings
6. Browse all 78 cards in "Reference" tab

No internet connection required - all 78 Rider-Waite cards are bundled locally.

The Rider-Waite tarot deck is in the public domain (published 1909).
```

---

### Step 6: Verify All Assets

#### 6.1 Asset Checklist

Before moving to Phase 3, verify:

**Screenshots**:
- [ ] 3-10 screenshots for 45mm Apple Watch
- [ ] 3-10 screenshots for 41mm Apple Watch
- [ ] 3-10 screenshots for 49mm Apple Watch (optional)
- [ ] 3-10 screenshots for 40mm Apple Watch (optional)
- [ ] All screenshots show actual app UI (no mockups)
- [ ] Screenshots are in correct order (best first)

**App Icon**:
- [ ] 1024×1024 pixels
- [ ] PNG format
- [ ] No transparency
- [ ] RGB color space
- [ ] ✅ Already exists: `WristArcanaWatchIcon2.png`

**Copy**:
- [ ] App name ≤ 30 characters
- [ ] Subtitle ≤ 30 characters (optional)
- [ ] Description ≤ 4000 characters
- [ ] Keywords ≤ 100 characters
- [ ] Promotional text ≤ 170 characters (optional)

**URLs**:
- [ ] Privacy policy URL is live and accessible
- [ ] Support URL is live and accessible
- [ ] Marketing URL (optional)

**Metadata**:
- [ ] Category selected
- [ ] Age rating completed (4+)
- [ ] Pricing set (Free)
- [ ] Availability configured

#### 6.2 Save Everything

Create a backup of all assets:
```bash
mkdir -p ~/Desktop/WristArcana-AppStore-Assets-FINAL
cp -r ~/Desktop/WristArcana-AppStore-Assets/* ~/Desktop/WristArcana-AppStore-Assets-FINAL/
```

- [ ] Assets backed up
- [ ] All text files saved
- [ ] Screenshots organized

---

## 🎓 What You've Learned

After completing Phase 2, you now know:
- ✅ How to create App Store screenshots for multiple watch sizes
- ✅ How to write compelling App Store copy that drives downloads
- ✅ How to research and choose effective keywords for ASO (App Store Optimization)
- ✅ How to create a privacy policy (even for apps that don't collect data)
- ✅ How to upload assets to App Store Connect

---

## ➡️ Next Steps

Once all checkboxes are complete:
- [ ] Mark Phase 2 as **Done**
- [ ] Move to **Phase 3: Final Testing & Code Review**

---

## 📚 Reference Links

- [App Store Screenshot Specifications](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications)
- [App Store Marketing Guidelines](https://developer.apple.com/app-store/marketing/guidelines/)
- [Keyword Optimization Tips](https://developer.apple.com/app-store/search/)
- [Privacy Policy Requirements](https://developer.apple.com/app-store/review/guidelines/#privacy)

---

## 🆘 Troubleshooting

**Q: My screenshots are rejected for wrong dimensions**
- A: Use simulator screenshots (Cmd+S in Xcode simulator) - they're always correct dimensions

**Q: Can I use the same screenshots for all watch sizes?**
- A: No, Apple requires device-specific screenshots. Use Xcode to capture each size.

**Q: Do I need a promo video?**
- A: No, it's optional. For v1.0, screenshots are sufficient.

**Q: Can I change my app name after submission?**
- A: Yes, but requires a new app version and review. Choose carefully now!

**Q: My keyword list is over 100 characters**
- A: Remove spaces after commas, use shorter synonyms, prioritize most important terms

**Q: Do I need to localize (translate) for other languages?**
- A: Not required. Start with English. You can add localizations later.
