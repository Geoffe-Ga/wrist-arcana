# Draw Screen Layout – RCA and Solution Plan

## Why Claude's attempts are failing
- **Spacer-driven layout fights safe areas and page dots.** `DrawCardView` currently uses a `VStack` with a single `Spacer` inside a `GeometryReader`. The text lands at the top of the VStack, but the button is simply pushed down until the spacer runs out of space. This ignores the watchOS safe-area insets added by the status bar/clock and the `.page`-style `TabView` page indicators, so the title and button shift depending on device size and tab chrome instead of staying pinned to known edges. 【F:WristArcana/Views/DrawCardView.swift†L28-L70】【F:WristArcana/Views/MainView.swift†L14-L30】
- **Padding prevents the glow from reaching the edge.** The CTA button is given `.padding(.bottom, 10)`, which lifts both the circle and its shadow off the bottom of the screen. Because the glow radius extends beyond the button frame, any extra bottom padding makes the glow stop short of the screen edge. 【F:WristArcana/Views/DrawCardView.swift†L55-L70】【F:WristArcana/Components/CTAButton.swift†L17-L38】
- **GeometryReader without explicit alignment leaves the title floating.** The title relies on default top alignment and font scaling, but there is no top inset to position it directly under the clock. On smaller watches the clock/safe area eats into the available height, causing the title to drift downward once the button + spacer consume space. 【F:WristArcana/Views/DrawCardView.swift†L28-L52】
- **No guardrails for horizontal centering.** Both elements rely on the parent `VStack` to center them, but insets from tab chrome or future padding changes could shift them. Explicit centering on the full-width container is safer than incidental alignment from the stack. 【F:WristArcana/Views/DrawCardView.swift†L28-L70】

## Comprehensive solution plan
1. **Reframe the layout with a ZStack and safe-area insets.**
   - Wrap the screen in `ZStack(alignment: .top)` so the title and button are positioned independently of each other.
   - Use `safeAreaInset(edge: .top)` to place the "Tarot" title directly under the clock, ensuring consistent spacing across devices.
   - Use `safeAreaInset(edge: .bottom)` to host the CTA button so its frame aligns with the safe-area edge while letting the shadow/glow extend to the absolute bottom.
2. **Explicit centering for both elements.**
   - Give the title a `.frame(maxWidth: .infinity, alignment: .center)` and keep the button inside a horizontally centered container so neither can drift with parent padding.
3. **Remove bottom padding that lifts the glow.**
   - Drop the `.padding(.bottom, 10)` on the CTA button; if extra breathing room is needed above the page dots, replace it with a small negative `safeAreaInset` offset so the glow, not the button body, touches the edge.
4. **Control vertical spacing with constants instead of Spacer.**
   - Replace the single `Spacer` with measured spacing (e.g., a `Spacer(minLength:)` or fixed `padding`) so clock/title spacing is deterministic and not affected by button height or tab indicators.
5. **Accommodate multiple watch sizes.**
   - Keep the existing responsive sizing helpers but cap the button height if it would collide with the title when safe-area insets shrink the available height; adjust the scale calculation to consider `geometry.safeAreaInsets`.
6. **Testing and validation.**
   - Add SwiftUI previews for 41mm, 45mm, and Ultra sizes showing the title flush below the clock and the glow touching the bottom edge.
   - Run the Draw tab in the simulator on multiple sizes to confirm the button is not clipped by the page indicator and remains horizontally centered.
   - If UI tests exist for button visibility, extend them with assertions for element positions using snapshot/screen size heuristics.

## Execution checklist
- [x] Refactor `DrawCardView` layout using `ZStack` + `safeAreaInset` for top and bottom anchoring.
- [x] Remove bottom padding from the CTA button; ensure the glow naturally reaches the bottom edge.
- [x] Add alignment frames to explicitly center title and button.
- [x] Update size helpers to respect safe-area insets when computing heights.
- [x] Expand previews to cover multiple watch sizes and verify the layout contract.
- [x] Run SwiftFormat/SwiftLint and applicable UI tests after changes.

**Completed:** All checklist items implemented in commit 0e2a873. Layout now uses ZStack with safeAreaInsets, respects safe areas in sizing calculations, and includes 3 watch size previews. All linters pass.
