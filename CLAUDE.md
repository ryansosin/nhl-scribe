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

## Build Order & Status

| # | Step | Status |
|---|------|--------|
| 1 | Project scaffold + data model (all 32 NHL teams) | ✅ Done |
| 2 | Name entry screen | ✅ Done |
| 3 | Home screen + sticker book shell (empty grid) | ⬜ Next |
| 4 | Team screen with logo and narration | ⬜ |
| 5 | Dotted letter tracing mechanic with PencilKit | ⬜ |
| 6 | Celebration screen | ⬜ |
| 7 | Goalie screen with NHL API fetch and AsyncImage | ⬜ |
| 8 | Goalie name tracing | ⬜ |
| 9 | YouTube goal horn embed | ⬜ |
| 10 | Sticker award animation + UserDefaults persistence | ⬜ |

**Resume at: Step 3 — Home screen + sticker book shell**

---

## Key Files

| File | Purpose |
|------|---------|
| `Hockey_ScribeApp.swift` | `@main` entry point — injects `AppState` as environment object |
| `HockeyWriterApp.swift` | Intentionally empty (was a duplicate `@main`) |
| `Item.swift` | Intentionally empty (SwiftData boilerplate — not used) |
| `Models/AppState.swift` | `ObservableObject` — holds `childName`, `completedTeamIDs`, `currentTeam`; persists to UserDefaults |
| `Models/NHLTeam.swift` | `NHLTeam` struct + `Color(hex:)` extension |
| `Models/TeamData.swift` | `allNHLTeams` — all 32 teams hardcoded with colors + YouTube video IDs |
| `Views/ContentView.swift` | Root router: shows `NameEntryView` if no name saved, else home screen |
| `Views/NameEntryView.swift` | First-launch name entry screen; saves to `AppState.childName` |

---

## Architecture Decisions

- **Storage**: UserDefaults only (via `AppState` `@Published` `didSet`). No CoreData, no SwiftData.
- **TTS**: AVSpeechSynthesizer throughout — no third-party TTS.
- **Letter tracing**: CoreGraphics `CGPath` + `CGLineDash` dotted overlay. PencilKit for input. Detection should be very forgiving (4.5-year-old).
- **Goalie photos**: `AsyncImage` with `URLCache`. NHL API: `https://api-web.nhle.com/v1/roster/{abbrev}/current`. Headshots: `https://assets.nhle.com/mugs/{playerID}.png`.
- **Team logos**: Bundle as SVG assets in the asset catalog named `logo_{ABBREV}` (e.g. `logo_BOS`). Not yet added — needs to be done before Step 4.
- **Goal horn videos**: WKWebView YouTube embed, autoplay.

---

## Build Notes / Known Issues

- Xcode project was created with **SwiftData** selected as storage option. `Item.swift` and the SwiftData `ModelContainer` setup have been gutted — the files are empty stubs kept so Xcode doesn't break. Do not delete them from the Xcode project navigator.
- To test the name entry screen from scratch: **Simulator → Device → Erase All Content and Settings** (clears UserDefaults).
- SourceKit shows false-positive "Cannot find type" errors in the editor because it doesn't resolve cross-file types without a full index. Builds succeed fine.

---

## App Flow (full spec)

1. **First launch** → Name entry screen → stores child's name
2. **Home screen** → "Play" button + sticker book button
3. **Session per team** (random, no repeats until all 32 done):
   - Team screen: logo + primary color bg + narration "Let's write [NICKNAME], Teddy!"
   - Trace the nickname (dotted uppercase letters, PencilKit, phonics sounds per letter)
   - Hockey celebration (confetti in team colors, "GOAL!" animation, crowd cheer, ~3s)
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
- Letter completion: phonics sound for each letter (e.g. "buh" for B)
- Celebration: *"Amazing job, [childName]!"*
- Goalie screen: *"Tap a goalie, [childName]!"*
- Goalie name: spoken aloud on tap via AVSpeechSynthesizer
