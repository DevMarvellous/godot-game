# Master Game Plan: Campus Life Simulator (Nigeria)

> **Vision**: A 3D Top-Down / Isometric Nigerian University Life Simulator (inspired by *The Sims* and *Lagos Life*).
> You play as an undergraduate student balancing survival (food, sleep), academics (CGPA, lectures), faith (fellowship, prayer), hustle (finances), and campus relationships over a university semester.

---

## 1. How the Game is Structured (The Architecture)

Everything is built in clean, isolated pieces so you can edit, scrap, or upgrade any part anytime without breaking the rest:

### A. The Master Scene (`scenes/main.tscn`)
This is the campus container. It holds:
- **Lighting & Sky**: `DirectionalLight3D` + `WorldEnvironment` (smooth Sunrise, Midday, Sunset, Night transitions).
- **The Sectors / Zones**:
  1. **Hostel Sector**: Bedroom with Bed (sleeping fast-forwards time, recovers Energy, ends the day).
  2. **Academics Sector**: Study Hall with Lecture Desks (interactive study modal, attend scheduled classes).
  3. **Cafeteria / Buka Sector**: Food counter (interactive Nigerian food menu).
  4. **Chapel Sector**: Fellowship altar (prayer, bonus during 17:00-19:00 fellowship).
  5. **Commercial / Courtyard**: Central ATM (allowance withdrawal).
- **The Actors**: `Player3D` and roaming `NPCs` (Emeka, Sister Blessing, Dr. Adebayo).
- **The Screen UI**: 2D `HUD` overlay + popup modal dialogs (`FoodMenu`, `StudyMenu`).

### B. Global Engines (Autoload Singletons)
- **`TimeSystem`**: The master clock. 1 real second = 2 game minutes. Powers day progression, schedules, and passive need decay.
- **`Schedule`**: The timetable manager. Fires lectures at 09:00 & 14:00, fellowship at 17:00, curfew at 22:00. Penalizes skipping class (-0.10 CGPA).

---

## 2. Expanded Master Roadmap

### Phase 1: Core Foundation & Semester Prototype (Current Phase)
- [x] **Milestone 1**: 3D CharacterBody3D controls, 3D courtyard blockout, Bed, Desk, Cafe, Chapel, ATM, and HUD.
- [x] **Milestone 2**: In-game 24h clock, campus timetable, day/night lighting, lecture attendance/skipping penalties, sleep & burnout collapse.
- [x] **Milestone 3**: Interactive Nigerian Buka Food Menu (Jollof, Indomie, Egusi, Meat Pie, Sapa special) + Study & Lecture modal.
- [x] **Milestone 4**: Roaming 3D student & lecturer NPCs with campus dialogue bubbles.
- [x] **Milestone 5**: Semester Targets & Daily Report Card (Win/loss conditions: First Class, 2:1, Sapa bankruptcy, Probation, Spiritual burnout).
- [ ] **Milestone 6**: Multiple Campus Interiors & Door Portals (Hostel room inside, Lecture hall inside, Chapel inside).
- **Milestone 6: Multiple Campus Interiors & Door Portals**:
  - Break campus into distinct interconnected rooms/scenes:
    - *Hostel Hallway & Room* (wardrobe, bed, roommate).
    - *Large Lecture Theatre* (steep lecture hall with 50 seats, chalkboard, lecturer podium).
    - *Campus Chapel Auditorium* (pews, pulpit, choir instruments).
    - *Campus Market / Student Union Building* (provision stores, printing business center, barber shop).
- **Milestone 7: Money Side Hustles & Student Economy**:
  - Laptop side gigs (freelance graphic design, coding, assignment typing).
  - Hostel business (selling snacks, soft drinks, noodles to dorm mates).
  - Urgent 2k calls home to parents (success depends on your current CGPA report).
- **Milestone 8: Semester Exam Week & Mini-Games**:
  - Midterm tests and Final Exams with interactive quiz mini-games or quick-time challenges.
  - Moral dilemmas: Exam Malpractice temptations (cheating expo vs studying honestly).
- **Milestone 9: Social Relationships & Dialogue Trees**:
  - Relationship meters with NPCs: Stranger -> Classmate -> Close Friend -> Best Friend / Crush.
  - Joining campus fellowships / departmental study groups.

### Phase 3: Visual Polish & Nigerian Campus Audio
- **Milestone 10: Character Customizer**:
  - Choose gender, skin tone, hairstyles (braids, fade, dreads), varsity jackets, native attire.
- **Milestone 11: Real Low-Poly 3D Assets**:
  - Replace prototype boxes with stylized low-poly Nigerian campus models (danfo bus, hostel bunks, lecture benches, buka pots).
- **Milestone 12: Sound & Ambience**:
  - Campus footsteps, crowd chatter, chapel hymns, buka sizzling, ambient crickets at night, chill lofi-Afrobeats music.

### Phase 4: Release & Deployment
- **Milestone 13: Web Export (HTML5)**:
  - Optimize build bundle for browsers. Host on itch.io or custom domain for one-click browser play.
- **Milestone 14: Mobile Builds (Android / iOS)**:
  - Add on-screen touch joystick and tap-to-move for phones, package Android APK for Google Play Store.

### Phase 5: Long-Term Online Multiplayer (Future Expansion)
- Once single-player is proven and popular:
  - WebSocket lobby server for multiplayer campus hangouts (Lagos Life style chatrooms, visiting other students' rooms, trading items).

---

## 3. Scope & Golden Rules
1. **Never break editability**: All data (dishes, dialogue, study options, quests) is stored in simple dictionaries or exported inspector fields so anyone can edit them.
2. **Performance first**: Low-poly art, 60 FPS cap, event-driven scripts. Never use unoptimized loops that heat up devices.
3. **Playable at every commit**: Each milestone ends with a working, runnable game.
