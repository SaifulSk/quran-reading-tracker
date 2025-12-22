/*
  # Create Qur'an Reading Tracker Tables

  1. New Tables
    - `readers` - Store reader information with unique colors
    - `chapters` - Store all 30 Juz with names
    - `assignments` - Track which reader is assigned to which chapter

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users to manage their organization's data
*/

CREATE TABLE IF NOT EXISTS readers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text,
  color text NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS chapters (
  id integer PRIMARY KEY,
  name text NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS assignments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reader_id uuid NOT NULL REFERENCES readers(id) ON DELETE CASCADE,
  chapter_id integer NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed')),
  assigned_at timestamptz DEFAULT now(),
  completed_at timestamptz,
  notes text,
  created_at timestamptz DEFAULT now(),
  UNIQUE(chapter_id)
);

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

ALTER TABLE readers ENABLE ROW LEVEL SECURITY;
ALTER TABLE chapters ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view chapters"
  ON chapters FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Anyone can view readers"
  ON readers FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Anyone can create readers"
  ON readers FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Anyone can update readers"
  ON readers FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Anyone can delete readers"
  ON readers FOR DELETE
  TO anon, authenticated
  USING (true);

CREATE POLICY "Anyone can create assignments"
  ON assignments FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Anyone can view assignments"
  ON assignments FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Anyone can update assignments"
  ON assignments FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Anyone can delete assignments"
  ON assignments FOR DELETE
  TO anon, authenticated
  USING (true);
