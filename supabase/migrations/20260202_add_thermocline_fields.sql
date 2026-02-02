-- Migration: Add thermocline prediction support fields to lakes table
-- Date: 2026-02-02
-- Description: Adds max_depth_ft, surface_area_acres, and mixing_type columns 
--              for thermocline depth prediction calculations

-- Add new columns to lakes table
ALTER TABLE lakes 
  ADD COLUMN IF NOT EXISTS max_depth_ft DECIMAL(5,1),
  ADD COLUMN IF NOT EXISTS mixing_type TEXT CHECK (mixing_type IN ('monomictic', 'dimictic', 'polymictic'));

-- Note: area_acres may already exist - this handles the case where it doesn't
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'lakes' AND column_name = 'area_acres'
  ) THEN
    ALTER TABLE lakes ADD COLUMN area_acres DECIMAL(10,2);
  END IF;
END $$;

-- Add index for location-based queries (thermocline varies by latitude)
CREATE INDEX IF NOT EXISTS idx_lakes_location ON lakes(center_lat, center_lon);

-- Optional: Create thermocline predictions cache table
-- Uncomment if you want to store historical predictions
/*
CREATE TABLE IF NOT EXISTS thermocline_predictions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lake_id TEXT NOT NULL REFERENCES lakes(id) ON DELETE CASCADE,
  predicted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  surface_temp_f DECIMAL(4,1),
  thermocline_top_ft DECIMAL(4,1),
  thermocline_bottom_ft DECIMAL(4,1),
  target_min_ft DECIMAL(4,1),
  target_max_ft DECIMAL(4,1),
  confidence DECIMAL(3,2),
  status TEXT,
  factors JSONB
);

-- Index for efficient lake + time queries
CREATE INDEX idx_thermo_lake_time ON thermocline_predictions(lake_id, predicted_at DESC);

-- Automatically clean up old predictions (older than 30 days)
CREATE OR REPLACE FUNCTION cleanup_old_thermocline_predictions()
RETURNS trigger AS $$
BEGIN
  DELETE FROM thermocline_predictions 
  WHERE predicted_at < NOW() - INTERVAL '30 days';
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cleanup_thermocline_trigger
  AFTER INSERT ON thermocline_predictions
  FOR EACH STATEMENT
  EXECUTE FUNCTION cleanup_old_thermocline_predictions();
*/

-- Seed data for common crappie lakes with thermocline-relevant metadata
-- These values are approximate and should be verified/updated with actual lake data

INSERT INTO lakes (id, name, state, center_lat, center_lon, max_depth_ft, area_acres, mixing_type)
VALUES
  ('grenada', 'Grenada Lake', 'MS', 33.8117, -89.7478, 65, 35000, 'monomictic'),
  ('sardis', 'Sardis Lake', 'MS', 34.4092, -89.7853, 45, 32100, 'monomictic'),
  ('enid', 'Enid Lake', 'MS', 34.1608, -89.8833, 35, 28000, 'polymictic'),
  ('arkabutla', 'Arkabutla Lake', 'MS', 34.7544, -90.1225, 28, 12700, 'polymictic'),
  ('pickwick', 'Pickwick Lake', 'TN', 34.9461, -88.2639, 57, 43100, 'monomictic'),
  ('kentucky', 'Kentucky Lake', 'TN', 36.5, -88.1, 75, 160300, 'dimictic'),
  ('barkley', 'Lake Barkley', 'KY', 36.8, -88.0, 60, 57920, 'dimictic'),
  ('weiss', 'Weiss Lake', 'AL', 34.1339, -85.7917, 35, 30200, 'polymictic'),
  ('guntersville', 'Guntersville Lake', 'AL', 34.35, -86.3, 60, 67900, 'monomictic'),
  ('ross_barnett', 'Ross Barnett Reservoir', 'MS', 32.4369, -90.0339, 35, 33000, 'polymictic'),
  ('millwood', 'Millwood Lake', 'AR', 33.7, -94.05, 45, 29500, 'monomictic'),
  ('lake_fork', 'Lake Fork', 'TX', 32.7667, -95.5833, 70, 27690, 'monomictic'),
  ('sam_rayburn', 'Sam Rayburn Reservoir', 'TX', 31.0667, -94.1, 80, 114500, 'monomictic'),
  ('toledo_bend', 'Toledo Bend', 'TX', 31.2, -93.6, 110, 181600, 'dimictic'),
  ('reelfoot', 'Reelfoot Lake', 'TN', 36.4167, -89.4167, 18, 15000, 'polymictic')
ON CONFLICT (id) DO UPDATE SET
  max_depth_ft = EXCLUDED.max_depth_ft,
  area_acres = EXCLUDED.area_acres,
  mixing_type = EXCLUDED.mixing_type;

COMMENT ON COLUMN lakes.max_depth_ft IS 'Maximum lake depth in feet - used for thermocline depth prediction';
COMMENT ON COLUMN lakes.area_acres IS 'Lake surface area in acres - affects wind mixing calculations';
COMMENT ON COLUMN lakes.mixing_type IS 'Lake mixing classification: monomictic (1 turnover/year), dimictic (2), polymictic (frequent)';
