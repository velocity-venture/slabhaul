-- SlabHaul Bait Database Schema
-- Professional-grade bait catalog with effectiveness tracking

-- ============================================================================
-- BAIT BRANDS TABLE
-- ============================================================================
CREATE TABLE public.bait_brands (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  logo_url TEXT,
  website TEXT,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- BAIT CATALOG TABLE
-- ============================================================================
CREATE TABLE public.baits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id UUID REFERENCES public.bait_brands(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  model_number TEXT,
  
  -- Primary categorization
  category TEXT NOT NULL CHECK (category IN ('jig', 'crankbait', 'soft_plastic', 'spoon', 'spinner', 'live_bait', 'other')),
  subcategory TEXT, -- hair_jig, tube_jig, swim_jig, deep_diving_crankbait, etc.
  
  -- Physical specifications
  available_colors TEXT[] DEFAULT '{}', -- ['chartreuse', 'white', 'pink', 'black']
  available_sizes TEXT[] DEFAULT '{}',  -- ['1/16oz', '1/8oz', '1/4oz']
  weight_range_min DOUBLE PRECISION, -- minimum weight in ounces
  weight_range_max DOUBLE PRECISION, -- maximum weight in ounces
  
  -- Media and documentation
  primary_image_url TEXT,
  additional_images TEXT[] DEFAULT '{}',
  product_description TEXT,
  manufacturer_notes TEXT,
  
  -- Metadata
  is_crappie_specific BOOLEAN DEFAULT true,
  is_verified BOOLEAN DEFAULT false, -- verified by SlabHaul team
  retail_price_usd DOUBLE PRECISION,
  availability_status TEXT CHECK (availability_status IN ('available', 'discontinued', 'seasonal')),
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- BAIT EFFECTIVENESS REPORTS
-- ============================================================================
CREATE TABLE public.bait_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bait_id UUID NOT NULL REFERENCES public.baits(id) ON DELETE CASCADE,
  lake_id TEXT REFERENCES public.lakes(id) ON DELETE SET NULL,
  attractor_id TEXT REFERENCES public.attractors(id) ON DELETE SET NULL,
  
  -- Location data
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  geom GEOMETRY(POINT, 4326),
  
  -- Bait specifics used
  color_used TEXT NOT NULL,
  size_used TEXT NOT NULL,
  weight_used DOUBLE PRECISION, -- actual weight in ounces
  
  -- Fishing results
  fish_caught INTEGER DEFAULT 0,
  fish_species TEXT DEFAULT 'crappie', -- white_crappie, black_crappie, bass, etc.
  largest_fish_length DOUBLE PRECISION, -- inches
  largest_fish_weight DOUBLE PRECISION, -- pounds
  
  -- Conditions
  water_temp DOUBLE PRECISION,
  water_clarity TEXT CHECK (water_clarity IN ('clear', 'stained', 'muddy')),
  weather_conditions TEXT,
  time_of_day TEXT CHECK (time_of_day IN ('dawn', 'morning', 'midday', 'afternoon', 'dusk', 'night')),
  season TEXT CHECK (season IN ('spring', 'summer', 'fall', 'winter')),
  
  -- Technique
  technique_used TEXT, -- trolling, casting, vertical_jigging, etc.
  depth_fished DOUBLE PRECISION, -- feet
  
  -- User attribution (optional - allow anonymous reports)
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  is_verified_catch BOOLEAN DEFAULT false, -- verified by photo/witness
  
  -- Report metadata
  report_date DATE NOT NULL DEFAULT CURRENT_DATE,
  confidence_score INTEGER CHECK (confidence_score BETWEEN 1 AND 5) DEFAULT 3,
  notes TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-populate geometry from lat/lon
CREATE OR REPLACE FUNCTION set_bait_report_geom()
RETURNS TRIGGER AS $$
BEGIN
  NEW.geom := ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER bait_report_geom_trigger
  BEFORE INSERT OR UPDATE ON public.bait_reports
  FOR EACH ROW EXECUTE FUNCTION set_bait_report_geom();

-- ============================================================================
-- BAIT EFFECTIVENESS SUMMARY VIEW
-- ============================================================================
CREATE VIEW public.bait_effectiveness AS
SELECT 
  b.id as bait_id,
  b.name as bait_name,
  bb.name as brand_name,
  b.category,
  br.color_used,
  br.size_used,
  COUNT(br.id) as total_reports,
  SUM(br.fish_caught) as total_fish,
  AVG(br.fish_caught) as avg_fish_per_trip,
  MAX(br.largest_fish_length) as biggest_fish_length,
  MAX(br.largest_fish_weight) as biggest_fish_weight,
  AVG(br.confidence_score) as avg_confidence,
  COUNT(DISTINCT br.lake_id) as lakes_reported
FROM public.baits b
LEFT JOIN public.bait_brands bb ON b.brand_id = bb.id
LEFT JOIN public.bait_reports br ON b.id = br.bait_id
GROUP BY b.id, b.name, bb.name, b.category, br.color_used, br.size_used;

-- ============================================================================
-- LOCATION-BASED BAIT RECOMMENDATIONS VIEW
-- ============================================================================
CREATE VIEW public.location_bait_recommendations AS
SELECT 
  br.lake_id,
  br.latitude,
  br.longitude,
  b.id as bait_id,
  b.name as bait_name,
  bb.name as brand_name,
  br.color_used,
  br.size_used,
  AVG(br.fish_caught) as avg_effectiveness,
  COUNT(br.id) as report_count,
  MAX(br.report_date) as most_recent_report
FROM public.bait_reports br
JOIN public.baits b ON br.bait_id = b.id
LEFT JOIN public.bait_brands bb ON b.brand_id = bb.id
WHERE br.fish_caught > 0
GROUP BY br.lake_id, br.latitude, br.longitude, b.id, b.name, bb.name, br.color_used, br.size_used
HAVING COUNT(br.id) >= 2 -- Only show baits with multiple successful reports
ORDER BY avg_effectiveness DESC;

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================
CREATE INDEX idx_baits_category ON public.baits(category);
CREATE INDEX idx_baits_brand_id ON public.baits(brand_id);
CREATE INDEX idx_baits_crappie_specific ON public.baits(is_crappie_specific) WHERE is_crappie_specific = true;

CREATE INDEX idx_bait_reports_geom ON public.bait_reports USING GIST (geom);
CREATE INDEX idx_bait_reports_bait_id ON public.bait_reports(bait_id);
CREATE INDEX idx_bait_reports_lake_id ON public.bait_reports(lake_id);
CREATE INDEX idx_bait_reports_date ON public.bait_reports(report_date);
CREATE INDEX idx_bait_reports_success ON public.bait_reports(fish_caught) WHERE fish_caught > 0;
CREATE INDEX idx_bait_reports_season ON public.bait_reports(season);

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================
ALTER TABLE public.bait_brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.baits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bait_reports ENABLE ROW LEVEL SECURITY;

-- Brands: public read, admin write
CREATE POLICY "Bait brands are publicly readable"
  ON public.bait_brands FOR SELECT USING (true);

-- Baits: public read, admin write  
CREATE POLICY "Baits are publicly readable"
  ON public.baits FOR SELECT USING (true);

-- Reports: public read, authenticated users can write
CREATE POLICY "Bait reports are publicly readable"
  ON public.bait_reports FOR SELECT USING (true);
CREATE POLICY "Authenticated users can submit bait reports"
  ON public.bait_reports FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Users can update their own reports"
  ON public.bait_reports FOR UPDATE USING (auth.uid() = user_id);

-- ============================================================================
-- SEED DATA - Popular Crappie Brands
-- ============================================================================
INSERT INTO public.bait_brands (name, description) VALUES 
('Strike King', 'Premium fishing lures and baits'),
('B''n''M Pole Company', 'Crappie-specific tackle and baits'),
('Rebel', 'Classic crankbaits and fishing lures'),
('Berkley', 'Innovative soft plastics and hard baits'),
('Bobby Garland', 'Crappie jigs and soft plastics'),
('Road Runner', 'Specialty jigs and spinners'),
('Blakemore', 'Road Runner jigs and crappie tackle'),
('Uncle Josh', 'Pork baits and trailers'),
('Kalin''s', 'Soft plastic grubs and jigs'),
('Custom Jigs & Spins', 'Hand-tied jigs and spoons');

-- ============================================================================
-- SAMPLE BAIT DATA - Core Crappie Baits
-- ============================================================================
WITH brand_ids AS (
  SELECT id, name FROM public.bait_brands 
)
INSERT INTO public.baits (brand_id, name, category, subcategory, available_colors, available_sizes, weight_range_min, weight_range_max, is_crappie_specific, product_description)
SELECT 
  b.id,
  'Hair Jig',
  'jig',
  'hair_jig',
  ARRAY['white', 'yellow', 'chartreuse', 'pink', 'black', 'orange'],
  ARRAY['1/32oz', '1/16oz', '1/8oz', '1/4oz'],
  0.03125,
  0.25,
  true,
  'Classic crappie hair jig with marabou feathers'
FROM brand_ids b WHERE b.name = 'Bobby Garland'

UNION ALL

SELECT 
  b.id,
  'Tube Jig',
  'soft_plastic',
  'tube_jig',  
  ARRAY['white', 'chartreuse', 'pink', 'smoke', 'clear'],
  ARRAY['1.5"', '2"', '2.5"'],
  0.0625,
  0.125,
  true,
  'Hollow tube soft plastic with built-in jig head'
FROM brand_ids b WHERE b.name = 'Bobby Garland'

UNION ALL

SELECT
  b.id,
  'Baby Shad',
  'crankbait', 
  'shallow_crankbait',
  ARRAY['shad', 'chartreuse_shad', 'silver', 'gold'],
  ARRAY['2"', '2.5"'],
  0.125,
  0.25,
  true,
  'Shallow diving crankbait perfect for crappie'
FROM brand_ids b WHERE b.name = 'Rebel';

-- ============================================================================
-- FUNCTIONS FOR BAIT RECOMMENDATIONS
-- ============================================================================

-- Function to get top baits for a specific location
CREATE OR REPLACE FUNCTION get_location_bait_recommendations(
  search_lat DOUBLE PRECISION,
  search_lon DOUBLE PRECISION,
  search_radius_miles DOUBLE PRECISION DEFAULT 5.0,
  limit_results INTEGER DEFAULT 10
)
RETURNS TABLE(
  bait_name TEXT,
  brand_name TEXT,
  color TEXT,
  size TEXT,
  effectiveness_score DOUBLE PRECISION,
  total_reports BIGINT,
  distance_miles DOUBLE PRECISION
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    b.name,
    bb.name,
    br.color_used,
    br.size_used,
    AVG(br.fish_caught) as effectiveness_score,
    COUNT(br.id) as total_reports,
    AVG(ST_Distance(
      ST_SetSRID(ST_MakePoint(search_lon, search_lat), 4326)::geography,
      br.geom::geography
    ) / 1609.344) as distance_miles
  FROM public.bait_reports br
  JOIN public.baits b ON br.bait_id = b.id
  LEFT JOIN public.bait_brands bb ON b.brand_id = bb.id
  WHERE ST_DWithin(
    ST_SetSRID(ST_MakePoint(search_lon, search_lat), 4326)::geography,
    br.geom::geography,
    search_radius_miles * 1609.344
  )
  AND br.fish_caught > 0
  GROUP BY b.name, bb.name, br.color_used, br.size_used
  HAVING COUNT(br.id) >= 2
  ORDER BY effectiveness_score DESC, total_reports DESC
  LIMIT limit_results;
END;
$$ LANGUAGE plpgsql;

-- Function to get seasonal bait recommendations
CREATE OR REPLACE FUNCTION get_seasonal_bait_recommendations(
  target_season TEXT,
  limit_results INTEGER DEFAULT 15
)
RETURNS TABLE(
  bait_name TEXT,
  brand_name TEXT,
  color TEXT,
  avg_effectiveness DOUBLE PRECISION,
  success_rate DOUBLE PRECISION
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    b.name,
    bb.name,
    br.color_used,
    AVG(br.fish_caught) as avg_effectiveness,
    (COUNT(CASE WHEN br.fish_caught > 0 THEN 1 END)::DOUBLE PRECISION / COUNT(*)::DOUBLE PRECISION) * 100 as success_rate
  FROM public.bait_reports br
  JOIN public.baits b ON br.bait_id = b.id
  LEFT JOIN public.bait_brands bb ON b.brand_id = bb.id
  WHERE br.season = target_season
  GROUP BY b.name, bb.name, br.color_used
  HAVING COUNT(br.id) >= 3
  ORDER BY success_rate DESC, avg_effectiveness DESC
  LIMIT limit_results;
END;
$$ LANGUAGE plpgsql;