-- SlabHaul Migration 003: Add Lakes with Thermocline Metadata
-- Adds popular crappie lakes across the South with depth/area data for thermocline predictions

-- Update existing lakes with thermocline-relevant metadata
UPDATE public.lakes SET 
  max_depth_ft = 18,
  area_acres = 15000,
  mixing_type = 'polymictic'
WHERE id = 'reelfoot_lake_tn';

UPDATE public.lakes SET 
  max_depth_ft = 15,
  area_acres = 2400,
  mixing_type = 'polymictic'
WHERE id = 'horseshoe_lake_ar';

UPDATE public.lakes SET 
  max_depth_ft = 75,
  area_acres = 160300,
  mixing_type = 'monomictic'
WHERE id = 'kentucky_lake_tn';

-- Add new columns if not present
ALTER TABLE public.lakes ADD COLUMN IF NOT EXISTS max_depth_ft DECIMAL(5,1);
ALTER TABLE public.lakes ADD COLUMN IF NOT EXISTS area_acres DECIMAL(10,2);
ALTER TABLE public.lakes ADD COLUMN IF NOT EXISTS mixing_type TEXT;

-- ============================================================================
-- TENNESSEE / KENTUCKY TVA LAKES
-- ============================================================================
INSERT INTO public.lakes (id, name, state, center_lat, center_lon, zoom_level, normal_pool_elevation, usgs_gage_id, attractor_count, max_depth_ft, area_acres, mixing_type) VALUES
  ('pickwick_lake_tn', 'Pickwick Lake', 'TN/AL', 35.052, -88.250, 11.0, 414.0, '03592500', 0, 57, 43100, 'monomictic'),
  ('lake_barkley_ky', 'Lake Barkley', 'KY/TN', 36.831, -87.912, 11.0, 359.0, '03438220', 0, 60, 57920, 'monomictic'),
  ('wheeler_lake_al', 'Wheeler Lake', 'AL', 34.675, -87.350, 11.0, 556.3, '03575100', 0, 50, 67100, 'monomictic'),
  ('guntersville_lake_al', 'Guntersville Lake', 'AL', 34.417, -86.300, 11.0, 595.0, '03574500', 0, 55, 67900, 'monomictic'),
  ('chickamauga_lake_tn', 'Chickamauga Lake', 'TN', 35.250, -85.100, 11.0, 682.5, '03566500', 0, 52, 35400, 'monomictic'),
  ('watts_bar_lake_tn', 'Watts Bar Lake', 'TN', 35.700, -84.700, 11.0, 741.0, '03540500', 0, 70, 39000, 'monomictic')
ON CONFLICT (id) DO UPDATE SET
  max_depth_ft = EXCLUDED.max_depth_ft,
  area_acres = EXCLUDED.area_acres,
  mixing_type = EXCLUDED.mixing_type;

-- ============================================================================
-- MISSISSIPPI LAKES (Prime crappie country)
-- ============================================================================
INSERT INTO public.lakes (id, name, state, center_lat, center_lon, zoom_level, normal_pool_elevation, usgs_gage_id, attractor_count, max_depth_ft, area_acres, mixing_type) VALUES
  ('grenada_lake_ms', 'Grenada Lake', 'MS', 33.812, -89.748, 12.0, 212.0, '07285400', 0, 65, 35000, 'monomictic'),
  ('sardis_lake_ms', 'Sardis Lake', 'MS', 34.409, -89.785, 12.0, 264.0, '07277700', 0, 45, 32100, 'monomictic'),
  ('enid_lake_ms', 'Enid Lake', 'MS', 34.161, -89.883, 12.0, 233.0, '07277500', 0, 35, 28000, 'polymictic'),
  ('arkabutla_lake_ms', 'Arkabutla Lake', 'MS', 34.754, -90.123, 12.0, 212.0, '07268800', 0, 28, 12700, 'polymictic'),
  ('ross_barnett_ms', 'Ross Barnett Reservoir', 'MS', 32.450, -90.030, 12.0, 297.5, '02485600', 0, 35, 33000, 'polymictic')
ON CONFLICT (id) DO UPDATE SET
  max_depth_ft = EXCLUDED.max_depth_ft,
  area_acres = EXCLUDED.area_acres,
  mixing_type = EXCLUDED.mixing_type;

-- ============================================================================
-- ARKANSAS LAKES
-- ============================================================================
INSERT INTO public.lakes (id, name, state, center_lat, center_lon, zoom_level, normal_pool_elevation, usgs_gage_id, attractor_count, max_depth_ft, area_acres, mixing_type) VALUES
  ('beaver_lake_ar', 'Beaver Lake', 'AR', 36.350, -93.900, 11.0, 1120.0, '07048600', 0, 200, 28370, 'dimictic'),
  ('bull_shoals_ar', 'Bull Shoals Lake', 'AR', 36.400, -92.600, 11.0, 659.0, '07054500', 0, 200, 45440, 'dimictic'),
  ('lake_ouachita_ar', 'Lake Ouachita', 'AR', 34.550, -93.200, 11.0, 578.0, '07359610', 0, 180, 40100, 'dimictic'),
  ('millwood_lake_ar', 'Millwood Lake', 'AR', 33.733, -94.067, 12.0, 259.2, '07340000', 0, 25, 29500, 'polymictic'),
  ('lake_conway_ar', 'Lake Conway', 'AR', 35.100, -92.450, 13.0, 262.0, NULL, 0, 20, 6700, 'polymictic')
ON CONFLICT (id) DO UPDATE SET
  max_depth_ft = EXCLUDED.max_depth_ft,
  area_acres = EXCLUDED.area_acres,
  mixing_type = EXCLUDED.mixing_type;

-- ============================================================================
-- TEXAS LAKES
-- ============================================================================
INSERT INTO public.lakes (id, name, state, center_lat, center_lon, zoom_level, normal_pool_elevation, usgs_gage_id, attractor_count, max_depth_ft, area_acres, mixing_type) VALUES
  ('lake_fork_tx', 'Lake Fork', 'TX', 32.850, -95.550, 12.0, 403.0, '08020450', 0, 70, 27690, 'monomictic'),
  ('toledo_bend_tx', 'Toledo Bend', 'TX/LA', 31.400, -93.600, 11.0, 172.0, '08025500', 0, 110, 181600, 'monomictic'),
  ('sam_rayburn_tx', 'Sam Rayburn Reservoir', 'TX', 31.100, -94.100, 11.0, 164.4, '08039100', 0, 80, 114500, 'monomictic'),
  ('cedar_creek_tx', 'Cedar Creek Lake', 'TX', 32.150, -96.050, 12.0, 322.0, '08062700', 0, 45, 32623, 'monomictic'),
  ('richland_chambers_tx', 'Richland Chambers', 'TX', 31.950, -96.100, 12.0, 315.0, '08064100', 0, 50, 44752, 'monomictic')
ON CONFLICT (id) DO UPDATE SET
  max_depth_ft = EXCLUDED.max_depth_ft,
  area_acres = EXCLUDED.area_acres,
  mixing_type = EXCLUDED.mixing_type;

-- ============================================================================
-- OKLAHOMA / MISSOURI
-- ============================================================================
INSERT INTO public.lakes (id, name, state, center_lat, center_lon, zoom_level, normal_pool_elevation, usgs_gage_id, attractor_count, max_depth_ft, area_acres, mixing_type) VALUES
  ('grand_lake_ok', 'Grand Lake', 'OK', 36.600, -94.800, 11.0, 744.0, '07191000', 0, 140, 46500, 'dimictic'),
  ('lake_eufaula_ok', 'Lake Eufaula', 'OK', 35.300, -95.400, 11.0, 585.0, '07245000', 0, 87, 102200, 'monomictic'),
  ('table_rock_lake_mo', 'Table Rock Lake', 'MO', 36.600, -93.350, 11.0, 915.0, '07053810', 0, 200, 43100, 'dimictic'),
  ('truman_lake_mo', 'Truman Lake', 'MO', 38.250, -93.400, 11.0, 706.0, '06918070', 0, 90, 55600, 'monomictic'),
  ('lake_ozarks_mo', 'Lake of the Ozarks', 'MO', 38.150, -92.750, 10.0, 660.0, '06926000', 0, 130, 54000, 'monomictic')
ON CONFLICT (id) DO UPDATE SET
  max_depth_ft = EXCLUDED.max_depth_ft,
  area_acres = EXCLUDED.area_acres,
  mixing_type = EXCLUDED.mixing_type;

-- Index for efficient location queries
CREATE INDEX IF NOT EXISTS idx_lakes_location ON public.lakes(center_lat, center_lon);
CREATE INDEX IF NOT EXISTS idx_lakes_state ON public.lakes(state);

-- ============================================================================
-- MIXING TYPE REFERENCE
-- ============================================================================
-- monomictic: Mixes once per year (most southern reservoirs) - strong summer thermocline
-- dimictic: Mixes twice per year (spring/fall) - common in deeper northern lakes  
-- polymictic: Mixes frequently (shallow lakes) - may not develop stable thermocline

COMMENT ON COLUMN public.lakes.mixing_type IS 'Lake mixing classification: monomictic (1x/year), dimictic (2x/year), polymictic (frequent)';
COMMENT ON COLUMN public.lakes.max_depth_ft IS 'Maximum lake depth in feet at normal pool';
COMMENT ON COLUMN public.lakes.area_acres IS 'Lake surface area in acres at normal pool';
