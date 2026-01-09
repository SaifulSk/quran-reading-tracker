/*
  # Add User-Specific Data Separation
  
  1. New Columns
    - Add `user_id` to readers table (track which user created/owns the reader)
    - Add `user_id` to assignments table (track which user created the assignment)
  
  2. Changes
    - Update RLS policies to filter data by user_id
    - Each user only sees their own readers and assignments
    - Chapters remain shared (all users see all chapters)
  
  3. Security
    - RLS policies now enforce user_id filtering
    - Users cannot access other users' readers or assignments
*/

-- Add user_id to readers
ALTER TABLE readers ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;

-- Add user_id to assignments
ALTER TABLE assignments ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;

-- Drop old readers policies
DROP POLICY IF EXISTS "Authenticated users can view all readers" ON readers;
DROP POLICY IF EXISTS "Authenticated users can insert readers" ON readers;
DROP POLICY IF EXISTS "Authenticated users can update readers" ON readers;
DROP POLICY IF EXISTS "Authenticated users can delete readers" ON readers;

-- Drop old assignments policies
DROP POLICY IF EXISTS "Authenticated users can view all assignments" ON assignments;
DROP POLICY IF EXISTS "Authenticated users can insert assignments" ON assignments;
DROP POLICY IF EXISTS "Authenticated users can update assignments" ON assignments;
DROP POLICY IF EXISTS "Authenticated users can delete assignments" ON assignments;

-- Create new readers policies (user-specific)
CREATE POLICY "Users can view their own readers"
  ON readers FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert their own readers"
  ON readers FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own readers"
  ON readers FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete their own readers"
  ON readers FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- Create new assignments policies (user-specific)
CREATE POLICY "Users can view their own assignments"
  ON assignments FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert their own assignments"
  ON assignments FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own assignments"
  ON assignments FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete their own assignments"
  ON assignments FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- Keep chapters policy as-is (shared across all users)
DROP POLICY IF EXISTS "Authenticated users can view all chapters" ON chapters;
DROP POLICY IF EXISTS "Authenticated users can insert chapters" ON chapters;
DROP POLICY IF EXISTS "Authenticated users can update chapters" ON chapters;
DROP POLICY IF EXISTS "Authenticated users can delete chapters" ON chapters;

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
