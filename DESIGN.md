# Lagos Campus Life Simulator — Master Design & Architecture Document

> **Vision**: An authentic, highly relatable 3D Nigerian University life simulator running seamlessly in mobile browsers and low-spec phones with **$0 server infrastructure costs**.

---

## 1. Zero-Cost ($0) Infrastructure & Hosting Architecture

We operate with **$0 budget for backends/databases** (only domain budget). Here is the exact stack and capacity:

```
[ Player Mobile Browser / PWA ]
              │
              ├── 1. Static Web Hosting: GitHub Pages / Cloudflare Pages ($0, Unlimited Bandwidth, Free SSL)
              │
              ├── 2. Primary Save Layer: Browser IndexedDB (`user://`) (Offline-first, 0 server calls, infinite players)
              │
              └── 3. Cloud Auth & Sync: Supabase Free Tier (PostgreSQL + GoTrue Auth)
                     ├── Max Active Users: 50,000 Monthly Active Users (MAU) for $0
                     ├── Database Storage: 500 MB (Stores millions of student save records)
                     ├── Bandwidth: Unlimited API Requests
                     └── Row-Level Security (RLS): Prevents score/wallet hacking
```

### Multiplayer on $0 Budget:
- **Dedicated Game Servers (Godot Headless 24/7)** cost $10–$40/month per server and will crash when traffic spikes.
- **Our Solution (Serverless Social Hub)**:
  - **Single-player simulation** (lectures, tests, sleep, semester grades, CGPA) runs 100% on the player's device.
  - **Multiplayer Presence**: Supabase Realtime Channels (supports up to **200 concurrent live players** in public hubs like Quad, Cafeteria, Mall for $0). Players broadcast their position and chat bubbles to others in the same room.

---

## 2. Modular File & Directory Structure

To keep the game easily editable, understandable, and upgradable without breaking code, everything is strictly isolated into clear folders:

```
mycampuslife/
├── scenes/
│   ├── rooms/                  # Isolated hub environments (only 1 loaded at a time)
│   │   ├── hostel_room.tscn    # Moremi Hall / Hall 2 (Bed, Wardrobe, Desk, Water Jerrycan)
│   │   ├── campus_mall.tscn    # Madam Kikelomo Boutique (Clothes, shoes, gadgets)
│   │   ├── mama_put.tscn       # Campus Cafeteria (Jollof, Amala, Plantain)
│   │   ├── lecture_hall.tscn   # 100L Faculty Lecture Theatre (Classes & CA Tests)
│   │   ├── football_stadium.tscn # Sports complex & Inter-faculty matches
│   │   ├── sub_building.tscn   # Student Union Building (Provisions, Typing centre)
│   │   └── barbing_salon.tscn  # Master Sunday's Barbing & Styling Salon
│   │
│   ├── player_3d.tscn          # Player body, distinct 3D hair/outfit meshes & camera
│   ├── hud.tscn                # Top stats bar (Energy, Hunger, Faith, CGPA, Wallet, Clock)
│   ├── phone_system.tscn       # In-game smartphone with AMOLED wallpapers & apps
│   ├── wardrobe_menu.tscn      # Wardrobe changer & 3D dressing mirror
│   ├── mall_menu.tscn          # Madam Kikelomo Boutique shop & checkout interface
│   ├── food_menu.tscn          # Mama Put ordering menu
│   └── admission_screen.tscn   # 5-step fresher matriculation & 3D preview booth
│
├── scripts/
│   ├── data/                   # 100% PURE DATA (Edit stats, items, clothes without touching code!)
│   │   ├── wardrobe_data.gd    # Hairstyles, outfits, complexions, prices & mesh types
│   │   ├── mall_items_data.gd  # Power bank, scientific calculator, oxford set, sneakers
│   │   ├── food_data.gd        # Jollof, Fried Rice, Eba, Egusi, Amala, Meat, Zobo
│   │   ├── student_profile.gd  # Persistent matriculation biodata, matric no, allowance
│   │   └── database_config.gd  # Supabase credentials & local IndexedDB save handlers
│   │
│   ├── autoload/               # Global Singletons (Run in background)
│   │   ├── time_system.gd      # 24-hour clock, day/night cycle, semester calendar
│   │   ├── room_manager.gd     # Lightweight scene switching & memory cleanup
│   │   ├── sound_manager.gd    # In-memory procedural synth sound effects (0 extra bytes)
│   │   └── semester_manager.gd # Academic weeks, exams, CGPA calculation
│   │
│   ├── base_room.gd            # Universal room controller (ceiling fans, fixtures, NPCs)
│   ├── campus_objects_3d.gd    # Interactive 3D props (Beds, desks, counters, ATMs)
│   └── phone_system.gd         # Phone navigation, WhatsApp gist, Kuda wallet, Hustle ads
```

---

## 3. Character Customization & Visual Dressing System

### 3D Visual Mesh Swapping (Not just color changes!):
- **Hairstyles (5 Distinct Meshes)**:
  1. `Clean Low Cut & Waves` (Classic fade mesh)
  2. `Classic Round Afro` (Volumetric rounded afro mesh)
  3. `Box Braids & Dreads` (Cascading braided geometry)
  4. `Campus Baseball Cap` (Sporty snapback cap mesh)
  5. `Traditional Headwrap / Gele` (Layered regal cultural gele mesh)

- **Outfits (5 Distinct Meshes)**:
  1. `Casual Polo & Denim Jeans` (Standard lecture attire)
  2. `Senator Native Attire` (Long tunic & embroidered front collar)
  3. `Tech Bro Campus Hoodie` (Oversized cowl & hood silhouette)
  4. `Corporate Shirt & Silk Tie` (Formal presentation necktie)
  5. `Ankara Print Flare Gown` (Flared traditional gown skirt)

- **Complexions**: Rich Cocoa, Warm Chestnut, Golden Bronze, Honey Almond.

### Where You Dress & Shop:
1. **Admission Screen**: Initial fresher creation in an interactive 3D SubViewport booth.
2. **Hostel Room Wardrobe**: Free outfit & hair switching between items you already own.
3. **Campus Mall Boutique**: Shop at **Madam Kikelomo's Boutique** to buy exclusive native attires, designer shades, power banks, and provisions with your campus allowance!
4. **Master Sunday's Salon**: Get fresh fades and salon braids.

---

## 4. Room Realism & Authentic Nigerian Campus Atmosphere

Rooms are designed with relatable student details, not plain empty boxes:
- **Hostel Room**:
  - Double bunk bed with blue foam mattress
  - Big yellow 25L water jerrycan & blue plastic laundry bucket (for water shortages!)
  - Wooden reading table with laptop and notebook
  - Rotating ceiling fan responding to room physics
  - Dynamic hostel naming: **Moremi Hall (Room 204)** for female students, **Hall 2 (Room 112)** for male students
  - Roommate NPC (**Segun** or **Chisom**) giving realistic campus gist

- **Mama Put Joint**:
  - Steaming food counters serving Jollof, Egusi, Amala, and Dodo
  - Mama Cashout calling you *"My pikin, come chop!"*

- **Campus Mall & Boutique**:
  - Glass display tables with provisions, calculators, and sneakers
  - Madam Kikelomo running the cash register and fitting room

- **Lecture Theatres & SUB**:
  - Tiered wooden seating rows, whiteboards, SUG campaign posters, and business centres.

---

## 5. Economy & Daily Life-Sim Balance

1. **Starting Allowance (Asymmetric Spawns)**:
   - *Scholarship Kid / Chief's Child*: ₦250,000 + iPhone 15 Pro Max (Must maintain 4.5+ CGPA)
   - *Average Hustler*: ₦30,000 + Tecno Spark 10 (Standard balance of meals & handouts)
   - *Sapa Fighter*: ₦4,000 + Cracked Android (Must do odd jobs to survive)

2. **Daily Expenses**:
   - Food at Mama Put: ₦500 – ₦1,500 per meal
   - Campus shuttle / Keke: ₦100 – ₦200 per ride
   - Handouts & CA tests: ₦1,500 – ₦3,000

3. **Earning Money (Hustles)**:
   - SUB Typing & Proofreading (+₦2,500)
   - Graphic Design Posters (+₦4,500)
   - Freelance Coding (+₦8,500)
   - Request "Urgent 2k" from family via Phone Bank App
   - Watch Sponsored Ad Promo (+₦1,500 & +25% Energy)

---

## 6. Mobile Browser Performance & Data Budget Rules

1. **Rendering Method**: `GL Compatibility` (WebGL 2 / OpenGL ES 3.0), compatible with cheap Android devices and iPhones.
2. **Frame Rate Target**: Capped at **30 FPS on mobile** to prevent battery drain and thermal throttling (60 FPS on desktop).
3. **Shadows & Lighting**:
   - Real-time directional shadow casting is turned OFF.
   - Rooms use soft ambient tinting and simple baked blob silhouettes.
4. **Audio**:
   - 100% Procedural in-memory synthetic audio generator (`SoundManager`).
   - Zero MB audio download overhead!
5. **Texture & Asset Budget**:
   - Palettes and materials use flat color shaders with zero bloated 4K textures.
   - Total export build stays under **15 MB** compressed, cached instantly via ServiceWorker.

---

## 7. Immediate Roadmap & Implementation Order

- [x] Modular data stores created (`wardrobe_data.gd`, `mall_items_data.gd`, `food_data.gd`, `database_config.gd`).
- [x] 3D mesh swapping for 5 distinct hairstyles and 5 outfits on `Player3D`.
- [x] Dynamic hostel room adaptation (Moremi Hall / Hall 2, Chisom / Segun).
- [x] Rename all foreign/confusing terms to authentic Nigerian words (Campus Mall, Mama Put).
- [x] Verified Godot 4.7.2 headless test suite running with 0 errors.
- [ ] **Mall Shopping & Checkout UI (`mall_menu.tscn`)**: Madam Kikelomo Boutique checkout for buying clothes and gadgets.
- [ ] **Hostel Details & Nigerian Props Expansion**: Add generator outside window, Indomie crates, and laundry line.
- [ ] **Supabase Cloud Sync Adapter**: Optional one-click cloud backup for students switching phones.
