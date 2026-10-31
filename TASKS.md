# My Campus Life - Upcoming Tasks Roadmap

This file contains all the tasks that still need to be done. It does not list finished items. Each task explains what needs to be created and how to build it. All features are designed to be wholesome, fun, clean, and engaging for all players.

---

## Task 1: Connect Google Sign In with Supabase
### What Needs to be Done
Connect Google OAuth credentials so players can sign in with one tap using their real Google account.

### How to Do It
1. Open Google Cloud Console under Credentials.
2. Create an OAuth 2.0 Client ID for Web application.
3. Add https://mycampuslife.vercel.app and http://localhost:8000 under Authorized JavaScript Origins.
4. Add https://qissxomdrgimimkedwpy.supabase.co/auth/v1/callback under Authorized Redirect URIs.
5. Copy the Client ID and Client Secret into the Supabase Dashboard under Authentication Providers Google.
6. Test in web shell html that clicking the Google button signs the user in and restores their cloud profile.

---

## Task 2: Campus Fellowship Praise Concert
### What Needs to be Done
Add an interactive musical and worship event at the University Chapel with Christian praise songs and student choir participation.

### How to Do It
1. In chapel room gd, add an interactive organ piano and choir podium.
2. When the player walks to the choir stage, trigger an interactive rhythm mini game where tapping keys plays uplifting praise melodies.
3. Boost the player Faith and Energy stats by 30 points upon completing a fellowship session.
4. Add Sister Blessing and student choir NPCs singing and welcoming new freshers with encouraging scriptures.

---

## Task 3: Student Entrepreneurship and Freelance Creative Agency
### What Needs to be Done
Allow students to earn honest income through creative talents like graphic design, laptop coding, photography, baking, and academic tutoring.

### How to Do It
1. In campus gigs menu gd, expand the Student Union Building work stations.
2. Add interactive mini tasks:
   - Graphic Design Station: Design flyers for campus conferences to earn 2,500 Naira.
   - Code Bug Bounty: Fix software bugs at Silicon Lagoon Tech Hub to earn 3,500 Naira.
   - Handout Printing Hustle: Fast typing and printing of past questions for freshers to earn 1,800 Naira.
   - Peer Tutoring: Teach junior 100L students before exams to earn 2,000 Naira and raise academic reputation.

---

## Task 4: Hostel Room Customization and Study Hub
### What Needs to be Done
Allow players to personalize their hostel room with useful furniture, study lamps, bookshelves, and home decor.

### How to Do It
1. In mall items data gd, add new placeable room items: Study Lamp, Double Deck Bookshelf, QASA Standing Fan, Ergonomic Desk Chair, and Campus Map Wall Poster.
2. In base room gd, save owned furniture in student profile and display them in the hostel room upon entry.
3. High level study furniture grants passive study focus buffs, speeding up exam preparation.

---

## Task 5: Dean Cup Faculty Football Championship
### What Needs to be Done
Expand the newly renovated football stadium with a full tournament mode where faculties compete for the championship trophy with zero gambling.

### How to Do It
1. In stadium room gd, connect the interactive football and goalposts into a 5 round penalty shootout challenge against Goalkeeper Emeka.
2. Players aim shots at corners using power meters for pure skill and fun.
3. Scoring goals earns the Faculty Gold Cup trophy and celebratory crowd cheers with zero monetary wagering.
4. Add athletic 400m sprint timing laps on the track to train student stamina.

---

## Task 6: WhatsApp and Social Shareable Student Life Card
### What Needs to be Done
Add a 1 tap phone button that generates a clean, shareable student ID badge card summarizing your student achievements and avatar drip.

### How to Do It
1. In web shell html, build an HTML canvas renderer styled like a modern university student ID card.
2. Include student name, department, CGPA grade, 3D avatar picture, and a wholesome personality title like First Class Scholar, Campus Athlete, Master Baker, or Fellowship Leader.
3. Connect the browser Web Share API so the player can share the badge image directly to WhatsApp Status or download it to their phone gallery.

---

## Task 7: In-Game Settings and Direct Player Feedback
### What Needs to be Done
Add a comprehensive settings menu with audio controls, performance toggles, and a direct bug feedback box.

### How to Do It
1. In scenes hud tscn and phone system gd, add an easy to reach Settings button.
2. Include volume sliders for Master, Background Music, and Sound Effects.
3. Include camera view switcher for Top View, Classic Angle, and 3D Perspective.
4. Include a Send Feedback box that writes user comments, ratings, and device model straight into the Supabase campus user feedback table.

---

## Task 8: Driveable Campus Danfo Bus and Keke Shuttle
### What Needs to be Done
Let players drive the yellow Danfo bus or tricycle Keke around the campus ring road to transport students between faculties.

### How to Do It
1. In campus gate scene, place an interactive yellow Danfo bus.
2. Create simple arcade vehicle physics with forward drive, reverse, steering, and braking.
3. Place passenger stops at Hostel, Lecture Hall, Library, and Stadium.
4. Picking up waiting student NPCs and dropping them at their destination rewards 150 Naira transport fare per trip.

---

## Task 9: Nigerian Emote and Wardrobe Hairstyles Expansion
### What Needs to be Done
Expand the student wardrobe with additional authentic hairstyles, dresses, and expressive Nigerian campus emotes.

### How to Do It
1. In wardrobe data gd, add more hairstyles including cornrows, puff afro braids, and traditional gele headwrap.
2. In player 3d gd, add expressive emotes: Odogwu Stride, Praise Jump, Graduation Dance, and Serious Concentration.
3. Enhance the phone emote selector UI with clear icons and bright text for high contrast on mobile screens.
