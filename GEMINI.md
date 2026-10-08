# Project Context: Campus Life Simulator (Godot 4.7)

## 1. Collaboration & Communication Rules
- **No Ambiguity**: Plain English only. No vague jargon or buzzwords.
- **Never Be a Yes-Man**: Provide frank, realistic technical and design feedback. Flag bottlenecks immediately.
- **Bias for Action**: Build minimal playable slices first, test immediately, and iterate.
- **High Optimization**: Keep CPU/GPU footprint tiny so web/mobile builds run at 60 FPS without heating up devices.
- **High Editability**: All catalogs (food dishes, study options, NPC dialogues, timetable, semester days & grade cutoffs) are easily editable.

## 2. Technical Stack & Engine Standards
- **Engine**: Godot 4.7+ (Standard 64-bit edition).
- **FPS Capping**: `run/max_fps=60` enabled.
- **Physics**: 3D CharacterBody3D powered by Godot Jolt Physics.
- **Renderer**: GL Compatibility (`gl_compatibility`).
- **Language**: GDScript 2.0 with static typing strictly enforced.

## 3. Implemented Architecture & Current State
The game is a **3D Top-Down / Isometric Campus Life Simulator** inspired by *Lagos Life* and *The Sims*:

### Autoload Singletons:
1. **TimeSystem (`scripts/autoload/time_system.gd`)**:
   - Master in-game 24h clock: 1 real second = 2 game minutes.
   - Day counter with weekdays (Monday to Sunday).
   - Signals: `minute_passed`, `hour_changed`, `day_started`, `slept`.
2. **Schedule (`scripts/autoload/schedule.gd`)**:
   - Timetable manager for Monday-Friday (Lectures at 09:00 & 14:00, Fellowship 17:00-19:00, Curfew 22:00).
   - Signals: `lecture_started`, `lecture_attended`, `lecture_missed`.
3. **SemesterManager (`scripts/autoload/semester_manager.gd`)**:
   - Tracks 14-day university semester progression.
   - Evaluates daily class attendance/absence.
   - Calculates Nigerian grade classifications: First Class (>=4.50), 2:1 (>=3.50), 2:2 (>=2.40), 3rd Class (>=1.50), Probation (<1.50).
   - Generates daily report card data and final semester graduation outcomes.

### Interactive Menus & Modals:
1. **Buka Food Menu (`scenes/food_menu.tscn`, `scripts/food_menu.gd`)**:
   - Dishes: Jollof Rice & Chicken, Indomie & Eggs, Pounded Yam & Egusi, Meat Pie & Drink, Sapa Special.
2. **Study & Lecture Menu (`scenes/study_menu.tscn`, `scripts/study_menu.gd`)**:
   - Attending active lectures for major CGPA boosts (+0.15).
   - Self-study options: Quick Revision, Past Questions Practice, Overnight Marathon.
3. **Daily Report Card & Semester Finals (`scenes/summary_menu.tscn`, `scripts/summary_menu.gd`)**:
   - Pops up automatically when the player sleeps to end each day.
   - Displays classes attended, missed lectures, CGPA standing, faith, wallet balance, and commentary.
   - Evaluates final degree outcome on Day 14 with restart capability.

### Core Systems & Scenes:
1. **Main World (`scenes/main.tscn`, `scripts/main.gd`)**:
   - Dynamic Day/Night Cycle lighting (Sunrise, Daylight, Sunset, Night).
   - 4 Sectors: Hostel Room, Study Hall, Cafeteria (Buka), Chapel Fellowship, plus Central ATM.
   - Roaming NPCs: Emeka (Course Rep), Sister Blessing (Chapel Exec), Dr. Adebayo (Lecturer).
2. **Player Controller (`scenes/player_3d.tscn`, `scripts/player_3d.gd`)**:
   - `CharacterBody3D` with Jolt physics, smooth turning, overhead 3D camera.
3. **Stat Management (`scripts/needs_manager.gd`)**:
   - Energy, Hunger, Faith, CGPA, Wallet (₦).
   - Missed lecture penalties (-0.10 CGPA).
   - Collapse / Pass-out mechanic past 02:00 AM or 0 Energy.
4. **HUD Overlay (`scenes/hud.tscn`, `scripts/hud.gd`)**:
   - Real-time Clock, Day, Timetable banner, Wallet, and bars.

## 4. Roadmap & Milestones
- [x] **Milestone 1**: Core 3D movement, fixtures, and needs loop.
- [x] **Milestone 2**: In-game clock, daily schedule, missed lecture penalties, day/night lighting, sleep cycle.
- [x] **Milestone 3**: Nigerian Buka food menu (Jollof, Suya, Indomie) and Study choices menu.
- [x] **Milestone 4**: Animated student & lecturer NPCs walking around the courtyard.
- [x] **Milestone 5**: Semester Targets, Daily Report Card, and Win/Lose conditions.
- [ ] **Milestone 6**: Campus Interiors & Door Portals (Hostel inside, Lecture hall inside, Chapel inside).
- [ ] **Milestone 7**: Money Side Hustles (freelancing on laptop, selling snacks, calls home).
- [ ] **Milestone 8**: Exam Week Mini-Games & Moral Dilemmas.
- [ ] **Milestone 9**: Character Customizer & Low-Poly 3D Assets.
- [ ] **Milestone 10**: Web & Android Release.
