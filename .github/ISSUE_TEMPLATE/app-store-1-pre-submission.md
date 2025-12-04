---
name: Phase 1 - Pre-Submission Setup
about: Apple Developer Program enrollment and Xcode configuration
title: '[RELEASE] Phase 1: Pre-Submission Setup'
labels: ['release', 'app-store', 'phase-1']
assignees: ''
---

# Phase 1: Pre-Submission Setup (10 Story Points)

**Parent Epic**: #TBD - App Store Submission
**Estimated Time**: 3-5 days (includes approval wait time)

---

## 🎯 Goals

- Enroll in Apple Developer Program
- Set up App Store Connect
- Configure Xcode project for production
- Set up code signing

---

## ✅ Checklist

### Step 1: Apple Developer Program Enrollment

#### 1.1 Create/Sign In to Apple ID
- [ ] Go to [developer.apple.com](https://developer.apple.com)
- [ ] Sign in with your Apple ID (or create one if needed)
- [ ] **Use an Apple ID you want associated with your developer account long-term**

#### 1.2 Enroll in Apple Developer Program
- [ ] Click "Account" → "Enroll"
- [ ] Choose "Individual" (unless you're a company/organization)
- [ ] Fill out enrollment form:
  - Legal name (must match payment method)
  - Address
  - Phone number (may receive verification call)
- [ ] **Pay $99 USD annual fee** (credit card required)
- [ ] Submit enrollment

#### 1.3 Wait for Approval
- [ ] Check email for enrollment confirmation
- [ ] **Expected wait time**: 24-48 hours (can be faster)
- [ ] You'll receive email: "Your enrollment is now active"

> ⏰ **While waiting for approval, you can start on Step 2 (Xcode Configuration)**

---

### Step 2: Xcode Project Configuration

#### 2.1 Open Project in Xcode
```bash
cd ~/Projects/wrist-arcana
open WristArcana/WristArcana.xcodeproj
```

#### 2.2 Select the WristArcana Watch App Target
- [ ] In Xcode's project navigator (left sidebar), click **WristArcana** (blue icon)
- [ ] In the targets list, select **"WristArcana Watch App"**
- [ ] Click the **"Signing & Capabilities"** tab

#### 2.3 Configure Automatic Signing (Recommended for First Release)
- [ ] Check **"Automatically manage signing"**
- [ ] Select your **Team** from dropdown (your Apple Developer account)
  - If you don't see your team, click "Add Account" and sign in with your developer Apple ID
- [ ] Verify **Bundle Identifier** is: `com.creekmasons.WristArcana.watchkitapp`
  - ⚠️ If you want to change it, do it now (must be unique globally)
  - Recommended format: `com.yourname.WristArcana.watchkitapp`

#### 2.4 Verify General Settings
- [ ] Click **"General"** tab
- [ ] Verify settings:
  ```
  Display Name: WristArcana
  Bundle Identifier: com.creekmasons.WristArcana.watchkitapp (or your custom one)
  Version: 1.0.0
  Build: 1

  Minimum Deployments:
  watchOS: 10.0
  ```

#### 2.5 Configure App Icon
- [ ] In **"General"** tab, scroll to **"App Icon"**
- [ ] Verify it shows: `AppIcon` (should already be set)
- [ ] Click the arrow to open `Assets.xcassets`
- [ ] Verify `AppIcon` has the file: `WristArcanaWatchIcon2.png` (1024x1024)
- [ ] **Required**: Icon must be:
  - 1024 × 1024 pixels
  - PNG format
  - No transparency
  - RGB color space (not CMYK)
  - ✅ Already exists at: `WristArcana/Resources/Assets.xcassets/AppIcon.appiconset/WristArcanaWatchIcon2.png`

#### 2.6 Set Build Configuration to Release
- [ ] In Xcode menu: **Product** → **Scheme** → **Edit Scheme...**
- [ ] Select **"Run"** in left sidebar
- [ ] Change **Build Configuration** to **Release** (for testing production build)
- [ ] Click **Close**
- [ ] **Important**: Set back to **Debug** for development work later

---

### Step 3: App Store Connect Setup

> ⚠️ **Wait until Apple Developer enrollment is approved before this step**

#### 3.1 Access App Store Connect
- [ ] Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
- [ ] Sign in with your Apple Developer account Apple ID
- [ ] Click **"My Apps"**

#### 3.2 Create New App
- [ ] Click the **"+"** button → **"New App"**
- [ ] Fill out form:
  ```
  Platform: watchOS (ONLY watchOS, not iOS)

  Name: WristArcana
  (This is the public App Store name - you can change it later)

  Primary Language: English (U.S.)

  Bundle ID: Select "com.creekmasons.WristArcana.watchkitapp"
             (or your custom bundle ID from Xcode)

  SKU: wristarcana-watch-001
  (Internal identifier, users never see this - can be anything unique)

  User Access: Full Access
  (You're the only developer initially)
  ```
- [ ] Click **"Create"**

#### 3.3 Verify App Information
- [ ] You should now see the **App Store** page for WristArcana
- [ ] Verify the **Bundle ID** matches Xcode
- [ ] Note the **Apple ID** (numeric ID assigned to your app - you'll need this later)

---

### Step 4: Create App ID & Provisioning Profile (Optional - Automatic Signing Does This)

> 📝 **Note**: If you enabled "Automatically manage signing" in Step 2.3, Xcode handles this automatically. Only do this manually if you need advanced capabilities.

#### Manual Setup (Advanced Users Only)
<details>
<summary>Click to expand manual setup instructions</summary>

1. Go to [developer.apple.com/account](https://developer.apple.com/account)
2. Click **"Certificates, Identifiers & Profiles"**
3. Click **"Identifiers"** → **"+"** button
4. Select **"App IDs"** → Continue
5. Select **"App"** → Continue
6. Fill out:
   - Description: `WristArcana Watch App`
   - Bundle ID: `com.creekmasons.WristArcana.watchkitapp` (Explicit)
   - Capabilities: None needed for v1.0
7. Click **Register**

**Provisioning Profile**:
1. Click **"Profiles"** → **"+"** button
2. Select **"watchOS App Development"** → Continue
3. Select your App ID → Continue
4. Select your certificate → Continue
5. Select devices (if testing on physical watch) → Continue
6. Name: `WristArcana Watch Development` → Generate
7. Download and double-click to install

Repeat for **"App Store"** distribution profile when ready to submit.

</details>

---

### Step 5: Test Archive & Validation (Dry Run)

#### 5.1 Create Test Archive
- [ ] In Xcode, select **Product** → **Destination** → **Any watchOS Device (arm64)**
  - ⚠️ Must select "Any watchOS Device", NOT a simulator
- [ ] **Product** → **Clean Build Folder** (hold Option key to see this)
- [ ] **Product** → **Archive**
- [ ] Wait for archive to complete (2-5 minutes)

#### 5.2 Validate Archive (Don't Upload Yet)
- [ ] **Window** → **Organizer** (or it opens automatically)
- [ ] Select **Archives** tab
- [ ] Select your WristArcana archive (most recent)
- [ ] Click **"Validate App"**
- [ ] Select your **Team**
- [ ] Click **"Next"** through all options (accept defaults)
- [ ] Wait for validation (1-3 minutes)
- [ ] **Expected result**: ✅ "Validation successful"

#### 5.3 Fix Validation Errors (If Any)
<details>
<summary>Common validation errors and fixes</summary>

**Error**: "No suitable application records were found"
- **Fix**: Make sure you created the app in App Store Connect (Step 3.2)

**Error**: "Bundle identifier mismatch"
- **Fix**: Verify Bundle ID in Xcode matches App Store Connect exactly

**Error**: "Invalid code signing"
- **Fix**: In Xcode → Signing & Capabilities → Re-select Team and enable "Automatically manage signing"

**Error**: "Missing required icon sizes"
- **Fix**: Verify `Assets.xcassets/AppIcon.appiconset/Contents.json` has:
  ```json
  {
    "images": [
      {
        "filename": "WristArcanaWatchIcon2.png",
        "idiom": "universal",
        "platform": "watchos",
        "size": "1024x1024"
      }
    ]
  }
  ```

**Error**: "Invalid watchOS deployment target"
- **Fix**: Set minimum deployment to watchOS 10.0 (Xcode → General → Minimum Deployments)

</details>

---

### Step 6: Verify watchOS-Only Configuration

#### 6.1 Confirm No iOS Target
- [ ] In Xcode project navigator, verify there is **NO** iOS app target
- [ ] Only these targets should exist:
  - `WristArcana Watch App` (main app)
  - `WristArcana Watch AppTests` (unit tests)
  - `WristArcana Watch AppUITests` (UI tests)

#### 6.2 Verify Info.plist Settings (Embedded in Build Settings)
- [ ] In Xcode, select **WristArcana Watch App** target
- [ ] Click **"Build Settings"** tab
- [ ] Search for "Info.plist" (filter box at top)
- [ ] Verify key settings:
  ```
  Product Name: WristArcana
  Product Bundle Identifier: com.creekmasons.WristArcana.watchkitapp
  Marketing Version: 1.0.0
  Current Project Version: 1
  ```

#### 6.3 Test on Physical Apple Watch (If Available)
- [ ] Connect Apple Watch to Mac via iPhone
- [ ] In Xcode: **Window** → **Devices and Simulators**
- [ ] Select your Apple Watch
- [ ] Verify it's connected and ready
- [ ] Select watch as run destination in Xcode
- [ ] Click **Run** (▶️ button)
- [ ] App should install and launch on watch
- [ ] Test core functionality:
  - [ ] Draw a card
  - [ ] View history
  - [ ] Add a note
  - [ ] Multi-select delete

> 📝 **Don't have a physical watch?** That's OK! Simulator testing is sufficient for first submission, but Apple reviewers will test on real hardware.

---

## 🎓 What You've Learned

After completing Phase 1, you now know:
- ✅ How to enroll in the Apple Developer Program
- ✅ How to configure Xcode for App Store distribution
- ✅ How to create an app in App Store Connect
- ✅ How to validate an archive before submission
- ✅ watchOS-only app configuration

---

## ➡️ Next Steps

Once all checkboxes are complete:
- [ ] Mark Phase 1 as **Done**
- [ ] Move to **Phase 2: Asset Creation & Content**

---

## 📚 Reference Links

- [Apple Developer Enrollment](https://developer.apple.com/programs/enroll/)
- [App Store Connect Overview](https://developer.apple.com/app-store-connect/)
- [Xcode Code Signing](https://developer.apple.com/support/code-signing/)
- [watchOS App Distribution](https://developer.apple.com/documentation/watchos-apps/distributing-your-watchos-app)

---

## 🆘 Troubleshooting

**Q: I can't see my team in Xcode**
- A: Go to Xcode → Preferences → Accounts → Add your Apple ID → It will automatically import your team

**Q: Validation fails with "No account for team"**
- A: Make sure your Apple Developer enrollment is approved (check email)

**Q: Can I test with a free Apple ID?**
- A: You can run on simulator, but you MUST have a paid Developer Program membership ($99/year) to submit to App Store

**Q: Should I use manual code signing?**
- A: For your first app, stick with automatic signing. Manual is for advanced workflows.

**Q: What if my bundle ID is already taken?**
- A: Change it in Xcode → General → Bundle Identifier (use `com.yourname.WristArcana.watchkitapp`) and re-create the app in App Store Connect
