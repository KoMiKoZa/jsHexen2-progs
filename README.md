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
| _(baseline)_ | Vanilla import | Raven v1.21-final mission-pack source, untouched |

_(fixes land here as they are committed — torch/lightning light bug first,
then crashes & broken levels, then visible misbehaviors, then rules & abuse)_

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
