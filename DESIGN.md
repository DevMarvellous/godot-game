# Design Document — Campus Life Sim (DRAFT, decisions pending)

This is the "think before we regret it" document. It lists what the game is, what it looks like,
every location / feature / character option planned, and the hard technical truths.
Nothing here is final. Section 10 lists the decisions that must be made first.

---

## 0. Corrections (things I said earlier that were wrong or unverified)

1. **Lagos Life is 2D isometric, not 3D.** It is a website built with Next.js (React), not a game engine.
   It is a shared online world (you see and chat with other real players), saves your progress on their
   servers, and installs as a home-screen web app. It needs iOS 16.4+ on iPhones.
2. **Lagos Life uses a map of real places** (Quilox, Eko Hotel, Shrine, CcHub Yaba, plus Abuja and Port Harcourt).
   I said it uses "room hubs". I had not checked that, and I shouldn't have said it.
3. **Our current build is a single 3D courtyard with 5 boxes**, not separate rooms yet. The "campus map" button
   currently teleports you inside that one courtyard.

---

## 1. The biggest problem: 3D + Godot 4 + phone browser

You want: (a) 3D, (b) runs in a phone browser, (c) no lag, (d) low data. **You can't fully have all four with Godot 4.**

| Fact | Effect on us |
|------|--------------|
| A default Godot 4 web export is about **40 MB** (about 8–10 MB with Brotli compression on the server). | First load costs data. Later loads can be cached (PWA), so they cost ~0 MB. |
| A **custom export template** with unused engine features stripped can get under 10 MB. Stripping out 3D gives the biggest saving. | 2D builds can be much smaller than 3D builds. |
| **Godot 4 on iPhone Safari is unreliable** (hangs while loading, crashes, reloads, audio problems). Every iPhone browser uses Safari's engine underneath. | iPhone players in the browser will have a bad time. |
| Low-end Android phones (2–3 GB RAM, common in Nigeria) struggle with 3D in a browser. | Very strict 3D budgets are required, or we accept that some phones can't run it. |
| A **native Android app** (APK / Play Store) built with Godot runs much faster than the web version, works offline, and only costs data once at install. | Native Android is the most reliable "mobile" target for 3D. |

### The three realistic paths

| Path | What it means | Good | Bad |
|------|---------------|------|-----|
| **A. 3D, Android app first** | Keep 3D. Main release = Android APK / Play Store. Web build = demo link for Android Chrome only. | Best performance. Keeps all our work. 3D looks more premium than Lagos Life. | Players have to install it. No instant link-to-play like Lagos Life. iPhone comes later as a native app. |
| **B. 2D isometric, browser first (Godot)** | Rebuild the visuals in 2D isometric (Lagos Life style). Use a custom web template without 3D. | Smallest download. Runs on cheap phones. Closest to what made Lagos Life spread (send a link, play instantly). | Redo the visuals (player, rooms, NPCs). Godot on iPhone Safari is still shaky. |
| **C. Web tech (like Lagos Life)** | Drop Godot. Use Phaser / PixiJS + TypeScript. | Best browser support (including iPhone). Smallest size. | Throw away the Godot setup. New stack. |

**What carries over no matter which path we pick:** about 70% of the logic (clock, timetable, semester, stats,
food menu data, study data, report card logic) is plain logic, not 3D. Only the player, world, and NPC scenes are 3D-specific.

**My recommendation:** test before deciding. Export the current build and open it on **your actual phone** (≈30 min of work).
- If it runs fine and loads okay → Path A (3D), with web as a bonus.
- If it lags or takes too long to load → Path B (2D isometric).

I would not pick Path C unless iPhone browser support turns out to be essential.

---

## 2. What the game looks like (target, any path)

- **Camera:** fixed angle looking down at about 45°, like The Sims / Lagos Life. The player can't rotate it (rotation is
  fiddly on touch screens and costs performance). Pinch to zoom in and out.
- **Art style:** chunky, colourful, low-detail ("low-poly" in 3D, flat isometric tiles in 2D). Flat colours from ONE small
  palette texture shared by everything = tiny download, fast rendering.
- **Lighting:** day/night by tinting the whole scene, NOT real-time shadows. Characters get a cheap dark circle under their feet instead of a real shadow.
- **UI = an in-game phone.** One button opens a phone with apps:
  WhatsApp-style chats (NPC/friends), Bank app (wallet, transfers home), Timetable, Campus Map (travel), Results portal (CGPA), Settings.
  This feels natural to Nigerian students, fits a phone screen, and keeps the main screen clean.
- **Main screen:** joystick bottom-left, action button bottom-right, small stat bar at the top, phone button top-right.

---

## 3. Locations

Each location is its **own small scene, loaded only when you enter it** (only one is in memory at a time, which keeps memory and lag low).
You move between them through doors or the Map app (map travel costs in-game minutes and sometimes keke/shuttle money).

### MVP (first 6)
| # | Location | What you do there |
|---|----------|-------------------|
| 1 | **Hostel Room** (4-person room, bunks) | Sleep, change clothes, store items, roommate interactions, save game |
| 2 | **Hostel Compound / Corridor** | Hub area outside the room: bathroom queue, water buckets, meeting hostel mates, hostel hustle (selling snacks) |
| 3 | **Faculty Lecture Theatre** | Attend lectures, tests, sit next to classmates (social), see the lecturer |
| 4 | **Cafeteria / Buka** | Buy food (menu), sit and eat, meet people |
| 5 | **Campus Fellowship / Chapel** | Fellowship services, prayer, choir/ushering roles, fellowship friends |
| 6 | **Student Union Building (SUB)** | Business centre (printing, typing = money), POS/ATM, provisions shop, barber/salon |

### Later
- Library (quiet study, bigger CGPA gains, "e-library" with power outages)
- Department lab (science/computer labs, practicals)
- Lecturer's office (beg for marks, submit assignments, resolve "missing script")
- Sports field (inter-faculty football, fitness)
- Health centre (when sick from bad food or no sleep)
- Admin block / Bursary (school fees payment queue)
- Campus gate + shuttle/keke park (travel, off-campus trips)
- Off-campus lodge (move out of hostel in 200L+)
- Auditorium (departmental week, dinner night, concerts, convocation)
- Mosque (only if we go with the general-student audience; see decision 3)

---

## 4. Feature list

### Core (MVP)
- Needs: Energy, Hunger, Hygiene (new; the bathroom queue makes it fun), Faith, Mood
- Money: allowance (weekly, from parents), spending, "Urgent 2k" requests home
- Academics: department, courses, timetable, attendance, assignments, tests, exams, grades, CGPA (see Section 5)
- Time: clock, days, weeks, semester (14 in-game days for now, editable)
- Report card at end of day; results at end of semester
- Save/load (local on the phone)

### Campus life events (random, data-driven, editable)
- "NEPA took light": no power, so you can't charge your phone or use the laptop, and the library is closed
- Water shortage: hygiene drops, bathroom queue gets longer
- Surprise test announced by the course rep
- Fellowship programme / vigil
- Departmental dues collection
- Strike rumour (ASUU) — a semester pause event (sensitive topic; keep it light)
- Roommate borrows money / eats your food

### Later systems
- Side hustles: business centre typing, selling snacks in the hostel, freelance on a laptop (dept-dependent), tutoring
- Relationships: friendship meter with NPCs (Stranger → Classmate → Friend → Close friend), study groups
- Moral choices: exam malpractice offers ("expo"), sorting lecturers, lending money; consequences later in the semester
- Character customization and a clothing shop
- Levels: 100L → 400L (or 500L/600L for Engineering/Medicine), with harder courses each year

---

## 5. Academics (realistic Nigerian system, all data-editable)

### Important change needed
Right now CGPA goes up by +0.15 when you attend a lecture. That's a placeholder and it isn't how CGPA works. The real model:
1. Each course has a **score out of 100** = Continuous Assessment (attendance + assignments + test, 30–40%) + Exam (60–70%).
2. The score becomes a grade at semester end.
3. GPA = (sum of grade points × credit units) ÷ total credit units. CGPA = the same across all semesters.

This is more authentic, easier to balance, and every number lives in data files you can edit.

### Grading (5-point scale; varies slightly by school, editable)
| Score | Grade | Points |
|-------|-------|--------|
| 70–100 | A | 5 |
| 60–69 | B | 4 |
| 50–59 | C | 3 |
| 45–49 | D | 2 |
| 40–44 | E | 1 |
| 0–39 | F | 0 (carryover) |

Class of degree: First 4.50–5.00 · 2:1 3.50–4.49 · 2:2 2.40–3.49 · Third 1.50–2.39 · Pass 1.00–1.49.

### Departments (MVP: pick 3; each changes courses, timetable, difficulty, side hustles)
| Faculty | Department | Flavour |
|---------|------------|---------|
| Science | **Computer Science** | Labs; can do freelance coding later |
| Social Sciences | **Mass Communication** | Lighter timetable; campus radio / content hustle |
| Health Sciences | **Medicine & Surgery** | Hard mode: heavy timetable, long programme, high stress |
| Later | Economics, Law, Electrical Engineering, Microbiology, Accounting, English | |

### Example 100L first-semester courses (editable)
GST 111 Communication in English (2 units) · GST 112 Nigerian Peoples & Culture (2) · MTH 101 Elementary Mathematics I (3) ·
PHY 101 General Physics I (3) · CHM 101 General Chemistry I (3) · BIO 101 General Biology I (3) · CSC 101 Introduction to Computing (3) ·
MAC 101 Introduction to Mass Communication (3) · ECO 101 Principles of Economics I (3)

---

## 6. Characters (body, clothes, how we make them)

### How the body is built (performance-friendly)
- **One shared skeleton** for every character (player + NPCs). All animations are made once and work for everyone.
- **Swappable parts:** body, head, hair, top, bottom, shoes, accessory. Customization = swapping parts.
- **Colours come from a palette texture**, so skin tone and clothing colour are just a palette swap (almost zero cost).
- **Budget:** ≤ 3,000–5,000 triangles per character, ≤ 15 characters visible at once.

### Customization options (MVP list)
- **Skin tones:** 6–8 shades, mostly across the brown range
- **Hair:** low cut, fade, afro, dreads, cornrows, box braids, ponytail, wig/straight, headwrap/gele, hijab, bald
- **Casual:** T-shirt, polo, hoodie, jeans, joggers, shorts, sneakers, slides
- **Church / formal:** shirt & tie, Sunday gown, skirt & blouse, suit jacket
- **Native:** Ankara shirt/dress (Ankara = texture patterns on one shirt mesh, cheap), agbada, senator/kaftan, buba & sokoto, iro & buba
- **Department / status:** lab coat, medical ward coat, faculty jersey, fellowship T-shirt
- **Accessories:** glasses, backpack, cap, headphones, wristwatch

### Where the 3D models come from (honest options)
I can write all the code, but **I can't produce good-looking 3D art.** Art is the real bottleneck of this project, not code.

| Option | Cost | Notes |
|--------|------|-------|
| **Free CC0 packs:** Quaternius (modular characters + a large free animation library), KayKit, Kenney | Free, no credit required | Good quality, consistent low-poly style. **Problem:** very few African hairstyles or native clothes. We'd add those ourselves. |
| **Mixamo** (Adobe) for animations | Free (needs an Adobe account) | Idle, walk, sit, sleep, eat, talk, wave, kneel/pray. Allowed in commercial games. |
| **Commission a Nigerian 3D artist** (X/Twitter, Fiverr) | Paid (price varies a lot) | Best for authentic hair, native wear, and campus props. Could be done for just the "African" pieces on top of a CC0 base. |
| **Make them yourself in Blender** | Free, costs time | Low-poly is learnable in weeks. I can guide step by step. |

**Recommendation:** pick ONE CC0 base pack now so the art style is consistent, then add African hair and clothes on top (commissioned or Blender).
If we go 2D (Path B), the same idea applies with isometric sprite packs, but animated isometric sprites with clothing layers are MORE work per outfit than 3D parts.

---

## 7. Performance and data budgets (rules we enforce)

| Item | Budget |
|------|--------|
| Frame rate | 30 FPS on phones (saves battery; plenty for a life sim), 60 on desktop. Settings toggle. |
| Triangles visible per room | ≤ 30,000 |
| Draw calls per frame | ≤ 60–80 |
| Textures | Shared atlases, ≤ 1024 px, mobile compression (ETC2/ASTC) |
| Real-time shadows | **Off.** Blob shadows under characters |
| Lights | 1 directional + tint. No dynamic point lights on mobile |
| Characters on screen | ≤ 15; far ones animate at a lower rate |
| Memory | Only the current room is loaded |
| Web first load | ≤ 15 MB compressed (needs a custom template); later loads cached = ~0 MB |
| Android install | ≤ 60 MB |
| Multiplayer traffic (later) | ≤ 2–3 MB per hour: send positions only for players in the same room, ~5 times/second, only while they move |

### Problems in the current build to fix
- The sun has **real-time shadows on** → turn off for mobile.
- **Emoji in buttons (🚌 🛏 📋) and the ₦ sign may show as empty boxes** on phones and web, because Godot's built-in font may not include them.
  Fix: bundle a font that has ₦ (e.g. Noto Sans), and use small icon images instead of emoji.
- FPS cap is 60 → change to 30 on mobile.
- Stats are changed directly by objects/menus (bed, food menu, etc.). That has to change before multiplayer (see Section 8).

---

## 8. Multiplayer — decide the shape now, build it later

### Why decide now
Some code choices made today are hard to undo later. Two in particular:

**1. The clock conflict.** Right now sleeping **skips time** (fast-forwards to 07:00). In a shared online world you can't do that,
because other players are in the same world at the same time. So we must choose:

| Model | How it works | Fits |
|-------|--------------|------|
| **Hybrid (recommended)** | Your semester (classes, CGPA, needs) runs on **your own clock** like now. Multiplayer happens in **social spaces** (Buka, SUB, fellowship hangout, events) where you see and chat with other real players. Those spaces don't depend on anyone's clock. | Keeps the deep single-player sim. Easier to build. Works offline. |
| **Shared world clock** | One clock for everyone (like an MMO). No time skipping; 1 game day = e.g. 2 real hours. Sleep = log off. | Closest to Lagos Life. Much harder. Needs servers running 24/7 from day one. |

**2. Who is allowed to change stats.** In multiplayer, the **server** must decide money and grades, or people will cheat.
So every action (buy food, attend lecture, sleep) should go through one central "actions" layer, not be applied directly by the bed or menu script.
Today that layer runs locally. Later, the same calls are sent to the server. This refactor is cheap now and painful later.

### Tech for later (no code yet)
- **Nakama** (open-source game server with an official Godot 4 client): accounts, friends, chat, groups (fellowships/departments), real-time rooms, cloud saves, leaderboards.
  Self-host on a small cloud server (roughly $10–20/month to start) or use their paid hosting.
- Alternative: Supabase (accounts + database) + a small headless Godot server for real-time rooms.
- Web builds must use WebSockets/WebRTC (ENet doesn't work in browsers). Nakama handles this for us.

### Safety (lesson from Lagos Life's ad scandal)
Chat filtering, report/block buttons, no outside links in chat or ads, moderator tools, age gate.
Multiplayer = ongoing moderation work and running costs. That's a business decision, not just a coding one.

---

## 9. Code refactors to do BEFORE adding more content

1. **PlayerData** (one saveable object holding all stats, money, courses, inventory, outfit, relationships) instead of stats scattered on the player node.
2. **GameActions** layer (Section 8.2) — the only place allowed to change PlayerData.
3. **Data files (Godot Resources)** for courses, departments, food items, clothes, events, NPCs → editable in the Godot Inspector without touching code.
4. **Room loader**: each location is its own scene; doors and the Map app call `RoomLoader.go_to("buka")`.
5. **Save system** (local now; cloud later through the same interface).
6. **Mobile settings**: 30 FPS, shadows off, bundled font, icons instead of emoji.
7. **Course-based CGPA** (Section 5).

---

## 10. Open decisions (needed before the next build step)

1. **Platform path:** A (3D, Android app first) / B (2D isometric, browser first) / test on your phone first (recommended).
2. **Multiplayer shape:** Hybrid (recommended) / Shared world clock / single-player only.
3. **Audience:** Campus Christians (fellowship-centred) / all students (faith is one part; may include a mosque/MSS).
4. **Art source:** CC0 pack + add African pieces (recommended) / commission an artist / you learn Blender.
5. **First 3 departments:** default = Computer Science, Mass Communication, Medicine & Surgery.

