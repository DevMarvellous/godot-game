# 🎨 My Campus Life — Brand Assets & Social Share Images

All official icons, banners, and Open Graph social sharing images are centralized here and in `docs/`.

## 🖼️ How to Change the Share Banner (Fast 1-Step Update)
Whenever you create or receive a new banner design:
1. Save your new image as **`docs/og-preview.jpg`** (recommended size: **1200 × 630 px**).
2. Commit and push to GitHub:
   ```bash
   git add docs/og-preview.jpg
   git commit -m "Update social share preview image"
   git push origin master
   ```
3. Vercel automatically deploys it! WhatsApp, Twitter/X, Discord, and Facebook will immediately show your new image when anyone shares `https://mycampuslife.vercel.app`.

---

## 📁 Current Asset Manifest

| File | Purpose | Dimensions |
| :--- | :--- | :--- |
| `docs/og-preview.jpg` | **Primary Social Share Banner** (WhatsApp, Twitter, Discord, Facebook) | 1200 × 630 |
| `docs/og-preview.png` | Lossless PNG version of the share banner | 1200 × 630 |
| `docs/app_icon_v1.jpg` | 3D App Icon (Tilted Cap + Gold Naira + Laurel) | 512 × 512 |
| `docs/app_icon_v2.jpg` | 3D App Icon (Varsity "MCL" Ribbon Edition) | 512 × 512 |
| `docs/app_icon_v3.jpg` | 3D App Icon (Centered Gold Crest Edition) | 512 × 512 |
| `docs/logo.svg` | Scalable Vector Logo Crest (Admissions Portal & Favicon) | Vector SVG |
| `docs/logo_horizontal.svg` | Wide Brand Header (GitHub README & Website Header) | 960 × 260 |
| `docs/logo_minimal.svg` | Minimal Squircle App Icon | Vector SVG |
| `docs/manifest.json` | PWA Web App Manifest for mobile "Add to Home Screen" | JSON |

