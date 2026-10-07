# Project Context: Campus Life Simulator (Godot 4.7)

## 1. Collaboration & Communication Rules
- **No Ambiguity**: Plain English only. No vague jargon or buzzwords.
- **Never Be a Yes-Man**: Provide frank, realistic technical and design feedback. Flag bottlenecks immediately.
- **Bias for Action**: Build minimal playable slices first, test immediately, and iterate.

## 2. Technical Stack & Engine Standards
- **Engine**: Godot 4.7+ (Standard 64-bit edition).
- **Physics**: 3D CharacterBody3D powered by Godot Jolt Physics.
- **Renderer**: GL Compatibility (`gl_compatibility`) for web and mobile export viability.
- **Language**: GDScript 2.0 with static typing strictly enforced (`var speed: float = 8.0`, `func update() -> void:`).
- **Input Map**:
  - `move_left`: A, Left Arrow
  - `move_right`: D, Right Arrow
  - `move_up`: W, Up Arrow
  - `move_down`: S, Down Arrow
  - `interact`: E, Spacebar

## 3. Implemented Architecture & Current State
The game is a **3D Top-Down / Isometric Campus Life Simulator** inspired by *Lagos Life* and *The Sims*:

### Autoload Singletons:
1. **TimeSystem (`scripts/autoload/time_system.gd`)**:
   - Master in-game 24h clock: 1 real second = 2 game minutes.
   - Day counter with weekdays (Monday to Sunday).
   - Signals: `minute_passed`, `hour_changed`, `day_started`, `slept`.
   - Supports minute-by-minute fast-forward so sleeping processes hunger and missed classes realistically.
2. **Schedule (`scripts/autoload/schedule.gd`)**:
   - Timetable manager for Monday-Friday:
     - 09:00 - 11:00: GST 101 Lecture
     - 14:00 - 16:00: Lab Practical
     - 17:00 - 19:00: Chapel Fellowship (daily)
     - 22:00: Hostel Curfew
   - Signals: `lecture_started`, `lecture_attended`, `lecture_missed`.

### Core Systems & Scenes:
1. **Main World (`scenes/main.tscn`, `scripts/main.gd`)**:
   - 3D courtyard level with dynamic **Day/Night Cycle lighting**:
     - 06:00 - 08:00: Golden Sunrise.
     - 08:00 - 17:00: Bright Daylight with soft shadows.
     - 17:00 - 19:30: Amber Sunset.
     - 19:30 - 06:00: Deep Blue Moonlight.
   - 4 Sectors: Hostel Room, Study Hall, Cafeteria (Buka), Chapel Fellowship, plus Central ATM.
2. **Player Controller (`scenes/player_3d.tscn`, `scripts/player_3d.gd`)**:
   - `CharacterBody3D` with Jolt physics collision, smooth 3D rotation toward movement direction.
   - Overhead angled 3D camera (`Camera3D`) following the player.
   - 3D Billboard labels above the player's head for interaction prompts and popups.
3. **Stat Management (`scripts/needs_manager.gd`)**:
   - Stats decay per in-game minute:
     - **Energy**: Restored by sleeping in Hostel Bed (sleeps until 07:00).
     - **Hunger**: Restored by eating at Buka.
     - **Faith**: Restored by prayer & chapel fellowship (bonus during 17:00-19:00 fellowship).
     - **CGPA**: Boosted by attending scheduled lectures (+0.15) or revision (+0.05). Penalized (-0.10) if lecture missed!
     - **Wallet**: Replenished via ATM (+₦2,000).
   - **Pass-Out Mechanic**: Collapsing from exhaustion if Energy <= 0 or awake past 02:00 AM. Wakes up at 08:00 AM in Hostel Bed with penalties.
4. **HUD Overlay (`scenes/hud.tscn`, `scripts/hud.gd`)**:
   - Real-time Clock & Day (`07:00 • Day 1 (Mon)`).
   - Live Timetable Banner (`Next: GST 101 Lecture at 09:00` / `NOW: GST 101 Lecture`).
   - Wallet (₦), CGPA, Energy, Hunger, Faith bars.

## 4. Roadmap & Milestones
- [x] **Milestone 1**: Core 3D movement, fixtures, and needs loop.
- [x] **Milestone 2**: In-game clock, daily schedule, missed lecture penalties, day/night lighting, sleep cycle.
- [ ] **Milestone 3**: Nigerian Buka food menu (Jollof, Suya, Indomie) and interactive choice dialogs.
- [ ] **Milestone 4**: Animated student & lecturer NPCs walking around the courtyard.
- [ ] **Milestone 5**: Semester targets (win/lose conditions).
- [ ] **Milestone 6**: Low-poly art models and Nigerian campus audio.
- [ ] **Milestone 7**: Web release on itch.io.
