<p align="center"><img src=".github/icon.png" width="96" height="96" alt="jsHexen2 Progs"></p>

# jsHexen2 Progs

![License: GPL v2](https://img.shields.io/badge/License-GPL_v2-blue.svg)
![Progs](https://img.shields.io/badge/progs-1.0.0--dev-orange.svg)
![Base](https://img.shields.io/badge/base-Raven_v1.12a-8B0000.svg)

The game code (`progs.dat`) of jsHexen2, a Hexen II source port: HexenC source based on Raven's
final released source for Portal of Praevus (v1.12a). The fixes work in any Hexen II engine; the
optional redesigns need jsHexen2.

This program runs the original Hexen II campaign as well as the Portal of Praevus expansion, so
this one file is the game logic for both. It is changed one commit at a time. Most commits fix
bugs in Raven's code: crashes, blocked progression, and things that do not do what they were
written to do. Some fixes change how the game plays, such as each class's armor values. A few
changes are optional redesigns, described below.

## Redesigns and jsHexen2

In jsHexen2, a few mechanics have optional redesigns, marked **[JSH2 REDESIGN]** in the
changelog. Each one is a switch, on by default. With a switch off, or on any other engine, that
mechanic plays as in Raven's game apart from the bug fixes in the same code, which stay on either
way. Where a fix makes a redesign's off state differ from Raven's, its changelog row says so.

| Switch | What it covers |
|---|---|
| `jsp_baglist` | Aiming at a backpack within reach lists what's inside. |
| `jsp_golembox` | Iron golems move in the player's box, so they follow you wherever their body fits. |
| `jsp_hammerreturn` | The Crusader's tomed hammer strikes what it passes through on the way back. |
| `jsp_loosedrops` | A killed monster throws each dropped item out separately instead of leaving one bag. |
| `jsp_swimstrokes` | Swimming plays stroke sounds as you move, not only when you press jump, and one stroke never cuts off another. |
| `jsp_tempestcharge` | The Tempest Staff's normal fire is a charge: letting go before full charge cancels the ball, held fire holds the charged pose between balls, letting go at full charge closes the staff, and the hum plays while charging instead of on the ball. |
| `jsp_torchblaze` | The torch is a large light at full burn and drops to the original size for its last 7 seconds, and it can be refreshed only in the last 5 of those seconds. |

Each switch is a `jsp_*` console variable that the program reads with `cvar()`. It also defines a
marker function of the same name so that jsHexen2 lists the switch in the jsHexen2 Progs category
of its Options menu. The markers for `jsp_loosedrops`, `jsp_tempestcharge` and `jsp_torchblaze`
are empty, and the engine supplies their label and tooltip; `jsp_baglist`, `jsp_golembox`,
`jsp_hammerreturn` and `jsp_swimstrokes` return their own.

Other engines do not register these variables, so `cvar()` returns 0 there and the mechanic
behaves as in Raven's code, the same as switching it off in jsHexen2.

### Adding a switch to your own mod

Any progs can add switches to that category. Declare one with a function with no parameters
whose name starts with `jsp_` and that returns the label, an optional tooltip and an optional
`off` for a switch that starts off:

```c
string jsp_mymod_bigjump (void)
{
	return "Big Jump|Jumps go twice as high. Off: the normal jump.";
}
```

Then read it where the behavior happens:

```c
if (cvar("jsp_mymod_bigjump"))
	self.velocity_z = self.velocity_z * 2;
```

Nothing calls the function; jsHexen2 reads the text from the compiled progs. Keep these rules:

- The `return` with a string constant must be the function's first statement. If anything comes
  before it, or the function returns a variable or a computed string, the switch has no text.
  An empty `void jsp_mymod_bigjump (void) {}` also works and shows a readable form of the name
  as the label.
- A name is `jsp_` followed by up to 27 letters, digits and underscores, 31 characters in all.
- Labels are cut at 24 characters and tooltips at 256. `"Label||off"` starts off without a tooltip.
- A switch belongs to its name, not to your mod, so put your mod's name in it. Two mods that
  declare `jsp_bigjump` share one setting.
- `jsp_loosedrops`, `jsp_tempestcharge` and `jsp_torchblaze` belong to the engine: jsHexen2
  always has them, on by default. Don't use them for your own switches.
- Every other engine reads 0, so write the code so that 0 is the original behavior.
- `cvar()` runs on the server: in multiplayer the host's settings apply to everyone. Read the
  value each time you need it if a change should apply right away.
- Up to 32 switches per progs. The player's choices are saved in `config.cfg`.

## Saves

No entity fields are added or reordered, so the save layout is Raven's. Fixes are written so that
saves made before them still load. Where something already stored in a save keeps its old
behavior, the changelog row says so.

## For Devs & Modders

If you take a fix from here into another source port or a mod, check it first. This code is
developed with AI assistance, alongside the jsHexen2 engine and tested on it. A row that names a
bug as Raven's is our reading of the cause, and it can be wrong: a fix may depend on jsHexen2's
behavior, or correct an earlier change of ours rather than the original code. Compare against
Raven's source yourself.

The first commit, `78436a8`, is Raven's source unmodified. Its title says v1.21; that is a
mislabel, and the content is the v1.12a release. `git diff 78436a8 -- portals/<file>` shows
everything that differs from the original, and `git show <hash>` shows a single change.

## Version

Current: **jsHexen2 Progs 1.0.0** (in development).

The console prints the version on connect, in any engine:

```
jsHexen2+ Progs 1.0.0 (based on Raven v1.12a)
```

Numbering is semantic: MAJOR is a generation, MINOR each released batch of fixes, PATCH a
correction to a batch. The jsHexen2 engine has its own version.

## Bugs caused by Raven's compiler

Raven built Hexen II's game code with their own compiler, HCC. In three cases the code reads
correctly, but HCC builds something else:

- **Two calls in one line.** HCC can let the second call's result overwrite the first's:
  `visible() && infront()` ran as `infront() && infront()`, so golems fired through walls. Ten
  places in the shipped game.
- **`if (vector)`.** HCC tests only the vector's first part, x, so `if (self.velocity)` was false
  for anything not moving along x, such as something falling straight down. 34 places in the
  shipped game, all meant "the vector isn't zero".
- **A local named like a global.** A local with the same name and type as a global isn't a new
  variable in HCC: it is the global, so the function overwrites the global. 13 places in the
  shipped game.

The places where this changes the game are marked **[RAVEN HCC BUG]** below. The first two are
fixed twice, on purpose:

- **Here, in the source.** Each of these lines is rewritten so that every compiler reads it the
  same way. Taken into another mod, it keeps the fix whichever compiler builds that mod: Raven's
  HCC, NHCC, uHexen2's hcc, FTEQCC, or jsHexen2-hcc with `-noretfix` or `-noifvecfix`. This source
  as a whole needs jsHexen2-hcc; see Building.
- **In the compiler.** [jsHexen2-hcc](https://github.com/KoMiKoZa/jsHexen2-hcc) builds such lines
  correctly and warns where it finds one, so the same mistake can't creep into new code here or
  into other mods. On this source it finds none left.

The third is fixed here, in the source, so every compiler builds the same game. FTEQCC lists any
such local with its warning F306; on this source it lists none.

## Changelog

One row per change. `git show <hash>` shows exactly what changed.

<details open>
<summary><h3>1.0.0 (in development): 70 game fixes, 9 Raven HCC fixes, 7 optional redesigns</h3></summary>

| Commit | Date | Change | What it does |
|---|---|---|---|
| `ad82a1b` | 2026-11-17 | Previous weapon during an attack | The previous-weapon command (`impulse 12`) skipped the wait that the number keys and next weapon (`impulse 10`) keep while you attack or change weapons. Pressed during an attack, it changed your weapon but left the old one in your hand until your next switch: the Crusader's hammer then stopped attacking, or fired Sunstaff beams. Pressed while a weapon was being drawn, it gave the drawn weapon the new one's attacks: the Crusader swung the Ice Mace like a hammer until the hammer came back into view. Pressed while a weapon was being put away, when it picked that same weapon again, the put-away animation kept repeating, and fire, the number keys and next weapon did nothing until you pressed previous weapon again. It now waits like the others: a press during an attack or a weapon change is ignored. |
| `6ac6c8c`, `a124426` | 2026-11-15 | Iron golem size | **[JSH2 REDESIGN]** An iron golem moves in the player's box, as stone golems and yakmen do, so it follows you wherever its body fits. In Raven's game it moves as a box 96 units wide and 100 tall around a body 64 wide and 80 tall, so it can't follow you through some places its body fits, and you can fight it from where it can't reach you. On egypt1, one chasing you stops partway down a ramp, where the corridor's ceiling is too low for its box; on egypt4, one on hard skill is placed where it can't move at all. With the switch on, the egypt1 golem comes down the ramp and fights, and the egypt4 golem leaves its spot. Its body can sink into walls and low ceilings, further than a stone golem's does. Switch: `jsp_golembox`; off, or on another engine, iron golems move in Raven's box. A golem from an older save, or one in play when you flip the switch, changes box the next time it walks or runs; going back to Raven's box waits until it stands where that box fits. Hexen II's maps place 20 iron golems, all on the Egypt maps; Portal of Praevus places none. |
| `8d014e1` | 2026-11-15 | Silent barrels | Pushing a barrel made no sound, while a pushed chair scrapes along the floor. Barrels now make the same wooden scrape, as they do in Raven's HexenWorld. |
| `03db4a6`, `cfc07ce`, `2081855`, `3802965` | 2026-11-15 | Tempest Staff charge | **[JSH2 REDESIGN]** Normal fire is a charge: hold fire and the ball leaves at full charge, about half a second after the press; let go earlier and the charge cancels at no cost. Held fire repeats at Raven's sustained rate, holding the charged pose between balls, and letting go at full charge closes the staff back to rest. The hum plays while the staff charges, and the ball flies silent. Tome mode is unchanged. Switch: `jsp_tempestcharge`; off, or on another engine, the staff plays as in Raven's game: every press fires after a full windup, held fire waits out the refire in Raven's hold animation, and the ball carries Raven's flight hum. One difference stays either way: the windup always plays at the game's animation pace, where Raven's could run once per server frame (see Tempest Staff fixes). The first ball comes about half a second after the press, not 69 ms as in Raven's at 72 frames a second. Held fire spaces balls about 1 s apart, not up to 1.1 s. Quick presses fire fewer balls than in Raven's game. |
| `68cc25e`, `29e414e`, `e2e0748`, `943d0a0` | 2026-11-15 | Two-size torch light | **[JSH2 REDESIGN]** The torch is a large light at full burn and drops to the original size for its last 7 seconds, when the going-out sound plays. It can be refreshed only in the last 5 of those 7 seconds, so a burning torch can't be wasted. Engines without the matching render change show the original size throughout. Switch: `jsp_torchblaze`; off, or on another engine, the torch keeps one size for its whole burn and can be refreshed as in Raven's game, only in the last 5 seconds of its full burn. Two of Raven's faults stay fixed either way: each use after a refresh restarted the torch, so one torch burned forever for free (a refreshed torch now waits for its next full burn, and is paid for when lit, `f997888`), and another active effect, such as invisibility, let a player refresh at any point of the burn. |
| `ddac294` | 2026-11-15 | Punch dagger stuck on one swing | **[RAVEN HCC BUG]** The Assassin's punch dagger is meant to take turns between its four swings. While a stone imp set to come to life when it sees you was watching you, the dagger used only its fourth swing. It now always takes turns. Raven's maps don't show this: Hexen II's 12 stone imps are all woken by a trigger or never wake, and Portal of Praevus has none. It happens with a stone imp (gargoyle flag set) that has no `targetname` and no `wait -1`. We reproduced it on egypt1 with an `.ent` file that removed its stone imps' `targetname`s. |
| `b6281c9` | 2026-11-14 | Tomed Meteor Staff fired too fast | With the Tome of Power, the Meteor Staff's tornado had no cooldown and its fire animation ran once per server frame, so on a fast machine it fired 7 tornadoes a second, 20 green mana each. It now fires one per fire animation, about two a second on any machine, and the tornado leaves as you press fire, like the normal shot. |
| `163ec37` | 2026-11-14 | Ice Mace skipped shots | The Ice Mace plays one of five short firing animations at random and fires an ice shard as each one starts. When it picked the animation it had just played, it began that one partway through and fired nothing. Every animation fires now, so held fire shoots at an even pace. |
| `c533f4a` | 2026-11-14 | Flame Orb cast | The Flame Orb's fire code ran every server frame on top of the weapon's own timing, so the hand cast played two frames at a time and was over in a tenth of a second, and a faster machine fired faster. The cast now plays out in full, and the Flame Orb fires once per cast: about one stream a second, or one swarm every 1.7 s with the Tome of Power. |
| `e8f8d81` | 2026-11-14 | Meteor tornado fell behind falling targets | **[RAVEN HCC BUG]** The tomed Meteor Staff's tornado speeds up by its target's speed to keep up with it, but a target falling or jumping straight up or down counted as standing still, so the tornado fell behind. It now keeps up with those too. |
| `d744e84`, `884e2aa` | 2026-11-13 | Swim strokes | **[JSH2 REDESIGN]** The swim stroke sound played only when you pressed jump to swim up, so plain swimming was silent. Swimming through deep water or slime now plays a stroke each time the last one has finished, and the jump stroke waits for its sound to finish too, so strokes never cut off or overlap each other. Floating still, sinking and wading waist-deep stay silent. Switch: `jsp_swimstrokes`; off, or on another engine, a stroke plays only on jump, with Raven's timing. |
| `2a97ca9` | 2026-11-13 | Gauntlet second punch | The second punch of the Paladin's gauntlet combo was meant to skip two frames of its wind-up but never did. It now lands its hit a little sooner. |
| `2a97ca9` | 2026-11-13 | Monster jump spots worked once | The spots in maps where monsters jump across a gap stopped working after the first monster used them. They now work for every monster, unless the map sets them to work once. In Portal of Praevus this changes tibet2 and tibet9: monsters jump each time they cross one. |
| `2a97ca9` | 2026-11-13 | Bubble emitters | A map's bubble emitter set to repeat puffed once and stopped, and one triggered a second time streamed bubbles without end. They now puff every time the map says, and each trigger gives one puff. The maps that ship with the game don't use them this way. |
| `607a622`, `286a21c` | 2026-11-13 | Medusas never stepped aside | A medusa without a clear shot at you was meant to step to the side to get one, but she kept coming straight at you. She now sidesteps. |
| `607a622` | 2026-11-13 | Imps died in mid-air | An imp killed in flight played out its whole death while still falling. It now falls in its falling pose, lands with a thud and then finishes dying. |
| `607a622` | 2026-11-13 | Doors that froze while closing | In rare cases a closing door froze at the end of its travel, without its closing sound, and the game still treated it as closing. It now stops as closed, with the sound. |
| `607a622` | 2026-11-13 | Silent crown capture | Taking the Sword and Crown in a team game was meant to play a thunderclap, but the sound was misnamed and nothing played. It plays now. |
| `dd3347c` | 2026-11-12 | Hurt imps and sheep staggered the wrong way | **[RAVEN HCC BUG]** A hurt imp or sheep is meant to stagger away from whoever hit it. It always staggered toward the same compass direction instead, wherever you stood. It now backs away from you. |
| `dd3347c` | 2026-11-12 | Mezzomen blocked shots from behind | **[RAVEN HCC BUG]** A mezzoman is meant to block or charge only at a shot coming at his front. He also reacted to shots from the side or behind, which he couldn't see. Now only shots in front of him count. |
| `dd3347c` | 2026-11-12 | Pentacles climbing down | **[RAVEN HCC BUG]** The wall-crawling Pentacles started climbing down at random even when the step down was blocked. It now does so only when the step down works. |
| `dd3347c` | 2026-11-12 | Narrow particle sprays | **[RAVEN HCC BUG]** The meteor tornado's spray in water or lava, and the burst where Death's bones land, came out in a tighter spot than meant. They now spread as wide as written. |
| `9fbe0c6` | 2026-11-12 | Players pushed each other from any side | **[RAVEN HCC BUG]** In coop and deathmatch, running into another player is meant to push them only when you're moving toward them. The check never worked, so a player beside or behind you was pushed too. It now pushes only a player you're moving toward. |
| `9fbe0c6` | 2026-11-12 | Golems fired their eye beam without seeing you | **[RAVEN HCC BUG]** A golem charging its eye beam was meant to fire only if it could see you, but it fired whenever it faced you, behind a wall too. Without a line of sight it now goes back to chasing you. |
| `9fbe0c6` | 2026-11-12 | Victory roar through walls | **[RAVEN HCC BUG]** When a mezzoman or yakman killed its target, it roared or howled whenever it faced the body, even out of sight behind a wall. It now does so only when it can see the body. |
| `e95be96` | 2026-11-12 | Bag contents | **[JSH2 REDESIGN]** Aiming at a backpack within reach shows what's inside as a centered message to you alone: one line per item with its count, and items you can't take marked "(full)" in the console's lettering. In coop a player's pack is titled with their number ("Player 2's Backpack"). A game message stays up for 3 seconds before the list comes back. Switch: `jsp_baglist`; off, or on another engine, there's no list. |
| `0778bc4`, `dcedcb5` | 2026-11-12 | Bag pickup threw away what didn't fit | Touching a bag gave you what you could carry and lost the rest: with 23 Discs of Repulsion, a bag of 5 gave you 2 and the other 3 were gone. You now take what fits and the rest stays in the bag for you or a teammate. A bag you've partly emptied waits a second before it gives you more, so standing on it doesn't top you up after every shot. The bag goes once it's empty, or after its usual two minutes. The pickup message lists only what you took, without the stray number that came before armor pieces. |
| `8d98ee4` | 2026-11-12 | Full mana used up a dropped bag | Touching a bag with nothing in it you could carry (full mana, for example) took the bag anyway and printed "You get ...Nothing!", so in coop it used up a teammate's dropped pack. Such a bag now stays on the ground, as single mana pickups do, for someone who has room. |
| `a099c06` | 2026-11-12 | Returning tomed hammer shoves you | With the Tome, the Crusader's hammer flies back to you after each throw. On the way back it was solid to you, so when it reached you, you stopped dead for a moment, stepped up, or were pulled back. It now passes through you and is caught the moment it reaches you. |
| `a099c06` | 2026-11-12 | Returning hammer hits | **[JSH2 REDESIGN]** On its way back, the tomed hammer strikes enemies in its path with the same hit as on the way out. It doesn't strike the same enemy twice in a row, so the one it bounced off isn't hit again. Switch: `jsp_hammerreturn`; off, or on another engine, it hurts nothing on the way back. |
| `de01716` | 2026-11-12 | Imp swoop attack does nothing | An imp's swoop has one hit, and anything that touched the imp first used it up: your own shot during its wind-up, a wall it brushed, another imp's ice shot. The charge then flew into you and did no damage. Now only contact during the attack itself counts, and shots are ignored. A shot hitting the imp mid-charge no longer stuns it or flings it along the shot's path. |
| `3a2360b` | 2026-11-11 | Scarab Staff charge sound stutters | The charge sound restarted four times at the start of each charge, because each charge frame lasts four game ticks. It now plays once per charge. |
| `abb3791` | 2026-11-11 | Barrels slide away under a player | Standing on a barrel, chair or pushable brush pushed it the way the player moved, so it slid out from under them, and landing on one shoved it aside. A player on top now stands on it. A side push that was sometimes ignored now always works. |
| `3540d74` | 2026-11-11 | Scarab Staff tap spam and fast charge | Tapping the Assassin's Scarab Staff fired a 33-damage pincer on every click, and a full charge took 0.8 s instead of 2.8 s at 72 Hz. Its fire code re-ran every server frame while fire was held. The next shot now waits for the 0.4 s settle animation, and a full charge takes 2.8 s at any frame rate. |
| `1fb7bf7` | 2026-11-11 | Thrown items stuck in the ceiling or floor | A thrown inventory item was placed at a fixed spot in front of the view after a thin line check. Under a low ceiling it started inside the ceiling and hung there; thrown down, it started in the floor or was refused. It now starts where its box fits, and players or monsters next to you no longer block it. A refused throw no longer deletes the previous item. |
| `b9c19e1` | 2026-11-11 | Monsters flick back to your corpse | Monsters copy the enemy of a nearby monster that spots one, without checking it is alive, so after you died they kept turning back to your body. With no enemy on either side, the same shortcut stopped walking monsters for up to a second. A dead or missing enemy is now ignored. |
| `27e0dda`, `9662622` | 2026-11-11 | Armor used the wrong class's values | Armor values are stored as four pieces per class but were looked up one slot per class, so every class except the Paladin got other classes' pieces. With all four worn, the Crusader got 65%, the Necromancer 60% and the Assassin 45%, instead of 55%. Each class now uses its own values, which jsHexen2's HUD (an engine fix) already showed. |
| `79aefbf` | 2026-11-11 | Patrollers walk to the player at the end of a path | A patrolling monster that reached a path corner with no next target walked to the player instead of stopping, without having seen them, and after a death paced over the body. Looking up an empty target name matched the first unnamed entity, the player. A corner with no target now ends the path. |
| `7bd2a94` | 2026-11-11 | Monsters pace over your corpse | After you died, monsters dropped you as their enemy but kept walking to your body, through it and back. A monster that loses its enemy now returns to its patrol path, or stands where it is. One whose map target is not a patrol corner also stands instead of walking back to that target. |
| `f39ee64`, `220e4b5` | 2026-11-11 | Loose monster drops | **[JSH2 REDESIGN]** A killed monster throws each dropped item out separately, the way Quake throws its backpack, instead of leaving one bag on the corpse. Containers split their contents and pop them up. Player packs stay bags, and a drop of more than 8 items stays one bag. Switch: `jsp_loosedrops`; off, or on another engine, drops are as in the original. |
| `28d692c` | 2026-11-11 | Dropped armor gave nothing | A piece of armor dropped by a monster or a coop/DM player printed its pickup message but gave nothing: the pickup reads the item's type name, which dropped pieces lacked. They are named now. A dropped piece already lying in an older save still gives nothing. |
| `6419bcb` | 2026-11-11 | Lifted objects fly off sideways | Lifting an object (impulse 13) could carry it sideways, because objects at rest keep the sideways speed they landed with. The lift now clears that speed, so the object goes straight up and lands where it stood. |
| `3582715` | 2026-10-15 | Pickup sound on every tomed hammer catch | With the Tome, every catch of the returning hammer played the weapon-pickup sound. Raven's note marks the sound as a placeholder for the select animation, which already plays. The catch is now silent apart from that animation. |
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
| `03db4a6`, `2081855` | 2026-06-12 | Tempest Staff fixes | A dispatch bug re-ran the staff's fire code every server frame while firing, so the first windup played faster on faster machines. Only the weapon's own animation steps the charge now, at the game's animation pace, so the windup takes the same time on any machine, and the spin after drawing the staff takes about 0.8 s, as in Raven's code. Also fixed: the shot sound played twice, each ball carried two looping hums, and switching weapons mid-fire left the staff's light on. The charge light is now white instead of the torch's dim light, so the staff and the torch no longer share, or put out, each other's light. |
| `9bf5d28` | 2026-06-12 | Scorpion claw misses on slopes | The scorpion's claw traced straight from its floor-level origin, so on slopes and steps it hit terrain and never connected. A miss now retries aimed at the target's center with the same reach. Flat ground is unchanged. (Shanjaq/uhexen2-progs) |
| `68cc25e` | 2026-06-12 | Water douses the torch | Raven wrote a water-douse function and never called it (`//Never called?!`). Restored: going fully under water puts out a lit torch, and a torch can't be lit with your head under water (no torch is used). Always on. |
| `f997888` | 2026-06-12 | Infinite-torch exploit | A torch was used up only at burn-out, and refreshing it near the end postponed that forever. It is now used up when lit, like other artifacts. (Math; same fix as SoT) |
| `660f17b` | 2026-06-12 | Torch light bug | `EF_TORCHLIGHT` was 6, two other effect flags combined, so firing the Tempest Staff or catching fire could turn the torch into a wide white light or put its light out. It is now its own flag, and other code no longer strips the torch's light. |
| `e872eb7` | 2026-06-12 | Version print | The console prints `jsHexen2+ Progs 1.0.0 (based on Raven v1.12a)` on connect. |
| `78436a8` | 2026-06-12 | Vanilla import | Raven's mission-pack source v1.12a, unmodified. |

</details>

## Building

The source is in `portals/`. Build it with [jsHexen2-hcc](https://github.com/KoMiKoZa/jsHexen2-hcc)
1.0.2 or later; a ready-built `hcc.exe` for Windows is on its
[Releases](https://github.com/KoMiKoZa/jsHexen2-hcc/releases) page:

```
cd portals
hcc
```

The program is written to `portals/progs.dat`, and the compiler writes `files.dat` in the same
folder. jsHexen2-hcc 1.0.1 builds it too, with `hcc -ot -name Progs.src`.

Older compilers can't build this source. Raven's HCC, NHCC and jsHexen2-hcc 1.0.0 don't accept
`\\` (a backslash) in a string, which the bag list uses for the `\1` lettering escape. Without
shared globals for intermediate results (`-noot` in 1.0.2, or 1.0.1 without `-ot`), this source
also uses 65,518 of the 65,536 globals a `progs.dat` can address.

Keep the first 16 characters of the connect message in `Client.hc` (`ClientConnect`) exactly
`jsHexen2+ Progs `. jsHexen2 looks for them to recognize a build of these progs; without them it
treats your build as someone else's program.

## License

GPL v2, the license of Raven's Hexen II source release that this code is based on.
