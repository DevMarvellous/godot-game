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

- [x] **Female & Male Hostel Differentiation**:
  - Dynamically switches title between *Moremi Hall* (Female) and *Hall 2* (Male).
  - Dynamically swaps roommate NPC between *Chisom* (female) and *Segun* (male).
- [ ] **Roommate Personality Archetypes**:
  - *The Bookworm*: Always studying, shares past questions.
  - *The Chef*: Always boiling Indomie, offers free food when sapa strikes.
  - *The Pastor/Prayer Warrior*: Wakes everyone up for morning devotion (+Faith, -Sleep).
  - *The Hustler*: Selling crypto, perfumes, and hostel snacks.

### 2. Multi-Vendor Cafeteria (Mama Put & Senate Bistro)
- [x] **Mama Put (Affordable Campus Joint)**:
  - *Mama Cashout*: Jollof rice, fried fish, plantain.
  - *Iya Basira*: Amala lafun, ewedu, gbegiri, goat meat.
  - *Mallam Danladi*: Indomie, suya beef, cold malt & zobo.
- [x] **The Senate Bistro & VIP Lounge (High-End Dining)**:
  - *Chef Pierre*: Gourmet iced latte focus boosters, continental steaks.

### 3. Sports & Recreation
- [x] **Dean's Cup Football Stadium**:
  - Full pitch with goalposts, boundary fences, interactive physics soccer ball.
  - *Coach Balogun* athletic training & tournament dialogue.

### 4. Interactive Phone & Group Chat
- [x] **CampuSApp Messaging**:
  - Official 100L Departmental Group Chat with pinned course rep deadlines and live banter.

### 5. Gameplay Mechanics & Feel
- [x] **Stamina & Sprinting**: Shift key / double push moves player 1.55x faster with dynamic stride gait.
- [ ] **Hostel Inspection Random Event**: Hall warden checks for banned hot plates / boiling rings.
- [ ] **Rain / Heatwave Weather System**: Random weather changes campus ambient lighting.

---

## 💰 Section C: Game Monetization & Ad Placement Architecture

### 1. Rewarded Video Ads (Highest eCPM & Player-Friendly)
- **Concept**: Players *choose* to watch a short 15-30s ad in exchange for high-value in-game perks.
- **Triggers**:
  - 📺 **Sapa Bailout**: Watch an ad on the phone app for instant ₦1,500 + 25% Energy recharge.
  - ⚡ **Exam Panic Study Pass**: Watch an ad when entering an exam with low stamina to get a +10 Continuous Assessment bonus mark.
  - 🚌 **Free Keke Shuttle Pass**: Watch 1 ad for 5 free instant campus trips without paying ₦100 fare.

### 2. In-Game Native Campus Billboards
- **Concept**: Realistic 3D billboard meshes placed around the football stadium and campus courtyard.
- **Placement**:
  - Football stadium perimeter fences.
  - Campus ATM booth walls.
  - Can display real sponsor banners (e.g. telecom networks, fintech apps, campus food brands) without interrupting gameplay.

### 3. Web Monetization Providers (HTML5)
- **Google AdSense for Games / H5 Games Ads**: Directly integrates with Godot HTML5 canvas.
- **GameDistribution / CrazyGames SDK**: Built-in rewarded ad API that can trigger Javascript calls from Godot (`JavaScriptBridge.eval()`).


