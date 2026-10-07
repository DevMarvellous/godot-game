# Game Plan (living document — expected to change)

## What the game is (one sentence)
A 3D top-down life simulator where you play a Nigerian university student who has to balance
sleep, food, money, grades, and faith across a semester.

## Who it's for (still open)
- Option A: Campus Christians specifically (fellowship, devotion, moral choices are central).
- Option B: Students in general (faith is one stat among many, not the focus).
- Decision deadline: after Milestone 2 is playable. Do not block building on this.

## Platform order
1. Web browser (HTML5 export) — first.
2. Android (Play Store) — after the web version is fun.
3. iOS — last.

Because web is first: keep 3D simple (low-poly shapes, few lights, Compatibility renderer).

## Milestones
Each milestone ends with something you can play, then a git push.

| # | Milestone | What you can do when it's done | Status |
|---|-----------|-------------------------------|--------|
| 1 | Core loop | Walk around, use bed/desk/food/chapel/ATM, see stats change | DONE |
| 2 | Time & days | Clock runs, day/night lighting, lectures on schedule, missed lecture penalty, sleep/passout | DONE |
| 3 | Choices & menus | Food menu with Nigerian dishes and prices, choices with consequences | NEXT |
| 4 | People | NPC students walking around, simple talk interactions | TODO |
| 5 | Semester goal | Win/lose condition: finish semester with CGPA + money + faith targets | TODO |
| 6 | Look & sound | Replace boxes with low-poly models, add sounds and music | TODO |
| 7 | Web release | Export to HTML5, host on itch.io, get friends to test | TODO |

## Rules for scope
- No multiplayer until Milestone 7 is shipped and people actually play it.
- No custom 3D modeling until Milestone 6. Boxes are fine.
- If a feature takes more than 2 sessions, cut it down.

