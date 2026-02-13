-- SlabHaul Security Fixes
-- Resolves Supabase Security Advisor findings (08 Feb 2026)
--
-- Fixes:
--   ERROR  security_definer_view  - Drop unused SECURITY DEFINER view
--   ERROR  rls_disabled_in_public - spatial_ref_sys exposed (resolved by moving PostGIS)
--   WARN   extension_in_public    - Move PostGIS to extensions schema
--   WARN   function_search_path_mutable - Pin search_path on set_attractor_geom()
--
-- NOTE: auth_leaked_password_protection must be enabled in the Supabase Dashboard
--       under Authentication > Settings > Password Security.

BEGIN;

-- ============================================================================
-- 1. DROP user_waypoints_with_text VIEW
--    This SECURITY DEFINER view bypasses RLS by executing with the creator's
--    permissions rather than the querying user's. It is not used by the app.
-- ============================================================================
DROP VIEW IF EXISTS public.user_waypoints_with_text;

-- ============================================================================
-- 2. MOVE PostGIS TO extensions SCHEMA
--    This removes spatial_ref_sys and other PostGIS system tables from the
--    public schema, preventing them from being exposed via the PostgREST API.
--    This resolves both the extension_in_public warning AND the
--    rls_disabled_in_public error on spatial_ref_sys.
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS extensions;

GRANT USAGE ON SCHEMA extensions TO public;
GRANT USAGE ON SCHEMA extensions TO anon;
GRANT USAGE ON SCHEMA extensions TO authenticated;
GRANT USAGE ON SCHEMA extensions TO service_role;

ALTER EXTENSION postgis SET SCHEMA extensions;

-- ============================================================================
-- 3. FIX set_attractor_geom() FUNCTION — pin search_path
--    An unpinned search_path allows schema injection attacks. We pin it to
--    empty and use fully-qualified function references for PostGIS calls.
-- ============================================================================
CREATE OR REPLACE FUNCTION public.set_attractor_geom()
RETURNS TRIGGER
SECURITY INVOKER
SET search_path = ''
AS $$
BEGIN
  NEW.geom := extensions.st_setsrid(extensions.st_makepoint(NEW.longitude, NEW.latitude), 4326);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMIT;
