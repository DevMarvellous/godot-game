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

### Phase 2: Campus Expansion & Deeper Systems
- [x] **Milestone 6: Distinct Indoor Room Scenes & Door Portals**:
  - 9 Dedicated 3D room scenes loaded cleanly:
    - `res://scenes/rooms/hostel_room.tscn` (Bunk bed, wardrobe, laptop hustle, fan)
    - `res://scenes/rooms/lecture_hall.tscn` (Faculty LT1, benches, Dr. Adebayo, CA tests)
    - `res://scenes/rooms/lecture_theatre_2.tscn` (Sciences LT2, Prof. Okonjo, Mrs. Folashade)
    - `res://scenes/rooms/library_hall.tscn` (Bookshelves, quiet study carrels)
    - `res://scenes/rooms/buka_court.tscn` (Mama Cashout Campus Canteen & Eatery)
    - `res://scenes/rooms/chapel_hall.tscn` (Wooden pews, altar, pulpit, Sister Blessing)
    - `res://scenes/rooms/sub_building.tscn` (Cybercafé PCs, mini mart, Brother Chinedu, ATM)
    - `res://scenes/rooms/campus_garden.tscn` (Botanical Gardens & Prayer Walk)
    - `res://scenes/rooms/barbing_salon.tscn` (Master Sunday Executive Salon & Braiding)
- [x] **Milestone 7: Money Side Hustles & Student Economy**:
  - Laptop side gigs (freelance design, typing assignments).
  - SUB Business Centre typing and printing workstation.
  - "Urgent 2k" calls home to parents via in-game phone (success tied to current CGPA).
  - Campus Keke NAPEP shuttle transit (₦100 fare vs 20-min walking penalty).
- [x] **Milestone 8: Semester Exam Week & Moral Dilemmas**:
  - Multiple-choice Continuous Assessment test papers with instant grading.
  - **Exam Malpractice & Academic Integrity System** (Honest Effort vs "Expo / Microchip" cheat sheets, invigilator scrutiny, Disciplinary Committee penalties).
- [x] **Milestone 9: Student Relationships & Friendship Meters**:
  - Chatting with NPCs boosts friendship meters (Coursemate -> Study Partner -> Close Friend -> Trusted Ally).
  - Unlocks unique perks (attendance backup, grading leniency, prayer bonuses, gig payouts).

### Phase 3: Visual Polish & Sound
- [x] **Milestone 10: Character Customizer & Modular Humanoid Visuals**:
  - Modular low-poly humanoid body (melanin skin tones, hairstyles, faculty polos, slacks, sneakers).
  - Walking limb swing and torso bobbing animation.
  - Interactive styling menu in the Barbing Salon.
- [x] **Milestone 11: In-Game Smartphone ("Campus Connect")**:
  - Digital Student ID, Timetable, CGPA Portal, WhatsApp Gist, OPay Wallet, Hustle Hub.
- [x] **Milestone 11.5: Web & Mobile Online Multiplayer Foundation**:
  - `WebSocketMultiplayerPeer` architecture (`NetworkManager`) compatible with HTML5 WebAssembly, Android, and PC.
  - Room sync, interpolated puppet avatars (`NetworkPlayer`), and 3D speech bubbles.
  - Quick Campus Slang & Chat Popup (`ChatWheel`) for instant 1-tap mobile communication.
- [x] **Milestone 12: Sound & Audio Feedback (`SoundManager`)**:
  - 100% self-contained procedural audio: UI button clicks, coin/allowance chimes, Keke shuttle horn, exam bell, exhaustion alert tone.

### Phase 4: Polish & Deployment
- [x] **Milestone 13: Web Export Configuration (HTML5)**:
  - Configured `export_presets.cfg` targeting `builds/web/index.html`.
  - Non-threaded fallback enabled for zero-header compatibility on any web host (GitHub Pages, itch.io, Netlify, Vercel).
  - GL Compatibility renderer with adaptive canvas resizing.
- [ ] **Milestone 14: Google Play Store Android APK**.
