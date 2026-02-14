# SlabHaul

Crappie fishing companion app — attractor maps, weather dashboard, spider rigging depth calculator, and a full crappie knowledge base. Built with Flutter, backed by Supabase, seeded with real data from 3 lakes.

## Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter 3.x |
| State Management | Riverpod |
| Routing | GoRouter (StatefulShellRoute) |
| Backend / Auth | Supabase (PostgreSQL + PostGIS + Auth) |
| Maps | flutter_map + OSM tiles + Marker Clustering |
| Charts | fl_chart |
| Weather API | Open-Meteo (no key required) |
| Lake Levels API | USGS Water Services |
| HTTP | dio + http |

## Features

### 1. Attractor Map (Primary Feature)
- Interactive map with 30 real fish attractor locations across 3 lakes
- Color-coded markers by type (brush pile, PVC tree, stake bed, pallet)
- Marker clustering at zoom levels
- Bottom sheet with GPS coordinates, depth, source, navigate-to-GPS
- Lake selector and type filter chips
- Wind overlay with speed/direction

### 2. Weather Dashboard
- Current conditions (temp, feels like, humidity, wind)
- Barometric pressure trend with sparkline chart
- 24-hour hourly forecast strip
- 7-day daily forecast
- Sun/moon card with phase calculation
- Wind compass visualization
- Lake conditions card (water level vs normal pool, water temp)
- Water level chart (7-day USGS data)

### 3. Spider Rigging Depth Calculator
- Physics-based depth calculation (force-balance model)
- Sinker weight, line out, boat speed, line type inputs
- Animated line angle diagram (CustomPaint)
- Depth zone classification (Shallow/Mid/Deep/Ultra-Deep)
- Preset chips for quick setup

### 4. Crappie Knowledge Base
- Seasonal patterns (Winter, Pre-Spawn, Spawn, Post-Spawn/Summer, Fall)
- 5 fishing techniques with pros/cons/setup/pro tips
- 4 bait categories with rigging methods and color recommendations
- Full-text search across all content

### 5. Auth & Profile
- Email/password sign in/sign up
- Google and Apple OAuth
- Guest mode (all features work without auth)
- Profile with settings, status card, data sources

## Supported Lakes

| Lake | State | Attractors | Source |
|------|-------|------------|--------|
| Horseshoe Lake | AR | 10 | AGFC |
| Reelfoot Lake | TN | 10 | TWRA |
| Kentucky Lake | TN/KY | 10 | KDFWR / TWRA |

## Setup

### Prerequisites
- Flutter SDK 3.x installed
- A device or emulator

### Quick Start

```bash
# 1. Generate platform directories (if not present)
flutter create --project-name slabhaul .

# 2. Copy env file and add your keys (optional — app works in mock mode without them)
cp .env.example .env

# 3. Install dependencies
flutter pub get

# 4. Run
flutter run
```

### Environment Variables (`.env` or `--dart-define`)

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
MAPBOX_ACCESS_TOKEN=your-mapbox-token
```

All three are optional. Without Supabase, the app loads attractors from the bundled `assets/data/attractors.json` and auth runs in guest mode. Weather and lake levels use free public APIs (Open-Meteo, USGS) that require no keys.

For local development, you can create a `.env` file (see `.env.example`). For production and CI builds, prefer `--dart-define` so secrets do not need to be bundled as assets:

```
flutter build web \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

### Supabase Setup (Optional)

1. Create a Supabase project
2. Run `supabase/migrations/001_initial_schema.sql` in the SQL Editor
3. Run `supabase/migrations/002_seed_data.sql` to populate lakes and attractors
4. Copy the project URL and anon key to `.env`

## Architecture

```
lib/
├── main.dart                          # Entry point
├── app/
│   ├── theme.dart                     # Dark theme (teal accent)
│   ├── routes.dart                    # GoRouter with 5-tab shell
│   ├── app_shell.dart                 # Bottom navigation
│   └── providers.dart                 # Top-level service providers
├── core/
│   ├── models/                        # Data classes (6 files)
│   ├── services/                      # API clients with mock fallback (4 files)
│   └── utils/                         # Calculator, weather utils, moon phase (4 files)
├── shared/widgets/                    # Reusable UI components (5 files)
└── features/
    ├── map/                           # Attractor map (8 files)
    ├── weather/                       # Weather dashboard (11 files)
    ├── calculator/                    # Spider rigging calculator (6 files)
    ├── knowledge_base/                # Crappie knowledge (6 files)
    └── auth/                          # Login, profile, auth providers (4 files)
```

**~55 Dart source files** | Mock-first architecture | All services have real API + offline fallback

## Data

- `assets/data/attractors.json` — 30 attractor locations (bundled for offline)
- `supabase/migrations/` — PostgreSQL schema with PostGIS spatial indexing + RLS
