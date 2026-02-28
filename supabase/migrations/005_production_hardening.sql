-- SlabHaul Production Hardening Migration
-- Adds: hotspots table, missing RLS policies, indexes, CHECK constraints, seed data

-- ============================================================================
-- 1. HOTSPOTS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.hotspots (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  lake_id TEXT REFERENCES public.lakes(id) ON DELETE CASCADE,
  lake_name TEXT NOT NULL,
  structure_type TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  min_depth_ft DOUBLE PRECISION NOT NULL CHECK (min_depth_ft >= 0),
  max_depth_ft DOUBLE PRECISION NOT NULL CHECK (max_depth_ft >= 0),
  best_seasons TEXT[] DEFAULT '{}',
  techniques TEXT[] DEFAULT '{}',
  ideal_conditions JSONB DEFAULT '{}',
  notes TEXT,
  confidence_score INTEGER CHECK (confidence_score BETWEEN 0 AND 100),
  geom GEOMETRY(POINT, 4326),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT chk_hotspot_depth_order CHECK (max_depth_ft >= min_depth_ft)
);

-- PostGIS trigger for automatic geometry
CREATE OR REPLACE FUNCTION set_hotspot_geom()
RETURNS TRIGGER AS $$
BEGIN
  NEW.geom := ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER hotspot_geom_trigger
  BEFORE INSERT OR UPDATE ON public.hotspots
  FOR EACH ROW EXECUTE FUNCTION set_hotspot_geom();

-- Indexes
CREATE INDEX idx_hotspots_lake_id ON public.hotspots(lake_id);
CREATE INDEX idx_hotspots_geom ON public.hotspots USING GIST(geom);
CREATE INDEX idx_hotspots_structure ON public.hotspots(structure_type);

-- RLS
ALTER TABLE public.hotspots ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Hotspots are publicly readable"
  ON public.hotspots FOR SELECT
  USING (true);

-- ============================================================================
-- 2. MISSING RLS POLICIES
-- ============================================================================

-- Users can delete their own bait reports
CREATE POLICY "Users can delete their own reports"
  ON public.bait_reports FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- 3. MISSING INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_bait_reports_user_id
  ON public.bait_reports(user_id);

CREATE INDEX IF NOT EXISTS idx_attractors_verified
  ON public.attractors(verified);

CREATE INDEX IF NOT EXISTS idx_bait_reports_multi
  ON public.bait_reports(bait_id, lake_id, report_date);

-- ============================================================================
-- 4. CHECK CONSTRAINTS ON EXISTING TABLES
-- ============================================================================

-- Attractor depth must be non-negative
ALTER TABLE public.attractors
  ADD CONSTRAINT chk_attractor_depth_positive
  CHECK (depth IS NULL OR depth >= 0);

-- Bait report sanity constraints
ALTER TABLE public.bait_reports
  ADD CONSTRAINT chk_report_fish_caught_positive
  CHECK (fish_caught >= 0);

ALTER TABLE public.bait_reports
  ADD CONSTRAINT chk_report_water_temp_range
  CHECK (water_temp IS NULL OR water_temp BETWEEN 20 AND 110);

ALTER TABLE public.bait_reports
  ADD CONSTRAINT chk_report_depth_positive
  CHECK (depth_fished IS NULL OR depth_fished >= 0);

ALTER TABLE public.bait_reports
  ADD CONSTRAINT chk_report_fish_length_positive
  CHECK (largest_fish_length IS NULL OR largest_fish_length >= 0);

ALTER TABLE public.bait_reports
  ADD CONSTRAINT chk_report_fish_weight_positive
  CHECK (largest_fish_weight IS NULL OR largest_fish_weight >= 0);

-- ============================================================================
-- 5. SEED HOTSPOTS DATA (19 hotspots across 3 lakes)
-- ============================================================================

INSERT INTO public.hotspots (id, name, latitude, longitude, lake_id, lake_name, structure_type, description, min_depth_ft, max_depth_ft, best_seasons, techniques, ideal_conditions, notes, confidence_score)
VALUES
  -- Horseshoe Lake, AR (5 hotspots)
  (
    'horseshoe_cypress_flats',
    'North Cypress Flats',
    34.945, -90.342,
    'horseshoe_lake_ar', 'Horseshoe Lake',
    'flat',
    'Shallow cypress flats ideal for spring spawn. Fish stage here as water warms into the 55-65°F range.',
    2, 6,
    ARRAY['pre_spawn', 'spawn'],
    ARRAY['slip_float', 'tight_lining', 'shooting_docks'],
    '{"min_water_temp_f": 55, "max_water_temp_f": 68, "water_level_trend": "stable", "time_of_day": "early_morning"}'::jsonb,
    'Look for active beds around cypress knees. Fish extremely shallow during active spawn.',
    85
  ),
  (
    'horseshoe_bridge_complex',
    'Highway 77 Bridge',
    34.932, -90.348,
    'horseshoe_lake_ar', 'Horseshoe Lake',
    'bridge_piling',
    'Deep pilings provide year-round holding structure. Crappie suspend at various depths depending on season.',
    8, 18,
    ARRAY['summer', 'fall', 'winter'],
    ARRAY['vertical_jigging', 'spider_rigging', 'tight_lining'],
    '{"min_water_temp_f": 45, "max_water_temp_f": 78, "max_wind_mph": 15}'::jsonb,
    'Work pilings systematically with electronics. Fish often suspend 8-12ft regardless of bottom depth.',
    90
  ),
  (
    'horseshoe_channel_ledge',
    'Old River Channel',
    34.928, -90.355,
    'horseshoe_lake_ar', 'Horseshoe Lake',
    'ledge',
    'The old river channel creates a defined ledge where crappie stage during transition periods.',
    10, 18,
    ARRAY['post_spawn', 'fall'],
    ARRAY['spider_rigging', 'trolling', 'vertical_jigging'],
    '{"min_water_temp_f": 65, "max_water_temp_f": 80, "pressure_trend": "falling"}'::jsonb,
    'Follow the channel edge with spider rigs. Post-spawn fish stack up here before moving deep.',
    80
  ),
  (
    'horseshoe_brush_complex_south',
    'South Shore Brush Piles',
    34.918, -90.362,
    'horseshoe_lake_ar', 'Horseshoe Lake',
    'brush_pile',
    'AGFC brush pile complex with multiple structures in 8-14ft. Consistent producer year-round.',
    8, 14,
    ARRAY['summer', 'fall', 'winter'],
    ARRAY['vertical_jigging', 'tight_lining'],
    '{"min_water_temp_f": 50, "max_water_temp_f": 85, "max_wind_mph": 20}'::jsonb,
    'Multiple brush piles within casting distance. Work each one before moving.',
    88
  ),
  (
    'horseshoe_marina_docks',
    'Horseshoe Lake Marina',
    34.930, -90.340,
    'horseshoe_lake_ar', 'Horseshoe Lake',
    'dock',
    'Marina docks with deep water access nearby. Crappie use dock shade and structure year-round.',
    4, 12,
    ARRAY['summer', 'fall'],
    ARRAY['shooting_docks', 'vertical_jigging', 'casting'],
    '{"min_water_temp_f": 70, "max_water_temp_f": 90, "time_of_day": "midday", "min_cloud_cover": 0, "max_cloud_cover": 30}'::jsonb,
    'Best on sunny days when fish seek shade. Shoot small jigs under walkways.',
    75
  ),

  -- Reelfoot Lake, TN (6 hotspots)
  (
    'reelfoot_grassy_flats',
    'South End Grassy Flats',
    36.340, -89.405,
    'reelfoot_lake_tn', 'Reelfoot Lake',
    'flat',
    'Legendary spawning grounds. Massive crappie move shallow when water hits 58-62°F.',
    2, 5,
    ARRAY['pre_spawn', 'spawn'],
    ARRAY['slip_float', 'tight_lining', 'casting'],
    '{"min_water_temp_f": 55, "max_water_temp_f": 65, "water_level_trend": "stable", "time_of_day": "early_morning"}'::jsonb,
    'Fish can be in 18 inches of water during peak spawn. Approach quietly.',
    95
  ),
  (
    'reelfoot_stumps_west',
    'West Basin Stump Fields',
    36.395, -89.410,
    'reelfoot_lake_tn', 'Reelfoot Lake',
    'timber',
    'Vast stump fields from the 1811 earthquake. Fish relate to vertical structure year-round.',
    3, 8,
    ARRAY['post_spawn', 'summer', 'fall'],
    ARRAY['tight_lining', 'vertical_jigging', 'slip_float'],
    '{"min_water_temp_f": 60, "max_water_temp_f": 85}'::jsonb,
    'Stay tight to stumps. Fish often suspend just off the wood.',
    90
  ),
  (
    'reelfoot_bayou_point',
    'Bayou du Chien Point',
    36.415, -89.375,
    'reelfoot_lake_tn', 'Reelfoot Lake',
    'point',
    'Deep point where the bayou enters. Current and depth changes attract baitfish.',
    5, 12,
    ARRAY['summer', 'fall', 'winter'],
    ARRAY['spider_rigging', 'vertical_jigging', 'trolling'],
    '{"min_water_temp_f": 48, "max_water_temp_f": 75, "water_level_trend": "rising"}'::jsonb,
    'Rising water pushes fresh oxygen and baitfish. Fish stack on the point during fall.',
    85
  ),
  (
    'reelfoot_cypress_row',
    'North Cypress Row',
    36.425, -89.395,
    'reelfoot_lake_tn', 'Reelfoot Lake',
    'timber',
    'Line of ancient cypress trees creating a travel corridor for crappie.',
    4, 10,
    ARRAY['pre_spawn', 'post_spawn', 'fall'],
    ARRAY['slip_float', 'tight_lining', 'casting'],
    '{"min_water_temp_f": 52, "max_water_temp_f": 72, "pressure_trend": "falling"}'::jsonb,
    'Fish the edges of cypress bases. Crappie use these as staging areas before and after spawn.',
    88
  ),
  (
    'reelfoot_air_park',
    'Air Park Boat Lane',
    36.380, -89.365,
    'reelfoot_lake_tn', 'Reelfoot Lake',
    'creek_channel',
    'Dredged boat lane creates deeper channel through shallow flats. Winter concentration point.',
    6, 12,
    ARRAY['winter', 'fall'],
    ARRAY['vertical_jigging', 'spider_rigging', 'tight_lining'],
    '{"min_water_temp_f": 40, "max_water_temp_f": 55, "time_of_day": "midday"}'::jsonb,
    'Winter crappie stack in the channel. Slow vertical presentation is key in cold water.',
    82
  ),

  -- Kentucky Lake, TN/KY (8 hotspots)
  (
    'kentucky_blood_river',
    'Blood River Mouth',
    36.580, -88.230,
    'kentucky_lake_tn', 'Kentucky Lake',
    'creek_channel',
    'Major tributary creek channel. Fish stage here during seasonal transitions.',
    15, 35,
    ARRAY['pre_spawn', 'post_spawn', 'fall'],
    ARRAY['spider_rigging', 'trolling', 'long_lining'],
    '{"min_water_temp_f": 50, "max_water_temp_f": 70, "water_level_trend": "stable"}'::jsonb,
    'Follow the channel swing with spider rigs. Fish the 18-25ft depth zone during transitions.',
    92
  ),
  (
    'kentucky_paris_landing',
    'Paris Landing State Park',
    36.520, -88.110,
    'kentucky_lake_tn', 'Kentucky Lake',
    'point',
    'Main lake point with adjacent marina and brush piles. Multi-season producer.',
    8, 25,
    ARRAY['summer', 'fall', 'winter'],
    ARRAY['vertical_jigging', 'spider_rigging', 'casting'],
    '{"min_water_temp_f": 55, "max_water_temp_f": 80, "max_wind_mph": 18}'::jsonb,
    'Work the point from 12-20ft. Brush piles on the flat hold fish year-round.',
    85
  ),
  (
    'kentucky_big_sandy_ledge',
    'Big Sandy Channel Ledge',
    36.450, -88.050,
    'kentucky_lake_tn', 'Kentucky Lake',
    'ledge',
    'Sharp channel ledge dropping from 15 to 35ft. Summer thermocline often sets up here.',
    15, 35,
    ARRAY['summer', 'fall'],
    ARRAY['spider_rigging', 'vertical_jigging', 'trolling'],
    '{"min_water_temp_f": 70, "max_water_temp_f": 85, "time_of_day": "early_morning"}'::jsonb,
    'Fish just above the thermocline. Early morning bite before fish move deep.',
    88
  ),
  (
    'kentucky_bridge_78',
    'Highway 78 Bridge',
    36.680, -88.150,
    'kentucky_lake_tn', 'Kentucky Lake',
    'bridge_piling',
    'Main lake bridge with deep pilings. Night fishing under lights produces big slabs.',
    20, 45,
    ARRAY['summer', 'winter'],
    ARRAY['vertical_jigging', 'tight_lining'],
    '{"min_water_temp_f": 55, "max_water_temp_f": 85, "time_of_day": "night"}'::jsonb,
    'Night fishing is productive all summer. Fish suspend 15-25ft around lit pilings.',
    80
  ),
  (
    'kentucky_new_johnsonville',
    'New Johnsonville Flats',
    36.025, -87.980,
    'kentucky_lake_tn', 'Kentucky Lake',
    'flat',
    'Extensive shallow flats protected from main lake wind. Prime spawning habitat.',
    3, 10,
    ARRAY['pre_spawn', 'spawn'],
    ARRAY['slip_float', 'casting', 'tight_lining'],
    '{"min_water_temp_f": 55, "max_water_temp_f": 68, "water_level_trend": "stable", "max_wind_mph": 12, "time_of_day": "early_morning"}'::jsonb,
    'Protected from south wind. Fish push into 4-6ft during spawn.',
    90
  ),
  (
    'kentucky_brush_complex_12',
    'Mile Marker 12 Brush',
    36.715, -88.095,
    'kentucky_lake_tn', 'Kentucky Lake',
    'brush_pile',
    'TWRA brush pile complex at consistent 18-22ft. Reliable year-round structure.',
    18, 22,
    ARRAY['summer', 'fall', 'winter'],
    ARRAY['vertical_jigging', 'spider_rigging'],
    '{"min_water_temp_f": 50, "max_water_temp_f": 82, "pressure_trend": "stable"}'::jsonb,
    'Multiple piles within 200 yards. Work methodically with electronics.',
    87
  ),
  (
    'kentucky_ledbetter_bay',
    'Ledbetter Bay Stumps',
    36.820, -88.280,
    'kentucky_lake_tn', 'Kentucky Lake',
    'timber',
    'Submerged timber field in the upper bay. Fish hold tight to wood in 10-18ft.',
    10, 18,
    ARRAY['fall', 'winter', 'pre_spawn'],
    ARRAY['tight_lining', 'vertical_jigging', 'slip_float'],
    '{"min_water_temp_f": 45, "max_water_temp_f": 65, "pressure_trend": "falling"}'::jsonb,
    'Cold water concentration point. Fish pull tight to stumps when temps drop.',
    83
  )
ON CONFLICT (id) DO NOTHING;
