# 🔮 Wrist Arcana

Wrist Arcana is a watchOS 11 companion for personal tarot readings. The app lets you draw a card, jot down quick reflections, and browse the full Rider–Waite–Smith deck – all from your wrist. This repository contains the Xcode project, data set, and scripts that power the current implementation.

## 📱 App at a glance

- **Draw a card** – `DrawCardView` drives the primary experience: press the large CTA button to trigger `CardDrawViewModel`, which performs a cryptographically secure draw, plays haptics, and saves the pull to history using SwiftData.【F:WristArcana/Views/DrawCardView.swift†L1-L165】【F:WristArcana/ViewModels/CardDrawViewModel.swift†L1-L128】
- **Review your readings** – `HistoryView` surfaces the last 100 pulls, supports swipe-to-delete, and opens a detail screen where you can edit or remove notes. Storage pressure is monitored through `StorageMonitor` so the app can prompt for pruning when the watch is close to full.【F:WristArcana/Views/HistoryView.swift†L1-L123】【F:WristArcana/Utilities/StorageMonitor.swift†L1-L66】
- **Browse the deck** – The reference tab loads every card from `DecksData.json` through `CardRepository`. You can drill from suit lists down to detailed meanings, including upright/reversed interpretations and keyword chips.【F:WristArcana/Views/CardReferenceView.swift†L1-L37】【F:WristArcana/Views/CardReferenceDetailView.swift†L1-L68】【F:WristArcana/Models/CardRepository.swift†L1-L74】

## 🧠 Under the hood

### Architecture

- **SwiftUI + MVVM** – `MainView` hosts a three-tab interface (Reference, Draw, History). Each tab instantiates its own view model, keeping UI code declarative while business logic lives in `ViewModels/` with protocol-driven dependencies.【F:WristArcana/Views/MainView.swift†L1-L36】【F:WristArcana/ViewModels/CardDrawViewModel.swift†L1-L128】
- **SwiftData persistence** – `CardPull` records are stored locally and exposed to the UI via model containers. History fetches are sorted and truncated in `HistoryViewModel` for fast loading on watch hardware.【F:WristArcana/Models/CardPull.swift†L1-L56】【F:WristArcana/ViewModels/HistoryViewModel.swift†L1-L123】
- **Protocol-based services** – `DeckRepositoryProtocol`, `StorageMonitorProtocol`, and `CardRepositoryProtocol` allow production implementations to be swapped with mocks in unit tests, keeping view models testable.【F:WristArcana/Models/DeckRepository.swift†L10-L76】【F:WristArcana/Utilities/StorageMonitor.swift†L1-L66】【F:WristArcana/Models/CardRepository.swift†L1-L74】

### Data & assets

- **Deck metadata** – `Resources/DecksData.json` includes every card from the Rider–Waite–Smith deck with upright/reversed text and keyword tags.【F:WristArcana/Resources/DecksData.json†L1-L28】
- **Card art pipeline** – The `scripts/` directory provides `download_rws_cards.sh` and `process_images.sh` helpers for fetching public-domain artwork and resizing it for the asset catalog (requires ImageMagick).【F:scripts/download_rws_cards.sh†L1-L92】【F:scripts/process_images.sh†L1-L54】
- **Reusable UI** – Components such as `CTAButton`, `CardImageView`, and `FlowLayout` keep the watch interface consistent across tabs.【F:WristArcana/Components/CTAButton.swift†L1-L82】【F:WristArcana/Components/CardImageView.swift†L1-L78】

### Quality checks

- **Unit tests with Swift Testing** – The `WristArcana Watch AppTests` target exercises repositories, utilities, and view models using Apple’s `Testing` package for async-friendly assertions.【F:WristArcana/WristArcana Watch AppTests/ViewModelTests/CardDrawViewModelTests.swift†L1-L118】
- **Continuous integration** – `.github/workflows/ci.yml` runs SwiftLint, SwiftFormat, and a watchOS simulator build on macOS runners to guard formatting and compilation.【F:.github/workflows/ci.yml†L1-L36】

## 🚀 Getting started

1. **Requirements**
   - Xcode 16.1 (or later) with the watchOS 11 SDK
   - macOS Sonoma or newer
   - SwiftLint & SwiftFormat (via Homebrew) if you plan to run the same checks locally
2. **Clone the repo**
   ```bash
   git clone https://github.com/Geoffe-Ga/wrist-arcana.git
   cd wrist-arcana
   ```
3. **Open the project** – Launch `WristArcana/WristArcana.xcodeproj` and select the **WristArcana Watch App** scheme.
4. **Run on a simulator** – Choose an Apple Watch Series 10 simulator (45mm or 49mm) targeting watchOS 11 and press **⌘R**.
5. **(Optional) Refresh artwork** – Execute the helper scripts if you need to regenerate card images before importing them into the asset catalog.

### Running tests

Use `xcodebuild` to execute the Swift Testing suites from the command line:

```bash
xcodebuild test \
  -project WristArcana/WristArcana.xcodeproj \
  -scheme "WristArcana Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)'
```

### Handy scripts

- `scripts/download_rws_cards.sh` – Downloads the Rider–Waite–Smith scans from sacred-texts.com (public domain).
- `scripts/process_images.sh` – Resizes and centers each card into @1x/@2x/@3x PNGs for the watch asset catalog.
- `scripts/find_simulator_db.sh` – Locates the SwiftData store inside a running watch simulator for debugging saved pulls.【F:scripts/find_simulator_db.sh†L1-L55】

## 🗂️ Directory overview

- `WristArcana/` – watchOS project you open in Xcode. Start here when orienting yourself to the code:
  - `Views/` – SwiftUI screens for the three tabs plus supporting flows such as `NoteEditorView` and `CardReferenceDetailView`. Every screen leans on a matching view model and keeps the body declarative.【F:WristArcana/Views/MainView.swift†L1-L36】【F:WristArcana/Views/NoteEditorView.swift†L1-L148】
  - `ViewModels/` – MVVM state holders that coordinate persistence, validation, and navigation. Each view model exposes protocol-driven dependencies to make unit testing straightforward.【F:WristArcana/ViewModels/CardDrawViewModel.swift†L1-L128】【F:WristArcana/ViewModels/HistoryViewModel.swift†L1-L123】
  - `Models/` – Domain types plus repositories for loading card metadata and wrapping SwiftData access to `CardPull` history objects.【F:WristArcana/Models/TarotCard.swift†L1-L70】【F:WristArcana/Models/CardRepository.swift†L1-L74】
  - `Components/` – Reusable UI building blocks such as the CTA button, flowing keyword layout, and shared card art renderer used across multiple screens.【F:WristArcana/Components/CTAButton.swift†L1-L82】【F:WristArcana/Components/FlowLayout.swift†L1-L108】
  - `Configuration/` – App-wide constants and theming helpers that centralize typography, color palette, and haptics tuning.【F:WristArcana/Configuration/AppConstants.swift†L1-L66】【F:WristArcana/Configuration/Theme.swift†L1-L69】
  - `Utilities/` – Cross-cutting services such as secure randomness, note sanitizing, storage pressure monitoring, and shared extensions. These utilities back the view models and tests.【F:WristArcana/Utilities/RandomGenerator.swift†L1-L60】【F:WristArcana/Utilities/StorageMonitor.swift†L1-L66】
  - `Resources/` – Bundled assets. `DecksData.json` holds the full Rider–Waite card corpus while `Assets.xcassets` stores processed artwork and watch complications.【F:WristArcana/Resources/DecksData.json†L1-L28】
  - `WristArcanaApp.swift` – watchOS app entry point that wires the shared model container into the scene hierarchy.【F:WristArcana/WristArcanaApp.swift†L1-L57】
  - `WristArcana Watch AppTests/` – Swift Testing suites with repository and view-model coverage supported by in-memory container fixtures.【F:WristArcana/WristArcana Watch AppTests/ViewModelTests/HistoryViewModelTests.swift†L1-L164】
  - `WristArcana Watch AppUITests/` – UI test scaffold prepared for future integration runs.
  - `WristArcana.xcodeproj` – The project file; open this to work in Xcode.
- `scripts/` – Automation for fetching tarot artwork, resizing image assets, and introspecting simulator data stores.【F:scripts/download_rws_cards.sh†L1-L92】【F:scripts/find_simulator_db.sh†L1-L55】
- `prompts/` – Product briefs, QA notes, and AI collaboration history that capture the design intent of major features.
- `TEST_FILES_TO_ADD.md` – Checklist of remaining resources or fixtures that still need to land in the repo.
- Root documentation (`README.md`, `CONTRIBUTING.md`, `CLAUDE.md`, `AGENTS.md`) – Onboarding material for maintainers and collaborating agents.

## 📜 License & attribution

- Artwork download scripts reference the Rider–Waite–Smith deck hosted by the Sacred Texts Archive. The images are in the public domain; review local laws before redistribution.【F:scripts/download_rws_cards.sh†L1-L92】
- No explicit open-source license file is currently included. Please contact the maintainer before reusing the code or assets commercially.

---

Questions or ideas? Open an issue or reach out via the contact details in the project history.
