-- SlabHaul Seed Data
-- Run in Supabase SQL Editor after 001_initial_schema.sql

-- ============================================================================
-- LAKES
-- ============================================================================
INSERT INTO public.lakes (id, name, state, center_lat, center_lon, zoom_level, normal_pool_elevation, usgs_gage_id, attractor_count) VALUES
  ('horseshoe_lake_ar', 'Horseshoe Lake', 'AR', 34.932, -90.350, 14.0, 196.0, '07047970', 10),
  ('reelfoot_lake_tn', 'Reelfoot Lake', 'TN', 36.387, -89.387, 13.0, 282.2, '07025400', 10),
  ('kentucky_lake_tn', 'Kentucky Lake', 'TN/KY', 36.620, -88.080, 11.0, 359.0, '03609750', 10);

-- ============================================================================
-- HORSESHOE LAKE ATTRACTORS (from AGFC GPX data)
-- ============================================================================
INSERT INTO public.attractors (id, name, latitude, longitude, lake_id, lake_name, state, type, depth, source, year_placed, verified) VALUES
  ('HRS22001', 'Horseshoe N Brush #1',        34.929398, -90.357797, 'horseshoe_lake_ar', 'Horseshoe Lake', 'AR', 'brush_pile', 12.0, 'AGFC', 2022, true),
  ('HRS22002', 'Horseshoe S Channel Brush',   34.922676, -90.366860, 'horseshoe_lake_ar', 'Horseshoe Lake', 'AR', 'brush_pile', 14.0, 'AGFC', 2022, true),
  ('HRS22003', 'Horseshoe Main Basin #1',     34.931767, -90.355678, 'horseshoe_lake_ar', 'Horseshoe Lake', 'AR', 'brush_pile', 10.0, 'AGFC', 2022, true),
  ('HRS22004', 'Horseshoe Main Basin #2',     34.933167, -90.354321, 'horseshoe_lake_ar', 'Horseshoe Lake', 'AR', 'brush_pile', 11.0, 'AGFC', 2022, true),
  ('HRS22005', 'Horseshoe NE Point Brush',    34.935855, -90.349700, 'horseshoe_lake_ar', 'Horseshoe Lake', 'AR', 'brush_pile',  8.0, 'AGFC', 2022, true),
  ('HRS23001', 'Horseshoe N Arm Stake Bed',   34.941028, -90.346573, 'horseshoe_lake_ar', 'Horseshoe Lake', 'AR', 'stake_bed',   6.0, 'AGFC', 2023, true),
  ('HRS23002', 'Horseshoe N Arm PVC',         34.941030, -90.344424, 'horseshoe_lake_ar', 'Horseshoe Lake', 'AR', 'pvc_tree',    7.0, 'AGFC', 2023, true),
  ('HRS23003', 'Horseshoe E Channel Brush',   34.940808, -90.338827, 'horseshoe_lake_ar', 'Horseshoe Lake', 'AR', 'brush_pile', 13.0, 'AGFC', 2023, true),
  ('HRS23004', 'Horseshoe E Point Stake Bed', 34.940438, -90.337273, 'horseshoe_lake_ar', 'Horseshoe Lake', 'AR', 'stake_bed',   9.0, 'AGFC', 2023, true),
  ('HRS23005', 'Horseshoe SE Flat Pallet',    34.936680, -90.329503, 'horseshoe_lake_ar', 'Horseshoe Lake', 'AR', 'pallet',      5.0, 'AGFC', 2023, true);

-- ============================================================================
-- REELFOOT LAKE ATTRACTORS (TWRA data)
-- ============================================================================
INSERT INTO public.attractors (id, name, latitude, longitude, lake_id, lake_name, state, type, depth, source, year_placed, verified) VALUES
  ('RFT001', 'Lower Blue Basin Brush #1',    36.3485, -89.4021, 'reelfoot_lake_tn', 'Reelfoot Lake', 'TN', 'brush_pile',  8.0, 'TWRA', 2023, true),
  ('RFT002', 'Lower Blue Basin Stake Bed',   36.3512, -89.3987, 'reelfoot_lake_tn', 'Reelfoot Lake', 'TN', 'stake_bed',   6.5, 'TWRA', 2023, true),
  ('RFT003', 'Swan Basin PVC Trees',         36.3725, -89.3615, 'reelfoot_lake_tn', 'Reelfoot Lake', 'TN', 'pvc_tree',    7.0, 'TWRA', 2022, true),
  ('RFT004', 'Swan Basin Deep Brush',        36.3698, -89.3582, 'reelfoot_lake_tn', 'Reelfoot Lake', 'TN', 'brush_pile', 10.0, 'TWRA', 2022, true),
  ('RFT005', 'Moultrie Field Brush Line',    36.3915, -89.4185, 'reelfoot_lake_tn', 'Reelfoot Lake', 'TN', 'brush_pile',  9.0, 'TWRA', 2024, true),
  ('RFT006', 'Moultrie Pallet Reef',         36.3942, -89.4210, 'reelfoot_lake_tn', 'Reelfoot Lake', 'TN', 'pallet',      6.0, 'TWRA', 2024, true),
  ('RFT007', 'Samburg Channel Brush',        36.3835, -89.3742, 'reelfoot_lake_tn', 'Reelfoot Lake', 'TN', 'brush_pile', 12.0, 'TWRA', 2023, true),
  ('RFT008', 'Upper Blue Basin Stake Bed',   36.4015, -89.3895, 'reelfoot_lake_tn', 'Reelfoot Lake', 'TN', 'stake_bed',   5.5, 'TWRA', 2024, true),
  ('RFT009', 'Indian Creek Mouth Brush',     36.3568, -89.3825, 'reelfoot_lake_tn', 'Reelfoot Lake', 'TN', 'brush_pile', 11.0, 'TWRA', 2022, true),
  ('RFT010', 'Walnut Log PVC',               36.3655, -89.4092, 'reelfoot_lake_tn', 'Reelfoot Lake', 'TN', 'pvc_tree',    8.0, 'TWRA', 2023, true);

-- ============================================================================
-- KENTUCKY LAKE ATTRACTORS (KDFWR / TWRA data)
-- ============================================================================
INSERT INTO public.attractors (id, name, latitude, longitude, lake_id, lake_name, state, type, depth, source, year_placed, verified) VALUES
  ('KYL001', 'Jonathan Creek Brush #1',       36.8382, -88.1248, 'kentucky_lake_tn', 'Kentucky Lake', 'TN/KY', 'brush_pile', 18.0, 'KDFWR', 2023, true),
  ('KYL002', 'Jonathan Creek Deep Stake Bed', 36.8415, -88.1192, 'kentucky_lake_tn', 'Kentucky Lake', 'TN/KY', 'stake_bed',  22.0, 'KDFWR', 2023, true),
  ('KYL003', 'Blood River Channel Brush',     36.7805, -88.0815, 'kentucky_lake_tn', 'Kentucky Lake', 'TN/KY', 'brush_pile', 25.0, 'KDFWR', 2022, true),
  ('KYL004', 'Blood River PVC Forest',        36.7768, -88.0782, 'kentucky_lake_tn', 'Kentucky Lake', 'TN/KY', 'pvc_tree',   20.0, 'KDFWR', 2022, true),
  ('KYL005', 'Sledd Creek Mouth Brush',       36.9218, -88.2605, 'kentucky_lake_tn', 'Kentucky Lake', 'TN/KY', 'brush_pile', 15.0, 'TWRA',  2024, true),
  ('KYL006', 'Sledd Creek Pallet Reef',       36.9185, -88.2558, 'kentucky_lake_tn', 'Kentucky Lake', 'TN/KY', 'pallet',     12.0, 'TWRA',  2024, true),
  ('KYL007', 'Big Bear Creek Deep Brush',     36.8412, -88.1395, 'kentucky_lake_tn', 'Kentucky Lake', 'TN/KY', 'brush_pile', 30.0, 'KDFWR', 2023, true),
  ('KYL008', 'Big Bear Creek Stake Bed',      36.8445, -88.1428, 'kentucky_lake_tn', 'Kentucky Lake', 'TN/KY', 'stake_bed',  16.0, 'KDFWR', 2023, true),
  ('KYL009', 'Ledbetter Creek Brush Line',    36.8695, -88.1785, 'kentucky_lake_tn', 'Kentucky Lake', 'TN/KY', 'brush_pile', 20.0, 'KDFWR', 2024, true),
  ('KYL010', 'Cypress Creek PVC Trees',       36.7925, -88.0952, 'kentucky_lake_tn', 'Kentucky Lake', 'TN/KY', 'pvc_tree',   14.0, 'TWRA',  2024, true);
