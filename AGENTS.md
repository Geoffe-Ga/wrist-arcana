# WristArcana project map

- `WristArcana/Views/` – SwiftUI entry points for the Reference, Draw, and History tabs plus supporting flows (note editor, card detail).
- `WristArcana/ViewModels/` – MVVM logic that orchestrates card draws, deck loading, and history persistence via protocol-driven services.
- `WristArcana/Models/` – Tarot domain models (`TarotCard`, `TarotDeck`, `CardPull`) and repositories for SwiftData and JSON-backed data sources.
- `WristArcana/Components/` – Shared UI building blocks (CTA button, card art renderer, flow layout) reused across screens.
- `WristArcana/Configuration/` – Theme and constants centralizing typography, colors, haptics, and limits.
- `WristArcana/Utilities/` – Cross-cutting helpers (random generator, storage monitor, note sanitizer, date formatting extensions).
- `WristArcana/Resources/` – Asset catalog and `DecksData.json` bundle shipped with the watch app.
- `WristArcanaApp.swift` & `WristArcana.xcodeproj` – App entry point and project file to open in Xcode.
- `WristArcana Watch AppTests/` & `WristArcana Watch AppUITests/` – Unit and UI test targets with Swift Testing scaffolding.
- `scripts/` – Shell utilities for tarot art downloads, image processing, and simulator inspection.
- `prompts/` – Product briefs and debugging prompts capturing design intent for AI collaborators.
- `TEST_FILES_TO_ADD.md` – Checklist of remaining assets or fixtures slated for inclusion.
- Root docs (`README.md`, `CONTRIBUTING.md`, `CLAUDE.md`) – Onboarding references and workflow guidance.
