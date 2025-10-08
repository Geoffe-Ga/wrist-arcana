1. **Test-Driven Development (TDD) Is Required**
  - Write tests before or alongside new features.

  - For the backend (FastAPI), use pytest with lightweight, isolated tests.

  - Every bug fix must include a failing test that reproduces the bug before it is resolved.

2. **CI is Your Feedback Loop**
  - GitHub Actions is the source of truth for project health.

  - CI should pass green on every merge to main.

  - If CI fails, fix it before continuing. You are not permitted to “comment out the failing test.”

  - Agents must:

    - Iterate on .github/workflows until builds, linting, typing, and tests all pass.

    - Use caching, parallelism, and fail-fast behavior where beneficial.

    - Add new jobs for new language environments or tools as needed (e.g. SwiftLint, Expo CLI, Docker health checks).

3. **Make Small, Meaningful Commits**

  - Each commit should introduce one small logical change or fix.

  - Each pull request should include:

    - A brief human-readable summary

    - A short explanation for agents (if relevant)

    - Assurance that all CI steps have passed

    - `pre-commit run --all-files` status of Green

4. **Optimize for Learning and Maintainability**

  - Write code that teaches.

  - Comment your intentions more than your syntax.

  - Leave TODOs only if they are actionable and necessary.

  - Never introduce magic numbers or clever hacks without explanation.

5. **No Untested Assumptions**

  - Agents must validate their changes by:

    - Writing or updating relevant tests

    - Running the app in a simulated environment

    - Checking network requests for accurate backend interaction

6. **Respect the Archetypal Wavelength**

  - Restoration leads to Rising.

 - Agents are expected to work in cycles: test → think → implement → test → think → refine → repeat (until all green).

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
