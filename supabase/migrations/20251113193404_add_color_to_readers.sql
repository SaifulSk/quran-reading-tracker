/*
  # Add color column to readers table

  Adds a color field to track each reader's assigned color for visual identification
  in the Juz assignment grid.

  1. New Columns
    - `color` (text) - Hex color code for the reader (e.g., '#FF6B6B')
*/

ALTER TABLE readers ADD COLUMN color text DEFAULT '#3B82F6';
