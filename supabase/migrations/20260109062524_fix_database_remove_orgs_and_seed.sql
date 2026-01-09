/*
  # Fix Database Schema and Seed Chapters
  
  1. Changes
    - Drop all existing RLS policies
    - Remove organization_id from all tables
    - Drop organization-related tables
    - Create simple RLS policies for authenticated users
    - Seed chapters table with 30 Juz
  
  2. Security
    - All authenticated users can access all data
    - Simple single-tenant approach
*/

-- Drop all existing policies
DROP POLICY IF EXISTS "Users view readers in their orgs" ON readers;
DROP POLICY IF EXISTS "Users create readers in their orgs" ON readers;
DROP POLICY IF EXISTS "Users update readers in their orgs" ON readers;
DROP POLICY IF EXISTS "Users delete readers in their orgs" ON readers;

DROP POLICY IF EXISTS "Public read access to chapters" ON chapters;
DROP POLICY IF EXISTS "Users view chapters in their orgs" ON chapters;
DROP POLICY IF EXISTS "Users create chapters in their orgs" ON chapters;
DROP POLICY IF EXISTS "Users update chapters in their orgs" ON chapters;
DROP POLICY IF EXISTS "Users delete chapters in their orgs" ON chapters;

DROP POLICY IF EXISTS "Users view assignments in their orgs" ON assignments;
DROP POLICY IF EXISTS "Users create assignments in their orgs" ON assignments;
DROP POLICY IF EXISTS "Users update assignments in their orgs" ON assignments;
DROP POLICY IF EXISTS "Users delete assignments in their orgs" ON assignments;

DROP POLICY IF EXISTS "Users can view their organizations" ON organizations;
DROP POLICY IF EXISTS "Users can create organizations" ON organizations;
DROP POLICY IF EXISTS "Organization admins can update" ON organizations;

DROP POLICY IF EXISTS "Users can view their own memberships" ON organization_members;
DROP POLICY IF EXISTS "Users can insert their own memberships" ON organization_members;

-- Drop organization-related foreign key constraints
ALTER TABLE IF EXISTS readers DROP CONSTRAINT IF EXISTS readers_organization_id_fkey CASCADE;
ALTER TABLE IF EXISTS chapters DROP CONSTRAINT IF EXISTS chapters_organization_id_fkey CASCADE;
ALTER TABLE IF EXISTS assignments DROP CONSTRAINT IF EXISTS assignments_organization_id_fkey CASCADE;

-- Drop organization_id columns
ALTER TABLE IF EXISTS readers DROP COLUMN IF EXISTS organization_id CASCADE;
ALTER TABLE IF EXISTS chapters DROP COLUMN IF EXISTS organization_id CASCADE;
ALTER TABLE IF EXISTS assignments DROP COLUMN IF EXISTS organization_id CASCADE;

-- Drop organization tables
DROP TABLE IF EXISTS organization_members CASCADE;
DROP TABLE IF EXISTS organizations CASCADE;

-- Create simple RLS policies for readers
CREATE POLICY "Authenticated users can view all readers"
  ON readers FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert readers"
  ON readers FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update readers"
  ON readers FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete readers"
  ON readers FOR DELETE
  TO authenticated
  USING (true);

-- Create simple RLS policies for chapters
CREATE POLICY "Authenticated users can view all chapters"
  ON chapters FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert chapters"
  ON chapters FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update chapters"
  ON chapters FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete chapters"
  ON chapters FOR DELETE
  TO authenticated
  USING (true);

-- Create simple RLS policies for assignments
CREATE POLICY "Authenticated users can view all assignments"
  ON assignments FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert assignments"
  ON assignments FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update assignments"
  ON assignments FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete assignments"
  ON assignments FOR DELETE
  TO authenticated
  USING (true);

-- Clear existing chapters and seed with 30 Juz
TRUNCATE chapters CASCADE;

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
  (30, 'Juz 30');
