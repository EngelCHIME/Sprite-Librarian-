# Sprite-Librarian project schema v1

Sprite-Librarian treats existing raster sprites as authoritative source data. Rigging, motion,
generation metadata and validation sit above those pixels and must never silently rewrite source assets.

## Initial Handcannoneer fixture

- Logical frame size: 200 x 200 px
- Directions: 16 at 22.5-degree increments
- Existing animations: idle, move, attack, death, destroyed
- Canonical semantic rename: attack -> ranged_attack
- Existing source pixels remain unchanged by the rename
- Current known frame total: 2,880

## Direction order

E, ESE, SE, SSE, S, SSW, SW, WSW, W, WNW, NW, NNW, N, NNE, NE, ENE

## Source-lock rule

Every imported source file receives a SHA-256 entry in source_manifest. Existing source sheets are
immutable. Edits create working/approved revisions rather than overwriting source.

## Milestone 1 acceptance

1. Import the existing Handcannoneer directional sprite package.
2. Represent it as character -> animation -> direction -> frames.
3. Preserve 200 x 200 frame geometry.
4. Re-export all existing source content.
5. Compare decoded RGBA pixels for every frame.
6. Pass only at 2,880/2,880 exact matches and zero changed pixels.

Rigging and AI generation begin only after this lossless round-trip passes.
