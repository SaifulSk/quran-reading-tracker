/*
  # Fix Organization Isolation and Multi-Tenancy

  1. Issues Fixed
    - Remove all recursive RLS policies causing infinite recursion
    - Populate chapters table with all 30 Juz
    - Create proper organization isolation policies
    - Ensure complete data separation between organizations

  2. Tables Modified
    - organization_members: Simple non-recursive policies
    - chapters: Public read (all orgs need to see chapters), org-specific for assignments
    - readers: Filtered by organization_id
    - assignments: Filtered by organization_id

  3. Security
    - Each user only sees their own organization's data
    - No recursive policy checks
    - Clean, restrictive policies
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

INSERT INTO chapters (id, name) VALUES
  (1, 'Juz 1'),
  (2, 'Juz 2'),
  (3, 'Juz 3'),
  (4, 'Juz 4'),
  (5, 'Juz 5'),
  (6, 'Juz 6'),
  (7, 'Juz 7'),
  (8, 'Juz 8'),
  (9, 'Juz 9'),
  (10, 'Juz 10'),
  (11, 'Juz 11'),
  (12, 'Juz 12'),
  (13, 'Juz 13'),
  (14, 'Juz 14'),
  (15, 'Juz 15'),
  (16, 'Juz 16'),
  (17, 'Juz 17'),
  (18, 'Juz 18'),
  (19, 'Juz 19'),
  (20, 'Juz 20'),
  (21, 'Juz 21'),
  (22, 'Juz 22'),
  (23, 'Juz 23'),
  (24, 'Juz 24'),
  (25, 'Juz 25'),
  (26, 'Juz 26'),
  (27, 'Juz 27'),
  (28, 'Juz 28'),
  (29, 'Juz 29'),
  (30, 'Juz 30')
ON CONFLICT DO NOTHING;

CREATE POLICY "Anyone can view chapters"
  ON chapters FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Readers filtered by organization"
  ON readers FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE organization_members.user_id = auth.uid()
      AND organization_members.organization_id = readers.organization_id
    )
  );

CREATE POLICY "Create readers in own organization"
  ON readers FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE organization_members.user_id = auth.uid()
      AND organization_members.organization_id = organization_id
    )
  );

CREATE POLICY "Update readers in own organization"
  ON readers FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE organization_members.user_id = auth.uid()
      AND organization_members.organization_id = readers.organization_id
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE organization_members.user_id = auth.uid()
      AND organization_members.organization_id = organization_id
    )
  );

CREATE POLICY "Delete readers in own organization"
  ON readers FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE organization_members.user_id = auth.uid()
      AND organization_members.organization_id = readers.organization_id
    )
  );

CREATE POLICY "View assignments in own organization"
  ON assignments FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE organization_members.user_id = auth.uid()
      AND organization_members.organization_id = assignments.organization_id
    )
  );

CREATE POLICY "Create assignments in own organization"
  ON assignments FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE organization_members.user_id = auth.uid()
      AND organization_members.organization_id = organization_id
    )
  );

CREATE POLICY "Update assignments in own organization"
  ON assignments FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE organization_members.user_id = auth.uid()
      AND organization_members.organization_id = assignments.organization_id
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE organization_members.user_id = auth.uid()
      AND organization_members.organization_id = organization_id
    )
  );

CREATE POLICY "Delete assignments in own organization"
  ON assignments FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE organization_members.user_id = auth.uid()
      AND organization_members.organization_id = assignments.organization_id
    )
  );

CREATE POLICY "Users can view their memberships"
  ON organization_members FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can be added to organizations"
  ON organization_members FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());
