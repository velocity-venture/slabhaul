-- SlabHaul Initial Schema
-- Run in Supabase SQL Editor

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS postgis;

-- ============================================================================
-- LAKES TABLE
-- ============================================================================
CREATE TABLE public.lakes (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  state TEXT NOT NULL,
  center_lat DOUBLE PRECISION NOT NULL,
  center_lon DOUBLE PRECISION NOT NULL,
  zoom_level DOUBLE PRECISION DEFAULT 13.0,
  normal_pool_elevation DOUBLE PRECISION,
  usgs_gage_id TEXT,
  attractor_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- ATTRACTORS TABLE
-- ============================================================================
CREATE TABLE public.attractors (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  name TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  lake_id TEXT REFERENCES public.lakes(id) ON DELETE CASCADE,
  lake_name TEXT NOT NULL,
  state TEXT NOT NULL,
  type TEXT CHECK (type IN ('brush_pile', 'pvc_tree', 'stake_bed', 'pallet', 'unknown')) DEFAULT 'unknown',
  depth DOUBLE PRECISION,
  description TEXT,
  source TEXT,
  year_placed INTEGER,
  verified BOOLEAN DEFAULT false,
  geom GEOMETRY(POINT, 4326),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-populate geometry from lat/lon
CREATE OR REPLACE FUNCTION set_attractor_geom()
RETURNS TRIGGER AS $$
BEGIN
  NEW.geom := ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER attractor_geom_trigger
  BEFORE INSERT OR UPDATE ON public.attractors
  FOR EACH ROW EXECUTE FUNCTION set_attractor_geom();

-- Spatial index
CREATE INDEX idx_attractors_geom ON public.attractors USING GIST (geom);
CREATE INDEX idx_attractors_lake_id ON public.attractors(lake_id);
CREATE INDEX idx_attractors_type ON public.attractors(type);

-- ============================================================================
-- USER FAVORITES (future use)
-- ============================================================================
CREATE TABLE public.user_favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  attractor_id TEXT REFERENCES public.attractors(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, attractor_id)
);

-- ============================================================================
-- CALCULATOR PRESETS (future use)
-- ============================================================================
CREATE TABLE public.calculator_presets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  sinker_weight_oz DOUBLE PRECISION NOT NULL,
  line_out_ft DOUBLE PRECISION NOT NULL,
  boat_speed_mph DOUBLE PRECISION NOT NULL,
  line_drag_factor DOUBLE PRECISION DEFAULT 1.0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================
ALTER TABLE public.lakes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attractors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.calculator_presets ENABLE ROW LEVEL SECURITY;

-- Lakes: public read
CREATE POLICY "Lakes are publicly readable"
  ON public.lakes FOR SELECT USING (true);

-- Attractors: public read
CREATE POLICY "Attractors are publicly readable"
  ON public.attractors FOR SELECT USING (true);

-- Favorites: users manage their own
CREATE POLICY "Users can read their favorites"
  ON public.user_favorites FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their favorites"
  ON public.user_favorites FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete their favorites"
  ON public.user_favorites FOR DELETE USING (auth.uid() = user_id);

-- Presets: users manage their own
CREATE POLICY "Users can manage their presets"
  ON public.calculator_presets FOR ALL USING (auth.uid() = user_id);
