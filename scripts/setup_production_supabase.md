# SlabHaul Production Supabase Setup

This guide walks through setting up Supabase for production deployment.

## 1. Create Production Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Choose your organization and project name: `slabhaul-prod`
3. Choose database password (save securely)
4. Select region (preferably US East for Tennessee users)

## 2. Get Production Keys

From your Supabase dashboard:

1. Go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (e.g., `https://your-project-id.supabase.co`)
   - **anon/public key** (starts with `eyJ...`)

## 3. Update Environment Variables

### For Local Development with Production Data:
Update `.env` file:
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=eyJ...your-anon-key...
MAPBOX_ACCESS_TOKEN=optional-for-future-use
```

### For Flutter Production Build:
The app will automatically use these environment variables.

## 4. Run Database Migrations

From your project root:

```bash
# Install Supabase CLI if not already installed
brew install supabase/tap/supabase

# Link to your production project
supabase link --project-ref your-project-id

# Push migrations to production
supabase db push
```

## 5. Verify Schema

Check that these tables exist in your production database:

- `lakes` - Lake information and thermocline data
- `attractors` - Fishing structure locations
- `trip_logs` - User fishing trip records
- `catches` - Individual fish catch records
- `weather_cache` (optional) - Cached weather data

## 6. Test Connection

1. Update `.env` with production values
2. Run the app: `flutter run`
3. Check logs for successful Supabase connection
4. Test creating a trip log to verify database write access

## 7. Production Build

For iOS/Android production builds:

```bash
# iOS
flutter build ios --release

# Android
flutter build appbundle --release
```

## Security Notes

- Never commit production keys to git
- Use different projects for development vs production  
- Consider enabling Row Level Security (RLS) for user data tables
- Set up proper backup schedules in Supabase dashboard

## Troubleshooting

### Connection Fails
- Verify URL format includes `https://`
- Check anon key is complete and unmodified
- Ensure project is active in Supabase dashboard

### Migration Errors
- Check local migrations match what you want in production
- Review migration files in `supabase/migrations/`
- Use `supabase db reset` locally to test migrations

### Performance
- Enable connection pooling for high traffic
- Consider upgrading to paid plan for production workloads
- Monitor database performance in Supabase dashboard