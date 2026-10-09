# 📋 Campus Life Simulator — Launch & Action Roadmap (TASKS.md)

This document tracks all human-action items for you (domain, branding, web hosting, HTML5 export) as well as technical game engine and multiplayer milestones.

---

## 🧑‍💻 Section A: Human Tasks (Things YOU Need To Do)

### 1. Game Branding & Domain
- [ ] **Finalize Official Game Title**:
  - Suggestions: *Lagos Campus Life*, *Naija Uni Quest*, *Campus Wahala*, *Matric 101*, *Varsity 9ja*, *Federal Uni Simulator*.
- [ ] **Game Icon & Favicon**:
  - Need a 512×512 PNG app icon (student wearing grad cap / backpack / hostel gate).
- [ ] **Domain & Hosting (Hostinger / Namecheap / Cloudflare)**:
  - Buy domain (e.g. `.com`, `.ng`, `.fun`, or `.site`).
  - Configure DNS (point A/CNAME record to Hostinger Web or Cloudflare Pages / GitHub Pages).
- [ ] **Hosting Setup**:
  - **Option 1 (Zero-Cost Starter)**: GitHub Pages (via repository `Settings -> Pages`).
  - **Option 2 (Custom Domain on Hostinger)**: Upload export files to `public_html`.
  - **Crucial Web Headers (SharedArrayBuffer)**: Set up `.htaccess` or Cloudflare Transform Rules to include:
    ```apache
    Cross-Origin-Opener-Policy: same-origin
    Cross-Origin-Embedder-Policy: require-corp
    ```

### 2. Godot Web HTML5 Export Templates
- [ ] Open Godot 4.7.
- [ ] Click **Editor -> Manage Export Templates**.
- [ ] Click **Download and Install** (ensures `web.zip` template is installed on your PC).
- [ ] In **Project -> Export**:
  - Add **Web** preset.
  - Export Path: `build/web/index.html`.

---

## 🛠️ Section B: Game Architecture & Outside-The-Box Polish

### 1. Dynamic Roommates & Gender Consideration
- [ ] **Female & Male Hostel Differentiation**:
  - Male student -> Male hostel room (e.g., *Hall 2 / Jaja Hall*), male roommates (*Segun, Femi, Chidi, Ibrahim*).
  - Female student -> Female hostel room (e.g., *Moremi / Queen Idia Hall*), female roommates (*Zainab, Chisom, Blessing, Hadiza*).
- [ ] **Roommate Personality Archetypes**:
  - *The Bookworm*: Always studying, shares past questions.
  - *The Chef*: Always boiling Indomie, offers free food when sapa strikes.
  - *The Pastor/Prayer Warrior*: Wakes everyone up for morning devotion (+Faith, -Sleep).
  - *The Hustler*: Selling crypto, perfumes, and hostel snacks.

### 2. Multi-Vendor Cafeteria (Not Just One Food Woman)
- [ ] Add 3 distinct cafeteria food vendors in Buka Court:
  - **Mama Cashout**: Jollof rice, fried fish, beans, plantain.
  - **Iya Basira**: Amala, ewedu, gbegiri, goat meat.
  - **Mallam Danladi / Suya Joint**: Indomie & eggs, suya, fresh bread, cold malt.

### 3. Dedicated Multiplayer & Online Sync
- [ ] **Dedicated WebSockets Server Architecture**:
  - Lightweight Node.js or Python WebSocket relay, or headless Godot server script.
  - Room-based channels (`hostel`, `lecture`, `buka`, `library`) so players only receive traffic for the room they are in.
  - Player nametags with Matric Number and custom appearance styling.
- [ ] **Live Campus Chat**:
  - Floating 3D speech bubbles over avatars.
  - Chat history drawer on the phone app.

### 4. Gameplay Mechanics & Feel
- [ ] **Stamina & Sprinting**: Hold shift / double tap virtual joystick to jog.
- [ ] **Hostel Inspection Random Event**: Hall warden checks for banned hot plates / boiling rings.
- [ ] **Rain / Heatwave Weather System**: Random weather changes campus ambient lighting.

