/*
  # Qur'an Reading Tracker Schema

  1. New Tables
    - `readers`
      - `id` (uuid, primary key)
      - `name` (text) - Reader's name
      - `email` (text, optional) - Contact email
      - `created_at` (timestamptz) - When reader was added
    
    - `chapters`
      - `id` (integer, primary key) - Chapter number (1-30)
      - `name` (text) - Chapter name (Juz)
      - `created_at` (timestamptz)
    
    - `assignments`
      - `id` (uuid, primary key)
      - `reader_id` (uuid, foreign key to readers)
      - `chapter_id` (integer, foreign key to chapters)
      - `status` (text) - 'pending', 'in_progress', or 'completed'
      - `assigned_at` (timestamptz) - When assignment was made
      - `completed_at` (timestamptz, nullable) - When reading was completed
      - `notes` (text, nullable) - Optional notes
    
  2. Security
    - Enable RLS on all tables
    - Allow public read access for viewing (no auth required for this use case)
    - Allow public write access for managing readers and assignments
    
  3. Important Notes
    - Pre-populate chapters table with 30 Juz (parts) of the Qur'an
    - Each chapter can be assigned to one reader at a time
    - Track status progression from pending → in_progress → completed
*/

CREATE TABLE IF NOT EXISTS readers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text,
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
  status text NOT NULL DEFAULT 'pending',
  assigned_at timestamptz DEFAULT now(),
  completed_at timestamptz,
  notes text,
  UNIQUE(chapter_id)
);

ALTER TABLE readers ENABLE ROW LEVEL SECURITY;
ALTER TABLE chapters ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to readers"
  ON readers FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow public insert to readers"
  ON readers FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Allow public update to readers"
  ON readers FOR UPDATE
  TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow public delete to readers"
  ON readers FOR DELETE
  TO public
  USING (true);

CREATE POLICY "Allow public read access to chapters"
  ON chapters FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow public read access to assignments"
  ON assignments FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow public insert to assignments"
  ON assignments FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Allow public update to assignments"
  ON assignments FOR UPDATE
  TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow public delete to assignments"
  ON assignments FOR DELETE
  TO public
  USING (true);

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
ON CONFLICT (id) DO NOTHING;