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

### Core Systems & Scenes:
1. **Main World (`scenes/main.tscn`, `scripts/main.gd`)**:
   - 3D courtyard level with `DirectionalLight3D` (sunlight + soft shadows) and procedural sky.
   - Four primary campus sectors with 3D boundaries:
     - **Hostel Bedroom**: Contains `HostelBed`.
     - **Study Hall**: Contains `StudyDesk`.
     - **Food Court**: Contains `Cafeteria` (Buka).
     - **Fellowship Ground**: Contains `Chapel` Altar.
     - **Courtyard**: Contains `ATM` terminal.
2. **Player Controller (`scenes/player_3d.tscn`, `scripts/player_3d.gd`)**:
   - `CharacterBody3D` with Jolt physics collision, smooth 3D rotation toward movement direction.
   - Overhead angled 3D camera (`Camera3D`) following the player.
   - 3D Billboard labels above the player's head for interaction prompts and popups.
3. **Stat Management (`scripts/needs_manager.gd`)**:
   - Tracks 5 core student stats:
     - **Energy** (0-100): Decays over time; restored by sleeping in Hostel Bed.
     - **Hunger** (0-100 fullness): Decays over time; restored by buying food at Cafeteria.
     - **Faith / Spiritual** (0-100): Restored by praying at Chapel Altar.
     - **CGPA** (0.00-5.00): Boosted by studying at Study Desk (consumes Energy).
     - **Wallet / Allowance** (Naira ₦): Spent on food, replenished via ATM.
4. **Interaction System (`scripts/interactable_3d.gd`, `scripts/campus_objects_3d.gd`)**:
   - `Area3D` proximity triggers that signal nearby players and execute modular effects on interaction.
5. **HUD Overlay (`scenes/hud.tscn`, `scripts/hud.gd`)**:
   - 2D `CanvasLayer` displaying real-time wallet counter (₦), CGPA, and progress bars.

## 4. Upcoming Roadmap
1. **Campus Clock / Time System**: Day & night cycle with scheduled lectures, chapel services, and curfew.
2. **Interactive Menus**: Cafeteria menu selection (Jollof rice, Suya, Indomie with different prices/buffs).
3. **NPC Students & Lecturers**: Basic AI agents walking paths, chatting, and reacting.
4. **Sound Effects & Nigerian Ambience**: Ambient campus sounds, interaction chimes, afrobeat-lite background loop.
