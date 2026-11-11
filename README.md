<p align="center"><img src=".github/icon.png" width="96" height="96" alt="jsHexen2 Progs"></p>

# jsHexen2 Progs

![License: GPL v2](https://img.shields.io/badge/License-GPL_v2-blue.svg)
![Progs](https://img.shields.io/badge/progs-1.0.0--dev-orange.svg)
![Base](https://img.shields.io/badge/base-Raven_v1.12a-8B0000.svg)

HexenC source for the Hexen II: Portal of Praevus game code (`progs.dat`), based on Raven's
final released source (v1.12a) and maintained alongside the
[jsHexen2](https://github.com/KoMiKoZa) engine.

The mission-pack program runs the original campaign as well as the expansion, so this one file
is the game logic for both. It is changed one commit at a time. Most commits fix bugs in Raven's
code: crashes, blocked progression, and things that do not do what they were written to do.
Some fixes change how the game plays, such as each class's armor values. A few changes are
optional redesigns, described below.

## Redesigns and jsHexen2

The redesigns only work in jsHexen2 and do not affect other engines. Bug fixes in the same code
apply regardless of the switches.

The repository includes a few redesigns of existing mechanics. They are marked
**[JSH2 REDESIGN]** in the changelog. Each one is declared as a switch for the jsHexen2 engine:
the program reads a `jsp_*` console variable with `cvar()`, and defines an empty function of the
same name so that jsHexen2 can list the switch on its Options → jsHexen2 Progs page. The switches
are on by default.

Other engines do not register these variables, so `cvar()` returns 0 there and the mechanic
behaves as in Raven's code, the same as switching it off in jsHexen2.

## Saves

No entity fields are added or reordered, so the save layout is Raven's. Fixes are written so that
saves made before them still load. Where something already stored in a save keeps its old
behavior, the changelog row says so.

## For Devs & Modders

If you take a fix from here into another source port or a mod, check it first. This code is developed with AI assistance, alongside the jsHexen2
engine and tested on it. A row that names a bug as Raven's is our reading of the cause, and it
can be wrong: a fix may depend on jsHexen2's behavior, or correct an earlier change of ours
rather than the original code. Compare against Raven's source yourself.

The first commit, `78436a8`, is Raven's source unmodified. Its title says v1.21; that is a
mislabel, and the content is the v1.12a release. `git diff 78436a8 -- portals/<file>` shows
everything that differs from the original, and `git show <hash>` shows a single change.

## Version

Current: **jsHexen2 Progs 1.0.0** (in development).

The console prints the version on connect:

```
jsHexen2+ Progs 1.0.0 (based on Raven v1.12a)
```

Numbering is semantic: MAJOR is a generation, MINOR each released batch of fixes, PATCH a
correction to a batch. The jsHexen2 engine has its own version.

## Changelog

One row per change. `git show <hash>` shows exactly what changed.

<details open>
<summary><h3>1.0.0 (in development): 62 changes</h3></summary>

| Commit | Date | Change | What it does |
|---|---|---|---|
| `3a2360b` | 2026-11-11 | Scarab Staff charge sound stutters | The charge sound restarted four times in the first moment of a charge, because the first charge frame lasts four thinks. It now plays once per charge. |
| `abb3791` | 2026-11-11 | Barrels slide away under a player | Standing on a barrel, chair or pushable brush pushed it the way the player moved, so it slid out from under them, and landing on one shoved it aside. A player on top now stands on it. A side push that was sometimes ignored now always works. |
| `3540d74` | 2026-11-11 | Scarab Staff tap spam and fast charge | Tapping the Assassin's Scarab Staff fired a 33-damage pincer on every click, and a full charge took 0.8 s instead of 2.8 s at 72 Hz. Its fire code re-ran every server frame while fire was held. The next shot now waits for the 0.4 s settle animation, and a full charge takes 2.8 s at any frame rate. |
| `1fb7bf7` | 2026-11-11 | Thrown items stuck in the ceiling or floor | A thrown inventory item was placed at a fixed spot in front of the view after a thin line check. Under a low ceiling it started inside the ceiling and hung there; thrown down, it started in the floor or was refused. It now starts where its box fits, and players or monsters next to you no longer block it. A refused throw no longer deletes the previous item. |
| `b9c19e1` | 2026-11-11 | Monsters flick back to your corpse | Monsters copy the enemy of a nearby monster that spots one, without checking it is alive, so after you died they kept turning back to your body. With no enemy on either side, the same shortcut stopped walking monsters for up to a second. A dead or missing enemy is now ignored. |
| `27e0dda`, `9662622` | 2026-11-11 | Armor used the wrong class's values | Armor values are stored as four pieces per class but were looked up one slot per class, so every class except the Paladin got other classes' pieces. With all four worn, the Crusader got 65%, the Necromancer 60% and the Assassin 45%, instead of 55%. Each class now uses its own values, which jsHexen2's HUD (an engine fix) already showed. |
| `79aefbf` | 2026-11-11 | Patrollers walk to the player at the end of a path | A patrolling monster that reached a path corner with no next target walked to the player instead of stopping, without having seen them, and after a death paced over the body. Looking up an empty target name matched the first unnamed entity, the player. A corner with no target now ends the path. |
| `7bd2a94` | 2026-11-11 | Monsters pace over your corpse | After you died, monsters dropped you as their enemy but kept walking to your body, through it and back. A monster that loses its enemy now returns to its patrol path, or stands where it is. One whose map target is not a patrol corner also stands instead of walking back to that target. |
| `29e414e` | 2026-11-11 | Torch light switch | **[JSH2 REDESIGN]** The two-size torch light (`68cc25e`) has a switch, `jsp_torchblaze`. Off, or on another engine, the torch keeps one size for its whole burn. The pay-on-light rule (`f997888`) applies either way. |
| `cfc07ce` | 2026-11-11 | Tempest Staff charge switch | **[JSH2 REDESIGN]** The charged trigger (`03db4a6`) has a switch, `jsp_tempestcharge`. Off, or on another engine, a tap fires a full windup as in the original. The pacing, sound and light fixes of `03db4a6` apply either way. |
| `f39ee64`, `220e4b5` | 2026-11-11 | Loose monster drops | **[JSH2 REDESIGN]** A killed monster throws each dropped item out separately, the way Quake throws its backpack, instead of leaving one bag on the corpse. Containers split their contents and pop them up. Player packs stay bags, and a drop of more than 8 items stays one bag. Switch: `jsp_loosedrops`; off, or on another engine, drops are as in the original. |
| `28d692c` | 2026-11-11 | Dropped armor gave nothing | A piece of armor dropped by a monster or a coop/DM player printed its pickup message but gave nothing: the pickup reads the item's type name, which dropped pieces lacked. They are named now. A dropped piece already lying in an older save still gives nothing. |
| `6419bcb` | 2026-11-11 | Lifted objects fly off sideways | Lifting an object (impulse 13) could carry it sideways, because objects at rest keep the sideways speed they landed with. The lift now clears that speed, so the object goes straight up and lands where it stood. |
| `3582715` | 2026-10-15 | Pickup sound on every tomed hammer catch | With the Tome, every catch of the returning hammer played the weapon-pickup sound. Raven's note marks the sound as a placeholder for the select animation, which already plays. The catch is now silent apart from that animation. |
| `e2e0748` | 2026-10-15 | White light left after the torch | Charging the Tempest Staff while the torch was guttering left a steady white light on the player after the torch went out. The staff deferred to any active torch, not only one in full blaze, which is the only one that owns that light. It now defers only to a blazing torch. |
| `e507ce9`, `e38568d` | 2026-10-15 | Deathmatch on maps without DM spawns | Starting deathmatch on a map with no `info_player_deathmatch` (`thomas`, for one) looped forever looking for a spawn spot until the engine aborted the game. It now falls back to the normal player start after three passes. Maps with DM spawns are unchanged. |
| `a51d7e1` | 2026-10-15 | Explosions at the map origin | An explosion sometimes went off at the map origin (Raven's FIXME). An exploding grenade, arrow or mine stayed damageable during its own blast, so a second explosion could kill it mid-explosion and leave it reading a deleted entity's position. Explosives are now undamageable once they go off, as exploding barrels already were. |
| `922564c` | 2026-10-15 | Chained explosions crash | Explosives destroyed by another explosion blew up inside the first one's damage loop. A chain of about eight overflowed the VM's call stack ("stack overflow", Raven's "crashes in a loop" FIXME), and shorter chains skipped part of the outer blast's victims. They now explode one frame later, as exploding barrels did. Damage and radius are unchanged. |
| `6fd1e2e` | 2026-10-15 | Rats vanish when they jump | Rats from broken barrels that leapt at a drop fell through to the walk step in the same think. Walking refuses airborne entities, and the failure handler deleted the rat. The jump now ends the think. |
| `26e6543` | 2026-10-15 | Rotating doors stuck open | A rotating door blocked on the first frame of closing froze open and ignored triggers (Raven's FIXME). The angular move computed a zero travel time and a NaN spin. It now handles "already there" the way sliding doors do, so a blocked door bounces and retries. |
| `22b5c8a` | 2026-08-15 | Monster drops always lost | Every random drop a monster rolled was lost: the loot was written to the corpse after the corpse had been copied to the drop. The roll now writes to the drop. Mana rolls were also counted as artifacts, and a henchman roll with nothing in it counted as a drop; the counting is corrected and the probability table is unchanged. Also present in HoT/uHexen2. |
| `22b5c8a` | 2026-08-15 | Mana-only backpacks deleted | A bag holding only mana or instant health was built and then deleted, because the guard counted artifacts and armor only. It now uses the same test as the guard above it. Affects monster drops and player packs in coop/DM. |
| `0a3304f` | 2026-06-19 | Broken jump after level re-entry | Re-entering a level kept a corrupt negative `.scale` from the previous level, and the jump impulse uses scale, so the player jumped downward. `ClientReEnter` now resets a non-positive scale to 1, as a fresh spawn does. What writes the bad scale is still unknown. |
| `b9e5573` | 2026-06-15 | Vorpal double mana charge | An un-tomed Vorpal hit cost 2–4 blue mana instead of 2: it was billed from a stale trace and charged twice for a direct hit. It now costs 2, plus 2 only when the swing also hits other monsters, and 0 on a miss. Tome mode is unchanged. |
| `856878a` | 2026-06-13 | Demoness mana typo | Damage taken refilled the Demoness's green mana 7–10 times too fast at high levels: `level - 2/10` instead of `(level - 2)/10`. Fixed to match the blue-mana line. (Pa3PyX) |
| `856878a` | 2026-06-13 | Soul spheres grant mana | The Necromancer's soul spheres were meant to grant mana, as the manual says, but read values nothing set. Restored with the documented decay: full value if collected quickly, fading over the sphere's 15 seconds. (Pa3PyX, as in HoT/uHexen2) |
| `856878a` | 2026-06-13 | Leech removes Mystic Urn overheal | The sickle's life leech and soul-sphere health clamped health to the maximum, deleting Mystic Urn overheal. Healing now applies only below the maximum. (Pa3PyX) |
| `b40cabd` | 2026-06-12 | Deathmatch rules in single player and coop | `noexit` and the time and frag limits applied in every mode, so leftover deathmatch settings could kill a player at an exit or end a map. They now require deathmatch. (HoT/uHexen2) |
| `b40cabd` | 2026-06-12 | Impulse 11 progression cheat | `impulse 11` let any player set the cross-level progression flags. Disabled, as in HoT. |
| `a97a976` | 2026-06-12 | Flag arithmetic corruption | Five places set flags with `+=` instead of the bitwise operator, corrupting the flags when the bit was already set. Fixed. (HoT/uHexen2) |
| `a97a976` | 2026-06-12 | Summoned weretiger head gib | A summoned weretiger's head-gib model was not precached, since summons skip its spawn function. Now precached in the summon path. (HoT/uHexen2) |
| `f4f79a2` | 2026-06-12 | Skull wizard teleports to the origin | If the skull wizard's target died during his teleport, he reappeared relative to a stale reference at the map origin. He now drops the target and reappears at random. (HoT/uHexen2) |
| `f4f79a2` | 2026-06-12 | Fish swim to the origin | Fish following a dead or removed school leader swam to the map origin. They now keep their last heading. (HoT/uHexen2) |
| `f4f79a2` | 2026-06-12 | Stuck bolts warp away | Crossbow bolts and stickmines stuck to a removed entity followed its recycled slot, usually to the map origin. They now detach and fall. (Shanjaq/uhexen2-progs) |
| `1dd0d6e` | 2026-06-12 | Werepanther corpse attacks | A werepanther killed mid-charge kept its body slam active and hit players while sliding. It now checks that it is alive. (HoT/uHexen2) |
| `1dd0d6e` | 2026-06-12 | Snake boss wakes when dead | The snake boss's wake toggle had no alive check and could wake the corpse. Fixed. (HoT/uHexen2) |
| `1dd0d6e` | 2026-06-12 | Imp dies "alive" | The imp's rising death never cleared its alive flag or stopped its wing sound. Both fixed. (HoT/uHexen2) |
| `1dd0d6e` | 2026-06-12 | Medusa's noisy corpse | Looping attack sounds kept playing on Medusa's corpse. Her death now silences them. (HoT/uHexen2) |
| `ddbc82d` | 2026-06-12 | Tornado always throws | `if (x = -1)` assigned instead of compared, so the tornado always threw victims at its goal and broke its own timer. Fixed. (HoT/uHexen2) |
| `ddbc82d` | 2026-06-12 | Lavaballs barely rise | `self.speed == 1000;` compared instead of assigned, leaving lavaballs at speed 0. Fixed. (HoT/uHexen2) |
| `ddbc82d` | 2026-06-12 | Raven shots pass through everything | A second assignment set the raven missile's solid type from the wrong constant, making it non-blocking. The line is removed. (HoT/uHexen2) |
| `ddbc82d` | 2026-06-12 | Assassin fade always on | A precedence slip made the assassin's fade-back branch always true. Parenthesized. (HoT/uHexen2) |
| `24efda5` | 2026-06-12 | Eidolon ending blocked | Killing Eidolon during his intro or transformation left him dead in an invalid state, and the ending never started. He is now invulnerable until each howl completes. (HoT/uHexen2) |
| `c36b473` | 2026-06-12 | Praevus ending blocked | The expansion's ending fired only from Praevus's health stages, so killing him fast enough to skip one left it stuck. His death now fires the chain once if the stages missed it. (HoT/uHexen2) |
| `9afccb3` | 2026-06-12 | Deathmatch level change on custom maps | Deathmatch on a custom map with no exit overwrote the current map name with "demo1". It now uses the next-map variable and records where an exit leads. (HoT/uHexen2) |
| `10cdf83` | 2026-06-12 | Summoned monster in a wall | A summoned creature that spawned in a wall removed itself, then kept initializing. It now stops. (HoT/uHexen2) |
| `25962aa` | 2026-06-12 | Tibet5 prayer wheel timer | A timer used 999999999999, too large for a float, which broke the prayer wheel. Replaced with the "never think again" value. (HoT/uHexen2) |
| `25962aa` | 2026-06-12 | Temple of Mars prize trigger | Spawnflag 8 means "trigger 4" on cross-level triggers but "start inactive" elsewhere, so the prize trigger started dead. Cleared on spawn. (HoT/uHexen2) |
| `d78477a` | 2026-06-12 | Scarab Staff deletes the world | A stray semicolon made the scarab's death remove its chained model unconditionally, which removed the world entity when there was none. Fixed. (HoT/uHexen2) |
| `f49860e` | 2026-06-12 | Unkillable monsters | A player-only camera invulnerability check applied to every entity, so a monster with a stray value in that field could not be damaged. Players only now. (HoT/uHexen2) |
| `f49860e` | 2026-06-12 | Tibet1 pentacles heal from hits | A player-only damage bonus was read from monsters too, turning their damage negative, so the catapult pentacles healed. Players only now. (HoT/uHexen2) |
| `09450d3` | 2026-06-12 | Mezzoman crash | The "assignment to world entity" crash: the mezzoman's reflection trigger kept running after removing itself when its owner died. It now stops. (HoT/uHexen2) |
| `09450d3` | 2026-06-12 | Tibet7 yakman never spawns | Removing a mezzoman's shield left a stale reference, and a later removal deleted whatever entity reused the slot; on tibet7 that was the yakman's spawner. References are now cleared. (HoT/uHexen2) |
| `03db4a6` | 2026-06-12 | Tempest Staff charged trigger | **[JSH2 REDESIGN]** Normal fire is a charge weapon: hold to charge for about a second, the ball fires at full charge, and releasing early cancels it at no cost. Holding repeats at the original sustained rate. Tome mode is unchanged. Switch: `jsp_tempestcharge` (`cfc07ce`). |
| `03db4a6` | 2026-06-12 | Tempest Staff fixes | A dispatch bug re-ran the staff's fire code every rendered frame while firing, so the first windup played faster on faster machines and the hold state never worked. Fixed with a time-paced charge. Also fixed: the shot sound played twice, each ball carried two looping hums, and switching weapons mid-fire left the staff's light on. |
| `9bf5d28` | 2026-06-12 | Scorpion claw misses on slopes | The scorpion's claw traced straight from its floor-level origin, so on slopes and steps it hit terrain and never connected. A miss now retries aimed at the target's center with the same reach. Flat ground is unchanged. (Shanjaq/uhexen2-progs) |
| `68cc25e` | 2026-06-12 | Water douses the torch | Raven wrote a water-douse function and never called it (`//Never called?!`). Restored: going fully under water puts out a lit torch, and a torch can't be lit with your head under water (no torch is used). Always on. |
| `68cc25e` | 2026-06-12 | Two-size torch light | **[JSH2 REDESIGN]** The torch is a large light at full burn and drops to the original size for its last 7 seconds, when the going-out sound plays. Refreshing works only during those 7 seconds, so a burning torch can't be wasted; this applies with the switch off too. Engines without the matching render change show the original size throughout. Switch: `jsp_torchblaze` (`29e414e`). |
| `f997888` | 2026-06-12 | Infinite-torch exploit | A torch was used up only at burn-out, and refreshing it near the end postponed that forever. It is now used up when lit, like other artifacts. (Math; same fix as SoT) |
| `660f17b` | 2026-06-12 | Torch light bug | `EF_TORCHLIGHT` was 6, two other effect flags combined, so firing the Tempest Staff or catching fire could turn the torch into a wide white light or put its light out. It is now its own flag, and other code no longer strips the torch's light. Using a torch in its dim phase now relights it. |
| `e872eb7` | 2026-06-12 | Version print | The console prints `jsHexen2+ Progs 1.0.0 (based on Raven v1.12a)` on connect. |
| `78436a8` | 2026-06-12 | Vanilla import | Raven's mission-pack source v1.12a, unmodified. |

</details>

## Building

The source is in `portals/`. It builds with **NHCC** (Jacques Krige's build of Raven's HCC) or
with the **hcc** from [Hammer of Thyrion / uHexen2](https://sourceforge.net/projects/uhexen2/).
No compiler binary is included here.

```
cd portals
nhcc.exe -name Progs.src      (or: hcc -os -oi -on)
```

The output is `progs.dat`, plus `progs.lno` for debugging. In jsHexen2 it goes in `jsh2/`; in
other engines, loose in `Portals/`.

Keep the first 16 characters of the connect message in `Client.hc` (`ClientConnect`) exactly
`jsHexen2+ Progs `. jsHexen2 looks for them to tell a build of these progs from another program
in `jsh2/`; without them, every later build shows as "Unknown jsHexen2 progs".

## License

GPL v2, the license of Raven's Hexen II source release that this code is based on.
