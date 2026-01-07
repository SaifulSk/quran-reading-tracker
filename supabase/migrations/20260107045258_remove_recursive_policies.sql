/*
  # Remove all recursive and conflicting policies

  1. Issue
    - Multiple conflicting policies causing infinite recursion
    - Self-referential check in organization_members
    - Need to keep only simple allow-all policies
*/

DO $$
BEGIN
  DROP POLICY IF EXISTS "Users can insert memberships in their orgs" ON organization_members;
  DROP POLICY IF EXISTS "Users can view their memberships" ON organization_members;
  DROP POLICY IF EXISTS "Users can view org assignments" ON assignments;
  DROP POLICY IF EXISTS "Users can create assignments in their org" ON assignments;
  DROP POLICY IF EXISTS "Users can update assignments in their org" ON assignments;
  DROP POLICY IF EXISTS "Users can view org readers" ON readers;
  DROP POLICY IF EXISTS "Users can create readers in their org" ON readers;
  DROP POLICY IF EXISTS "Users can delete readers in their org" ON readers;
  DROP POLICY IF EXISTS "Users can view org chapters" ON chapters;
  DROP POLICY IF EXISTS "Allow public read access to readers" ON readers;
  DROP POLICY IF EXISTS "Allow public insert to readers" ON readers;
  DROP POLICY IF EXISTS "Allow public delete to readers" ON readers;
  DROP POLICY IF EXISTS "Allow public update to readers" ON readers;
  DROP POLICY IF EXISTS "Allow public read access to assignments" ON assignments;
  DROP POLICY IF EXISTS "Allow public insert to assignments" ON assignments;
  DROP POLICY IF EXISTS "Allow public delete to assignments" ON assignments;
  DROP POLICY IF EXISTS "Allow public update to assignments" ON assignments;
  DROP POLICY IF EXISTS "Allow public read access to chapters" ON chapters;
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;
