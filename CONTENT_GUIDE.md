# 🛠️ My Campus Life — Live Backend & Content Updatability Guide

**My Campus Life** is engineered with a **Hot-Reloadable Live Config & Cloud Architecture** so you can update announcements, economy multipliers, shuttle fares, and database connections **without recompiling Godot**!

---

## 1. ☁️ Linking Your Free Supabase Database (Zero-Code or Config File)

You have **two ways** to connect your live Supabase PostgreSQL + Realtime Multiplayer database:

### Option A: Instant In-Browser Link (Fastest for Testing)
1. Open the game in your browser and click the **`☁️ Link Cloud DB`** button in the top-right corner of the Admissions Portal.
2. Paste your **Supabase Project URL** (`https://xxxx.supabase.co`) and **Anon Public Key** (`eyJ...`).
3. Click **Save & Connect Live** — both the HTML Multiplayer WebSocket (`MCL_NET`) and the Godot 4 engine (`DatabaseConfig` / `SupabaseClient`) immediately connect to your cloud database!

### Option B: Permanent For All Players on Vercel (`docs/cloud_config.js`)
Edit [`docs/cloud_config.js`](file:///C:/Users/1LUV/Documents/mycampuslife/docs/cloud_config.js) and paste your project credentials:
```javascript
window.MCL_CLOUD_CONFIG = {
  SUPABASE_URL: "https://your-project-id.supabase.co",
  SUPABASE_ANON_KEY: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  REALTIME_CHANNEL: "realtime:campus_global_lobby",
  LIVE_CONFIG_URL: "./live_game_config.json"
};
```
Commit and push to GitHub — Vercel will deploy it in ~15 seconds without rebuilding the `.wasm` or `.pck` files.

---

## 2. 🔄 Live Game Updates Without Rebuilding Godot

At startup, the game fetches live configuration from two sources in priority order:
1. **Supabase Table (`public.game_live_config`)** — if your Supabase DB is linked, any row you edit in the Supabase Table Editor takes effect immediately for all players.
2. **Static JSON (`docs/live_game_config.json`)** — editable directly on GitHub or Vercel!

### Editable Keys in `docs/live_game_config.json` & `public.game_live_config`:
| Key | Example Value | Effect in Game |
| :--- | :--- | :--- |
| `motd` | `"🎉 Welcome to Semester 1! Double Hustle Payouts Active!"` | Displays as a welcome toast notification and in the Phone Settings app. |
| `economy_boost_multiplier` | `1.25` | Multiplies campus side-hustle payouts for weekend events. |
| `shuttle_fare` | `100` | Sets default Keke / Danfo shuttle fare across campus. |
| `featured_event` | `"Silicon Lagoon Hackathon @ Tech Hub"` | Highlights current campus event. |

---

## 3. 🗄️ Setting Up the Database Schema (`supabase_schema.sql`)

1. Open your free [Supabase Dashboard](https://supabase.com/dashboard) → **SQL Editor**.
2. Copy and paste the entire contents of [`supabase_schema.sql`](file:///C:/Users/1LUV/Documents/mycampuslife/supabase_schema.sql) and click **Run**.
3. This creates:
   - `public.students` (with `@username`, `matric_no`, `cgpa`, `wallet_balance`, `appearance`, `inventory`, and anti-cheat `CHECK` constraints)
   - `public.campus_chat_logs` (global & room chat persistence)
   - `public.game_live_config` (remote live configuration table)

---

## 4. 🏛️ All 16 Campus Locations

| Room ID | Scene File | Description |
| :--- | :--- | :--- |
| `admission` | `res://scenes/admission_screen.tscn` | JAMB / Post-UTME Portal & Live Avatar Customization |
| `courtyard` | `res://scenes/main.tscn` | Main Campus Quad & Courtyard |
| `hostel` | `res://scenes/rooms/hostel_room.tscn` | Hall 2 (Male) / Moremi Hall (Female) Dormitory |
| `lecture` / `class` | `res://scenes/rooms/lecture_hall.tscn` | Faculty Lecture Theatre 1 (LT1) |
| `class2` | `res://scenes/rooms/lecture_theatre_2.tscn` | Sciences Lecture Theatre 2 (LT2) |
| `library` | `res://scenes/rooms/library_hall.tscn` | Central University Library |
| `mama_put` | `res://scenes/rooms/mama_put.tscn` | Mama Put Bukateria & Canteen |
| `mall` | `res://scenes/rooms/campus_mall.tscn` | Madam Kikelomo Campus Mall & Boutique |
| `stadium` | `res://scenes/rooms/football_stadium.tscn` | Sports Stadium & Football Pitch |
| `chapel` | `res://scenes/rooms/chapel_hall.tscn` | University Fellowship Chapel |
| `sub` | `res://scenes/rooms/sub_building.tscn` | Student Union Building (SUB) & Business Centre |
| `garden` | `res://scenes/rooms/campus_garden.tscn` | Campus Botanical Gardens & Peace Park Gazebo |
| `salon` | `res://scenes/rooms/barbing_salon.tscn` | Executive Barber & Hair Salon |
| `gate` | `res://scenes/rooms/campus_gate.tscn` | Main Campus Security Gate & Shuttle Park |
| `senate` | `res://scenes/rooms/senate_building.tscn` | University Senate & Registry Building |
| `convocation` | `res://scenes/rooms/convocation_hall.tscn` | Great Hall of Convocation & Alumni Arena |
| `tech_hub` | `res://scenes/rooms/tech_hub.tscn` | **NEW:** Silicon Lagoon Tech Hub & Campus Wellness Clinic |

