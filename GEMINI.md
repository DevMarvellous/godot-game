# Project Context: Campus Life Simulator (Godot 4.7)

## 1. Collaboration & Communication Rules
- **No Ambiguity**: Plain English only. No vague jargon or buzzwords.
- **Never Be a Yes-Man**: Provide frank, realistic technical and design feedback. Flag bottlenecks immediately.
- **Bias for Action**: Build minimal playable slices first, test immediately, and iterate.
- **High Optimization**: Keep CPU/GPU footprint tiny so web/mobile builds run at 60 FPS without heating up devices.
- **High Editability**: All catalogs (food dishes, study options, timetable hours) must be easily editable by the user in code or Godot Inspector.

## 2. Technical Stack & Engine Standards
- **Engine**: Godot 4.7+ (Standard 64-bit edition).
- **FPS Capping**: `run/max_fps=60` enabled to prevent battery drain.
- **Physics**: 3D CharacterBody3D powered by Godot Jolt Physics.
- **Renderer**: GL Compatibility (`gl_compatibility`) for web and mobile export viability.
- **Language**: GDScript 2.0 with static typing strictly enforced (`var speed: float = 8.0`, `func update() -> void:`).
- **Input Map**:
  - `move_left`: A, Left Arrow
  - `move_right`: D, Right Arrow
  - `move_up`: W, Up Arrow
  - `move_down`: S, Down Arrow
  - `interact`: E, Spacebar
  - `ui_cancel`: Esc (closes active menus)

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

### Interactive Menus & Modals:
1. **Buka Food Menu (`scenes/food_menu.tscn`, `scripts/food_menu.gd`)**:
   - Fully editable array `menu_items` in `scripts/food_menu.gd`.
   - Dishes: Jollof Rice & Chicken, Indomie & Eggs, Pounded Yam & Egusi, Meat Pie & Drink, Sapa Special (Pure Water & Biscuit).
   - Displays player wallet, disables unaffordable items, deducts money, restores Hunger & Energy.
2. **Study & Lecture Menu (`scenes/study_menu.tscn`, `scripts/study_menu.gd`)**:
   - Fully editable array `study_options` in `scripts/study_menu.gd`.
   - Scheduled lecture banner: prompts player to attend in-session classes for major CGPA boosts (+0.15).
   - Self-study options: Quick Revision, Past Questions Practice, Overnight Marathon.

### Core Systems & Scenes:
1. **Main World (`scenes/main.tscn`, `scripts/main.gd`)**:
   - 3D courtyard level with dynamic **Day/Night Cycle lighting**:
     - 06:00 - 08:00: Sunrise.
     - 08:00 - 17:00: Daylight with soft shadows.
     - 17:00 - 19:30: Sunset.
     - 19:30 - 06:00: Nighttime moonlight.
   - 4 Sectors: Hostel Room, Study Hall, Cafeteria (Buka), Chapel Fellowship, plus Central ATM.
   - Pauses player physics while modal menus are active for smooth controls.
2. **Player Controller (`scenes/player_3d.tscn`, `scripts/player_3d.gd`)**:
   - `CharacterBody3D` with Jolt physics collision, smooth 3D rotation toward movement direction.
   - Overhead angled 3D camera (`Camera3D`) following the player.
   - 3D Billboard labels above the player's head for interaction prompts and popups.
3. **Stat Management (`scripts/needs_manager.gd`)**:
   - Stats decay per in-game minute: Energy, Hunger, Faith, CGPA, Wallet (₦).
   - Lecture attendance & missed lecture penalties (-0.10 CGPA).
   - Pass-Out Mechanic: Collapsing from exhaustion if Energy <= 0 or awake past 02:00 AM.
4. **HUD Overlay (`scenes/hud.tscn`, `scripts/hud.gd`)**:
   - Real-time Clock & Day (`07:00 • Day 1 (Mon)`).
   - Live Timetable Banner (`Next: GST 101 Lecture at 09:00` / `NOW: GST 101 Lecture`).
   - Wallet (₦), CGPA, Energy, Hunger, Faith bars.

## 4. Roadmap & Milestones
- [x] **Milestone 1**: Core 3D movement, fixtures, and needs loop.
- [x] **Milestone 2**: In-game clock, daily schedule, missed lecture penalties, day/night lighting, sleep cycle.
- [x] **Milestone 3**: Nigerian Buka food menu (Jollof, Suya, Indomie) and Study choices menu.
- [ ] **Milestone 4**: Animated student & lecturer NPCs walking around the courtyard.
- [ ] **Milestone 5**: Semester targets (win/lose conditions).
- [ ] **Milestone 6**: Low-poly art models and Nigerian campus audio.
- [ ] **Milestone 7**: Web release on itch.io.
