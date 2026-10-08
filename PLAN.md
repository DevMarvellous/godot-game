# Master Game Plan: Campus Life Simulator (Nigeria)

> **CORE PRINCIPLE**: **MOBILE FIRST!** Desktop is secondary.
> Designed for touchscreens, thumbs, low battery consumption, and instant room-to-room transit—exactly like *Lagos Life*.

---

## 1. How the Game Is Structured (The Architecture)

### A. Map Design: Room-Based Hubs (Like *Lagos Life*)
Instead of a gigantic 2-kilometer open world that lags mobile phones and drains battery, the game uses **cozy, modular 3D Rooms & Locations**:
1. **Hostel Dormitory Room**: Bed, wardrobe, study desk, personal computer.
2. **Campus Lecture Theatre**: Rows of tiered benches, chalkboard, lecturer podium.
3. **Campus Buka / Food Court**: Food counters, Mama Put pots, outdoor student tables.
4. **Campus Chapel Auditorium**: Altar, wooden pews, fellowship stage.
5. **Campus Courtyard & Gate**: ATM terminal, bus stop, open hangout area.

Players move between these rooms either through **doorways** or using the **🚌 Quick Campus Transit** menu (campus shuttle fast travel).

### B. Mobile Touch Controls (Built In)
- **Virtual Joystick (Bottom-Left)**: Smooth thumb analog stick for walking.
- **Large Touch Action Button (Bottom-Right)**: Big thumb-friendly button that lights up when you are near an interactable object.
- **Quick Transit Button (Top-Right)**: Opens the campus map sheet to instantly travel between rooms.
- **Touch Emulation Enabled**: Clicking with mouse on PC tests mobile touch input 1:1.

---

## 2. Master Roadmap

### Phase 1: Core Foundation & Semester Prototype
- [x] **Milestone 1**: 3D CharacterBody3D movement, initial courtyard blockout, Bed, Desk, Cafe, Chapel, ATM, and HUD.
- [x] **Milestone 2**: In-game 24h clock, campus timetable, day/night lighting, lecture attendance/skipping penalties, sleep & burnout collapse.
- [x] **Milestone 3**: Interactive Nigerian Buka Food Menu (Jollof, Indomie, Egusi, Meat Pie, Sapa special) + Study & Lecture modal.
- [x] **Milestone 4**: Roaming 3D student & lecturer NPCs with campus dialogue bubbles (Emeka, Sister Blessing, Dr. Adebayo).
- [x] **Milestone 5**: 14-Day Semester Targets, Daily Report Card, and Win/Lose degree classifications.
- [x] **Milestone 5.5**: **Mobile Touch Controls** (Virtual Joystick, Large Thumb Action Button, Quick Campus Transit, Touch Emulation).

### Phase 2: Campus Expansion & Deeper Systems (Next Up)
- [ ] **Milestone 6: Distinct Indoor Room Scenes & Door Portals**:
  - Separate 3D room scenes loaded cleanly:
    - `res://scenes/rooms/hostel_room.tscn`
    - `res://scenes/rooms/lecture_hall.tscn`
    - `res://scenes/rooms/chapel_hall.tscn`
    - `res://scenes/rooms/buka_court.tscn`
- [ ] **Milestone 7: Money Side Hustles & Student Economy**:
  - Laptop side gigs (freelance design, typing assignments).
  - Hostel provision sales (selling drinks and noodles).
  - "Urgent 2k" calls home to parents (success tied to current CGPA).
- [ ] **Milestone 8: Semester Exam Week & Mini-Games**:
  - Midterm tests and Final Exams with quick-time quiz mini-games.
  - Moral dilemmas: Exam Malpractice temptations (cheating expo vs honest study).
- [ ] **Milestone 9: Student Relationships & Friendship Meters**:
  - Chatting with NPCs boosts friendship meters (Classmate -> Close Friend -> Best Friend / Crush).

### Phase 3: Visual Polish & Sound
- [ ] **Milestone 10: Character Customizer**:
  - Hairstyle, skin tone, varsity jackets, native attire.
- [ ] **Milestone 11: Real Stylized Low-Poly 3D Assets**:
  - Replace placeholder boxes with modular low-poly African campus models.
- [ ] **Milestone 12: Sound & Ambience**:
  - Campus footsteps, crowd murmurs, chapel hymns, buka sizzle, and lofi-Afrobeats music.

### Phase 4: Release & Deployment
- [ ] **Milestone 13: Web Export (HTML5)**: Mobile browser optimized.
- [ ] **Milestone 14: Google Play Store Android APK**.
