/*
  # Fix Infinite Recursion in Organization Members Policies

  1. Issue
    - organization_members RLS policies were causing infinite recursion
    - The subquery was comparing a column to itself in the WHERE clause

  2. Solution
    - Drop existing problematic policies on organization_members
    - Create simplified non-recursive policies
    - Policies now check membership without self-referential subqueries
*/

DO $$
BEGIN
  DROP POLICY IF EXISTS "Members can view org membership" ON organization_members;
  DROP POLICY IF EXISTS "Owners can manage members" ON organization_members;
  DROP POLICY IF EXISTS "Owners can remove members" ON organization_members;
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;

CREATE POLICY "Members can view org membership"
  ON organization_members FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Members can insert into org"
  ON organization_members FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());
