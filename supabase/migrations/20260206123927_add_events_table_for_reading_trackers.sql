/*
  # Add Events Table for Multiple Reading Trackers
  
  1. New Tables
    - `events` - stores reading tracker events (e.g., "Ramadan 2024", "Weekly Group", etc)
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `name` (text - event name)
      - `description` (text, nullable - event description)
      - `created_at` (timestamp)
  
  2. Changes
    - Add `event_id` to readers table (foreign key to events)
    - Add `event_id` to assignments table (foreign key to events)
    - Update RLS policies to filter by event_id and user_id
  
  3. Security
    - Users can only see events they created
    - Users can only access readers and assignments for their events
    - Each event is isolated per user
*/

-- Create events table
CREATE TABLE IF NOT EXISTS events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS for events
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- Add event_id to readers
ALTER TABLE readers ADD COLUMN IF NOT EXISTS event_id uuid REFERENCES events(id) ON DELETE CASCADE;

-- Add event_id to assignments
ALTER TABLE assignments ADD COLUMN IF NOT EXISTS event_id uuid REFERENCES events(id) ON DELETE CASCADE;

-- Drop old reader policies
DROP POLICY IF EXISTS "Users can view their own readers" ON readers;
DROP POLICY IF EXISTS "Users can insert their own readers" ON readers;
DROP POLICY IF EXISTS "Users can update their own readers" ON readers;
DROP POLICY IF EXISTS "Users can delete their own readers" ON readers;

-- Drop old assignment policies
DROP POLICY IF EXISTS "Users can view their own assignments" ON assignments;
DROP POLICY IF EXISTS "Users can insert their own assignments" ON assignments;
DROP POLICY IF EXISTS "Users can update their own assignments" ON assignments;
DROP POLICY IF EXISTS "Users can delete their own assignments" ON assignments;

-- Create new readers policies (event-specific)
CREATE POLICY "Users can view readers in their events"
  ON readers FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM events
      WHERE events.id = readers.event_id
      AND events.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert readers in their events"
  ON readers FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM events
      WHERE events.id = event_id
      AND events.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update readers in their events"
  ON readers FOR UPDATE
  TO authenticated
  USING (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM events
      WHERE events.id = readers.event_id
      AND events.user_id = auth.uid()
    )
  )
  WITH CHECK (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM events
      WHERE events.id = event_id
      AND events.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete readers in their events"
  ON readers FOR DELETE
  TO authenticated
  USING (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM events
      WHERE events.id = readers.event_id
      AND events.user_id = auth.uid()
    )
  );

-- Create new assignments policies (event-specific)
CREATE POLICY "Users can view assignments in their events"
  ON assignments FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM events
      WHERE events.id = assignments.event_id
      AND events.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert assignments in their events"
  ON assignments FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM events
      WHERE events.id = event_id
      AND events.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update assignments in their events"
  ON assignments FOR UPDATE
  TO authenticated
  USING (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM events
      WHERE events.id = assignments.event_id
      AND events.user_id = auth.uid()
    )
  )
  WITH CHECK (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM events
      WHERE events.id = event_id
      AND events.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete assignments in their events"
  ON assignments FOR DELETE
  TO authenticated
  USING (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM events
      WHERE events.id = assignments.event_id
      AND events.user_id = auth.uid()
    )
  );

-- Create RLS policies for events
CREATE POLICY "Users can view their own events"
  ON events FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert their own events"
  ON events FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own events"
  ON events FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete their own events"
  ON events FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());
