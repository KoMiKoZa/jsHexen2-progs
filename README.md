# jsHexen2+ Progs

![License: GPL v2](https://img.shields.io/badge/License-GPL_v2-blue.svg)
![Progs](https://img.shields.io/badge/progs-1.0.0--dev-orange.svg)
![Base](https://img.shields.io/badge/base-Raven_v1.12a-8B0000.svg)

Game-logic source (`progs.dat`) for **Hexen II: Portal of Praevus**, maintained
for the [jsHexen2+ engine](https://github.com/KoMiKoZa) project.

Based on **Raven's v1.12a of the Hexen II progs** — the final official source —
fixed one commit at a time. Priority goes to correctness: crashes, progression
blockers, and plain misbehavior. Content that shipped broken or unfinished is
restored to what it was meant to do, and in a few deliberate cases a mechanic
that never actually worked as designed is reworked rather than left limping —
kept rare and grounded in the original intent. Pure balance is left alone; where
a change is a matter of taste, it can ship as an optional toggle.

> [!IMPORTANT]
> **Your saves are safe.** The save-format fields are never touched, so any
> existing save loads with any version of these progs.

## What this covers

`progs.dat` is the game's logic — every monster, weapon, item, and trigger.
The expansion's progs (this project) contains all of the base game's logic
*plus* everything Portal of Praevus added, and a mission-pack engine
(jsHexen2+ included) runs **everything** through it — the original campaign
too. The base game's own `progs.dat` (in `data1/`, final official version
1.11) is a different, older program that mission-pack engines never load:
it sits inert and is out of scope here. Fixing this one file fixes all of
Hexen II as you actually play it.

> [!NOTE]
> **Works in other engines too.** This is a standard mission-pack `progs.dat`
> on the official v1.12 data layout — any engine that runs Portal of Praevus
> loads it: [Hammer of Thyrion / uhexen2](https://sourceforge.net/projects/uhexen2/),
> FTE's Hexen II support, forks, even the original 1998 expansion exe.
> One cosmetic feature (the two-state torch light) is paired with a jsHexen2+
> render upgrade and simply looks vanilla elsewhere; everything else is pure
> game logic and behaves identically on any engine.

## Version

Current: **jsHexen2+ Progs 1.0.0 (in development)**

The version is printed in the console when a map loads:

```
jsHexen2+ Progs 1.0.0 (based on Raven v1.12a)
```

Numbering is semantic: MAJOR = generation, MINOR = each released fix batch,
PATCH = corrections to a batch. The engine (`jsHexen2.exe`) has its own
separate version line.

## Changelog

Each fix is one commit. The commit hash is the unique ID — `git show <hash>`
shows exactly what changed.

<details open>
<summary><h3>📜 1.0.0 (in development) — 38 fixes &nbsp;<sub><i>(click to collapse)</i></sub></h3></summary>

<br>

| Commit | Date | Fix | What it does |
|---|---|---|---|
| `856878a` | 2026-06-13 | Succubus mana typo | A precedence typo (`level - 2/10` instead of `(level - 2)/10`) made damage taken refill the Demoness's green mana ~7–10× too fast at high levels. Parenthesized — the adjacent blue-mana line shows the intended formula. (Spotted by Pa3PyX.) |
| `856878a` | 2026-06-13 | Soul spheres grant mana | The Necromancer's soul spheres were supposed to grant mana — the manual even warns "Soul Spheres quickly lose their potency, so the Necromancer must be swift!" — but the code read values nothing ever set: the mechanic was dead since release. Restored with the documented decay: full potency if grabbed fast, fading to nothing over the sphere's 15 seconds. (Fix by Pa3PyX, shipped by HoT/uhexen2.) |
| `856878a` | 2026-06-13 | Leech vs Mystic Urn | The sickle's life-leech (and soul-sphere health) clamped your health to maximum unconditionally — one leech proc instantly deleted up to ~100 HP of Mystic Urn overheal. Healing now only applies when below max; overheal is preserved. (Spotted by Pa3PyX.) |
| `b40cabd` | 2026-06-12 | DM rules leaking into SP/coop | The `noexit` rule (kills players touching level exits) and the time/frag limits ran in *every* game mode — leftover deathmatch cvars could murder you at a single-player exit or end an SP/coop map out of nowhere. Both now require deathmatch. (HoT/uhexen2) |
| `b40cabd` | 2026-06-12 | Impulse 11 progression cheat | `impulse 11` let any player set the server's cross-level progression flags in any mode — skipping hub progression with one console command. Disabled, exactly as HoT does. |
| `a97a976` | 2026-06-12 | Flag arithmetic corruption | Five places set entity flags with `+=` (arithmetic add) instead of the bitwise operator — if the flag was already on, the whole flag set got corrupted (re-init, force-shield recast, summon paths). All five converted. (HoT/uhexen2) |
| `a97a976` | 2026-06-12 | Summoned weretiger head gib | The weretiger's head-gib model is only precached by its own spawn function, which summoned spawns skip — head-gibbing a summoned weretiger hit an unprecached model. Now precached in the summon path too. (HoT/uhexen2) |
| `f4f79a2` | 2026-06-12 | Skullwizard blinks at ghosts | His teleport-out lasts up to 3 seconds; if his target died or despawned meanwhile, he re-placed himself relative to a stale reference (which reads as the map origin). He now drops the dead target and reappears randomly, as designed for the no-enemy case. (HoT/uhexen2) |
| `f4f79a2` | 2026-06-12 | Fish schools swim to nowhere | Fish follow a school leader; a dead or removed leader read as coordinates 0,0,0 and the whole school migrated to the map origin. Orphaned fish now keep their last heading. (HoT/uhexen2) |
| `f4f79a2` | 2026-06-12 | Stuck bolts warp away | Crossbow bolts and stickmines stuck to an entity followed it — and if the host was *removed* rather than killed (or its slot recycled), they warped to wherever the slot now points, classically the map origin. They now detach and fall. (Shanjaq/uhexen2-progs) |
| `1dd0d6e` | 2026-06-12 | Werepanther corpse attacks | A werepanther killed mid-charge kept its body-slam active — the sliding corpse punched players and even redirected its own AI away from dying. Alive-gate added. (HoT/uhexen2) |
| `1dd0d6e` | 2026-06-12 | Snake boss re-wakes when dead | The snake boss's wake/sleep toggle had no alive check — triggering it after death woke the corpse. (HoT/uhexen2) |
| `1dd0d6e` | 2026-06-12 | Imp dies "alive" | The imp's ascending death never cleared its alive status and never stopped its wing-flap sound loop. Both fixed. (HoT/uhexen2) |
| `1dd0d6e` | 2026-06-12 | Medusa's noisy corpse | Her death now silences the attack/body sound channels — loop-marked samples otherwise played on the corpse forever. (HoT/uhexen2) |
| `ddbc82d` | 2026-06-12 | Tornado always-throw typo | `if (x = -1)` assigned instead of compared — always true, so the tornado always hurled victims at its goal, never did the random scatter, and corrupted its own timer doing it. (HoT/uhexen2) |
| `ddbc82d` | 2026-06-12 | Lavaballs barely rise | `self.speed == 1000;` compared instead of assigned — a statement that does nothing, so lavaballs kept speed 0. They actually fly now. (HoT/uhexen2) |
| `ddbc82d` | 2026-06-12 | Raven shot ghost physics | A typo'd second assignment overwrote the raven missile's collision type with a value from the wrong constant family (`DAMAGE_YES` = 1 = `SOLID_TRIGGER`) — the ravens flew as non-blocking ghosts for 27 years. Line deleted, as HoT does; deliberately *not* made damageable (no death wiring — it would crash on the first hit). |
| `ddbc82d` | 2026-06-12 | Stillness-fade always on | An operator-precedence slip (`&a\|b` parses as `(x&a)\|b`) made the assassin's fade-back-in branch always true. Parenthesized. (HoT/uhexen2) |
| `24efda5` | 2026-06-12 | Eidolon finale block | Killing Eidolon during his intro howl or mid-transformation killed him in an invalid state and the base campaign's ending never triggered — vanilla only suppressed his pain reactions during those windows, not death itself. He is now truly invulnerable through the intro and the grow, becoming vulnerable the moment each howl completes. (Fix from HoT/uhexen2.) |
| `c36b473` | 2026-06-12 | Praevus fast-kill finale block | The expansion's ending chain only fired from Praevus's mid-fight health stages — his death sequence never fired targets at all, so killing him fast enough to skip a stage left the finale permanently stuck. His death now fires the chain exactly once whenever the stages missed it. (Fix from HoT/uhexen2.) |
| `9afccb3` | 2026-06-12 | DM level change on custom maps | Deathmatch on a custom map with no exit *overwrote the live map-name global* mid-game with "demo1". It now uses the next-map variable properly and records where a found exit trigger leads. (Fix from HoT/uhexen2.) |
| `10cdf83` | 2026-06-12 | Summoned monster in a wall | A summoned creature spawning into a wall removed itself, then kept initializing its own corpse — use-after-remove. It now stops. (Fix from HoT/uhexen2.) |
| `25962aa` | 2026-06-12 | Tibet5 wheel timer | A trigger timer used the literal 999999999999 — too large for a float to carry cleanly, breaking the prayer wheel. Replaced with the proper "never think again" value. (Fix from HoT/uhexen2.) |
| `25962aa` | 2026-06-12 | Temple of Mars prize trigger | Cross-level triggers use spawnflag 8 as "trigger 4", but the same flag means "start inactive" on other triggers — an inherited inactive state left the prize trigger permanently dead. Cleared on spawn. (Fix from HoT/uhexen2.) |
| `d78477a` | 2026-06-12 | Scarab Staff world-remove | A stray semicolon made the scarab's death delete its chained model *unconditionally* — with no chain attached, it deleted the world entity. The conditional actually conditions now. (Fix from HoT/uhexen2.) |
| `f49860e` | 2026-06-12 | Unkillable monsters | A player-only camera invulnerability check was applied to every entity — a monster with a stray value in that field could not be damaged at all. Players only now. (Fix from HoT/uhexen2.) |
| `f49860e` | 2026-06-12 | Tibet1 pentacle invulnerable | A player-only damage-bonus field was read from monster attackers too, corrupting damage into negative numbers — the tibet1 catapult pentacles healed from hits instead of breaking. Players only now. (Fix from HoT/uhexen2.) |
| `09450d3` | 2026-06-12 | Mezzoman crash | The infamous "assignment to world entity" crash: the mezzoman's reflection trigger deleted itself when its owner died, then kept running its touch logic as a removed entity. It now stops after deleting itself. (Fix from HoT/uhexen2.) |
| `09450d3` | 2026-06-12 | Tibet7 yakman never spawns | Removing a mezzoman's shield left a dangling reference behind; a later "shield removal" deleted whatever entity had recycled the slot — on tibet7 it ate the yakman's spawn entity, so the boss never appeared. References are now cleared after removal. (Fix from HoT/uhexen2.) |
| `03db4a6` | 2026-06-12 | Tempest Staff: charged trigger | *(deliberate redesign)* The Demoness staff's normal fire is now a true charge weapon: press and hold to charge (about a second — the prongs open and the ball builds between them), the ball fires at full charge, and releasing early cancels it — no ball, no mana. A quick tap does nothing anymore. Holding keeps cycling charged shots at the vanilla sustained rate, so damage output is unchanged. The charge hums while it builds, and the Tome of Power mode is untouched. |
| `03db4a6` | 2026-06-12 | Tempest Staff: restorations | Weapon animations run on the player's 20Hz animation clock — but a dispatch bug re-entered the staff's fire code every rendered frame while the button was held, turbo-playing the first windup in a fraction of a second (framerate-dependent since retail: the faster the machine, the more instant the first ball) and wiping the weapon's hold-state flag every frame, so the designed hold behavior never worked. Fixed with a re-entry guard and an evenly time-paced charge. Also fixed: the shot played its sound twice (two copies stacked on different channels), every lightning ball dragged TWO copies of a looping hum through its whole flight (the ball now flies silent — the hum became the charge sound), and switching weapons mid-fire left the staff's light stuck on you. The charge light is now white like its lightning (it used to borrow the torch's orange); the staff and torch no longer share light bits at all. |
| `9bf5d28` | 2026-06-12 | Scorpion melee whiffs | Scorpions can now actually hit you on slopes and steps. Their claw swipe is a single straight trace at the scorpion's own origin height — floor level — so on uneven ground it clipped terrain short of the target, and a scorpion could claw at you endlessly without landing a hit. When the blind swipe misses, it now retries aimed at the target's center, with the same reach; flat-ground behavior is untouched. (Surfaced by Shanjaq/uhexen2-progs as a crouch-immunity fix — the trace geometry and a field repro on a slope showed terrain was the real culprit, and his raised retry still missed uphill.) |
| `68cc25e` | 2026-06-12 | Water douses the torch | Raven wrote a water-douse function and never wired it (shipped commented out, "`//Never called?!`"). Restored: going fully under water extinguishes a lit torch with a fizzle, and a torch can't be lit while your head is submerged (the attempt fizzles and costs nothing). Wading waist-deep is fine. |
| `68cc25e` | 2026-06-12 | Two-state torch light | The torch finally looks like its sound cues: full burn is a big warm light, the "going out" sound drops it to the vanilla dim size for the 7-second gutter, then it dies. The light is full-size from the moment you light up, and refreshing with a new torch works exactly during the gutter warning — a torch burning strong can't be relit, so hammering the use key no longer wastes torches. (On engines without the paired render change, both phases simply look vanilla.) |
| `f997888` | 2026-06-12 | Infinite-torch exploit | A torch is now consumed the moment you light it, like every other artifact. Vanilla only consumed it at burn-out — and refreshing the torch in its last 5 seconds postpones burn-out forever, so one torch could burn eternally without ever leaving your inventory. Visible change: the inventory count drops when you light up, and refreshing costs a torch. (Spotted by Math; same fix as SoT.) |
| `660f17b` | 2026-06-12 | Torch light bug | The torch no longer turns into a wide white light or goes dark when firing the Tempest Staff, and the *burn* system (catching fire, or water putting that fire out) no longer snuffs the torch's light along with it. Root cause: `EF_TORCHLIGHT` was `6` — two other flags glued together — so a burning torch secretly carried a white light that appeared whenever something else touched the player's light. It is now its own flag, and the staff/burn code never strips a light the torch owns. Also made dim-phase use actually relight (vanilla silently did nothing); the relight rule was later refined — see the two-state commit. |
| `e872eb7` | 2026-06-12 | Version print | The console shows `jsHexen2+ Progs 1.0.0 (based on Raven v1.12a)` on every map load, so you can always tell which progs you're running. |
| `78436a8` | 2026-06-12 | Vanilla import | Raven v1.12a-final mission-pack source, untouched baseline. |

</details>

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
`progs.dat` loose in your `Portals/` game directory — a loose file wins over
the copy inside the paks.

> [!TIP]
> Some installs already ship `progs.dat` extracted loose; replace it, and
> keep the original as `progs_vanilla.dat` so you can always A/B against
> stock behavior.

## Layout

- `portals/` — the mission-pack game-logic source (`.hc` files + `Progs.src`)

## License

GPL v2, following the Hexen II source-release lineage (same as
Hammer of Thyrion / uhexen2).
