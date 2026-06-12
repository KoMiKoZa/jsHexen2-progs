# jsHexen2+ Progs

Game-logic source (`progs.dat`) for **Hexen II: Portal of Praevus**, maintained
for the [jsHexen2+ engine](https://github.com/KoMiKoZa) project.

Based on **Raven's v1.21 of the Hexen II progs** — the final official source —
with bugs fixed one commit at a time. No balance changes, no redesigns:
if it crashed, blocked progress, or plainly misbehaved, it gets fixed.
If it would change how the game *feels*, it doesn't go in (or ships as an
opt-in toggle, off by default).

**Your saves are safe.** The save-format fields are never touched, so any
existing save loads with any version of these progs.

## Version

Current: **jsHexen2+ Progs 1.0.0 (in development)**

The version is printed in the console when a map loads:

```
jsHexen2+ Progs 1.0.0 (based on Raven v1.21)
```

Numbering is semantic: MAJOR = generation, MINOR = each released fix batch,
PATCH = corrections to a batch. The engine (`jsHexen2.exe`) has its own
separate version line.

## Changelog

Each fix is one commit. The commit hash is the unique ID — `git show <hash>`
shows exactly what changed.

### 1.0.0 (in development)

| Commit | Fix | What it does |
|---|---|---|
| `03db4a6` | Tempest Staff: charged trigger | *(deliberate redesign)* The Demoness staff's normal fire is now a true charge weapon: press and hold to charge (about a second — the prongs open and the ball builds between them), the ball fires at full charge, and releasing early cancels it — no ball, no mana. A quick tap does nothing anymore. Holding keeps cycling charged shots at the vanilla sustained rate, so damage output is unchanged. The charge hums while it builds, and the Tome of Power mode is untouched. |
| `03db4a6` | Tempest Staff: restorations | Weapon animations run on the player's 20Hz animation clock — but a dispatch bug re-entered the staff's fire code every rendered frame while the button was held, turbo-playing the first windup in a fraction of a second (framerate-dependent since retail: the faster the machine, the more instant the first ball) and wiping the weapon's hold-state flag every frame, so the designed hold behavior never worked. Fixed with a re-entry guard and an evenly time-paced charge. Also fixed: the shot played its sound twice (two copies stacked on different channels), every lightning ball dragged TWO copies of a looping hum through its whole flight (the ball now flies silent — the hum became the charge sound), and switching weapons mid-fire left the staff's light stuck on you. The charge light is now white like its lightning (it used to borrow the torch's orange); the staff and torch no longer share light bits at all. |
| `9bf5d28` | Scorpion melee whiffs | Scorpions can now actually hit you on slopes and steps. Their claw swipe is a single straight trace at the scorpion's own origin height — floor level — so on uneven ground it clipped terrain short of the target, and a scorpion could claw at you endlessly without landing a hit. When the blind swipe misses, it now retries aimed at the target's center, with the same reach; flat-ground behavior is untouched. (Surfaced by Shanjaq/uhexen2-progs as a crouch-immunity fix — the trace geometry and a field repro on a slope showed terrain was the real culprit, and his raised retry still missed uphill.) |
| `68cc25e` | Water douses the torch | Raven wrote a water-douse function and never wired it (shipped commented out, "`//Never called?!`"). Restored: going fully under water extinguishes a lit torch with a fizzle, and a torch can't be lit while your head is submerged (the attempt fizzles and costs nothing). Wading waist-deep is fine. |
| `68cc25e` | Two-state torch light | The torch finally looks like its sound cues: full burn is a big warm light, the "going out" sound drops it to the vanilla dim size for the 7-second gutter, then it dies. The light is full-size from the moment you light up, and refreshing with a new torch works exactly during the gutter warning — a torch burning strong can't be relit, so hammering the use key no longer wastes torches. (On engines without the paired render change, both phases simply look vanilla.) |
| `f997888` | Infinite-torch exploit | A torch is now consumed the moment you light it, like every other artifact. Vanilla only consumed it at burn-out — and refreshing the torch in its last 5 seconds postpones burn-out forever, so one torch could burn eternally without ever leaving your inventory. Visible change: the inventory count drops when you light up, and refreshing costs a torch. (Spotted by Math; same fix as SoT.) |
| `660f17b` | Torch light bug | The torch no longer turns into a wide white light or goes dark when firing the Tempest Staff, and the *burn* system (catching fire, or water putting that fire out) no longer snuffs the torch's light along with it. Root cause: `EF_TORCHLIGHT` was `6` — two other flags glued together — so a burning torch secretly carried a white light that appeared whenever something else touched the player's light. It is now its own flag, and the staff/burn code never strips a light the torch owns. Also made dim-phase use actually relight (vanilla silently did nothing); the relight rule was later refined — see the two-state commit. |
| `e872eb7` | Version print | The console shows `jsHexen2+ Progs 1.0.0 (based on Raven v1.21)` on every map load, so you can always tell which progs you're running. |
| `78436a8` | Vanilla import | Raven v1.21-final mission-pack source, untouched baseline. |

_(more fixes land here as they are committed — crashes & broken levels next,
then visible misbehaviors, then rules & abuse)_

## Building

The source compiles with any HexenC compiler from the Hexen II source-release
lineage. This project builds with **NHCC** (Jacques Krige's modified build of
Raven's HCC); the stock **hcc** that ships with [Hammer of Thyrion /
uhexen2](https://sourceforge.net/projects/uhexen2/) works as well — no
compiler binary is redistributed here for licensing reasons.

```
cd portals
nhcc.exe -name Progs.src      (or: hcc -os -oi -on)
```

Output: `progs.dat` (+ `progs.lno` line-number file for debugging). Place
`progs.dat` loose in your `Portals/` game directory — it overrides the
version inside the pak files.

## Layout

- `portals/` — the mission-pack game-logic source (`.hc` files + `Progs.src`)

## License

GPL v2, following the Hexen II source-release lineage (same as
Hammer of Thyrion / uhexen2).
