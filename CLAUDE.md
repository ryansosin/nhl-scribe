# Hockey Scribe — Project Context

iPadOS app for Teddy (age 4.5) to practice handwriting using NHL teams and goalie names. Apple Pencil input. TestFlight distribution only — no App Store compliance needed.

---

## Xcode Project Location

```
/Users/ryansosin/Documents/nhl-scribe/Hockey Scribe/Hockey Scribe.xcodeproj
```

All Swift source files live under:
```
/Users/ryansosin/Documents/nhl-scribe/Hockey Scribe/Hockey Scribe/
```

---

## Build Status

All 10 steps complete. The app is fully functional end-to-end.

| # | Step | Status |
|---|------|--------|
| 1 | Project scaffold + data model (all 32 NHL teams) | ✅ Done |
| 2 | Name entry screen | ✅ Done |
| 3 | Home screen + sticker book shell | ✅ Done |
| 4 | Team screen with logo and narration | ✅ Done |
| 5 | Dotted letter tracing mechanic with PencilKit | ✅ Done |
| 6 | Celebration screen | ✅ Done |
| 7 | Goalie screen with NHL API fetch and AsyncImage | ✅ Done |
| 8 | Goalie name tracing | ✅ Done |
| 9 | YouTube goal horn embed | ✅ Done |
| 10 | Sticker award animation + UserDefaults persistence | ✅ Done |

---

## Key Files

| File | Purpose |
|------|---------|
| `Hockey_ScribeApp.swift` | `@main` entry point — injects `AppState` as environment object |
| `HockeyWriterApp.swift` | Intentionally empty (was a duplicate `@main`) |
| `Item.swift` | Intentionally empty (SwiftData boilerplate — not used) |
| `Models/AppState.swift` | `ObservableObject` — holds `childName`, `completedTeamIDs`, `currentTeam`, `currentGoalie`, `sessionPhase`, `tracingSnapshot`; persists to UserDefaults |
| `Models/NHLTeam.swift` | `NHLTeam` struct + `Color(hex:)` extension |
| `Models/TeamData.swift` | `allNHLTeams` — all 32 teams hardcoded with colors + YouTube video IDs |
| `Views/ContentView.swift` | Root router: shows `NameEntryView` if no name saved, else routes by `sessionPhase` |
| `Views/NameEntryView.swift` | First-launch name entry screen; saves to `AppState.childName` |
| `Views/HomeView.swift` | Home screen: PLAY button, Sticker Book button, progress counter; 3-sec long-press resets app |
| `Views/TeamView.swift` | Team logo + primary color bg + TTS narration |
| `Views/TracingView.swift` | PencilKit letter tracing — handles both team nickname and goalie last name |
| `Views/PencilKitCanvas.swift` | `UIViewRepresentable` wrapper for `PKCanvasView` |
| `Views/CelebrationView.swift` | GOAL! confetti screen with tracing snapshot; used after both team and goalie tracing |
| `Views/GoalieView.swift` | Fetches roster from NHL API, shows goalie photo cards, tap to hear name |
| `Views/StickerAwardView.swift` | Sticker award animation; marks team complete in `AppState` |
| `Views/GoalHornView.swift` | WKWebView YouTube embed, autoplay; "Next Team!" button after 10s |
| `Views/StickerBookView.swift` | 32-team grid; completed = color logo + gold star, incomplete = dark silhouette |

---

## Architecture Decisions

- **Storage**: UserDefaults only (via `AppState` `@Published` `didSet`). No CoreData, no SwiftData.
- **TTS**: AVSpeechSynthesizer throughout — no third-party TTS.
- **Phonics sounds**: `AVSpeechUtterance(ssmlRepresentation:)` with IPA phoneme tags (`<phoneme alphabet="ipa" ph="...">`) — gives precise phonics sounds instead of letter names. Plain text spellings like "buh" were unreliable with the TTS engine.
- **Letter tracing**: PencilKit (`PKCanvasView`) for input, single full-screen canvas. Letter completion uses **spatial routing + pixel-mask coverage**, not timers:
  - Each letter `Text` view captures its `.global` frame into `letterFrames: [Int: CGRect]` via `onGeometryChange`. PKCanvasView ignores safe area, so its local stroke coords align 1:1 with `.global` window coords.
  - Each new stroke is attributed to a letter by `dominantLetter(for:)`: filter the stroke's points to the letters' vertical band, then assign by nearest letter midX. Lets Teddy race ahead — strokes get credited to the right letter even before we advance to it.
  - Coverage check (`LetterCoverageMask` in same file): render the dotted glyph at 0.2× scale into a bitmap, dilate via `CIGaussianBlur` radius 12 to merge sparse dots into a fat letter shape, count "on" pixels. Render the user's strokes (only those attributed to this letter) at the same scale. Coverage = pixel overlap / mask "on" pixels. Threshold **0.10** (very lenient — Teddy is 4).
  - On any `canvasViewDrawingDidChange`: re-attribute new strokes, evaluate the current letter, and if coverage trips, advance and recursively re-evaluate the next letter (so already-written-ahead letters complete instantly with no UI lag). Phonics utterances queue naturally on `AVSpeechSynthesizer`.
  - Fallback: 2s of inactivity with at least one stroke attributed to the current letter forces an advance, so Teddy can never get stuck.
  - Tunables at top of `TracingView`: `coverageThreshold`, `fallbackInactivity`. Mask `dilateRadius` and `renderScale` live on `LetterCoverageMask`.
- **Tracing canvas size**: Captured via `onGeometryChange` into `@State var canvasSize`; scale via `@Environment(\.displayScale)`. Do not use `UIScreen.main` (deprecated iOS 26).
- **Goalie photos**: `AsyncImage` with `URLCache`. NHL API: `https://api-web.nhle.com/v1/roster/{abbrev}/current`. Headshots: `https://assets.nhle.com/mugs/{playerID}.png`.
- **Team logos**: Bundle as SVG assets in the asset catalog named `logo_{ABBREV}` (e.g. `logo_BOS`).
- **Goal horn videos**: WKWebView YouTube embed, autoplay. JavaScript enabled via `defaultWebpagePreferences.allowsContentJavaScript` (not the deprecated `preferences.javaScriptEnabled`).
- **Bottom buttons**: Use `.safeAreaInset(edge: .bottom)` on the parent ZStack — not `.padding(.bottom, N)` inside a VStack, which doesn't account for safe area on all iPad models.
- **CelebrationView auto-advance**: Uses a cancellable `DispatchWorkItem` (stored in `@State`). The work item is cancelled on manual tap and in `onDisappear` to prevent a double-fire bug that was skipping the goalie screen.

---

## Build Notes / Known Issues

- Xcode project was created with **SwiftData** selected as storage option. `Item.swift` and the SwiftData `ModelContainer` setup have been gutted — the files are empty stubs kept so Xcode doesn't break. Do not delete them from the Xcode project navigator.
- SourceKit shows false-positive "Cannot find type" / "No such module" errors in the editor because it doesn't resolve cross-file types without a full index. Builds succeed fine — ignore these.
- **Developer reset**: 3-second long press anywhere on `HomeView` → confirmation alert → clears name + all stickers from both UserDefaults and live `AppState`. Use this before handing the iPad to Teddy.

---

## App Flow (full spec)

1. **First launch** → Name entry screen → stores child's name
2. **Home screen** → "Play" button + sticker book button
3. **Session per team** (random, no repeats until all 32 done):
   - Team screen: logo + primary color bg + narration "Let's write [NICKNAME], Teddy!"
   - Trace the nickname (dotted uppercase letters, PencilKit, phonics sounds per letter)
   - Hockey celebration (confetti in team colors, "GOAL!" animation, ~3.5s auto-advance or tap)
   - Goalie screen: 2–3 goalie photo cards, tap to hear name
   - Trace the goalie's last name
   - Hockey celebration again
   - Goal horn YouTube video (autoplay, "Next Team!" button after 10s)
   - Sticker awarded: logo animates into sticker book icon
4. **Sticker book**: 32-team grid, completed = color logo + gold star, incomplete = dark silhouette

---

## Narration Strings

- Team screen: *"Let's write [NICKNAME], [childName]!"*
- Tracing encouragement: *"Keep going!"*, *"You're doing great!"*
- Letter completion: IPA phonics sound per letter via SSML (e.g. `æ` for A, `bʌ` for B)
- Celebration: *"Amazing job, [childName]!"*
- Goalie screen: *"Tap a goalie, [childName]!"*
- Goalie name: spoken aloud on tap via AVSpeechSynthesizer
